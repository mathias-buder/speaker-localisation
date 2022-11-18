package mvc.model;

import mvc.enums.*;
import gnu.io.*;

import java.io.IOException;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Enumeration;
import java.util.List;
import java.util.Observable;
import java.util.Observer;
import java.util.TooManyListenersException;




public class SerialHandler extends Observable{

	CommPortIdentifier serialPortId;
	Enumeration enumComm;
	SerialPort serialPort;
	//OutputStream outputStream;
	InputStream inputStream;
	Boolean serialPortGeoeffnet = false;
	Serial serialPortState;

	public int baudrate = 460800;
	public int dataBits = SerialPort.DATABITS_8;
	public int stopBits = SerialPort.STOPBITS_1;
	public int parity = SerialPort.PARITY_EVEN;
	public int Bytes2Receive = 1;
	public byte[] data = new byte[Bytes2Receive];
	public boolean p_flag;
	public boolean t_flag;
	public float phi = 0;
	public float theta = 0;
	public SerialValueHandler serialValueHandler;;
	public Angle angleToGet;
	public Unit angleUnit;
	private List<String> debugMsg = new ArrayList<String>();
	private int i;
	
	
	/************************************************************************************
	 * CONSTRUCTOR
	 * 
	 * public RxTx_Receive()
	 ************************************************************************************/
	public SerialHandler(Observer observer, Unit unit ) {
		
		// Add Controller to observer list
		this.addObserver( observer );
		
		// Create UARTHandel instance
		serialValueHandler = new SerialValueHandler( SerialState.IDLE );
		
		// Reset serial port state
		serialPortState = Serial.CLOSED;
		
		// Set angle unit
		this.angleUnit = unit;
		
		// Set angle flag to be used to check if writable to file
		p_flag = false;
		t_flag = false;
	}
	
	/************************************************************************************
	 *  void notifyController( Angle angle )
	 * 
	  ************************************************************************************/
	private void notifyController( Angle angle ){
		setChanged();
		notifyObservers( angle );
	}
	
    
	/************************************************************************************
	 * Serial getState(){
	 * 
	 * @param Non
	 * @return serialPortState
	  ************************************************************************************/
	public Serial getState(){
		return ( serialPortState );
	}
	
	/************************************************************************************
	 * public List<String> scan()
	 * 
	 * @param Non
	 * @return availablePorts
	  ************************************************************************************/
	public List<String> scan() {
		List<String> availablePorts = new ArrayList<String>();
		enumComm = CommPortIdentifier.getPortIdentifiers();
		
		while (enumComm.hasMoreElements()) { 	
			serialPortId = (CommPortIdentifier) enumComm.nextElement();
		     	if(serialPortId.getPortType() == CommPortIdentifier.PORT_SERIAL) {
		     		availablePorts.add( serialPortId.getName() );
		    	}
		 }
		return availablePorts;
	}
	

	/************************************************************************************
     * 	Serial openSerialPort(String portNaStringme)
     * 
     * @param portName
     * @return serialState
      ************************************************************************************/
	public Serial openSerialPort( String portName ) {
		
		if (serialPortState == Serial.OPEN) {
			return Serial.USED;
		}
		
		enumComm = CommPortIdentifier.getPortIdentifiers();
		while(enumComm.hasMoreElements()) {
			serialPortId = (CommPortIdentifier) enumComm.nextElement();
			if (portName.contentEquals(serialPortId.getName())) {
				serialPortState = Serial.FOUND;
				break;
			}
		}

		if (serialPortState == Serial.CLOSED) {
			return Serial.NOT_FOUND;
		}
		try {
			serialPort = (SerialPort) serialPortId.open("öffnen und Senden", 500);
		} catch (PortInUseException e) {
			
			addDebugMsg("Port used");
		}
		/*
		try {
			outputStream = serialPort.getOutputStream();
		} catch (IOException e) {
			System.out.println("Keinen Zugriff auf OutputStream");
		}
		 */
		try {
			inputStream = serialPort.getInputStream();
		} catch (IOException e) {
			addDebugMsg("No Access to InputStream");
		}
		try {
			serialPort.addEventListener(new serialPortEventListener());
		} catch (TooManyListenersException e) {
			addDebugMsg("TooManyListenersException for Serialport");
		}
		serialPort.notifyOnDataAvailable(true);
		try {
			serialPort.setSerialPortParams(baudrate, dataBits, stopBits, parity);
		} catch(UnsupportedCommOperationException e) {
			addDebugMsg("Could not set interface parameters");
		}
		
		serialPortState = Serial.OPEN;
		return Serial.OPEN;
	}

	
	/************************************************************************************
	 * public void closeSerialPort()
	 * 
	 * @param Non
	 * @return Non
	  ************************************************************************************/
	
