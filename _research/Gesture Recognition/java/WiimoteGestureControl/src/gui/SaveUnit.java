package gui;


import java.io.File;
import java.io.FileWriter;
import java.io.BufferedWriter;
import event.*;

public class SaveUnit implements WiimoteListener {

	int counter;
	File file;
	FileWriter fw;
	BufferedWriter bw;

	public SaveUnit() {
		int i=0;
		while(new File(i+".txt").exists()) {
			i++;
		}
		
		this.counter = i;
		this.init();		
	}

	public void init() {
		try {			
			file = new File(this.counter + ".txt");
			fw = new FileWriter(file);
			bw = new BufferedWriter(fw);
		} catch (Exception e) {
			System.out.println("FILE: Datei schreiben fehlgeschlagen.");
		}
	}
	
	public void nextFile() {
		try {
			bw.write("Button released");
			this.bw.flush();
			this.bw.close();
			this.fw.close();
			this.counter++;
			this.init();
		} catch (Exception e) {
			System.out.println("FILE: Datei schreiben fehlgeschlagen.");
		}
	}
	
	public void close() {
		try {
			this.bw.close();
			this.fw.close();
		} catch (Exception e) {
			System.out.println("FILE: Datei schreiben fehlgeschlagen.");
		}
	}
	
	public void accelerationReceived(WiimoteAccelerationEvent event) {
		try {
			double x = event.getX();
			double y = event.getY();
			double z = event.getZ();
			bw.write(x+","+y+","+z);
			bw.newLine();
		} catch(Exception e) {
			System.out.println("FILE: Datei schreiben fehlgeschlagen.");
		}
	}

	public void buttonPressReceived(WiimoteButtonPressedEvent event) {
		try {
			bw.write("Button "+event.getButton()+" pressed");
			bw.newLine();
		} catch(Exception e) {
			System.out.println("FILE: Datei schreiben fehlgeschlagen.");
		}
	}

	public void buttonReleaseReceived(WiimoteButtonReleasedEvent event) {
		try {
			bw.write("Button released");
			bw.newLine();
			bw.flush();
		} catch(Exception e) {
			System.out.println("FILE: Datei schreiben fehlgeschlagen.");
		}
	}

	public void motionStartReceived(WiimoteMotionStartEvent event) {
		// TODO Auto-generated method stub
		
	}

	public void motionStopReceived(WiimoteMotionStopEvent event) {
		// TODO Auto-generated method stub
		
	}

	public void infraredReceived(InfraredEvent event) {
		// TODO Auto-generated method stub
		
	}
	
	public Integer getCounter() {
		return this.counter;
	}
	

}
