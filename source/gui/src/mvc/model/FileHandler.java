package mvc.model;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintStream;
import java.text.DecimalFormat;

public class FileHandler {

	private FileOutputStream out;		// declare a file output object
	private PrintStream p;				// declare a print stream object
	private DecimalFormat valueFormat;	// declare a value format
	private String extension;


    public FileHandler(String decimalFoamt, String extension) {
    	
    	valueFormat = new DecimalFormat(decimalFoamt);
    	this.extension = extension;
    }

    public void newFile( String fileName ) {

    	try {
	        // Create a new file output stream
	        out = new FileOutputStream( fileName + extension);
	
	        // Connect print stream to the output stream
	        p = new PrintStream( out );       
    	}
        catch (Exception e) {
        	System.err.println ("Error writing to file");
        }

    }
    
    public void writeAngles( float phi, float theta) {
    	p.println ( valueFormat.format(phi) + "," +  valueFormat.format(theta) );
    }
    
    public void writeLine( String text) {
    	p.println ( text );
    }
    
    
    public String getExtention(){
    	return this.extension;
    }
    
    public void close(){
    	p.close();
    	try {
			out.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
    }
}