	public Serial closeSerialPort()
	{
		if ( serialPortState == Serial.OPEN) {
			serialPort.close();
			serialPortState = Serial.CLOSED;
		} else {
			addDebugMsg("Serial port closed already");
		}
		
		return Serial.CLOSED;
	}
	
	
	/************************************************************************************
	 * void serialPortDatenAvailable()
	 ************************************************************************************/
	public void serialPortDatenAvailable() {
		
		serialValueHandler.setState( SerialState.CHECK );
		
		try {
			while( inputStream.available() > 0 ) {
				
				inputStream.read( data, 0, 1 );
				serialValueHandler.stateMachine( data );
				
				addDebugMsg( "Received: " + new String( data, 0, Bytes2Receive) );
				
				if( serialValueHandler.check( Angle.PHI ) ){
					phi = serialValueHandler.getAngle( Angle.PHI );
					addDebugMsg("PHI = " + serialValueHandler.getAngle( Angle.PHI ));
					notifyController( Angle.PHI );
				}

				
				if( serialValueHandler.check( Angle.THETA ) ){
					theta = serialValueHandler.getAngle( Angle.THETA );
					addDebugMsg( "THETA = " + serialValueHandler.getAngle( Angle.THETA ) );	
					notifyController( Angle.THETA );
				}
			}
			
			serialValueHandler.setState( SerialState.IDLE );
			
		} catch (IOException e) {
			addDebugMsg("Error while receiving data!");
		}
	}
	
	/************************************************************************************
	 * float getValue( Angle angle )
	 ************************************************************************************/
	public float getValue( Angle angle ) {
		
		switch (angle) {
			case PHI: 	return phi;
			case THETA:	return theta;
			default: 	return 0;
		}
	}
		
	/************************************************************************************
	 * void setDebugMsg( String msg )
	 ************************************************************************************/
	private void addDebugMsg( String msg ){
			this.debugMsg.add(msg);
	}
	
	
	/************************************************************************************
	 * void setDebugMsg( String msg )
	 ************************************************************************************/
	public void clearDebugMsg(){
			this.debugMsg.clear();
			serialValueHandler.debugMsg.clear();
	}
	
	
	/************************************************************************************
	 * String getDebugMsg(){
	 ************************************************************************************/
	public List<String> getDebugMsg(){
		return this.debugMsg;
	}
	
	
	
	/************************************************************************************
	 * class serialPortEventListener implements SerialPortEventListener
	 ************************************************************************************/
	class serialPortEventListener implements SerialPortEventListener {
		public void serialEvent(SerialPortEvent event) {
			//System.out.println("serialPortEventlistener");
			switch (event.getEventType()) {
			case SerialPortEvent.DATA_AVAILABLE:
				serialPortDatenAvailable();
				break;
			case SerialPortEvent.BI:
			case SerialPortEvent.CD:
			case SerialPortEvent.CTS:
			case SerialPortEvent.DSR:
			case SerialPortEvent.FE:
			case SerialPortEvent.OUTPUT_BUFFER_EMPTY:
			case SerialPortEvent.PE:
			case SerialPortEvent.RI:
			default:
			}
		}
	}	
}
