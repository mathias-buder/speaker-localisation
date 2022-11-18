package mvc.view;

import java.awt.BasicStroke;
import java.awt.Color;
import java.awt.Component;
import java.awt.Graphics;
import java.awt.Graphics2D;

public class DataLedHandler extends Component {

	private static final long serialVersionUID = 1L;
	private Graphics2D g2;
	private int  OriganX, OriganY;
	private BasicStroke dataLedStroke;
	private int dataLedRaius;
	private Color dataLedColor;
	private int lineWidth = 4;
	
	/******************************************************************
	 * CONSTRUCTOR
	 * 
	 * DataLedHandler()
	*******************************************************************/
	public DataLedHandler() {

		dataLedColor = Color.ORANGE;
		dataLedStroke = new BasicStroke( lineWidth );
	}

	/******************************************************************
	  paintDataLed()
	*******************************************************************/
	public void paintDataLed() {
		dataLedRaius = getWidth()/2;
		g2.setStroke(dataLedStroke);
		g2.setColor(Color.LIGHT_GRAY);
		g2.drawRect(0, 0, getWidth(), getHeight());
		g2.setColor(this.dataLedColor);
		g2.fillRect(lineWidth/2, lineWidth/2, getWidth()-lineWidth, getHeight()-lineWidth);
	}

	/******************************************************************
	  void setColor( Color color )
	 *******************************************************************/
	public void setColor( Color color ){
		this.dataLedColor = color;
	}
	
	/******************************************************************
	  void paint(Graphics g)
	 *******************************************************************/
	public void paint(Graphics g) {
		g2 = (Graphics2D) g;
			
		OriganX = (int) getSize().getWidth()/2;
		OriganY = (int) getSize().getHeight()/2;

		paintDataLed();
	}

		
}

