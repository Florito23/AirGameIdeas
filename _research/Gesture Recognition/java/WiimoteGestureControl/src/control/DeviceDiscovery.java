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
import java.util.Vector;

import javax.bluetooth.DeviceClass;
import javax.bluetooth.DiscoveryListener;
import javax.bluetooth.RemoteDevice;
import javax.bluetooth.ServiceRecord;

import device.Wiimote;

public class DeviceDiscovery implements DiscoveryListener {

	private Vector<RemoteDevice> devices;
	private boolean isInquiring;

	public DeviceDiscovery() {
		super();
		this.devices = new Vector<RemoteDevice>();
		this.isInquiring=true;
	}

	public void deviceDiscovered(RemoteDevice newdevice, DeviceClass devclass) {
		System.out.print("Device discovered: "
				+ newdevice.getBluetoothAddress() + " - ");
		// add the device to the vector
		if (!devices.contains(newdevice)
				&& devclass.getMajorDeviceClass() == 1280
				&& devclass.getMinorDeviceClass() == 4) {
			System.out.println("Is a Wiimote!");
			devices.addElement(newdevice);
		} else {
			System.out.println("Is NOT a Wiimote!");
		}
	}

	public void inquiryCompleted(int discType) {
		switch (discType) {
		case DeviceDiscovery.INQUIRY_COMPLETED:
			System.out.println("Inquiry completed.");
			break;

		case DeviceDiscovery.INQUIRY_ERROR:
			System.out.println("Inquiry error.");
			break;

		case DeviceDiscovery.INQUIRY_TERMINATED:
			System.out.println("Inquiry terminated.");
			break;
		}
		this.isInquiring=false;
	}

	public void serviceSearchCompleted(int arg0, int arg1) {
		// not necessary
	}

	public void servicesDiscovered(int arg0, ServiceRecord[] arg1) {
		// not necessary
	}

	public boolean isInquirying() {
		return this.isInquiring;
	}
	
	public Wiimote[] getDiscoveredWiimotes() throws IOException {
		Wiimote[] wiimotes = new Wiimote[devices.size()];

		for (int i = 0; i < devices.size(); i++) {
			wiimotes[i] = new Wiimote(devices.elementAt(i).getBluetoothAddress());
		}

		return wiimotes;
	}

}
