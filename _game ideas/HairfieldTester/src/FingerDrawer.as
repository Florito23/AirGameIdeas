package  
{
	import flash.system.Capabilities;
	import starling.display.BlendMode;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	
	/**
	 * Dispatched when a finger has moved. The data of the lineAB object
	 * @eventType	FingerDrawer.TOUCH_MOVEMENT
	 */
	[Event(name = "touchMovement", type = "starling.events.Event")] 
	
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class FingerDrawer extends Sprite
	{
		
		public static const TOUCH_MOVEMENT:String = "touchMovement";
		
		private static const DRAW_ON_SCREEN_ALPHA:Number = 0.1;
		
		private static const MIN_FINGER_SIZE_IN_CM:Number = 0.2;
		private static const MAX_FINGER_SIZE_IN_CM:Number = 3.0;
		
		/** Finger size in pixels **/
		private static var _fingerSize0:Number;
		private static var _fingerSize1:Number;
		
		
		private var _drawSprites:Array = new Array();
		
		private var _drawOnScreen:Boolean = false;
		
		public function FingerDrawer() 
		{
			var dpi:Number = Capabilities.screenDPI;
			var dpCm:Number = dpi / 2.54;
			_fingerSize0 = MIN_FINGER_SIZE_IN_CM * dpCm;
			_fingerSize1 = MAX_FINGER_SIZE_IN_CM * dpCm;
			//trace("dpi", dpi, ", dpcm", dpCm, ", FINGER(cm)", MIN_FINGER_SIZE_IN_CM, ", finger(px)", _fingerSize);
			
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			stage.addEventListener(TouchEvent.TOUCH, onStageTouch);
		}
		
		
		private var _currentTouches:Array = new Array();
		
		private function onStageTouch(e:TouchEvent):void 
		{
			var i:int;
			var touch:Touch;
			var touches:Vector.<Touch>;
			
			// touch begin
			touches = e.getTouches(stage, TouchPhase.BEGAN);
			for (i = 0; i < touches.length; i++) {
				touch = touches[i];
				_currentTouches[touch.id] = touch;
				if (_drawOnScreen) {
					_drawSprites[touch.id] = new Sprite();
					(_drawSprites[touch.id] as Sprite).alpha = DRAW_ON_SCREEN_ALPHA;
					(_drawSprites[touch.id] as Sprite).blendMode = BlendMode.ADD;
					addChild(_drawSprites[touch.id]);
				}
			}
			
			// touch drag
			touches = e.getTouches(stage, TouchPhase.MOVED);
			for (i = 0; i < touches.length; i++) {
				touch = touches[i];
				if (_currentTouches[touch.id]) {
					
					//trace(touch.pressure);
					var lineAB:LineAB = new LineAB(
						touch.previousGlobalX, touch.previousGlobalY, 
						touch.globalX, touch.globalY, map(touch.pressure, 0, 1, _fingerSize0, _fingerSize1, true));
						
					dispatchEventWith(TOUCH_MOVEMENT, false, lineAB);
					if (_drawOnScreen) {
						(_drawSprites[touch.id] as Sprite).addChild(new LineABQuad(lineAB));
					}
				}
			}
			
			// touch end
			touches = e.getTouches(stage, TouchPhase.ENDED);
			for (i = 0; i < touches.length; i++) {
				touch = touches[i];
				_currentTouches[touch.id] = null;
				if (_drawOnScreen) {
					removeChild(_drawSprites[touch.id]);
					_drawSprites[touch.id] = null;
				}
				
			}
			
			
		}
		
		
		private static function map(v:Number, v0:Number, v1:Number, w0:Number, w1:Number, clip:Boolean = false):Number {
			var out:Number = w0 + (w1 - w0) * (v - v0) / (v1 - v0);
			if (clip) {
				var wMin:Number = Math.min(w0, w1);
				var wMax:Number = Math.max(w0, w1);
				out = Math.max(wMin, Math.min(wMax, out));
			}
			return out;
		}
		
		public function get drawOnScreen():Boolean 
		{
			return _drawOnScreen;
		}
		
		public function set drawOnScreen(value:Boolean):void 
		{
			_drawOnScreen = value;
			//TODO: add/remove draw sprites?
		}
		
		
	}

}