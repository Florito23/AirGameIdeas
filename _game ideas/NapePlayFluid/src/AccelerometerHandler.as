package  
{
	import flash.events.AccelerometerEvent;
	import flash.sensors.Accelerometer;
	
	/**
	 * ...
	 * @author 0L4F
	 */
	public class AccelerometerHandler 
	{
		private var fl_Accelerometer:Accelerometer = new Accelerometer();
		private var _accelX:Number = 0;
		private var _accelY:Number = 0; 
		
		
		public function AccelerometerHandler() 
		{
			fl_Accelerometer.addEventListener(AccelerometerEvent.UPDATE, fl_AccelerometerUpdateHandler);
		}
		
		
		private function fl_AccelerometerUpdateHandler(e:AccelerometerEvent):void
		{
			_accelX = - e.accelerationX;
			_accelY = e.accelerationY;
		}
		
		
		public function get accelX():Number 
		{
			return _accelX;
		}
		
		
		public function get accelY():Number 
		{
			return _accelY;
		}
		
	}

}