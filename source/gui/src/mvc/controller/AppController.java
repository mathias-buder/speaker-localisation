package mvc.controller;

import mvc.model.*;
import mvc.view.*;
import mvc.enums.*;

import java.applet.AudioClip;
import java.awt.Color;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.File;
import java.text.SimpleDateFormat;
import java.util.List;
import java.util.Observable;
import java.util.Observer;
import java.util.Timer;
import java.util.TimerTask;

import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.LineEvent;
import javax.sound.sampled.LineListener;
import javax.swing.JCheckBox;
import javax.swing.JComboBox;


public class AppController implements Observer{

	private ViewHandler viewHandler;
	private SerialHandler serialHandler;
	private AppController controller;
	private addViewThread viewThread;
	private addModelThread modelThread;
	private MatlabIOHandler matlabIOHandler;
	private Timer dataLedTimer;
	private Timer dataWriteTimer;	// Has to be implemented
	private AudioHandler audioHandler;
	private AudioState audioState;
	private AudioType audioType;
	private Serial serialState;
	private String serialPortName;
	private boolean scanFlag;
	private boolean debugFlag;
	private Unit AngleUnit;
	private String angleFormatString;
	private FileState fileState;
	private String filePath;
	private Angle angleToReceived;
	private int i;
	private float phi, theta;
	private String audioFile = "src/audio.wav";
	private String defaultDirectory;
	
	
	/************************************************************************************
	* AppController()
	* 
	* CONSTRUCTOR
	************************************************************************************/
	public AppController() {
		
		serialPortName = "No";
		AngleUnit = Unit.RAD;
		angleFormatString = "#.#";
		scanFlag = false;
		debugFlag = false;
		fileState = FileState.CLOSED;
		dataLedTimer = new Timer();
	}
	
	
	/************************************************************************************
	* void setInstance( AppController controller )
	************************************************************************************/
	public void setInstance( AppController controller ) {
		this.controller = controller;
	}
	
	
	/************************************************************************************
	* void addListener()
	************************************************************************************/
	private void addListener() {
		viewHandler.setButtonScanListener( new ButtonScanListener() );
		viewHandler.setButtonConnectListener( new ButtonConnectListener() );
		viewHandler.setButtonPlayListener( new ButtonPlayListener() );
		viewHandler.setComboBoxScanResListener( new ComboBoxScanResListener() );
		viewHandler.setChackBoxEnableLogListener( new ChackBoxEnableLogListener() );
		viewHandler.setChackBoxEnableDebugListener( new ChackBoxEnableDebugListener() );
		viewHandler.setChackBoxTalkerListener( new ChackBoxTalkerListener() );
		viewHandler.setComboBoxAngleUnitListener( new ComboBoxAngleUnitListener() );
		viewHandler.setButtonSaveFileListener( new ButtonSaveFileListener() );
		viewHandler.setButtonLastListener( new ButtonLastListener() );
		viewHandler.setButtonRecordListener( new ButtonRecordListener() );
		try {
			audioHandler.setLineListener( new AudioLineListener() );
		} catch (Exception e) {}
	}
	

