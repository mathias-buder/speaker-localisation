package mvc.view;

import mvc.enums.*;
import javax.swing.JFrame;
import javax.swing.JPanel;
import javax.swing.border.EmptyBorder;
import java.awt.GridLayout;
import java.awt.Image;
import java.awt.Toolkit;
import javax.swing.JLabel;
import javax.swing.SwingConstants;
import java.awt.Font;
import javax.swing.border.TitledBorder;
import javax.swing.UIManager;
import java.awt.Color;
import java.awt.event.ActionListener;
import java.text.DecimalFormat;
import java.text.SimpleDateFormat;
import javax.swing.JFileChooser;
import javax.swing.JTextArea;
import javax.swing.JScrollPane;
import javax.swing.border.EtchedBorder;
import javax.swing.JButton;
import java.awt.Component;
import javax.swing.JComboBox;
import javax.swing.DefaultComboBoxModel;
import javax.swing.GroupLayout;
import javax.swing.GroupLayout.Alignment;
import javax.swing.LayoutStyle.ComponentPlacement;
import javax.swing.JCheckBox;
import javax.swing.JTabbedPane;
import java.awt.Dimension;
import java.io.File;

import javax.swing.ImageIcon;
import javax.swing.JSpinner;
import javax.swing.SpinnerNumberModel;

public class ViewHandler extends JFrame {

	private static final long serialVersionUID = 1L;
	private JPanel panel_digits_phi;
	private JLabel label_digits_phi;
	private JPanel panel_digits_theta;
	private JLabel label_digits_theta;
	private JPanel panel_user_control;
	private JScrollPane scrollPane_log;
	private JTextArea textArea_log;
	private SimpleDateFormat sdf;
	private JPanel panel_controls;
	private JButton button_Scan;
	private JButton button_AccessSerial;
	private JPanel panel_menu;
	private JComboBox comboBox_scanRes;
	private JCheckBox chckbx_EnableLog;
	private boolean log_flag;
	private boolean debug_flag;
	private JComboBox comboBox_AngleUnit;
	private JButton button_SelectPath;
	private JTabbedPane tabbedPane_msg;
	private JScrollPane scrollPane_debug;
	private JTextArea textArea_debug;
	private DecimalFormat angleFormat;
	private JFileChooser fileChooser;
	private String filePath;
	private JPanel panel_diagram_phi;
	private JPanel panel_diagram_theta;
	public DiagramHandler diagramHandlerPhi;
	public DiagramHandler diagramHandlerTheta;
	public DataLedHandler dataLedHandler;
	public Unit angleUnit;
	private JCheckBox chckbx_EnableDebug;
	private JComboBox comboBox_Talker;
	private JPanel panel_dataLed;
	private JPanel panel_phi;
	private JPanel panel_theta;
	private JPanel panel_checkboxes;
	private JButton button_Play;
	private JButton button_Last;
	private ImageIcon IconPlay;
	private ImageIcon IconPause;
	private ImageIcon IconRecord;
	private ImageIcon IconStop;
	private JButton button_Record;
	private JSpinner spinner_theta;
	private JSpinner spinner_phi;
	private int[] angleValuesToSave = new int[2];



