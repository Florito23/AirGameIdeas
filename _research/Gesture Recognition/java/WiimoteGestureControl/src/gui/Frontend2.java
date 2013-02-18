package gui;

import javax.swing.ButtonGroup;
import javax.swing.DefaultListModel;
import javax.swing.JPanel;
import javax.swing.JFrame;
import javax.swing.JLabel;


import java.awt.Rectangle;
import javax.swing.JScrollPane;
import javax.swing.JRadioButton;
import javax.swing.JTextField;
import javax.swing.JButton;


import java.awt.Color;
import java.awt.Font;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.awt.event.KeyEvent;
import java.awt.event.KeyListener;
import java.awt.event.WindowAdapter;
import java.awt.event.WindowEvent;
import java.io.IOException;
import java.util.HashMap;
import java.util.Vector;

import javax.swing.SwingConstants;

import logic.AccelerationStreamAnalyzer;
import device.Wiimote;

import event.*;
import javax.swing.JList;
import javax.swing.ListSelectionModel;
import javax.swing.event.ListSelectionEvent;
import javax.swing.event.ListSelectionListener;

import java.net.*;

import com.illposed.osc.OSCMessage;
import com.illposed.osc.OSCPortOut;

import promidi.*;

@SuppressWarnings("unchecked")
public class Frontend2 extends JFrame implements WiimoteListener, GestureListener,
 KeyListener {
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	/**
	 * 
	 */
	private int counter = 1;
	private int index_gestures = 0;
	private int index_gesture = 0;
	private int lastpressed = -1;
	private Vector<WiimoteAccelerationEvent>[][] gestures = new Vector[5][15];
	
	private int oscportint = 3333;
	private String oscipaddress = "127.0.0.1";  //  @jve:decl-index=0:
	private InetAddress oscaddress;  //  @jve:decl-index=0:
	private OSCPortOut oscsender;
	
	private MidiIO midiIO;
	private MidiOut midiOut;
	
	private Integer midideviceselect = 0;  //  @jve:decl-index=0:
	private Integer midichannelselect = 0;  //  @jve:decl-index=0:
	
	private boolean midiselected = true; // true = MIDI selected, false = OSC selected

	//private WiiMoteButtonState buttonstate;
	private Wiimote wiimote;
	@SuppressWarnings("unused")
	private AccelerationStreamAnalyzer astra;
	private SaveUnit sunit;
	private Graph graph;

	private HashMap<Integer, String> gesturenames = new HashMap<Integer, String>();  //  @jve:decl-index=0:
	//private JTable jTable = null;
	
	private DefaultListModel lijstmodel = new DefaultListModel();

	private JPanel jContentPane = null;
	private JScrollPane jScrollPane = null;
	
	private ButtonGroup buttongroup = new ButtonGroup();;  //  @jve:decl-index=0:
	
	private JTextField midicc = null; // MIDI CC TXTFIELD
	private JLabel midicclabel = null; // MIDI
	private JRadioButton midiselector = null; // MIDI KEUZE BUTTON
	
	private JRadioButton oscselector = null; // OSC KEUZE BUTTON
	private JLabel oscstringlabel = null; // OSC
	private JTextField oscstring = null; // OSC STRING TXTFIELD
	
	private JTextField gesturename = null;
	private JLabel gesturenamelabel = null;
	
	private JLabel status = null;
	
	private JButton testbutton = null; // TEST SIGNAL BUTTON
	
	private JButton addbutton = null; // ADD GESTURE BUTTON
	private JButton removebutton = null; // REMOVE GESTURE BUTTON
	private JButton sharebutton = null; // SHARE GESTURE BUTTON
	
	private JLabel legenda = null;
	
	private JList gesturelist = null; // LIJST MET GESTURES
	
	private JButton settings = null; // MIDI & OSC SETTINGS BUTTON
	
	//private int[] midiccarray = null;
	private Vector<Integer> midiccarray = new Vector<Integer>();  //  @jve:decl-index=0:
	private Vector<Integer> oscargarray = new Vector<Integer>();
	private Vector<Integer> midivaluearray = new Vector<Integer>();
	
	private Vector<Boolean> midiosc = new Vector<Boolean>(); // true = midi, false = osc
	
	private Vector<Boolean> disabled = new Vector<Boolean>();
	
	private Vector<Integer> gesturetextfilearray = new Vector<Integer>();  //  @jve:decl-index=0:
	
	private int selectedgesture = -1;
	
	/**
	 * This method initializes jScrollPane	
	 * 	
	 * @return javax.swing.JScrollPane	
	 */
	private JScrollPane getJScrollPane() {
		if (jScrollPane == null) {
			jScrollPane = new JScrollPane();
			jScrollPane.setBounds(new Rectangle(397, 24, 335, 243));
			jScrollPane.setViewportView(getGesturelist());
		}
		return jScrollPane;
	}

	/**
	 * This method initializes midiselector	
	 * 	
	 * @return javax.swing.JRadioButton	
	 */
	private JRadioButton getMidiselector() {
		if (midiselector == null) {
			midiselector = new JRadioButton();
			buttongroup.add(midiselector);
			midiselector.setBounds(new Rectangle(399, 372, 74, 23));
			midiselector.setText("MIDI");
			midiselector.setSelected(true);
			midiselector.setActionCommand("setMidiButton()");
			midiselector.addActionListener(buttonListener);
		}
		return midiselector;
	}

	/**
	 * This method initializes oscselector	
	 * 	
	 * @return javax.swing.JRadioButton	
	 */
	private JRadioButton getOscselector() {
		if (oscselector == null) {
			oscselector = new JRadioButton();
			buttongroup.add(oscselector);
			oscselector.setBounds(new Rectangle(479, 372, 72, 23));
			oscselector.setText("OSC");
			oscselector.setActionCommand("setOscButton()");
			oscselector.addActionListener(buttonListener);
		}
		return oscselector;
	}

	/**
	 * This method initializes gesturename	
	 * 	
	 * @return javax.swing.JTextField	
	 */
	private JTextField getGesturename() {
		if (gesturename == null) {
			gesturename = new JTextField();
			gesturename.setBounds(new Rectangle(498, 334, 188, 28));
			gesturename.addKeyListener(this);
		}
		return gesturename;
	}

	/**
	 * This method initializes testbutton	
	 * 	
	 * @return javax.swing.JButton	
	 */
	private JButton getTestbutton() {
		if (testbutton == null) {
			testbutton = new JButton();
			testbutton.setBounds(new Rectangle(392, 450, 113, 29));
			testbutton.setText("Test Signal");
			testbutton.addActionListener(buttonListener);
		}
		return testbutton;
	}

	/**
	 * This method initializes addbutton	
	 * 	
	 * @return javax.swing.JButton	
	 */
	private JButton getAddbutton() {
		if (addbutton == null) {
			addbutton = new JButton();
			addbutton.setBounds(new Rectangle(627, 274, 111, 29));
			addbutton.setText("Paste gesture");
			addbutton.addActionListener(buttonListener);
		}
		return addbutton;
	}

	/**
	 * This method initializes removebutton	
	 * 	
	 * @return javax.swing.JButton	
	 */
	private JButton getRemovebutton() {
		if (removebutton == null) {
			removebutton = new JButton();
			removebutton.setBounds(new Rectangle(392, 274, 129, 29));
			removebutton.setText("Remove gesture");
			removebutton.addActionListener(buttonListener);
		}
		return removebutton;
	}

	/**
	 * This method initializes sharebutton	
	 * 	
	 * @return javax.swing.JButton	
	 */
	private JButton getSharebutton() {
		if (sharebutton == null) {
			sharebutton = new JButton();
			sharebutton.setBounds(new Rectangle(517, 274, 113, 29));
			sharebutton.setActionCommand("Share gesture");
			sharebutton.setText("Share gesture");
			sharebutton.addActionListener(buttonListener);
		}
		return sharebutton;
	}

	/**
	 * This method initializes midicc	
	 * 	
	 * @return javax.swing.JTextField	
	 */
	private JTextField getMidicc() {
		if (midicc == null) {
			midicc = new JTextField();
			midicc.setBounds(new Rectangle(480, 409, 68, 28));
			midicc.addKeyListener(this);
		}
		return midicc;
	}

	/**
	 * This method initializes oscstring	
	 * 	
	 * @return javax.swing.JTextField	
	 */
	private JTextField getOscstring() {
		if (oscstring == null) {
			oscstring = new JTextField();
			oscstring.setBounds(new Rectangle(480, 409, 146, 28));
			oscstring.setVisible(false);
			oscstring.addKeyListener(this);
		}
		return oscstring;
	}

	private Graph getGraph() {
		if(graph == null){
			this.graph = new Graph();
			this.graph.setSize(294, 156);
			this.graph.setBounds(49, 24, 294, 156);
		}
		return graph;
	}

	/**
	 * This is the default constructor
	 */
	public Frontend2(Wiimote wiimote) {
		initialize();
		this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
		this.wiimote = wiimote;
		this.astra = wiimote.getAccelerationStreamAnalyzer();
		System.out.println(System.getProperty("os.name"));
		this.setResizable(false);
		this.addWindowListener(new WindowAdapter() {
			public void windowClosing(WindowEvent e) {
				((Frontend2)e.getSource()).getWiimote().disconnect();
				midiIO.dispose();
				System.exit(0);
			}
		});
		
		sunit = new SaveUnit();

		wiimote.addWiimoteListener(sunit);

		// Vektorfeld für Gesten initialisieren
		for (int i = 0; i < this.gestures.length; i++) {
			for (int j = 0; j < this.gestures[i].length; j++) {
				this.gestures[i][j] = new Vector<WiimoteAccelerationEvent>();
			}
		}
		
		midiIO = MidiIO.getInstance(this);
		midiIO.printOutputDevices();
		setMidiSettings(midideviceselect,midichannelselect);
		setOscSettings(oscipaddress,oscportint);

	} // EINDE DEFAULT CONSTRUCTOR

	/**
	 * This method initializes this
	 * 
	 * @return void
	 */
	private void initialize() {
		this.setSize(800, 555);
		this.setContentPane(getJContentPane());
		this.setTitle("Wiimote Gesturing App");
		this.setResizable(false);
		this.setVisible(true);
	} // INITIALIZE SPREEKT CONTENTPANE AAN VOOR LADEN GUI

	/**
	 * This method initializes jContentPane
	 * 
	 * @return javax.swing.JPanel
	 */
	private JPanel getJContentPane() {
		if (jContentPane == null) {
			midivaluelabel = new JLabel();
			midivaluelabel.setBounds(new Rectangle(560, 415, 72, 16));
			midivaluelabel.setText("MIDI Value:");
			legenda = new JLabel();
			legenda.setBounds(new Rectangle(49, 256, 294, 249));
			legenda.setOpaque(true);
			legenda.setBackground(new Color(240, 240, 240));
			legenda.setHorizontalAlignment(SwingConstants.CENTER);
			legenda.setText("<html>Press the A button on your Wii Remote<br>to record and train a new gesture.<br><br>After training the gesture about 15 times," +
					"<br>finalize the gesture by pressing the Home<br>button.<br><br>You can then do gesture recognition by<br>pressing the B button." +
					"<br><br>If a gesture gets recognized, the Wii<br>Remote will vibrate and the program will<br>send out the OSC or MIDI signal specified.</html>");
			oscstringlabel = new JLabel();
			oscstringlabel.setBounds(new Rectangle(399, 415, 75, 16));
			oscstringlabel.setText("OSC Args:");
			oscstringlabel.setVisible(false);
			midicclabel = new JLabel();
			midicclabel.setBounds(new Rectangle(399, 415, 65, 16));
			midicclabel.setText("Midi CC#:");
			status = new JLabel();
			status.setBounds(new Rectangle(49, 196, 293, 45));
			status.setOpaque(true);
			status.setBackground(new Color(171, 255, 139));
			status.setFont(new Font("Lucida Grande", Font.PLAIN, 12));
			status.setText("Status...");
			gesturenamelabel = new JLabel();
			gesturenamelabel.setBounds(new Rectangle(399, 340, 96, 16));
			gesturenamelabel.setText("Gesture name:");
			jContentPane = new JPanel();
			jContentPane.setLayout(null);
			jContentPane.setFont(new Font("Lucida Grande", Font.BOLD, 14));
			jContentPane.add(getJScrollPane(), null);
			jContentPane.add(getMidiselector(), null);
			jContentPane.add(getOscselector(), null);
			jContentPane.add(getGesturename(), null);
			jContentPane.add(gesturenamelabel, null);
			jContentPane.add(getTestbutton(), null);
			jContentPane.add(status, null);
			jContentPane.add(getAddbutton(), null);
			jContentPane.add(getRemovebutton(), null);
			jContentPane.add(getSharebutton(), null);
			jContentPane.add(getMidicc(), null);
			jContentPane.add(midicclabel, null);
			jContentPane.add(oscstringlabel, null);
			jContentPane.add(getOscstring(), null);
			jContentPane.add(legenda, null);
			jContentPane.add(getSettings(), null);
			jContentPane.add(midivaluelabel, null);
			jContentPane.add(getMidivalue(), null);
			jContentPane.add(getGraph(),null);
			settingsVisible(false);
		}
		return jContentPane;
	} // EINDE getJContentPane
	
	
	
	//METHODS VAN DE DEMO APP:
	
	public void accelerationReceived(WiimoteAccelerationEvent event) {
		
		this.graph.addAcceleration(event.getX(), event.getY(), event.getZ());
	}

	public void buttonPressReceived(WiimoteButtonPressedEvent event) {
		/*int button = event.getButton();
		switch (button) {
		case Wiimote.BUTTON_2:
			System.out.println("2-Button pressed");
			this.buttonstate.changeState(event);
			break;
		case Wiimote.BUTTON_1:
			System.out.println("1-Button pressed");
			break;
		case Wiimote.BUTTON_B:
			System.out.println("B-Button pressed");
			this.buttonstate.changeState(event);
			break;
		case Wiimote.BUTTON_A:
			System.out.println("A-Button pressed");
			this.buttonstate.changeState(event);
			break;
		case Wiimote.BUTTON_MINUS:
			System.out.println("MINUS-Button pressed");
			break;
		case Wiimote.BUTTON_HOME:
			System.out.println("HOME-Button pressed");
			this.buttonstate.changeState(event);
			this.console.append("Recording done...\n");
			this.console.setCaretPosition(this.console.getDocument().getLength());
			this.counter = 0;
			break;
		case Wiimote.BUTTON_LEFT:
			System.out.println("STEUERKREUZ LINKS-Button pressed");
			break;

		
		}*/
	}

	public void buttonReleaseReceived(WiimoteButtonReleasedEvent event) {
		//this.buttonstate.changeState(event);
		System.out.println("Button released");
	}
	

	public void motionStartReceived(WiimoteMotionStartEvent event) {
		//this.console.append("Motion starts\n");
		//this.console.setCaretPosition(this.console.getDocument().getLength());
	}
	
	public void motionStopReceived(WiimoteMotionStopEvent event) {
		//this.console.append("Motion stops\n");
		//this.console.setCaretPosition(this.console.getDocument().getLength());
	}

	public void gestureReceived(GestureEvent event) {
		
		if(!this.gesturenames.containsKey(event.getId())) {
			this.status.setText("Unknown gesture.");
			//this.console.append("Unknown gesture.\n");
			//this.console.setCaretPosition(this.console.getDocument().getLength());
			//@SuppressWarnings("unused")
			//InfoPopup info = new InfoPopup(this, event.getId());
			addNewGesture("Unknown Gesture", event.getId());
			vibrateWiimote(100);
		} else {
			if(!disabled.get(event.getId())){
				this.status.setText("Gesture " + this.gesturenames.get(event.getId()) + " recognized: "
					+ Math.round(event.getProbability() * 100) + "%.");
				if(midiosc.get(event.getId()) == true){
					sendMIDImessage(midiccarray.get(event.getId()),midivaluearray.get(event.getId()));
				} else {
					sendOSCmessage(oscargarray.get(event.getId()));
				}
				vibrateWiimote(100);
			} else {
				this.status.setText("Removed Gesture detected");
				this.status.setBackground(new Color(255, 0, 0));
			}
		}
	} // einde gestureReceived

	// }

	public void stateReceived(StateEvent event) {
		int state = event.getState();
		if (state == 0) { // no gesture recognised
			this.status.setText("Unknown gesture!");
			this.status.setBackground(new Color(255, 0, 0));
//			this.console.append("Unknown gesture!\n");
//			this.console.setCaretPosition(this.console.getDocument().getLength());
		} else if (state == 1) { // learning
			if(this.counter!=0) {
			this.status.setText("Recording gesture...");
			this.status.setBackground(new Color(255, 255, 0));
//			this.console.append("Recording gesture... " + (this.counter++) + "\n");
//			this.console.setCaretPosition(this.console.getDocument().getLength());
			} else {
				this.counter++;
			}
		} else if (state == 2) { // recognizing
			this.status.setText("Recognizing gesture...");
			this.status.setBackground(new Color(0, 200, 0));
//			this.console.append("Recognizing gesture... ");
//			this.console.setCaretPosition(this.console.getDocument().getLength());
		}

	}

	public void setGestureName(String name) {
		this.gesturenames.put(this.gesturenames.size(), name);
		addToGestureList(name);
	}
	


	public Wiimote getWiimote() {
		return this.wiimote;
	}
	
	public String[] parseStringAsArray(String input){
		String[] returnstring = input.split("\n");
		
		return returnstring;
	}

	public void loadGestureFromString(String gesturearray, String gesturename) {
		String[] datastring = parseStringAsArray(gesturearray);
		int i = 0;
		while (i < datastring.length) {
			//System.out.println(datastring[i]);
			if (datastring[i].contains(",") && this.lastpressed == Wiimote.BUTTON_A)  { // Beschleunigung
				String[] arr = datastring[i].split(",");
				double x = Double.parseDouble(arr[0]);
				//System.out.println(x);
				double y = Double.parseDouble(arr[1]);
				double z = Double.parseDouble(arr[2]);
				double absvalue = Math.sqrt((x*x)+(y*y)+(z*z));

				if (this.gestures[this.index_gesture][this.index_gestures].size()==0) {
					this.gestures[this.index_gesture][this.index_gestures] = new Vector<WiimoteAccelerationEvent>();
				}

				this.gestures[this.index_gesture][this.index_gestures]
						.add(new WiimoteAccelerationEvent(
								this.wiimote, x, y, z, absvalue));
				this.wiimote.fireAccelerationEvent(x, y, z, absvalue);
				
			} else if(datastring[i].contains(",") && this.lastpressed == Wiimote.BUTTON_B) {
				String[] arr = datastring[i].split(",");
				double x = Double.parseDouble(arr[0]);
				double y = Double.parseDouble(arr[1]);
				double z = Double.parseDouble(arr[2]);
				this.wiimote.fireAccelerationEvent(x, y, z, 0);							
			} else if (datastring[i].contains("pressed")) { 
				String[] arr = datastring[i].split(" ");
				int number = Integer.parseInt(arr[1]);
				this.lastpressed = number;
				this.wiimote.fireButtonPressedEvent(number);
			} else if (datastring[i].contains("released")) { 
				if (this.lastpressed == Wiimote.BUTTON_A) {
					this.index_gestures++;
					/*System.out.println("index-gestures: "
							+ this.index_gestures);*/
				}
				if (this.lastpressed == Wiimote.BUTTON_HOME) {
					this.index_gesture++;
					this.index_gestures = 0;
					/*System.out.println("index-gesture: "
							+ this.index_gesture);*/
					addNewGesture(gesturename, this.index_gesture-1);
				}
				this.lastpressed = -1;
				this.wiimote.fireButtonReleasedEvent();							
			}
			i++;
		}
	}
	

	public void infraredReceived(InfraredEvent event) {
		//this.irpopup.setIRPoints(event);
	}

	/**
	 * This method initializes gesturelist	
	 * 	
	 * @return javax.swing.JList	
	 */
	private JList getGesturelist() {
		if (gesturelist == null) {
			gesturelist = new JList(lijstmodel);
			gesturelist.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
			gesturelist.addListSelectionListener(listSelectionListener);
		}
		return gesturelist;
	}
	
	public void addToGestureList(String gesturename) {
		lijstmodel.addElement(gesturename);
	}
	
	private void switchToMidi() {
		oscstringlabel.setVisible(false);
		oscstring.setVisible(false);
		
		midicc.setVisible(true);
		midicclabel.setVisible(true);
		midivalue.setVisible(true);
		midivaluelabel.setVisible(true);
		
		midiselected = true;
	}
	
	private void switchToOSC() {
		oscstringlabel.setVisible(true);
		oscstring.setVisible(true);
		
		midicc.setVisible(false);
		midicclabel.setVisible(false);
		midivalue.setVisible(false);
		midivaluelabel.setVisible(false);
		
		midiselected = false;
	}
	
	private void sendOSCmessage(Integer arguments){
		
			Object args[] = new Object[1];
			args[0] = new Integer(arguments);
			OSCMessage msg = new OSCMessage("/gesture", args);
			 try {
				oscsender.send(msg);
			 } catch (Exception e) {
						System.out.println("Failed to send OSC message.");
						e.printStackTrace();		
			 }
			 //oscsender.close();
	}

	
	
	private void sendMIDImessage(Integer controllernr, Integer valuenr){
		System.out.println("sending MIDI message...");
		midiOut.sendController(new Controller(controllernr,valuenr));
	}
	
	private void sendTestSignal() {
		if(midiselected){
			sendMIDImessage(midiccarray.get(selectedgesture), midivaluearray.get(selectedgesture));
		}
		else {
			sendOSCmessage(oscargarray.get(selectedgesture));
		}
	}
	
	void vibrateWiimote(long time){
		try {
			wiimote.vibrateForTime(time);
		} catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	private void midiOscSettings() {
		//System.out.println("MIDI & OSC Settings");
		@SuppressWarnings("unused")
		SettingsPopup settingspopup = new SettingsPopup(this);
	}
	
	private void addGesture(){
		//System.out.println("Add Gesture...");
		@SuppressWarnings("unused")
		AddPopup addpopup = new AddPopup(this);
	}
	
	private void removeGesture(){
		if(selectedgesture != -1){
			//System.out.println("Remove Gesture...");
			if(lijstmodel.size()>1){
				if(selectedgesture>0){
					listSelected(selectedgesture-1);
					lijstmodel.remove(selectedgesture+1);
					disabled.set(selectedgesture+1, true);
				} else {
					listSelected(selectedgesture+1);
					lijstmodel.remove(selectedgesture-1);
					disabled.set(selectedgesture-1, true);
				}
			}else{
				settingsVisible(false);
				lijstmodel.remove(selectedgesture);
				disabled.set(selectedgesture, true);
			}
			
			if(lijstmodel.size() == 0){
				selectedgesture = -1;
			}
		}
	}
	
	private void shareGesture() {
		if(selectedgesture != -1){
			//System.out.println("Share Gesture...");
			@SuppressWarnings("unused")
			SharePopup sharing = new SharePopup(gesturetextfilearray.get(selectedgesture));
		}
	}
	
	private void settingsVisible(Boolean visible){ 
			gesturename.setVisible(visible);
			midicc.setVisible(visible);
			midivalue.setVisible(visible);
			midivaluelabel.setVisible(visible);
			oscstring.setVisible(visible);
			midiselector.setVisible(visible);
			oscselector.setVisible(visible);
			gesturenamelabel.setVisible(visible);
			testbutton.setVisible(visible);
			oscstringlabel.setVisible(visible);
			midicclabel.setVisible(visible);
	}
	
	public void keyPressed(KeyEvent e) {
		if(e.getKeyCode() == KeyEvent.VK_ENTER) {
			this.setValues();
		}
		
	}
	
	public void keyReleased(KeyEvent e) {

		
	}

	public void keyTyped(KeyEvent e) {

		
	}
	
	public void setValues() {
		String text = gesturename.getText();
		lijstmodel.set(selectedgesture,text);
		gesturenames.put(selectedgesture, text);
		text = midicc.getText();
		midiccarray.set(selectedgesture, Integer.valueOf(text).intValue());
		text = midivalue.getText();
		midivaluearray.set(selectedgesture, Integer.valueOf(text).intValue());
		text = oscstring.getText();
		oscargarray.set(selectedgesture, Integer.valueOf(text).intValue());
	}
	
	public Vector getMidiDevices() {
		Integer numberofdevices = midiIO.numberOfOutputDevices();
		
		Vector devicenames = new Vector();
		
		for (int i = 0; i < numberofdevices; i = i + 1){
			String singledevicename = midiIO.getOutputDeviceName(i);
			devicenames.add(singledevicename);
		}
		
		return devicenames;
	}
	
	private Integer getGestureListIndex(String name){
		Integer index = 0;
		Boolean succes = false;
		for(int i=0; i<gesturenames.size(); i++){
			if(gesturenames.get(i) != null){
				if(gesturenames.get(i).equals(name)){
					index = i;
					succes = true;
					break;
				}
			}
		}
		if(!succes==true){
			index = -1;
		}
		return index;
	}
	
	private void listSelected(int selection) {
		for(int i=0; i<gesturenames.size(); i++){
			if(gesturenames.get(i) != null){
				if(gesturenames.get(i).equals(lijstmodel.get(selection))){
					selection = i;
				}
			}
		}
		selectedgesture = selection;
		//System.out.println("List item " + (selection+1) + " selected.");
		gesturename.setText(gesturenames.get(selection));
		midicc.setText(midiccarray.get(selection).toString());
		midivalue.setText(midivaluearray.get(selection).toString());
		oscstring.setText(oscargarray.get(selection).toString());
		if(midiosc.get(selection).equals(true)){
			midiselector.setSelected(true);
			oscselector.setSelected(false);
			switchToMidi();
		}
		else {
			midiselector.setSelected(false);
			oscselector.setSelected(true);
			switchToOSC();
		}
	}
	
	ActionListener buttonListener = new ActionListener() {
        public void actionPerformed (ActionEvent e) {
        	//System.out.println(e.getActionCommand());
           if(e.getActionCommand().equals("setOscButton()")){
        	   //System.out.println("OSC button pressed");  //  @jve:decl-index=0:
        	   
        	   Boolean midiosctest = false;
        	   midiosc.set(selectedgesture, midiosctest);
        	   switchToOSC();
           }
           else if (e.getActionCommand().equals("setMidiButton()")){
        	   //System.out.println("MIDI button pressed");
        	   Boolean midiosctest = true;
        	   midiosc.set(selectedgesture, midiosctest);
        	   switchToMidi();
           }
           else if(e.getActionCommand().equals("Test Signal")){
        	   sendTestSignal();
           }
           else if(e.getActionCommand().equals("MIDI & OSC settings...")){
        	   //System.out.println("MIDI & OSC settings pressed...");
        	   midiOscSettings();
           }
           else if(e.getActionCommand().equals("Paste gesture")){
        	   addGesture();
           }
           else if(e.getActionCommand().equals("Remove gesture")){
        	   removeGesture();
           }
           else if(e.getActionCommand().equals("Share gesture")) {
        	   shareGesture();
           }
        };
     };
     

	/**
	 * This method initializes settings	
	 * 	
	 * @return javax.swing.JButton	
	 */
	private JButton getSettings() {
		if (settings == null) {
			settings = new JButton();
			settings.setBounds(new Rectangle(392, 480, 181, 29));
			settings.setText("MIDI & OSC settings...");
			settings.addActionListener(buttonListener);
		}
		return settings;
	}
     
	ListSelectionListener listSelectionListener = new ListSelectionListener() {
	      public void valueChanged(ListSelectionEvent listSelectionEvent) {
	        boolean adjust = listSelectionEvent.getValueIsAdjusting();
	        if (adjust) {
	          JList list = (JList) listSelectionEvent.getSource();
	          int selections = list.getSelectedIndex();
	          //Object selectionValues = list.getSelectedValue();
	          listSelected(selections);
	        }
	      }
	    };
	private JLabel midivaluelabel = null;
	private JTextField midivalue = null;
	public void addNewGesture(String text, Integer index) {
		setGestureName(text);
		Boolean midiosctest = true;
		midiosc.add(index, midiosctest);
		Integer initialnumber = 0;
		midiccarray.add(index, initialnumber);
		midivaluearray.add(index, 127);
		oscargarray.add(index, initialnumber);
		gesturelist.setSelectedIndex(getGestureListIndex(text));//TODO HIERE zit de fout
		gesturetextfilearray.add(index, sunit.getCounter());
		disabled.add(index, false);
		sunit.nextFile();
		settingsVisible(true);
		listSelected(getGestureListIndex(text));
	}
	
	public void setMidiSettings(Integer device, Integer channel) {
		midideviceselect = device;
		midichannelselect = channel;
		midiOut = midiIO.getMidiOut(channel,device);
	}
	
	public void setOscSettings(String ipaddress, Integer port){
		try{
			oscipaddress = ipaddress;
			oscportint = port;
			oscaddress = InetAddress.getByName(ipaddress);
			oscsender = new OSCPortOut(oscaddress,port);
		}
		catch (Exception e) {
			System.out.println("Failed to instantiate OSCPortOut.");
			e.printStackTrace();
		}
	}
	
	public Integer getMidiChannelSettings() {
		Integer channel = midichannelselect;
		return channel;
	}
	
	public Integer getMidiInterfaceSettings() {
		Integer device = midideviceselect;
		return device;
	}
	
	public Integer getOscPortSettings(){
		Integer oscport = oscportint;
		return oscport;
	}
	
	public String getOscIpAddress(){
		String ipaddress = oscipaddress;
		return ipaddress;
	}

	/**
	 * This method initializes midivalue	
	 * 	
	 * @return javax.swing.JTextField	
	 */
	private JTextField getMidivalue() {
		if (midivalue == null) {
			midivalue = new JTextField();
			midivalue.setBounds(new Rectangle(648, 409, 68, 28));
			midivalue.addKeyListener(this);
		}
		return midivalue;
	}
	    
}  //  @jve:decl-index=0:visual-constraint="10,10"