	/************************************************************************************
	* void start(){
	* 
	* Create model and view components
	************************************************************************************/
	public void start(){
		
		// Create thread to run model
		this.modelThread = new addModelThread();
		this.modelThread.start();
		
		// Create thread to run view
		this.viewThread = new addViewThread();
		this.viewThread.start();
		// wait until view component has been created
		while( viewThread.isAlive() ){};
		
		viewHandler.addLogMsg("Starting controller ...");
		
		// Create file audio handler
		try {
			this.audioHandler = new AudioHandler(audioFile);
		} catch (Exception e) {
			viewHandler.addLogMsg("Having trouble using sound card! Speaker connected?");
			viewHandler.addLogMsg("To use audio be sure speakers are ready to play sound and restart application!");
		}
		
		// Create file handler to write matlab .mat files
		this.matlabIOHandler = new MatlabIOHandler();
		
		// Install action listeners after view component has been created
		addListener();
		viewHandler.buttonAccessSerial(true);
		
		viewHandler.portItem(true);
		viewHandler.buttonSaveFile(true);
		defaultDirectory =	"src" + File.separator + "MAT_Files";
		viewHandler.addLogMsg("Setting default save directory " + defaultDirectory + " ...");
		
		try {
			viewHandler.setDefaultDirectory(defaultDirectory);
			viewHandler.buttonRecord(true);
			fileState = FileState.WRITE;
		} catch (Exception e1) {
			viewHandler.addLogMsg("Could not add default directory!");
			viewHandler.buttonRecord(false);
		}
		
		
		
		audioType = viewHandler.getSelectedAudioType();
		try {
			audioHandler.setAudio( audioType );
		} catch (Exception e) {}
		audioState = AudioState.STOP;
		
		// search for available serial ports
		scanSerial();
	}
	
	
	/************************************************************************************
	* void update(Observable o, Object msg)
	************************************************************************************/
	public void update(Observable o, Object msg) {
		
		// Get angle flag
		angleToReceived = (Angle) msg;
		viewHandler.addDebugMsg( "NotifyOberserver( " + angleToReceived.toString() + " ) called" );
		
		// Set angle value and angle pointer according to received angle flag
		viewHandler.setAngleVal( angleToReceived, angleFormatString, serialHandler.getValue( angleToReceived ) );
		viewHandler.setAnglePointer( angleToReceived, serialHandler.getValue( angleToReceived ));
		
		// Set data led to green to indicate that data has been received
		viewHandler.setDataLed( Color.GREEN );
		
		// Add debug messages if available 
		if( debugFlag ){
			for(i=0; i < serialHandler.getDebugMsg().size(); i++){
				viewHandler.addDebugMsg( serialHandler.getDebugMsg().get(i) );
			}
		}
		
		// Clear debug messages
		serialHandler.clearDebugMsg();
		
		// Store angels
		switch (angleToReceived) {
			case PHI:
				phi = serialHandler.getValue( angleToReceived );
			break;
			
			case THETA:
				theta = serialHandler.getValue( angleToReceived );
			break;
			
			default:
			break;
		}
		
		
		if( serialHandler.serialValueHandler.checkValueFileWrite() ) {
			viewHandler.addDebugMsg("Writing values to file...");
			viewHandler.addDebugMsg("Phi: "+ phi + ", Theta: " + theta);
			
			if(audioState == AudioState.RECORD){
				matlabIOHandler.addAngleValues(phi, theta);
			}
			
		}
		
		// Set data led back to orange after 100ms
		dataLedTimer.schedule(new TimerTask() {
			public void run() {
				viewHandler.setDataLed( Color.ORANGE );
			}
		}, 100);
	}
	
	
	/************************************************************************************
	* class ButtonScanListener implements ActionListener
	************************************************************************************/
	class ButtonScanListener implements ActionListener {
		public void actionPerformed(ActionEvent e) {
			scanSerial();
		}	
	}
	
	
	/************************************************************************************
	* void scanSerial()
	************************************************************************************/
	public void scanSerial(){
		
		scanFlag = false;
		viewHandler.clearPortItems();
		viewHandler.addLogMsg("Scanning for serial ports ...");
		List<String> availablePorts = serialHandler.scan();
		viewHandler.addLogMsg("Ports found :");
		
		for(int i = 0; i < availablePorts.size(); i++) {
			viewHandler.addPortItem( availablePorts.get(i) );
			viewHandler.addLogMsg( availablePorts.get(i) );
		}
		
		serialPortName = availablePorts.get(0);
		scanFlag = true;
	}
	
	
	/************************************************************************************
	* class ButtonConnectListener implements ActionListener
	************************************************************************************/
	class ButtonConnectListener implements ActionListener {
		public void actionPerformed(ActionEvent e) {
			
			serialState = serialHandler.getState();
			
			switch ( serialState ) {
				case CLOSED:
					viewHandler.addLogMsg("Connecting to serialport " + serialPortName + " ...");
					serialState = serialHandler.openSerialPort( serialPortName );
					
					switch (serialState) {
						case USED:
							viewHandler.addLogMsg("Serial Port " + serialPortName + " used already");
						break;
						
						case NOT_FOUND:
							viewHandler.addLogMsg("Serial Port " + serialPortName + " not found");
						break;
	
						case OPEN:
							// Disable 
							viewHandler.buttonAccessSerialSetText("Disconnect");
							viewHandler.portItem(false);
							viewHandler.addLogMsg("Serial Port " + serialPortName+ " connected");
						break;
						
						default:
							viewHandler.addLogMsg("No option selected");
						break;
					}
				break;
	
				case USED:
					viewHandler.addLogMsg("Serial Port " + serialPortName + " used already");
				break;
				
				case NOT_FOUND:
					viewHandler.addLogMsg("Serial Port " + serialPortName + " not found");
				break;

				case OPEN:
					viewHandler.addLogMsg("Disonnecting from serial port " + serialPortName + " ...");
					serialState = serialHandler.closeSerialPort();
					viewHandler.portItem(true);
					viewHandler.addLogMsg("Serial port " + serialPortName + " disconnected");
					viewHandler.buttonAccessSerialSetText("Connect");
				break;
				
				default:
					viewHandler.addLogMsg("No option selected");
				break;
			}
			viewHandler.addLogMsg( "Serial port state: " + serialState.toString() );
		}
	}
	
	
	
