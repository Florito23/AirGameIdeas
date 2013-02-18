/*
 * wiigee - accelerometerbased gesture recognition
 * Copyright (C) 2007, 2008 Benjamin Poppinga
 * 
 * Developed at University of Oldenburg
 * Contact: benjamin.poppinga@informatik.uni-oldenburg.de
 *
 * This file is part of wiigee.
 *
 * wiigee is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 * 
 * You should have received a copy of the GNU Lesser General Public License along
 * with this program; if not, write to the Free Software Foundation, Inc.,
 * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

package control;

import java.io.IOException;

import javax.bluetooth.DiscoveryAgent;
import javax.bluetooth.LocalDevice;

import device.Wiimote;
import event.GestureListener;
import event.WiimoteListener;

// Singleton
public class Wiigee {
	
	private static Wiigee instance;
	private Wiimote[] wiimotes;
	
	
	private Wiigee() throws IOException {
		this.wiimotes=this.discoverWiimotes();
		for(int i=0; i<this.wiimotes.length; i++) {
			this.wiimotes[i].setLED(i+1);
		}
	}
	
	public static Wiigee getInstance() throws IOException {
		if(instance==null) {
			instance=new Wiigee();
			return instance;
		} else {
			return instance;
		}
	}
	
	public void addWiimoteListener(WiimoteListener listener) {
		if(this.wiimotes.length>0) {
			this.wiimotes[0].addWiimoteListener(listener);
		}
	}
	
	public void addGestureListener(GestureListener listener) {
		if(this.wiimotes.length>0) {
			this.wiimotes[0].addGestureListener(listener);
		}
	}
	
	
	/**
	 * Returns an array of discovered wiimotes.
	 * 
	 * @return Array of discovered wiimotes or null if
	 * none discoverd.
	 */
	public Wiimote[] getWiimotes() {
		return this.wiimotes;
	}
	
	/**
	 * Returns the number of wiimotes discovered.
	 * 
	 * @return Number of wiimotes discovered.
	 */
	public int getNumberOfWiimotes() {
		return this.wiimotes.length;
	}
	
	/**
	 * Sets the Trainbutton for all wiimotes;
	 * 
	 * @param b Button encoding, see static Wiimote values
	 */
	public void setTrainButton(int b) {
		for(int i=0; i<this.wiimotes.length; i++) {
			this.wiimotes[i].setTrainButton(b);
		}
	}
	
	/**
	 * Sets the Recognitionbutton for all wiimotes;
	 * 
	 * @param b Button encoding, see static Wiimote values
	 */
	public void setRecognitionButton(int b) {
		for(int i=0; i<this.wiimotes.length; i++) {
			this.wiimotes[i].setRecognitionButton(b);
		}
	}
	
	/**
	 * Sets the CloseGesturebutton for all wiimotes;
	 * 
	 * @param b Button encoding, see static Wiimote values
	 */
	public void setCloseGestureButton(int b) {
		for(int i=0; i<this.wiimotes.length; i++) {
			this.wiimotes[i].setCloseGestureButton(b);
		}
	}
	
	/**
	 * With this method you gain access over the vibrate function of
	 * the wiimotes. You got to try which time in milliseconds would
	 * fit your requirements.
	 * 
	 * @param milliseconds
	 * 		time the wiimotes would vibrate
	 */
	public void vibrateForTime(long milliseconds) throws IOException {
		for(int i=0; i<this.wiimotes.length; i++) {
			this.wiimotes[i].vibrateForTime(milliseconds);
		}
	}
	
	
	/**
	 * Discover the wiimotes around the bluetooth host and
	 * make them available public via getWiimotes method.
	 * 
	 * @return Array of discovered wiimotes.
	 */
	private Wiimote[] discoverWiimotes() throws IOException {
			DeviceDiscovery deviceDiscovery = new DeviceDiscovery();
			LocalDevice localDevice = LocalDevice.getLocalDevice();
			System.out.println("My Bluetooth MAC: "+localDevice.getBluetoothAddress());
			
			DiscoveryAgent discoveryAgent = localDevice.getDiscoveryAgent();
			
			System.out.println("Starting device inquiry...");
			discoveryAgent.startInquiry(DiscoveryAgent.GIAC, deviceDiscovery);
			
			// i know this is bad from the view of an computer scientist...
			while(deviceDiscovery.isInquirying()) {
				try {
					Thread.sleep(1500);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}
			
			System.out.println("Device discovery completed!");			
			return deviceDiscovery.getDiscoveredWiimotes();
	}

}
