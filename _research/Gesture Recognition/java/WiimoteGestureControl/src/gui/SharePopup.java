package gui;

import javax.swing.JPanel;
import javax.swing.JFrame;
import javax.swing.JLabel;
import java.awt.Rectangle;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.io.BufferedReader;
import java.io.File;
import java.io.FileReader;
import java.util.Vector;


import javax.swing.SwingConstants;
import javax.swing.JButton;
import javax.swing.JScrollPane;
import javax.swing.JTextArea;



public class SharePopup extends JFrame implements ActionListener {

	private static final long serialVersionUID = 1L;
	private JPanel jContentPane = null;
	private JScrollPane jScrollPane = null;
	private JButton okbutton = null;
	private JLabel copyLegenda = null;
	private JTextArea jTextArea = null;

	
	private Integer textfile;
	private JLabel copyLegenda1 = null;
	
	/**
	 * This is the default constructor
	 */
	public SharePopup(Integer textfilenr) {
		super();
		textfile = textfilenr;
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
		this.setTitle("Share Gesture...");
	}

	/**
	 * This method initializes jContentPane
	 * 
	 * @return javax.swing.JPanel
	 */
	private JPanel getJContentPane() {
		if (jContentPane == null) {
			copyLegenda1 = new JLabel();
			copyLegenda1.setBounds(new Rectangle(15, 255, 376, 16));
			copyLegenda1.setText("... and paste it in a text file or send it by mail");
			copyLegenda1.setVerticalAlignment(SwingConstants.TOP);
			copyLegenda1.setHorizontalAlignment(SwingConstants.CENTER);
			copyLegenda = new JLabel();
			copyLegenda.setBounds(new Rectangle(14, 14, 371, 16));
			copyLegenda.setVerticalAlignment(SwingConstants.TOP);
			copyLegenda.setHorizontalAlignment(SwingConstants.CENTER);
			copyLegenda.setText("Copy this gesture by pressing \"Cmd + A\" - \"Cmd + C\"");
			jContentPane = new JPanel();
			jContentPane.setLayout(null);
			jContentPane.setVisible(true);
			jContentPane.add(getJScrollPane(), null);
			jContentPane.add(getOkbutton(), null);
			jContentPane.add(copyLegenda, null);
			jContentPane.add(copyLegenda1, null);
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
			okbutton.setBounds(new Rectangle(150, 285, 120, 29));
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
			fillTextArea(textfile);
		}
		return jTextArea;
	}
	
	private String parseArrayToString(Vector<String> data2) {
	    String returnString = "";
	    for(String s : data2)
	        returnString += s+"\n";
	    return returnString;
	}
	
	private void fillTextArea(Integer filenr){
		Vector<String> data = new Vector<String>();
		try {
			File file = new File(filenr + ".txt");
			String line;
			
	
			// Dtei einladen...
			if (file.exists()) {
				BufferedReader in = new BufferedReader(new FileReader(file));
				while ((line = in.readLine()) != null) {
					data.add(line);
				}
			}
		} catch (Exception ex) {
			ex.printStackTrace();
			System.out.println("Share gesture Exception: " + ex.getMessage());
		}
		
		String textData = parseArrayToString(data);
		jTextArea.append(textData);
	}
	

}
