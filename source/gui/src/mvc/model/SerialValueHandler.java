package mvc.model;

import java.util.ArrayList;
import java.util.List;

import mvc.enums.*;

public class SerialValueHandler {

	private SerialState state;
	private Angle angle;
	private int Bytes2Receive;
	private int Char_count;
	private int CHARS2RECEIVE;
	private float phi;
	private float theta;
	private String phi_identifier;
	private String theta_identifier;
	double[] ScaleFactor = {1, 0.1, 0.01, 0.001};
	private boolean phi_flag, theta_flag;
	public boolean phi_fileWrite_flag, theta_fileWrite_flag;
	public List<String> debugMsg = new ArrayList<String>();

	
	
	/************************************************************************************
	 * public SerialValueHandler( State InitState ) {
	 ************************************************************************************/
	public SerialValueHandler( SerialState InitState ) {
		this.state = InitState;
		this.Char_count = 0;
		this.Bytes2Receive = 1;
		this.CHARS2RECEIVE = 6;
		this.phi_identifier = "p";
		this.theta_identifier = "t";
		this.phi_flag = false;
		this.theta_flag = false;
		this.phi_fileWrite_flag = false;
		this.theta_fileWrite_flag = false;
	}
	
	/************************************************************************************
	 * void setState( State state )
	 ************************************************************************************/
	public void setState( SerialState state ) {
		this.state = state;
	}
	/************************************************************************************
	 * public State getState()
	 ************************************************************************************/
	public SerialState getState() {
		return this.state;
	}
	
	/************************************************************************************
	 * State stateMachine( byte[] data )
	 ************************************************************************************/
	public SerialState stateMachine( byte[] data ) {
		
		String received = new String (data, 0, Bytes2Receive);
		
		/**********************************************************
		 * STATE-MACHINE
		 **********************************************************/
		
		switch( this.state ) {
			case IDLE:
				debugMsg.add("State machine: " + this.state.toString());
			break;
			
			case CHECK:
				debugMsg.add("State machine: " + this.state.toString());
				// check received-string for angle identifier
				if( received.matches( phi_identifier ) ) {
					this.angle = Angle.PHI;
					this.phi = 0;
					this.phi_flag = false;
					this.state = SerialState.RECEIVE;
					this.Char_count++;
				}
				else if( received.matches( theta_identifier ) ) {
					this.angle = Angle.THETA;
					this.theta = 0;
					this.theta_flag = false;
					this.state = SerialState.RECEIVE;
					this.Char_count++;
				}
				else{
					this.state = SerialState.CHECK;
					this.Char_count = 0;
				}
			break;
			
			case RECEIVE:
				// Check angle
				switch( this.angle ) {
					// could be pos and neg
					case PHI:
						if( Char_count < (CHARS2RECEIVE-1) ){
							if( received.matches("\\d+") ) {
								phi += Float.parseFloat(received) * ScaleFactor[Char_count-1];
							}
							else {
								this.state = SerialState.CHECK;
								phi = 0;
								Char_count = 0;
							}
						}
						else {
							if( received.matches("-") ){
								phi = -phi;
							}
							phi_flag = true;
							phi_fileWrite_flag = true;
						}
						debugMsg.add("Phi: " + phi);
					break;
					// only pos
					case THETA:
						if( Char_count < (CHARS2RECEIVE-1) ){
							if( received.matches("\\d+") ) {
								theta += Float.parseFloat(received) * ScaleFactor[Char_count-1];
							}
							else {
								this.state = SerialState.CHECK;
								theta = 0;
								Char_count = 0;
							}
						}
						else {
							theta_flag = true;
							
							if(phi_fileWrite_flag){
								theta_fileWrite_flag = true;
							}
						}
						debugMsg.add("Theta: " + theta);
					break;

					default:
					break;
				}
				
				Char_count++;
				
				if( Char_count >= CHARS2RECEIVE ){
					Char_count = 0;
					this.state = SerialState.CHECK;
				}				
			break;
	
			default:
			break;
		}
		/**********************************************************/
		
		debugMsg.add("State machine: " + this.state.toString());
		debugMsg.add("phi_fileWrite_flag: " + phi_fileWrite_flag);
		debugMsg.add("theta_fileWrite_flag: " + theta_fileWrite_flag);
		debugMsg.add("Angle: " + this.angle.toString());
		debugMsg.add("Char_count: " + this.Char_count);
		return this.state;
	}
	
	
	/************************************************************************************
	 * float getAngle( Angle angle )
	 ************************************************************************************/
	public float getAngle( Angle angle ) {
		switch( angle ){
			case PHI: 	return this.phi;
			case THETA: return this.theta;
			default:	return -1;
		}
	}
	
	
	public boolean checkValueFileWrite(){
		if(phi_fileWrite_flag && theta_fileWrite_flag){
			phi_fileWrite_flag = false;
			theta_fileWrite_flag = false;
			return true;
		}
		else{
			return false;
		}
	}
	

	/************************************************************************************
	 * boolean check( Angle angle )
	 ************************************************************************************/
	public boolean check( Angle angle ){
		switch( angle ){
			case PHI: 	return this.phi_flag;
			case THETA: return this.theta_flag;	
			default:	return false;
		}
	}
}