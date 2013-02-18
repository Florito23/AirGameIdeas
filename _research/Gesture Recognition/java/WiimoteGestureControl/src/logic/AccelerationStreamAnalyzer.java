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

package logic;

import java.util.Vector;
import event.*;

/**
 * This class analyzes the WiimoteAccelerationEvents emitted from a Wiimote
 * and further creates and manages the different models for each type
 * of gesture. 
 * 
 * @author Benjamin 'BePo' Poppinga
 */
public class AccelerationStreamAnalyzer implements WiimoteListener {
	
	// Listener
	Vector<GestureListener> listen = new Vector<GestureListener>();
	
	// tolerance for directional equivalence filter
	double accepttolerance=0.2;
	
	// gesturespecific values
	private Gesture current; // current gesture
	private double maxacc;
	private double minacc;
	Vector<GestureModel> gesturemodel; // each gesturetype got its own 
									// gesturemodel in this vector
	
	Vector<Gesture> trainsequence;
	
	// State variables
	private boolean learning, analyzing;
	
	public AccelerationStreamAnalyzer() {
		this.maxacc=Double.MIN_VALUE;
		this.minacc=Double.MAX_VALUE;
		this.learning=false;
		this.analyzing=false;
		this.current=new Gesture();
		this.gesturemodel=new Vector<GestureModel>();
		this.trainsequence=new Vector<Gesture>();
	}

	/** 
	 * Since this class implements the WiimoteListener this procedure is
	 * necessary. It contains the filtering (directional equivalence filter)
	 * and adds the incoming data to the current motion, we want to train
	 * or recognize.
	 * 
	 * @param event The acceleration event which has to be processed by the
	 * directional equivalence filter and which has to be added to the current
	 * motion in recognition or training process.
	 */
	public void accelerationReceived(WiimoteAccelerationEvent event) {
		if(this.learning || this.analyzing) {
			if(this.current.getCountOfData()>0) {
				// directional equivalence filter
				WiimoteAccelerationEvent ref = this.current.getLastData();
				if(event.getX()<ref.getX()-accepttolerance ||
				   event.getX()>ref.getX()+accepttolerance ||
				   event.getY()<ref.getY()-accepttolerance ||
				   event.getY()>ref.getY()+accepttolerance ||
				   event.getZ()<ref.getZ()-accepttolerance ||
				   event.getZ()>ref.getZ()+accepttolerance) {
				this.current.add(event); // add event to gesture
				}
			} else {
				// new gesture, nothing to do for directional equivalence filter
				this.maxacc=Double.MIN_VALUE;
				this.minacc=Double.MAX_VALUE;
				this.current.add(event);
			}
			
			// (re)calculate max acceleration			
			if(Math.abs(event.getX()) > this.maxacc) {
				this.maxacc=Math.abs(event.getX());
				this.current.setMaxAcceleration(this.maxacc);
			}
			if(Math.abs(event.getY()) > this.maxacc) {
				this.maxacc=Math.abs(event.getY());
				this.current.setMaxAcceleration(this.maxacc);
			}
			if(Math.abs(event.getZ()) > this.maxacc) {
				this.maxacc=Math.abs(event.getZ());
				this.current.setMaxAcceleration(this.maxacc);
			}
			
			// (re)calculate min acceleration
			if(Math.abs(event.getX()) < this.minacc) {
				this.minacc=Math.abs(event.getX());
				this.current.setMinAcceleration(this.minacc);
			}
			if(Math.abs(event.getY()) < this.minacc) {
				this.minacc=Math.abs(event.getY());
				this.current.setMinAcceleration(this.minacc);
			}
			if(Math.abs(event.getZ()) < this.minacc) {
				this.minacc=Math.abs(event.getZ());
				this.current.setMinAcceleration(this.minacc);
			}
		}
		
	}

	/** 
	 * This method is from the WiimoteListener interface. A button press
	 * is used to control the data flow inside the structures. 
	 * 
	 */
	public void buttonPressReceived(WiimoteButtonPressedEvent event) {
		this.handleStartEvent(event);
	}

	public void buttonReleaseReceived(WiimoteButtonReleasedEvent event) {
		this.handleStopEvent(event);
	}
	
	public void motionStartReceived(WiimoteMotionStartEvent event) {
		this.handleStartEvent(event);
	}
	
	public void motionStopReceived(WiimoteMotionStopEvent event) {
		this.handleStopEvent(event);
	}
	
