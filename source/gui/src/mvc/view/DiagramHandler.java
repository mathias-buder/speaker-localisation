package mvc.view;

import mvc.enums.*;

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Component;
import java.awt.Font;
import java.awt.Graphics;
import java.awt.Graphics2D;
import java.awt.geom.Ellipse2D;
import java.awt.geom.Line2D;
import java.text.DateFormat;
import java.text.DecimalFormat;
import java.text.Format;
import java.text.SimpleDateFormat;
import java.util.Vector;


public class DiagramHandler extends Component {

	private static final long serialVersionUID = 1L;
	private Graphics2D g2;
	private Color majorGridColor;
	private BasicStroke majorGridStroke;
	
	private Color minorGridColor;
	private BasicStroke minorGridStroke;
	
	private Color gridMinorCircleColor;
	private BasicStroke gridMinorCircleStroke;
	
	private Color gridCircleColor;
	private BasicStroke gridCircleStroke;
	
	private Line2D anglePointer;
	private Color anglePointerColor;
	private BasicStroke anglePointerStroke;
	
	private double  OriganX, OriganY;
	private double currentPointerAngle;
	private double lastPointerAngle;
	//private double minAngleRes = 0.1243;
	private int lineLengthCorr = 30;
	private int gridCircleRaiusCorr = 40;
	private DecimalFormat labelFormat = new DecimalFormat("#");
	

