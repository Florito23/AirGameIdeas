package gui;

import java.awt.Color;
import java.awt.Graphics;
import javax.swing.JPanel;

public class Graph extends JPanel {
	
	/**
	 * 
	 */
	private static final long serialVersionUID = 3007744550878548564L;
	int width=600;
	int height=500;
	int time=width+1;
	int lastx, lasty, lastz=(height/2)-1;
	int x, y, z;
	
	public void setSize(int width, int height) {
		this.width=width;
		this.height=height;
	}

	public final void paintComponent(Graphics graphics) {
		
		if(time>=width) {
			time=0;
			graphics.clearRect(0, 0, width, height);
			
			graphics.setColor(Color.WHITE);
			graphics.fillRect(0, 0, width, height);
			graphics.setColor(Color.BLACK);
			graphics.drawLine(0, (height/2)-1, width, (height/2)-1);
			
			// Legende anlegen
			graphics.setColor(Color.RED);
			graphics.drawString("X", 5, 13);
			graphics.setColor(Color.GREEN);
			graphics.drawString("Y", 100, 13);
			graphics.setColor(Color.BLUE);
			graphics.drawString("Z", 195, 13);
			
			
		} else {
			graphics.setColor(Color.RED);
			graphics.drawLine(time, lastx, time, x);
			graphics.setColor(Color.GREEN);
			graphics.drawLine(time, lasty, time, y);
			graphics.setColor(Color.BLUE);
			graphics.drawLine(time, lastz, time, z);
		}
		
	}
	
	
	public void addAcceleration(double x, double y, double z) {
		this.lastx=this.x;
		this.lasty=this.y;
		this.lastz=this.z;
		// 5=maximalwert d. beschleunigung
		this.x=(int)(x/5*(height/2)-1)+(height/2)-1;
		this.y=(int)(y/5*(height/2)-1)+(height/2)-1;
		this.z=(int)(z/5*(height/2)-1)+(height/2)-1;
		time++;
		this.repaint();
		
	}
	
}
