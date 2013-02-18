/*

Disclaimer:

--Wiimote Gesturing MIDI & OSC application--

--By Wout Standaert--
--As part of his masters thesis Communication & MultimediaDesign--

--http://www.blobkat.com
--http://www.blobkat.com/blog



This application was originally modded from the WiiGee Demo application. It has the WiiGee Wii Remote gesturing library and an adjusted version of the proMIDI library included as source code. This was to change certain things inside of these libraries.


 * This application is free software; you can redistribute it and/or modify
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
import control.Wiigee;
import device.Wiimote;
import gui.Frontend2;

public class wiigeemain {
	
	public static void main(String[] args) {
		
		System.setProperty("bluecove.jsr82.psm_minimum_off", "true");

		
		try {
	        
			Wiigee wiigee = Wiigee.getInstance();
			
			wiigee.setTrainButton(Wiimote.BUTTON_A);
			wiigee.setRecognitionButton(Wiimote.BUTTON_B);
			wiigee.setCloseGestureButton(Wiimote.BUTTON_HOME);
			
			
			Wiimote[] wiimotes = wiigee.getWiimotes();
			
			
			Frontend2 frontend = new Frontend2(wiimotes[0]);
			
			wiigee.addWiimoteListener(frontend);
			wiigee.addGestureListener(frontend);

			
		} catch(Exception e) {
			System.out.print("main() Exception: ");
			e.printStackTrace();
		}
	}

}