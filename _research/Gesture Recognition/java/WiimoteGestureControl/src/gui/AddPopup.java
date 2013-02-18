package gui;

import javax.swing.JPanel;
import javax.swing.JFrame;
import javax.swing.JLabel;
import java.awt.Rectangle;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;



import javax.swing.SwingConstants;
import javax.swing.JButton;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;
import javax.swing.JTextField;



public class AddPopup extends JFrame implements ActionListener {

	private static final long serialVersionUID = 1L;
	private JPanel jContentPane = null;
	private JScrollPane jScrollPane = null;
	private JButton okbutton = null;
	private JLabel copyLegenda = null;
	private JTextArea jTextArea = null;


	
	private Frontend2 frontend;
	private JButton cancelbutton = null;
	private JLabel jLabel = null;
	private JTextField gesturenamefield = null;
	
	/**
	 * This is the default constructor
	 */
	public AddPopup(Frontend2 frontend2) {
		super();
		frontend = frontend2;
		//textfile = textfilenr;
		initialize();
		
	}

	/**
	 * This method initializes this
	 * 
	 * @return void
	 */
	private void initialize() {
		this.setSize(400, 350);
		this.setContentPane(getJContentPane());
		this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		this.setResizable(false);
		this.setTitle("Paste Gesture...");
	}

	/**
	 * This method initializes jContentPane
	 * 
	 * @return javax.swing.JPanel
	 */
	private JPanel getJContentPane() {
		if (jContentPane == null) {
			jLabel = new JLabel();
			jLabel.setBounds(new Rectangle(50, 260, 96, 16));
			jLabel.setText("Gesture Name:");
			copyLegenda = new JLabel();
			copyLegenda.setBounds(new Rectangle(14, 14, 371, 16));
			copyLegenda.setVerticalAlignment(SwingConstants.TOP);
			copyLegenda.setHorizontalAlignment(SwingConstants.CENTER);
			copyLegenda.setText("Paste your copied gesture here and click \"OK\"");
			jContentPane = new JPanel();
			jContentPane.setLayout(null);
			jContentPane.setVisible(true);
			jContentPane.add(getJScrollPane(), null);
			jContentPane.add(getOkbutton(), null);
			jContentPane.add(copyLegenda, null);
			jContentPane.add(getCancelbutton(), null);
			jContentPane.add(jLabel, null);
			jContentPane.add(getGesturenamefield(), null);
			this.add(jContentPane);
			this.setVisible(true);
		}
		return jContentPane;
	}

	/**
	 * This method initializes mididevice	
	 * 	
	 * @return javax.swing.JComboBox	
	 */
	
	public void actionPerformed(ActionEvent e) {
		// TODO Auto-generated method stub
		if(e.getSource()==okbutton){
			frontend.loadGestureFromString(jTextArea.getText(),gesturenamefield.getText());
			this.setVisible(false);
		} else if(e.getSource()==cancelbutton){
			this.setVisible(false);
		}
 	}

	/**
	 * This method initializes jScrollPane	
	 * 	
	 * @return javax.swing.JScrollPane	
	 */
	private JScrollPane getJScrollPane() {
		if (jScrollPane == null) {
			jScrollPane = new JScrollPane();
			jScrollPane.setBounds(new Rectangle(14, 44, 370, 200));
			jScrollPane.setViewportView(getJTextArea());
		}
		return jScrollPane;
	}

	/**
	 * This method initializes okbutton	
	 * 	
	 * @return javax.swing.JButton	
	 */
	private JButton getOkbutton() {
		if (okbutton == null) {
			okbutton = new JButton();
			okbutton.setBounds(new Rectangle(200, 290, 120, 29));
			okbutton.setText("OK");
			okbutton.addActionListener(this);
		}
		return okbutton;
	}

	/**
	 * This method initializes jTextArea	
	 * 	
	 * @return javax.swing.JTextArea	
	 */
	private JTextArea getJTextArea() {
		if (jTextArea == null) {
			jTextArea = new JTextArea();
		}
		return jTextArea;
	}
	

	/**
	 * This method initializes cancelbutton	
	 * 	
	 * @return javax.swing.JButton	
	 */
	private JButton getCancelbutton() {
		if (cancelbutton == null) {
			cancelbutton = new JButton();
			cancelbutton.setBounds(new Rectangle(70, 290, 120, 29));
			cancelbutton.setText("Cancel");
			cancelbutton.addActionListener(this);
		}
		return cancelbutton;
	}

	/**
	 * This method initializes gesturenamefield	
	 * 	
	 * @return javax.swing.JTextField	
	 */
	private JTextField getGesturenamefield() {
		if (gesturenamefield == null) {
			gesturenamefield = new JTextField();
			gesturenamefield.setBounds(new Rectangle(160, 254, 176, 28));
			gesturenamefield.setText("New Gesture");
		}
		return gesturenamefield;
	}
	

	

}