	public void handleStartEvent(ActionStartEvent event) {
		
		// TrainButton = record a gesture for learning
		if((!this.analyzing && !this.learning) && 
			event.isTrainInitEvent()) {
			System.out.println("Training started!");
			this.learning=true;
			this.fireStateEvent(1);
		}
		
		// RecognitionButton = record a gesture for recognition
		if((!this.analyzing && !this.learning) && 
			event.isRecognitionInitEvent()) {
			System.out.println("Recognition started!");
			this.analyzing=true;
			this.fireStateEvent(2);
		}
			
		// CloseGestureButton = starts the training of the model with multiple
		// recognized gestures, contained in trainsequence
		if((!this.analyzing && !this.learning) && 
			event.isCloseGestureInitEvent()) {
		
			if(this.trainsequence.size()>0) {
				System.out.println("Training the model with "+this.trainsequence.size()+" gestures...");
				this.fireStateEvent(1);
				this.learning=true;
				
				gesturemodel.add(new GestureModel(gesturemodel.size()));
				this.gesturemodel.lastElement().train(this.trainsequence);
				// this.gesturemodel.lastElement().printMap(); // debug purpos.
				this.trainsequence=new Vector<Gesture>();
				
				this.learning=false;
			} else {
				System.out.println("There is nothing to do. Please record some gestures first.");
			}
		}
	}
	
	public void handleStopEvent(ActionStopEvent event) {
		if(this.learning) { // button release and state=learning, stops learning
			if(this.current.getCountOfData()>0) {
				System.out.println("Finished recording (training)...");
				System.out.println("Data: "+this.current.getCountOfData());
				Gesture gesture = new Gesture(this.current);
				this.trainsequence.add(gesture);
				this.current=new Gesture();
				this.learning=false;
			} else {
				System.out.println("There is no data.");
				System.out.println("Please train the gesture again.");
				this.learning=false; // ?
			}
		}
		
		else if(this.analyzing) { // button release and state=analyzing, stops analyzing
			if(this.current.getCountOfData()>0) {
				System.out.println("Finished recording (recognition)...");
				System.out.println("Compare gesture with "+this.gesturemodel.size()+" other gestures.");
				Gesture gesture = new Gesture(this.current);
				this.analyze(gesture);
				this.current=new Gesture();
				this.analyzing=false;
			} else {
				System.out.println("There is no data.");
				System.out.println("Please recognize the gesture again.");
				this.analyzing=false; // ?
			}
		}
	}
	
	/** 
	 * This method recognize a specific gesture, given to the procedure.
	 * For classification a bayes classification algorithm is used.
	 * 
	 * @param g	gesture to recognize
	 */
	public void analyze(Gesture g) {
		System.out.println("Recognizing gesture...");
		
		// Wert im Nenner berechnen, nach Bayes
		double sum = 0;
		for(int i=0; i<this.gesturemodel.size(); i++) {
			sum+=this.gesturemodel.elementAt(i).getDefaultProbability()*
					this.gesturemodel.elementAt(i).matches(g);
		}
		
		int recognized = -1; // which gesture has been recognized
		double recogprob = Integer.MIN_VALUE; // probability of this gesture
		double probgesture = 0; // temporal value for bayes algorithm
		double probmodel = 0; // temporal value for bayes algorithm
		for(int i=0; i<this.gesturemodel.size(); i++) {
			double tmpgesture = this.gesturemodel.elementAt(i).matches(g);
			double tmpmodel = this.gesturemodel.elementAt(i).getDefaultProbability();
			
			if(((tmpmodel*tmpgesture)/sum)>recogprob) {
				probgesture=tmpgesture;
				probmodel=tmpmodel;
				recogprob=((tmpmodel*tmpgesture)/sum);
				recognized=i;
			}
		}
		
		// a gesture could be recognized
		if(recogprob>0 && probmodel>0 && probgesture>0 && sum>0) {
			this.fireGestureEvent(recognized, recogprob);
			System.out.println("######");
			System.out.println("Gesture No. "+recognized+" recognized: "+recogprob);
			System.out.println("######");
		} else {
			// no gesture could be recognized
			this.fireStateEvent(0);
			System.out.println("######");
			System.out.println("No gesture recognized.");
			System.out.println("######");
		}
		
	}
	
	/**
	 * Resets the complete gesturemodel. After reset no gesture is known
	 * to the system.
	 */
	public void reset() {
		if(this.gesturemodel.size()>0) {
			this.gesturemodel.clear();
			System.out.println("### Model reset ###");
		} else {
			System.out.println("There doesn't exist any data to reset.");
		}
	}
	
	/** 
	 * Add an GestureListener to receive Gesture/StateEvents.
	 * 
	 * @param g
	 * 	Class which implements GestureListener interface
	 */
	public void addGestureListener(GestureListener g) {
		this.listen.add(g);
	}
	
	private void fireGestureEvent(int id, double probability) {
		GestureEvent w = new GestureEvent(this, id, probability);
		for(int i=0; i<this.listen.size(); i++) {
			this.listen.get(i).gestureReceived(w);
		}
	}
	
	private void fireStateEvent(int state) {
		StateEvent w = new StateEvent(this, state);
		for(int i=0; i<this.listen.size(); i++) {
			this.listen.get(i).stateReceived(w);
		}
	}

	public void infraredReceived(InfraredEvent event) {
		// TODO Auto-generated method stub
		
	}

	
	

}
