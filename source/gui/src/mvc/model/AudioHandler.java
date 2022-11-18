package mvc.model;

import mvc.enums.*;

import java.io.File;
import java.io.IOException;
import java.net.URL;

import javax.sound.sampled.AudioInputStream;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.Clip;
import javax.sound.sampled.DataLine;
import javax.sound.sampled.FloatControl;
import javax.sound.sampled.LineListener;
import javax.sound.sampled.LineUnavailableException;
import javax.sound.sampled.UnsupportedAudioFileException;


/************************************************************************************
* class AudioHandler
************************************************************************************/
public class AudioHandler {

	private AudioInputStream audioIn;
	private Clip clip;
	private FloatControl panControl;
	private File file;
	
	/************************************************************************************
	* public AudioHandler()
	************************************************************************************/
	public AudioHandler(String fileName){
		
		try {
			this.file = new File(fileName);
			this.audioIn = AudioSystem.getAudioInputStream(this.file);
			//this.audioIn = AudioSystem.getAudioInputStream(AudioHandler.class.getResource("/audio/Original.wav"));
		} catch (UnsupportedAudioFileException | IOException e) {
			e.printStackTrace();
		}
		
		try {
			DataLine.Info info = new DataLine.Info( Clip.class, audioIn.getFormat( ) );
			try {
				this.clip = (Clip) AudioSystem.getLine(info);
			} catch (LineUnavailableException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
			
			try {
				this.clip.open(audioIn);
			} catch (LineUnavailableException | IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		finally { // We're done with the input stream.
			try {
				this.audioIn.close();
			} catch (IOException e) {
				// TODO Auto-generated catch block
				e.printStackTrace();
			}
		}
		
		
		try {
			// FloatControl.Type.BALANCE is probably the correct control to
			// use here, but it doesn't work for me, so I use PAN instead.
			this.panControl = (FloatControl) clip.getControl(FloatControl.Type.BALANCE);
		}
		catch(IllegalArgumentException e) {}
	}
	
	/************************************************************************************
	* void setAudio(Audio audio)
	************************************************************************************/
	public void setAudio(AudioType audio){
		
		switch (audio) {
			case MALE:
				this.panControl.setValue(-1.0f);
			break;
			
			case FEMALE:
				this.panControl.setValue(1.0f);
			break;
			
			default:
			break;
		}
		this.resetClip();
	}
	
	/************************************************************************************
	* void play()
	************************************************************************************/
	public void play(){
		this.clip.start();
	}
	
	/************************************************************************************
	* void stop()
	************************************************************************************/
	public void stop(){
		this.clip.stop();
	}

	/************************************************************************************
	* boolean isRunning()
	************************************************************************************/
	public boolean isRunning(){
		return this.clip.isRunning();
	}
	
	/************************************************************************************
	* void resetClip()
	************************************************************************************/
	public void resetClip(){
		this.clip.setFramePosition(0);
	}
	
	/************************************************************************************
	* boolean hasEnded()
	************************************************************************************/
	public boolean hasEnded(){
		if( this.clip.getFramePosition() == this.clip.getFrameLength() ){
			return true;
		}
		else {
			return false;
		}
	}
	
	/************************************************************************************
	* void setLineListener(LineListener l){
	************************************************************************************/
	public void setLineListener(LineListener l){
		this.clip.addLineListener(l);
	}
}
