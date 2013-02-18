package  
{
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class SquareGesture 
	{
		
		private const cornerThresh:Number = 50;
		
		private const RADIAN_DEVIATION:Number = 15 * Math.PI / 180.0;
		
		
		
		private var _stage:String = STAGE_WAITING_FOR_MOUSE_DOWN;
		
		private static const STAGE_WAITING_FOR_MOUSE_DOWN:String = "waitingForMouseDown";
		/**
		 * Detecting right line
		 */
		private static const STAGE_GOING_RIGHT:String = "goingRight";
		
		private static const STAGE_FAILED_GESTURE_WAITING_FOR_MOUSEUP:String = "failedGestureWaitingForMouseUp";
		
		
		
		private var _lastMouseDown:Boolean;
		
		public function SquareGesture() 
		{
			reset();
		}
		
		private function reset():void {
			_stage = STAGE_WAITING_FOR_MOUSE_DOWN;
			_lastMouseDown = false;
		}
		
		public function detect(mouseDown:Boolean, x:Number, y:Number, lpfX:Number, lpfY:Number, hpfX:Number, hpfY:Number):void 
		{
			
			// mouse triggers
			var mouseDownTrigger:Boolean = false;
			var mouseUpTrigger:Boolean = false;
			if (!_lastMouseDown && mouseDown) {
				mouseDownTrigger = true;
			}
			else if (_lastMouseDown && !mouseDown) {
				mouseUpTrigger = true;
			}
			_lastMouseDown = mouseDown;
			
			
			if (_stage == STAGE_WAITING_FOR_MOUSE_DOWN && mouseDownTrigger) {
				_stage = STAGE_GOING_RIGHT;
			}
			
			if (mouseDown) {
				var lpfDir:Number = Math.atan2(lpfY, lpfX);
				var hpfAbs:Number = Math.abs(hpfX) + Math.abs(hpfY);
				
				switch (_stage) {
					
					
					// wait for line drawing to right
					case STAGE_GOING_RIGHT:
						if (Math.abs(lpfDir - 0) > RADIAN_DEVIATION) {
							_stage = STAGE_FAILED_GESTURE_WAITING_FOR_MOUSEUP;
						}
						break;
				}
			}
			
			
			
			trace(_stage);
			
		}
		
	
		
	}

}