	/************************************************************************************
	 * public ViewHandler()
	 * 
	 * CONSTRUCTOR
	 ************************************************************************************/
	public ViewHandler() {
		setResizable(false);
		setTitle("3D-Speaker-Tracking");
		setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		setBounds(100, 100, 880, 866);
		JPanel contentPane = new JPanel();
		contentPane.setBorder(new EmptyBorder(5, 5, 5, 5));
		setContentPane(contentPane);
		
		
		IconPlay = new ImageIcon(ViewHandler.class.getResource("/image/Play.png"));
		IconPause = new ImageIcon(ViewHandler.class.getResource("/image/Pause.png"));
		IconRecord = new ImageIcon(ViewHandler.class.getResource("/image/Record.png"));
		IconStop = new ImageIcon(ViewHandler.class.getResource("/image/Stop.png"));
		
		Toolkit kit = Toolkit.getDefaultToolkit();
		Image img = kit.createImage(ViewHandler.class.getResource("/image/AppIcon2.png"));
		setIconImage(img);
		
		
		
		panel_user_control = new JPanel();
		panel_user_control.setBorder(new TitledBorder(UIManager.getBorder("TitledBorder.border"), "CONTROLS", TitledBorder.LEADING, TitledBorder.TOP, null, new Color(255, 153, 102)));
		
		panel_controls = new JPanel();
		panel_controls.setBorder(new EtchedBorder(EtchedBorder.LOWERED, null, null));
		
		JPanel panel_button = new JPanel();
		panel_button.setLayout(new GridLayout(0, 2, 0, 0));
		
		button_Scan = new JButton("Scan");
		button_Scan.setToolTipText("Scan for available serial ports");
		button_Scan.setFont(new Font("Tahoma", Font.PLAIN, 11));
		panel_button.add(button_Scan);
		
		button_AccessSerial = new JButton("Connect");
		button_AccessSerial.setToolTipText("Connect to selected serial port");
		button_AccessSerial.setFont(new Font("Tahoma", Font.PLAIN, 11));
		panel_button.add(button_AccessSerial);
		
		button_SelectPath = new JButton("Select path ...");
		button_SelectPath.setToolTipText("Select file to save received angle values");
		button_SelectPath.setFont(new Font("Tahoma", Font.PLAIN, 11));
		panel_button.add(button_SelectPath);
		
		panel_menu = new JPanel();
		
		comboBox_scanRes = new JComboBox();
		comboBox_scanRes.setToolTipText("Select serial port");
		comboBox_scanRes.setFont(new Font("Tahoma", Font.PLAIN, 11));
		
		JLabel lblPorts = new JLabel("Port");
		lblPorts.setHorizontalAlignment(SwingConstants.RIGHT);
		lblPorts.setFont(new Font("Tahoma", Font.BOLD, 11));
		
		comboBox_AngleUnit = new JComboBox();
		comboBox_AngleUnit.setToolTipText("Select angle unit");
		comboBox_AngleUnit.setFont(new Font("Tahoma", Font.PLAIN, 11));
		comboBox_AngleUnit.setModel(new DefaultComboBoxModel(Unit.values()));
		
		JLabel lblUnit = new JLabel("Unit");
		lblUnit.setHorizontalAlignment(SwingConstants.RIGHT);
		lblUnit.setFont(new Font("Tahoma", Font.BOLD, 11));
		
		panel_checkboxes = new JPanel();
		panel_checkboxes.setBorder(new TitledBorder(null, "Show", TitledBorder.LEADING, TitledBorder.TOP, null, null));
		
		comboBox_Talker = new JComboBox();
		comboBox_Talker.setToolTipText("Select audio speaker type");
		comboBox_Talker.setModel(new DefaultComboBoxModel(AudioType.values()));
		comboBox_Talker.setFont(new Font("Tahoma", Font.PLAIN, 11));
		
		JLabel lbl_Talker = new JLabel("Talker");
		lbl_Talker.setHorizontalAlignment(SwingConstants.RIGHT);
		lbl_Talker.setFont(new Font("Tahoma", Font.BOLD, 11));
		
		spinner_phi = new JSpinner();
		spinner_phi.setModel(new SpinnerNumberModel(0, -90, 90, 1));
		
		spinner_theta = new JSpinner();
		spinner_theta.setModel(new SpinnerNumberModel(0, 0, 359, 1));
		
		JLabel lblPhi = new JLabel("Phi [\u00B0]");
		lblPhi.setHorizontalAlignment(SwingConstants.RIGHT);
		lblPhi.setFont(new Font("Tahoma", Font.PLAIN, 11));
		
		JLabel lblTheta = new JLabel("Theta [\u00B0]");
		lblTheta.setHorizontalAlignment(SwingConstants.RIGHT);
		lblTheta.setFont(new Font("Tahoma", Font.PLAIN, 11));
		GroupLayout gl_panel_menu = new GroupLayout(panel_menu);
		gl_panel_menu.setHorizontalGroup(
			gl_panel_menu.createParallelGroup(Alignment.LEADING)
				.addGroup(gl_panel_menu.createSequentialGroup()
					.addGroup(gl_panel_menu.createParallelGroup(Alignment.TRAILING)
						.addGroup(gl_panel_menu.createSequentialGroup()
							.addContainerGap()
							.addComponent(lblPorts))
						.addGroup(gl_panel_menu.createParallelGroup(Alignment.TRAILING)
							.addGroup(gl_panel_menu.createSequentialGroup()
								.addContainerGap()
								.addComponent(lbl_Talker, GroupLayout.PREFERRED_SIZE, 47, GroupLayout.PREFERRED_SIZE))
							.addGroup(gl_panel_menu.createParallelGroup(Alignment.TRAILING)
								.addGroup(gl_panel_menu.createSequentialGroup()
									.addContainerGap()
									.addComponent(lblPhi))
								.addGroup(gl_panel_menu.createParallelGroup(Alignment.TRAILING)
									.addGroup(gl_panel_menu.createSequentialGroup()
										.addGap(43)
										.addComponent(lblUnit, GroupLayout.PREFERRED_SIZE, 24, GroupLayout.PREFERRED_SIZE))
									.addGroup(gl_panel_menu.createSequentialGroup()
										.addContainerGap()
										.addComponent(lblTheta, GroupLayout.DEFAULT_SIZE, 57, Short.MAX_VALUE))))))
					.addPreferredGap(ComponentPlacement.UNRELATED)
					.addGroup(gl_panel_menu.createParallelGroup(Alignment.LEADING)
						.addComponent(comboBox_AngleUnit, 0, 122, Short.MAX_VALUE)
						.addComponent(comboBox_scanRes, 0, 122, Short.MAX_VALUE)
						.addComponent(comboBox_Talker, 0, 122, Short.MAX_VALUE)
						.addGroup(gl_panel_menu.createSequentialGroup()
							.addGroup(gl_panel_menu.createParallelGroup(Alignment.TRAILING)
								.addComponent(spinner_theta, GroupLayout.PREFERRED_SIZE, 47, GroupLayout.PREFERRED_SIZE)
								.addComponent(spinner_phi, GroupLayout.PREFERRED_SIZE, 47, GroupLayout.PREFERRED_SIZE))
							.addPreferredGap(ComponentPlacement.RELATED)
							.addComponent(panel_checkboxes, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)))
					.addGap(85))
		);
		gl_panel_menu.setVerticalGroup(
			gl_panel_menu.createParallelGroup(Alignment.LEADING)
				.addGroup(gl_panel_menu.createSequentialGroup()
					.addContainerGap()
					.addGroup(gl_panel_menu.createParallelGroup(Alignment.TRAILING)
						.addGroup(gl_panel_menu.createSequentialGroup()
							.addGroup(gl_panel_menu.createParallelGroup(Alignment.BASELINE)
								.addComponent(comboBox_Talker, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
								.addComponent(lbl_Talker))
							.addPreferredGap(ComponentPlacement.UNRELATED)
							.addGroup(gl_panel_menu.createParallelGroup(Alignment.BASELINE)
								.addComponent(comboBox_scanRes, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
								.addComponent(lblPorts))
							.addGap(9)
							.addComponent(comboBox_AngleUnit, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
							.addGroup(gl_panel_menu.createParallelGroup(Alignment.TRAILING)
								.addGroup(gl_panel_menu.createSequentialGroup()
									.addGap(18)
									.addGroup(gl_panel_menu.createParallelGroup(Alignment.BASELINE)
										.addComponent(spinner_phi, GroupLayout.PREFERRED_SIZE, 32, GroupLayout.PREFERRED_SIZE)
										.addComponent(lblPhi))
									.addPreferredGap(ComponentPlacement.RELATED)
									.addGroup(gl_panel_menu.createParallelGroup(Alignment.BASELINE)
										.addComponent(spinner_theta, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE)
										.addComponent(lblTheta)))
								.addGroup(gl_panel_menu.createSequentialGroup()
									.addPreferredGap(ComponentPlacement.RELATED)
									.addComponent(panel_checkboxes, GroupLayout.DEFAULT_SIZE, 82, Short.MAX_VALUE))))
						.addGroup(gl_panel_menu.createSequentialGroup()
							.addComponent(lblUnit)
							.addGap(88)))
					.addGap(23))
		);
		gl_panel_menu.linkSize(SwingConstants.VERTICAL, new Component[] {spinner_phi, spinner_theta});
		gl_panel_menu.linkSize(SwingConstants.HORIZONTAL, new Component[] {comboBox_scanRes, comboBox_AngleUnit, comboBox_Talker});
		panel_checkboxes.setLayout(new GridLayout(2, 0, 0, 0));

		chckbx_EnableLog = new JCheckBox("log");
		chckbx_EnableLog.setToolTipText("Show log messages");
		panel_checkboxes.add(chckbx_EnableLog);
		chckbx_EnableLog.setFont(new Font("Tahoma", Font.PLAIN, 11));
		chckbx_EnableLog.setSelected(true);
		
		chckbx_EnableDebug = new JCheckBox("debug");
		chckbx_EnableDebug.setToolTipText("Show debug messages");
		panel_checkboxes.add(chckbx_EnableDebug);
		chckbx_EnableDebug.setFont(new Font("Tahoma", Font.PLAIN, 11));
		panel_menu.setLayout(gl_panel_menu);
		GroupLayout gl_panel_controls = new GroupLayout(panel_controls);
		gl_panel_controls.setHorizontalGroup(
			gl_panel_controls.createParallelGroup(Alignment.LEADING)
				.addGroup(gl_panel_controls.createSequentialGroup()
					.addGroup(gl_panel_controls.createParallelGroup(Alignment.TRAILING, false)
						.addComponent(panel_button, Alignment.LEADING, 0, 0, Short.MAX_VALUE)
						.addComponent(panel_menu, Alignment.LEADING, GroupLayout.PREFERRED_SIZE, 207, Short.MAX_VALUE))
					.addGap(44))
		);
		gl_panel_controls.setVerticalGroup(
			gl_panel_controls.createParallelGroup(Alignment.LEADING)
				.addGroup(gl_panel_controls.createSequentialGroup()
					.addComponent(panel_button, GroupLayout.PREFERRED_SIZE, 53, GroupLayout.PREFERRED_SIZE)
					.addPreferredGap(ComponentPlacement.RELATED)
					.addComponent(panel_menu, GroupLayout.PREFERRED_SIZE, GroupLayout.DEFAULT_SIZE, GroupLayout.PREFERRED_SIZE))
		);
		
		JPanel panel_audioControls = new JPanel();
		panel_button.add(panel_audioControls);
		panel_audioControls.setLayout(new GridLayout(0, 3, 0, 0));
		
		button_Record = new JButton("");
		button_Record.setToolTipText("Record received angles in file");
		button_Record.setIcon(IconRecord);
		button_Record.setFont(new Font("Tahoma", Font.PLAIN, 11));
		panel_audioControls.add(button_Record);
		
		button_Play = new JButton("");
		button_Play.setToolTipText("Play audio");
		button_Play.setIcon(IconPlay);
		panel_audioControls.add(button_Play);
		button_Play.setFont(new Font("Tahoma", Font.PLAIN, 11));
		
		button_Last = new JButton("");
		button_Last.setToolTipText("Reset audio");
		button_Last.setIcon(new ImageIcon(ViewHandler.class.getResource("/image/Last.png")));
		button_Last.setFont(new Font("Tahoma", Font.PLAIN, 11));
		panel_audioControls.add(button_Last);
		panel_controls.setLayout(gl_panel_controls);
		
		tabbedPane_msg = new JTabbedPane(JTabbedPane.TOP);
		
		scrollPane_log = new JScrollPane();
		tabbedPane_msg.addTab("Log", null, scrollPane_log, null);
		scrollPane_log.setToolTipText("");
		
		textArea_log = new JTextArea();
		textArea_log.setColumns(1);
		textArea_log.setEditable(false);
		scrollPane_log.setViewportView(textArea_log);
		
		scrollPane_debug = new JScrollPane();
		scrollPane_debug.setToolTipText("");
		tabbedPane_msg.addTab("Debug", null, scrollPane_debug, null);
		
		textArea_debug = new JTextArea();
		textArea_debug.setEditable(false);
		textArea_debug.setColumns(1);
		scrollPane_debug.setViewportView(textArea_debug);
		
		panel_phi = new JPanel();
		panel_phi.setSize(new Dimension(100, 100));
		panel_phi.setBorder(new TitledBorder(UIManager.getBorder("TitledBorder.border"), "PHI", TitledBorder.LEADING, TitledBorder.TOP, null, new Color(255, 153, 102)));
		
		panel_theta = new JPanel();
		panel_theta.setBorder(new TitledBorder(UIManager.getBorder("TitledBorder.border"), "THETA", TitledBorder.LEADING, TitledBorder.TOP, null, new Color(255, 153, 102)));
		
		panel_dataLed = new JPanel();
		panel_dataLed.setMinimumSize(new Dimension(2, 2));
		dataLedHandler = new DataLedHandler();
		GroupLayout gl_panel_dataLed = new GroupLayout(panel_dataLed);
		gl_panel_dataLed.setHorizontalGroup(
			gl_panel_dataLed.createParallelGroup(Alignment.LEADING)
				.addComponent(dataLedHandler, Alignment.TRAILING, GroupLayout.DEFAULT_SIZE, 109, Short.MAX_VALUE)
		);
		gl_panel_dataLed.setVerticalGroup(
			gl_panel_dataLed.createParallelGroup(Alignment.LEADING)
				.addComponent(dataLedHandler, GroupLayout.DEFAULT_SIZE, 6, Short.MAX_VALUE)
		);
		panel_dataLed.setLayout(gl_panel_dataLed);
		GroupLayout gl_contentPane = new GroupLayout(contentPane);
		gl_contentPane.setHorizontalGroup(
			gl_contentPane.createParallelGroup(Alignment.LEADING)
				.addGroup(gl_contentPane.createSequentialGroup()
					.addContainerGap()
					.addGroup(gl_contentPane.createParallelGroup(Alignment.LEADING)
						.addGroup(gl_contentPane.createSequentialGroup()
							.addGroup(gl_contentPane.createParallelGroup(Alignment.LEADING)
								.addComponent(panel_dataLed, GroupLayout.DEFAULT_SIZE, 846, Short.MAX_VALUE)
								.addGroup(gl_contentPane.createSequentialGroup()
									.addComponent(panel_phi, GroupLayout.PREFERRED_SIZE, 412, GroupLayout.PREFERRED_SIZE)
									.addPreferredGap(ComponentPlacement.RELATED, 20, Short.MAX_VALUE)
									.addComponent(panel_theta, GroupLayout.PREFERRED_SIZE, 412, GroupLayout.PREFERRED_SIZE)
									.addPreferredGap(ComponentPlacement.RELATED)))
							.addGap(9))
						.addGroup(gl_contentPane.createSequentialGroup()
							.addComponent(panel_user_control, GroupLayout.PREFERRED_SIZE, 845, GroupLayout.PREFERRED_SIZE)
							.addContainerGap(GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))))
		);
		gl_contentPane.setVerticalGroup(
			gl_contentPane.createParallelGroup(Alignment.LEADING)
				.addGroup(gl_contentPane.createSequentialGroup()
					.addComponent(panel_dataLed, GroupLayout.PREFERRED_SIZE, 6, GroupLayout.PREFERRED_SIZE)
					.addGap(5)
					.addGroup(gl_contentPane.createParallelGroup(Alignment.BASELINE, false)
						.addComponent(panel_phi, GroupLayout.PREFERRED_SIZE, 515, GroupLayout.PREFERRED_SIZE)
						.addComponent(panel_theta, GroupLayout.PREFERRED_SIZE, 433, GroupLayout.PREFERRED_SIZE))
					.addPreferredGap(ComponentPlacement.RELATED)
					.addComponent(panel_user_control, GroupLayout.DEFAULT_SIZE, 299, Short.MAX_VALUE)
					.addContainerGap())
		);
		gl_contentPane.linkSize(SwingConstants.VERTICAL, new Component[] {panel_phi, panel_theta});
		GroupLayout gl_panel_user_control = new GroupLayout(panel_user_control);
		gl_panel_user_control.setHorizontalGroup(
			gl_panel_user_control.createParallelGroup(Alignment.LEADING)
				.addGroup(gl_panel_user_control.createSequentialGroup()
					.addComponent(panel_controls, GroupLayout.PREFERRED_SIZE, 214, GroupLayout.PREFERRED_SIZE)
					.addPreferredGap(ComponentPlacement.RELATED)
					.addComponent(tabbedPane_msg, GroupLayout.DEFAULT_SIZE, 613, Short.MAX_VALUE))
		);
		gl_panel_user_control.setVerticalGroup(
			gl_panel_user_control.createParallelGroup(Alignment.LEADING)
				.addGroup(gl_panel_user_control.createSequentialGroup()
					.addGroup(gl_panel_user_control.createParallelGroup(Alignment.TRAILING)
						.addComponent(tabbedPane_msg, Alignment.LEADING)
						.addComponent(panel_controls, Alignment.LEADING, GroupLayout.DEFAULT_SIZE, GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
					.addContainerGap())
		);
		panel_user_control.setLayout(gl_panel_user_control);
		
		panel_digits_theta = new JPanel();
		panel_digits_theta.setBorder(new EtchedBorder(EtchedBorder.LOWERED, null, null));
		panel_digits_theta.setLayout(new GridLayout(0, 1, 0, 0));
		
		label_digits_theta = new JLabel("0.0\u00B0");
		label_digits_theta.setForeground(Color.GRAY);
		label_digits_theta.setFont(new Font("ISOCP", Font.BOLD, 50));
		label_digits_theta.setHorizontalAlignment(SwingConstants.CENTER);
		panel_digits_theta.add(label_digits_theta);
		diagramHandlerTheta = new DiagramHandler();
		
		
		panel_diagram_theta = new JPanel();
		panel_diagram_theta.setBackground(Color.WHITE);
		panel_diagram_theta.setBorder(null);
		panel_diagram_theta.setLayout(new GridLayout(1, 0, 0, 0));
		panel_diagram_theta.add(diagramHandlerTheta);
		GroupLayout gl_panel_theta = new GroupLayout(panel_theta);
		gl_panel_theta.setHorizontalGroup(
			gl_panel_theta.createParallelGroup(Alignment.LEADING)
				.addGroup(gl_panel_theta.createSequentialGroup()
					.addGroup(gl_panel_theta.createParallelGroup(Alignment.LEADING)
						.addComponent(panel_digits_theta, GroupLayout.PREFERRED_SIZE, 399, GroupLayout.PREFERRED_SIZE)
						.addComponent(panel_diagram_theta, GroupLayout.PREFERRED_SIZE, 304, GroupLayout.PREFERRED_SIZE))
					.addContainerGap())
		);
		gl_panel_theta.setVerticalGroup(
			gl_panel_theta.createParallelGroup(Alignment.LEADING)
				.addGroup(gl_panel_theta.createSequentialGroup()
					.addComponent(panel_digits_theta, GroupLayout.PREFERRED_SIZE, 63, GroupLayout.PREFERRED_SIZE)
					.addPreferredGap(ComponentPlacement.RELATED)
					.addComponent(panel_diagram_theta, GroupLayout.DEFAULT_SIZE, 340, Short.MAX_VALUE))
		);
		gl_panel_theta.linkSize(SwingConstants.HORIZONTAL, new Component[] {panel_digits_theta, panel_diagram_theta});
		panel_theta.setLayout(gl_panel_theta);
		
		panel_digits_phi = new JPanel();
		panel_digits_phi.setSize(new Dimension(100, 100));
		panel_digits_phi.setBorder(new EtchedBorder(EtchedBorder.LOWERED, null, null));
		panel_digits_phi.setLayout(new GridLayout(0, 1, 0, 0));
		
		diagramHandlerPhi = new DiagramHandler();
		
		panel_diagram_phi = new JPanel();
		panel_diagram_phi.setBackground(Color.WHITE);
		panel_diagram_phi.setBorder(null);
		panel_diagram_phi.setLayout(new GridLayout(0, 1, 0, 0));
		panel_diagram_phi.add(diagramHandlerPhi);
		GroupLayout gl_panel_phi = new GroupLayout(panel_phi);
		gl_panel_phi.setHorizontalGroup(
			gl_panel_phi.createParallelGroup(Alignment.LEADING)
				.addGroup(gl_panel_phi.createSequentialGroup()
					.addGroup(gl_panel_phi.createParallelGroup(Alignment.LEADING)
						.addComponent(panel_digits_phi, GroupLayout.PREFERRED_SIZE, 399, GroupLayout.PREFERRED_SIZE)
						.addComponent(panel_diagram_phi, GroupLayout.PREFERRED_SIZE, 396, GroupLayout.PREFERRED_SIZE))
					.addContainerGap(GroupLayout.DEFAULT_SIZE, Short.MAX_VALUE))
		);
		gl_panel_phi.setVerticalGroup(
			gl_panel_phi.createParallelGroup(Alignment.LEADING)
				.addGroup(gl_panel_phi.createSequentialGroup()
					.addComponent(panel_digits_phi, GroupLayout.PREFERRED_SIZE, 64, GroupLayout.PREFERRED_SIZE)
					.addPreferredGap(ComponentPlacement.RELATED)
					.addComponent(panel_diagram_phi, GroupLayout.DEFAULT_SIZE, 421, Short.MAX_VALUE))
		);
		gl_panel_phi.linkSize(SwingConstants.HORIZONTAL, new Component[] {panel_digits_phi, panel_diagram_phi});
		
		label_digits_phi = new JLabel("0.0\u00B0");
		label_digits_phi.setForeground(Color.GRAY);
		label_digits_phi.setHorizontalAlignment(SwingConstants.CENTER);
		label_digits_phi.setFont(new Font("ISOCP", Font.BOLD, 50));
		panel_digits_phi.add(label_digits_phi);
		panel_phi.setLayout(gl_panel_phi);
		contentPane.setLayout(gl_contentPane);
		
		
		sdf = new SimpleDateFormat("H:mm:ss:S");
		log_flag = true;
		debug_flag = false;
		this.angleFormat = new DecimalFormat();
		
		fileChooser = new JFileChooser("Choose directory");
		angleUnit = Unit.DEG;
	}
	
	
	/************************************************************************************
	 * void setAngleVal( Angle angle, String format, float value)
	 ************************************************************************************/
	public void setAngleVal( Angle angle, String format, float value) {
		
		angleFormat.applyPattern(format);
	
		switch (angle) {
			case PHI:
				switch (this.angleUnit) {
					case DEG:
						label_digits_phi.setText( angleFormat.format( Math.toDegrees(value) ) + "°" );
					break;
					
					case RAD:
						label_digits_phi.setText( angleFormat.format( value ) + "rad" );
					break;
	
					default:
					break;
				}
			break;
			
			case THETA:
				switch (this.angleUnit) {
					case DEG:
						label_digits_theta.setText( angleFormat.format( Math.toDegrees(value) ) + "°" );
					break;
					
					case RAD:
						label_digits_theta.setText( angleFormat.format( value ) + "rad" );
					break;
	
					default:
					break;
				}
			break;
	
			default:
			break;
		}
	}
	
	
	/************************************************************************************
	* void setAngleUnit( Unit unit )
	************************************************************************************/
	public void setAngleUnit( Unit unit ){
		this.angleUnit = unit;
	}
	
	/************************************************************************************
	* public void addLogMsg( String msg )
	************************************************************************************/
	public void addLogMsg( String msg ) {
		if( log_flag ){
			textArea_log.append(sdf.format(System.currentTimeMillis()) + " - " + msg + "\n");
			// scroll to very bottom
			textArea_log.setCaretPosition(textArea_log.getDocument().getLength());
		}
	}
	
	/************************************************************************************
	* void addDebugMsg( String msg )
	************************************************************************************/
	public void addDebugMsg( String msg ) {
		if( debug_flag ){
			textArea_debug.append(sdf.format(System.currentTimeMillis()) + " - " + msg + "\n");
			// scroll to very bottom
			textArea_debug.setCaretPosition(textArea_debug.getDocument().getLength());
		}
	}
	
	/************************************************************************************
	* void setX...Listener( ActionListener l ) {
	************************************************************************************/
	public void setButtonScanListener( ActionListener l ) {
		this.button_Scan.addActionListener(l);
	}
	
	public void setButtonConnectListener( ActionListener l ) {
		this.button_AccessSerial.addActionListener(l);
	}
	
	public void setComboBoxScanResListener( ActionListener l ) {
		this.comboBox_scanRes.addActionListener(l);
	}
	
	public void setChackBoxEnableLogListener( ActionListener l ) {
		this.chckbx_EnableLog.addActionListener(l);
	}
	
	public void setChackBoxEnableDebugListener( ActionListener l ) {
		this.chckbx_EnableDebug.addActionListener(l);
	}
	
	public void setComboBoxAngleUnitListener( ActionListener l ) {
		this.comboBox_AngleUnit.addActionListener(l);
	}
	
	public void setButtonSaveFileListener( ActionListener l ) {
		this.button_SelectPath.addActionListener(l);
	}
	
	public void setButtonRecordListener( ActionListener l ) {
		this.button_Record.addActionListener(l);
	}
	
	public void setButtonPlayListener( ActionListener l ) {
		this.button_Play.addActionListener(l);
	}
	
	public void setButtonLastListener( ActionListener l ) {
		this.button_Last.addActionListener(l);
	}
	
	public void setChackBoxTalkerListener( ActionListener l) {
		this.comboBox_Talker.addActionListener(l);
	}
	
	/************************************************************************************
	 * void addPortItem(String port)
	 ************************************************************************************/
	public void addPortItem(String port) {
		comboBox_scanRes.addItem(makeObj(port));
	}
	
	/************************************************************************************
	 * void clearPortItems() 
	 ************************************************************************************/
	public void clearPortItems() {
		comboBox_scanRes.removeAllItems();
	}
	
	/************************************************************************************
	 * Object makeObj(final String item)s
	 ************************************************************************************/
	 private Object makeObj(final String item) {
	     return new Object() { public String toString() { return item; } };
	}
	
	/************************************************************************************
	* String getPortItem() {
	************************************************************************************/
	 public String getPortItem() {
		 return comboBox_scanRes.getSelectedItem().toString();
	}
	 
	/************************************************************************************
	* void portItem( boolean flag) {
	************************************************************************************/
	 public void portItem( boolean flag) {
		 comboBox_scanRes.setEnabled( flag );
	}
 
	/************************************************************************************
	* void buttonSaveFile( boolean flag)
	************************************************************************************/
	 public void buttonSaveFile( boolean flag){
		 button_SelectPath.setEnabled( flag );
	 }
	 
	/************************************************************************************
	* void buttonConnect( boolean flag)
	************************************************************************************/
	 public void buttonAccessSerial( boolean flag){
		 button_AccessSerial.setEnabled( flag );
	}
	 
	/************************************************************************************
	* void buttonScan( boolean flag)
	************************************************************************************/
	public void buttonScan( boolean flag){
		 button_Scan.setEnabled( flag );
	}
	 
	/************************************************************************************
	* void buttonConnect( boolean flag)
	************************************************************************************/
	public void buttonRecord( boolean flag){
		button_Record.setEnabled( flag );
	}
	
	/************************************************************************************
	* void buttonPlay( boolean flag)
	************************************************************************************/
	public void buttonPlay( boolean flag){
		 button_Play.setEnabled( flag );
	}
	 
	/************************************************************************************
	* void buttonPlay( boolean flag)
	************************************************************************************/
	public void buttonLast( boolean flag){
		 button_Last.setEnabled( flag );
	}
	
	/************************************************************************************
	* void ComboBoxAudioType( boolean flag)
	************************************************************************************/
	public void ComboBoxAudioType( boolean flag){
		 comboBox_Talker.setEnabled( flag );
	}
	 
	/************************************************************************************
	* void buttonAccessSerialSetText(String text)
	************************************************************************************/
	 public void buttonAccessSerialSetText(String text){
		 button_AccessSerial.setText(text);
	}
	 

	/************************************************************************************
	* void buttonAccessSerialSetText(String text)
	************************************************************************************/
	 public void spinnerAngleToSave(boolean flag){
		 spinner_phi.setEnabled(flag);
		 spinner_theta.setEnabled(flag);
	}
	
	
	
	/************************************************************************************
	* void setLog( boolean flag)
	************************************************************************************/
	 public void setLog( boolean flag) {
		log_flag = flag;
	}
	
	/************************************************************************************
	* void setDebug( boolean flag) 
	************************************************************************************/
	 public void setDebug( boolean flag) {
		debug_flag = flag;
	}
	
	/************************************************************************************
	* File openFileDialog() 
	************************************************************************************/
	 public FileState openFileDialog() { 

		fileChooser.setDialogType( JFileChooser.OPEN_DIALOG ); 
		fileChooser.setFileSelectionMode( JFileChooser.FILES_AND_DIRECTORIES ); 
		
		fileChooser.setVisible(true); 
		final int result = fileChooser.showOpenDialog(null); 
		
		switch (result) {
			case JFileChooser.APPROVE_OPTION:
				filePath = fileChooser.getSelectedFile().getPath();
				//System.out.println( fileChooser.getSelectedFile().getPath() );
				fileChooser.setVisible(false); 
			return FileState.SELECTED;
		
			case JFileChooser.CANCEL_OPTION:
				fileChooser.setVisible(false); 
			return FileState.ABORT;
			
			default:
				fileChooser.setVisible(false); 
		return FileState.ERROR;
		}
	}
	
	/************************************************************************************
	* String getFilePath()
	************************************************************************************/
	public String getFilePath(){
		 return filePath;
	 }
	 
	/************************************************************************************
	* void setAnglePointer( Angle angle, double value )
	************************************************************************************/
	public void setAnglePointer( Angle angle, double value ){
		 
		 switch (angle) {
			case PHI:
				diagramHandlerPhi.setAnglePointer(value);
				diagramHandlerPhi.repaint();
			break;
			case THETA:
				diagramHandlerTheta.setAnglePointer(value);
				diagramHandlerTheta.repaint();
			break;
	
			default:
			break;
			
		}
	}
	
	/************************************************************************************
	*  void setDataLed(Color color)
	************************************************************************************/
	public void setDataLed(Color color){
		 dataLedHandler.setColor(color);
		 dataLedHandler.repaint();
	}
	
	/************************************************************************************
	* void buttonPlayIcon(String text)
	************************************************************************************/
	public void setButtonPlayIcon(String text){
		if(text.matches("Play")){
			this.button_Play.setIcon(IconPlay);
		 }
		 else {
			this.button_Play.setIcon(IconPause);
		}
	}
	
	/************************************************************************************
	* Audio getSelectedAudioType()
	************************************************************************************/
	public AudioType getSelectedAudioType(){
		return ( (AudioType) this.comboBox_Talker.getSelectedItem() );
	}
	
	
	/************************************************************************************
	* void buttonRecordIcon(String text)
	************************************************************************************/
	public void setButtonRecordIcon(String text){
		if(text.matches("Record")){
			this.button_Record.setIcon(IconRecord);
		 }
		 else {
			this.button_Record.setIcon(IconStop);
		}
	}
	
	/************************************************************************************
	* int[] getAngleValuesToSave()
	************************************************************************************/
	public int[] getAnglesToSave(){
		angleValuesToSave[0] = (int) this.spinner_phi.getValue();
		angleValuesToSave[1] = (int) this.spinner_theta.getValue();
		return angleValuesToSave;
		
	}
	
	
	public void setDefaultDirectory(String path){
		final File file = new File(path); 
		fileChooser.setCurrentDirectory(file);
	}
}