	/************************************************************************************
	* class ButtonSaveFileListener implements ActionListener
	************************************************************************************/
	class ButtonSaveFileListener implements ActionListener {
		public void actionPerformed(ActionEvent e) {
			
			viewHandler.addLogMsg("File chooser: OPENING ...");
			fileState = viewHandler.openFileDialog();

			switch (fileState) {
				case SELECTED:
					viewHandler.addLogMsg("File chooser: " + fileState.toString());
					filePath = viewHandler.getFilePath();
					viewHandler.addLogMsg("Path: " + filePath +" selected");
					viewHandler.buttonRecord(true);
					fileState = FileState.WRITE;
				break;
				
				case ABORT:
					
				break;
				
				case ERROR:
				break;
	
				default:
				break;
			}
			viewHandler.addLogMsg("File chooser: " + fileState.toString());
		}	
	}
	

	/************************************************************************************
	* class ComboBoxScanResListener implements ActionListener
	************************************************************************************/
	class ComboBoxScanResListener implements ActionListener {
		public void actionPerformed(ActionEvent e) {
			
			JComboBox portList = (JComboBox) e.getSource();
			
			if( (portList.getItemCount() > 0) && scanFlag ){
				serialPortName = portList.getSelectedItem().toString();
				viewHandler.addLogMsg("Serial port " + serialPortName + " selected");
			}
		}
	}
	
	
	/************************************************************************************
	* class ComboBoxAngleUnitListener implements ActionListener
	* 
	************************************************************************************/
	class ComboBoxAngleUnitListener implements ActionListener {
		public void actionPerformed(ActionEvent e) {
			
			// Get unit list
			JComboBox unitList = (JComboBox) e.getSource();
			AngleUnit = (Unit) unitList.getSelectedItem();
			
			// Set unit to model
			viewHandler.setAngleUnit( AngleUnit );
			
			// Add log message
			viewHandler.addLogMsg( "Angle unit " + AngleUnit.toString() + " selected" );
		}
	}
	
	
	/************************************************************************************
	* class ChackBoxEnableLogListener implements ActionListener
	************************************************************************************/
	class ChackBoxEnableLogListener implements ActionListener {
		public void actionPerformed(ActionEvent e) {
			
			JCheckBox checkBox = (JCheckBox) e.getSource();
			
			if( checkBox.isSelected() ){
				viewHandler.setLog(true);
				viewHandler.addLogMsg("Log enabled");
			}
			else {
				viewHandler.addLogMsg("Log disabled");
				viewHandler.setLog(false);
			}
		}
	}
	
	
	/************************************************************************************
	* class ChackBoxEnableLogListener implements ActionListener
	************************************************************************************/
	class ChackBoxEnableDebugListener implements ActionListener {
		public void actionPerformed(ActionEvent e) {
			
			JCheckBox checkBox = (JCheckBox) e.getSource();
			
			if( checkBox.isSelected() ){
				viewHandler.setDebug(true);
				debugFlag = true;
				viewHandler.addLogMsg("Debug enabled");
			}
			else {
				viewHandler.addLogMsg("Debug disabled");
				debugFlag = false;
				viewHandler.setDebug(false);
			}
		}
	}
	
	
	
	/************************************************************************************
	* class ChackBoxEnableLogListener implements ActionListener
	************************************************************************************/
	class ButtonPlayListener implements ActionListener {
		public void actionPerformed(ActionEvent e) {
			
			if(!audioHandler.isRunning()){
				audioHandler.play();
				audioState = AudioState.RUN;
				viewHandler.addLogMsg("playing audio ...");
				viewHandler.setButtonPlayIcon("Pause");
			}
			else{
				audioHandler.stop();
				audioState = AudioState.STOP;
				viewHandler.addLogMsg("Pausing audio ...");
				viewHandler.setButtonPlayIcon("Play");
			}
		}
	}
	