	/******************************************************************
	 * CONSTRUCTOR
	 * 
	 DiagramHandler()
	*******************************************************************/
	public DiagramHandler() {

		anglePointer = new Line2D.Double();
		this.currentPointerAngle = 0.0;
		this.lastPointerAngle = 0.0;
		
		majorGridColor = new Color(0, 0, 0, 100);
		majorGridStroke = new BasicStroke(1.3f);
		
		minorGridColor = new Color(0, 0, 0, 80);
		minorGridStroke = new BasicStroke(	1.0f,                      					// Width
											BasicStroke.CAP_ROUND,    					// End cap
							                BasicStroke.CAP_ROUND,    					// Join style
							                10.0f,                     					// Miter limit
							                new float[] {10.0f, 9.0f, 3.0f, 9.0f}, 		// Dash pattern
							                0.0f );
		
		
		anglePointerColor = new Color(255, 100, 0, 150);
		anglePointerStroke = new BasicStroke(	8.0f,
												BasicStroke.CAP_BUTT,    				// End cap
												BasicStroke.JOIN_BEVEL );				// Join style
		
		gridMinorCircleColor = new Color(230, 200, 220, 180);
		gridMinorCircleStroke = new BasicStroke( 1.0f,                      			// Width
                							BasicStroke.CAP_ROUND,    					// End cap
							                BasicStroke.JOIN_ROUND,    					// Join style
							                10.0f,                     					// Miter limit
							                new float[] {15.0f, 9.0f, 3.0f, 9.0f}, 		// Dash pattern
							                0.0f );                     				// Dash phase
		
		gridCircleColor = new Color(180, 180, 180, 255);
		gridCircleStroke = new BasicStroke(2.0f);

	}

	
	/******************************************************************
	 double angleToX(double r, double Angle)
	*******************************************************************/
	private double angleToX(double r, double angle) {
		return ( r * Math.cos(angle) );
	}
	
	
	/******************************************************************
	 double angleToY(double r, double Angle)
	*******************************************************************/
	private double angleToY(double r, double angle) {
		return ( r * Math.sin(angle) );
	}
	
	
	/******************************************************************
	  void createGrid()
	*******************************************************************/
	public void paintGrid() {
		
		double xGrid, yGrid, xLabel, yLabel, angle, gridLineLength, labelLineLength;
		double gridLineSpacing, amountGrindLineSpacing;
		double gridCircleRaius, gridCircelSpacing;
		int i, gridCircelAmount;
		
		
		gridLineLength = getWidth()/2-lineLengthCorr;
		labelLineLength = getWidth()/2 - 10;
		gridLineSpacing = Math.PI/4;
		amountGrindLineSpacing = 2*Math.PI / gridLineSpacing;

		gridCircleRaius = getWidth()/2-gridCircleRaiusCorr;
		gridCircelAmount = 5;
		gridCircelSpacing = gridCircleRaius / gridCircelAmount;
		

		g2.setColor(gridMinorCircleColor);
		g2.setStroke(gridMinorCircleStroke);
		
		for( i=0; i < gridCircelAmount-1; i++ ) {
			g2.draw( new Ellipse2D.Double( OriganX - gridCircelSpacing * (i+1), OriganY - gridCircelSpacing * (i+1), 2*gridCircelSpacing * (i+1), 2*gridCircelSpacing * (i+1)) );
		}
		
		g2.setColor(gridCircleColor);
		g2.setStroke(gridCircleStroke);
		g2.draw( new Ellipse2D.Double( OriganX - gridCircleRaius, OriganY - gridCircleRaius, 2*gridCircleRaius, 2*gridCircleRaius ) );
		
		
		
		
		// Create major grid lines
		g2.setColor(majorGridColor);
		g2.setStroke(majorGridStroke);
		
		for( i=0; i < amountGrindLineSpacing; i++ ) {
			angle = gridLineSpacing * i;
			xGrid = OriganX + angleToX( gridLineLength, angle );
			yGrid = OriganY - angleToY( gridLineLength, angle );
			xLabel = OriganX + angleToX( labelLineLength, angle ) - 8;
			yLabel = OriganY - angleToY( labelLineLength, angle ) + 5;
			g2.draw( new Line2D.Double(OriganX, OriganY, xGrid, yGrid) );
			g2.setFont( new Font("ISOCP 60", Font.BOLD, 13) );
			g2.drawString( labelFormat.format(Math.toDegrees(angle)) + "°", (int) xLabel, (int) yLabel );
		}
		
		// Create minor grid lines
		g2.setColor(minorGridColor);
		g2.setStroke(minorGridStroke);
		
		for( i=0; i < amountGrindLineSpacing; i++ ) {
			angle = gridLineSpacing * i;
			xGrid = OriganX + angleToX( gridCircleRaius, angle + Math.PI/8 );
			yGrid = OriganY - angleToY( gridCircleRaius, angle + Math.PI/8 );	
			g2.draw( new Line2D.Double(OriganX, OriganY, xGrid, yGrid) );
			g2.setFont( new Font("ISOCP 60", Font.PLAIN, 13) );
		}
		
		
		
	}

	
	/******************************************************************
	  void paintAnglePointer()
	*******************************************************************/
	public void paintAnglePointer(double angle){
		
		double x, y, lineLength;
		lineLength = getWidth()/2 - gridCircleRaiusCorr;
		
		x = OriganX + angleToX(lineLength, angle);
		y = OriganY - angleToY(lineLength, angle);
		
		anglePointer.setLine( OriganX, OriganY, x, y );
		
		g2.setColor(anglePointerColor);
		g2.setStroke(anglePointerStroke);
		g2.draw(anglePointer);
	}
	
	
	public void setAnglePointer( double angle ){
		this.lastPointerAngle = this.currentPointerAngle;
		this.currentPointerAngle = angle;
	}
		

	/******************************************************************
	  void paint(Graphics g)
	***********************************
	*
	*********************************/
	public void paint(Graphics g) {
		g2 = (Graphics2D) g;
			
		OriganX = getSize().getWidth()/2;
		OriganY = getSize().getHeight()/2;

		paintGrid();
		
		
		double angleStep, newAngle, stopAngle, startAngle;
		int spacing = 10;
		
		stopAngle = this.currentPointerAngle;
		startAngle = this.lastPointerAngle;
		
		
		//if(startAngle == stopAngle){
			paintAnglePointer( this.currentPointerAngle );
		
			//flag = false;
			/*
		}
		else{
			while( startAngle < stopAngle  ){
				angleStep = (stopAngle - startAngle) / spacing;
				newAngle = startAngle + angleStep;
				
				paintAnglePointer( newAngle );
				
				startAngle = newAngle;
				
				System.out.println("Looping ...");
			}
		}
		
		*/
		
		/*
		while(angle != targetAngle){
		
			angleStep = (stopAngle - startAngle) / spacing;
			
			newAngle = startAngle + angleStep;
			
			draw(anglePointerWithNewAngle);
			
			startAngle = newAngle;
		
		}
		*/
		

	}

		
}

