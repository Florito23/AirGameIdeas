package gui;

import javax.swing.JPanel;
import javax.swing.JFrame;
import javax.swing.JLabel;
import java.awt.Rectangle;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;

import javax.swing.JTextField;
import javax.swing.SwingConstants;
import javax.swing.JComboBox;
import javax.swing.JButton;

public class SettingsPopup extends JFrame implements ActionListener, KeyListener {

	private static final long serialVersionUID = 1L;
	private JPanel jContentPane = null;
	private JLabel ipaddresslabel = null;
	private JLabel oscportlabel = null;
	private JLabel midiinterfacelabel = null;
	private JLabel midichannellabel = null;
	private JTextField ipaddress = null;
	private JTextField oscport = null;
	private JTextField midichannel = null;
	private JLabel oscsettingslabel = null;
	private JLabel midisettingslabel = null;
	private JComboBox mididevice = null;
	private JButton cancelbutton = null;
	private JButton okbutton = null;
	
	private Frontend2 frontend;
	
	/**
	 * This is the default constructor
	 */
	public SettingsPopup(Frontend2 frontend2) {
		super();
		frontend = frontend2;
		
		initialize();
		
	}

	/**
	 * This method initializes this
	 * 
	 * @return void
	 */
	private void initialize() {
		this.setSize(320, 250);
		this.setContentPane(getJContentPane());
		this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		this.setResizable(false);
		this.setTitle("MIDI & OSC Settings...");
	}

	/**
	 * This method initializes jContentPane
	 * 
	 * @return javax.swing.JPanel
	 */
	private JPanel getJContentPane() {
		if (jContentPane == null) {
			midisettingslabel = new JLabel();
			midisettingslabel.setBounds(new Rectangle(23, 102, 105, 16));
			midisettingslabel.setVerticalAlignment(SwingConstants.CENTER);
			midisettingslabel.setText("MIDI Settings");
			oscsettingslabel = new JLabel();
			oscsettingslabel.setBounds(new Rectangle(25, 14, 87, 16));
			oscsettingslabel.setText("OSC Settings");
			midichannellabel = new JLabel();
			midichannellabel.setBounds(new Rectangle(23, 157, 89, 16));
			midichannellabel.setText("MIDI Channel:");
			midiinterfacelabel = new JLabel();
			midiinterfacelabel.setBounds(new Rectangle(23, 130, 84, 16));
			midiinterfacelabel.setText("MIDI Device:");
			oscportlabel = new JLabel();
			oscportlabel.setBounds(new Rectangle(25, 70, 66, 16));
			oscportlabel.setText("OSC Port:");
			ipaddresslabel = new JLabel();
			ipaddresslabel.setBounds(new Rectangle(25, 42, 72, 16));
			ipaddresslabel.setText("IP Address:");
			jContentPane = new JPanel();
			jContentPane.setLayout(null);
			jContentPane.add(ipaddresslabel, null);
			jContentPane.add(oscportlabel, null);
			jContentPane.add(midiinterfacelabel, null);
			jContentPane.add(midichannellabel, null);
			jContentPane.add(getIpaddress(), null);
			jContentPane.add(getOscport(), null);
			jContentPane.add(getMidichannel(), null);
			jContentPane.add(oscsettingslabel, null);
			jContentPane.add(midisettingslabel, null);
			jContentPane.add(getMididevice(), null);
			jContentPane.add(getCancelbutton(), null);
			jContentPane.add(getOkbutton(), null);
			jContentPane.setVisible(true);
			this.add(jContentPane);
			this.setVisible(true);
		}
		return jContentPane;
	}

	/**
	 * This method initializes ipaddress	
	 * 	
	 * @return javax.swing.JTextField	
	 */
	private JTextField getIpaddress() {
		if (ipaddress == null) {
			ipaddress = new JTextField();
			ipaddress.setBounds(new Rectangle(118, 36, 146, 28));
			ipaddress.addKeyListener(this);
			ipaddress.setText(frontend.getOscIpAddress());
		}
		return ipaddress;
	}

	/**
	 * This method initializes oscport	
	 * 	
	 * @return javax.swing.JTextField	
	 */
	private JTextField getOscport() {
		if (oscport == null) {
			oscport = new JTextField();
			oscport.setBounds(new Rectangle(118, 64, 146, 28));
			oscport.addKeyListener(this);
			oscport.setText(Integer.toString(frontend.getOscPortSettings()));
		}
		return oscport;
	}

	/**
	 * This method initializes midichannel	
	 * 	
	 * @return javax.swing.JTextField	
	 */
	private JTextField getMidichannel() {
		if (midichannel == null) {
			midichannel = new JTextField();
			midichannel.setBounds(new Rectangle(118, 151, 146, 28));
			midichannel.addKeyListener(this);
			midichannel.setText(Integer.toString(frontend.getMidiChannelSettings()));
		}
		return midichannel;
	}

	/**
	 * This method initializes mididevice	
	 * 	
	 * @return javax.swing.JComboBox	
	 */
	private JComboBox getMididevice() {
		if (mididevice == null) {
			mididevice = new JComboBox(frontend.getMidiDevices());
			mididevice.setBounds(new Rectangle(116, 125, 182, 27));
			mididevice.setSelectedIndex(frontend.getMidiInterfaceSettings());
		}
		return mididevice;
	}

	/**
	 * This method initializes cancelbutton	
	 * 	
	 * @return javax.swing.JButton	
	 */
	private JButton getCancelbutton() {
		if (cancelbutton == null) {
			cancelbutton = new JButton();
			cancelbutton.setBounds(new Rectangle(112, 190, 100, 29));
			cancelbutton.setText("Cancel");
			cancelbutton.addActionListener(this);
		}
		return cancelbutton;
	}

	/**
	 * This method initializes okbutton	
	 * 	
	 * @return javax.swing.JButton	
	 */
	private JButton getOkbutton() {
		if (okbutton == null) {
			okbutton = new JButton();
			okbutton.setBounds(new Rectangle(207, 190, 95, 29));
			okbutton.setText("OK");
			okbutton.addActionListener(this);
		}
		return okbutton;
	}

	private void setValues(){
		Integer selecteddevice = mididevice.getSelectedIndex();
		String selectedchannel = midichannel.getText();
		Integer midichannel = Integer.valueOf(selectedchannel).intValue();
		
		String selectedport = oscport.getText();
		Integer selectedportnr = Integer.valueOf(selectedport).intValue();
		
		String selectedip = ipaddress.getText();
		
		frontend.setMidiSettings(selecteddevice, midichannel);
		frontend.setOscSettings(selectedip, selectedportnr);
		
		this.setVisible(false);
	}
	
	public void actionPerformed(ActionEvent e) {
		// TODO Auto-generated method stub
		if(e.getSource()==okbutton) {
			this.setValues();
		} else if(e.getSource()==cancelbutton){
			this.setVisible(false);
		}
	}

	public void keyPressed(KeyEvent e) {
		// TODO Auto-generated method stub
		if(e.getKeyCode() == KeyEvent.VK_ENTER) {
			this.setValues();
		}
		
	}

	public void keyReleased(KeyEvent e) {
		// TODO Auto-generated method stub
		
	}

	public void keyTyped(KeyEvent e) {
		// TODO Auto-generated method stub
		
	}

}