	/************************************************************************************
	* class ChackBoxEnableLogListener implements ActionListener
	************************************************************************************/
	class ButtonRecordListener implements ActionListener {
		public void actionPerformed(ActionEvent e) {
			
			
			switch (audioState) {
				case STOP:
					switch (fileState) {
						case WRITE:
							viewHandler.addLogMsg("File created");
							viewHandler.addLogMsg("Recording started ...");
							matlabIOHandler.clearAngleValues();
							audioHandler.resetClip();
							audioHandler.play();
							audioState = AudioState.RECORD;
							viewHandler.setButtonRecordIcon("Stop");
							viewHandler.buttonPlay(false);
							viewHandler.buttonLast(false);
							viewHandler.ComboBoxAudioType(false);
							viewHandler.buttonSaveFile(false);
							viewHandler.buttonAccessSerial(false);
							viewHandler.buttonScan(false);
							viewHandler.spinnerAngleToSave(false);
						break;
						
						default:
						break;
					}
				break;
				
				case RECORD:
					
					if(matlabIOHandler.checkValues()){
						matlabIOHandler.setAnglesToSave(viewHandler.getAnglesToSave());
						matlabIOHandler.setAudioType(audioType);
						matlabIOHandler.setFilePath(filePath);
						viewHandler.addLogMsg("Creating file " + matlabIOHandler.getFileName() + ".mat ...");
						matlabIOHandler.createFile();
						viewHandler.addLogMsg("File created");
					}
					else{
						viewHandler.addLogMsg("No angle values to write");
					}
					audioState = AudioState.STOP;
					viewHandler.setButtonRecordIcon("Record");
					audioHandler.stop();
					audioHandler.resetClip();
					viewHandler.addLogMsg("Audio stoped");
					viewHandler.buttonPlay(true);
					viewHandler.buttonLast(true);
					viewHandler.ComboBoxAudioType(true);
					viewHandler.buttonSaveFile(true);
					viewHandler.buttonAccessSerial(true);
					viewHandler.buttonScan(true);
					viewHandler.spinnerAngleToSave(true);
				break;
					
				default:
				break;
			}
			
			
			
			
		}
	}
	
	/************************************************************************************
	* class ChackBoxEnableLogListener implements ActionListener
	************************************************************************************/
	class ButtonLastListener implements ActionListener {
		public void actionPerformed(ActionEvent e) {
			audioHandler.resetClip();
			viewHandler.addLogMsg("Resetting audio ...");
		}
	}
	
	
	
	/************************************************************************************
	* class ChackBoxEnableLogListener implements ActionListener
	************************************************************************************/
	class AudioLineListener implements LineListener {
		public void update(LineEvent event) {
			if( !audioHandler.isRunning() && audioHandler.hasEnded() ){
				viewHandler.setButtonPlayIcon("Play");
				audioHandler.resetClip();
				audioState = AudioState.STOP;
				viewHandler.addLogMsg("Audio stoped");
				viewHandler.setButtonRecordIcon("Record");
				
				switch (fileState) {
				case WRITE:
					if(matlabIOHandler.checkValues()){
						matlabIOHandler.setAudioType(audioType);
						matlabIOHandler.setFilePath(filePath);
						matlabIOHandler.setAnglesToSave(viewHandler.getAnglesToSave());
						viewHandler.addLogMsg("Creating file " + matlabIOHandler.getFileName() + ".mat ...");
						matlabIOHandler.createFile();
						viewHandler.addLogMsg("File created");
					}
					else{
						viewHandler.addLogMsg("No angle values to write");
					}
					break;

				default:
					break;
				}
				viewHandler.buttonPlay(true);
				viewHandler.buttonLast(true);
				//viewHandler.buttonRecord(false);
				viewHandler.ComboBoxAudioType(true);
				viewHandler.buttonAccessSerial(true);
				viewHandler.buttonScan(true);
				viewHandler.buttonSaveFile(true);
				viewHandler.spinnerAngleToSave(true);
			}
		}
	}
	
	
	/************************************************************************************
	* class ChackBoxTalkerListener implements ActionListener
	************************************************************************************/
	class ChackBoxTalkerListener implements ActionListener {
		public void actionPerformed(ActionEvent e) {
			
			JComboBox portList = (JComboBox) e.getSource();
			audioType = (AudioType) portList.getSelectedItem();
			
			audioHandler.setAudio(audioType);
			viewHandler.addLogMsg("Talker " + audioType.toString() + " selected");
		}
	}
	
	
	/************************************************************************************
	* class addModelThread extends Thread
	************************************************************************************/
	class addModelThread extends Thread {
		public void run() {
			try {
				serialHandler = new SerialHandler(controller, AngleUnit);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
	
	/************************************************************************************
	* class addViewThread extends Thread
	************************************************************************************/
	class addViewThread extends Thread {
		public void run() {
			try {
				viewHandler = new ViewHandler();
				viewHandler.setVisible(true);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
	}
	
}