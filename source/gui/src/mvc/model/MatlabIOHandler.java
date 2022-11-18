package mvc.model;

import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;
import mvc.enums.AudioType;
import com.jmatio.io.MatFileWriter;
import com.jmatio.types.MLChar;
import com.jmatio.types.MLDouble;

/************************************************************************************
* class MatlabIOHandler
************************************************************************************/
public class MatlabIOHandler {

	private List<Double> phiValues;
	private List<Double> thetaValues;
	private AudioType audioType;
	private ArrayList valueList;
	private SimpleDateFormat simpleDateFormat;
	private int phiDeg, thetaDeg;
	private String fileName;
	private String filepath;
	private String fileSeparetor;
	private double[] angleSetUp;
	
	/************************************************************************************
	* MatlabIOHandler()
	************************************************************************************/
	public MatlabIOHandler(){
		this.valueList = new ArrayList();
		this.phiValues = new ArrayList<Double>();
		this.thetaValues = new ArrayList<Double>();
		this.simpleDateFormat = new SimpleDateFormat("dd-mm-yy_H-mm-ss");
		this.fileSeparetor =  System.getProperty("file.separator");
		angleSetUp = new double[2];
	}
	
	/************************************************************************************
	* void addAngleValues(double phi, double theta)
	************************************************************************************/
	public void addAngleValues(double phi, double theta) {
		this.phiValues.add(phi);
		this.thetaValues.add(theta);
	}
	
	
	/************************************************************************************
	* void clearAngleValues() {
	************************************************************************************/
	public void clearAngleValues() {
		this.phiValues.clear();
		this.thetaValues.clear();
	}
	
	
	
	
	/************************************************************************************
	* setAudioType(AudioType audioType)
	************************************************************************************/
	public void setAudioType(AudioType audioType){
		this.audioType = audioType;
	}
	
	/************************************************************************************
	* void setAnglesToSave(int phi, int theta)
	************************************************************************************/
	public void setAnglesToSave(int[] angle){
		this.phiDeg = angle[0];
		this.thetaDeg = angle[1];
		this.angleSetUp[0] = new Integer(angle[0]).doubleValue();
		this.angleSetUp[1] = new Integer(angle[1]).doubleValue();
	}
	
	/************************************************************************************
	* void setFileName()
	************************************************************************************/
	private void setFileName(){
		this.fileName = simpleDateFormat.format( System.currentTimeMillis() ) +
						"_" + this.audioType.toString() +
						"_Phi_" + this.phiDeg +
						"_Theta_" + this.thetaDeg;
	}
	
	/************************************************************************************
	* String getFileName(){
	************************************************************************************/
	public String getFileName(){
		return this.fileName;
	}
	
	/************************************************************************************
	* void setFilePath(String filePath)
	************************************************************************************/
	public void setFilePath(String filePath){
		this.filepath = filePath;
		setFileName();
	}
	 
	/************************************************************************************
	* boolean checkValues()
	************************************************************************************/
	public boolean checkValues(){
		if(this.phiValues.isEmpty() || this.thetaValues.isEmpty()){
			return false;
		}
		else{
			return true;
		}
	}
	
	
	/************************************************************************************
	* void createFile(String fileName)
	************************************************************************************/
	public void createFile(){
		setFileName();
		this.valueList.add( new MLChar( "created", simpleDateFormat.format( System.currentTimeMillis() ) ) );
		this.valueList.add( new MLChar( "audioType", this.audioType.toString() ) );
		this.valueList.add( new MLDouble( "anglesSetUp", this.angleSetUp, this.angleSetUp.length) );
		this.valueList.add( new MLDouble( "phi", phiValues.toArray(new Double[phiValues.size()]), phiValues.size()) );
		this.valueList.add( new MLDouble( "theta", thetaValues.toArray(new Double[thetaValues.size()]), thetaValues.size()) );

		try {
			new MatFileWriter( 	this.filepath +
								this.fileSeparetor +
								this.fileName +
								".mat", valueList );
		} catch (IOException e) {
			e.printStackTrace();
		}
		this.phiValues.clear();
		this.thetaValues.clear();
		
	}
}
