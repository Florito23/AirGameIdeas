package
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import starling.core.Starling;
	
	/**
	 * ...
	 * @author 0L4F
	 */
	
	[swf(framerate=60, width=480, height=800, backgroundColor=0x000000)]
	
	
	public class NapePlayFluid extends Sprite
	{
		private var deviceSettings:DeviceSettings = new DeviceSettings();
		
		
		public function NapePlayFluid()
		{
			super();

			stage.scaleMode = StageScaleMode.NO_SCALE;
			//stage.scaleMode = StageScaleMode.
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.DEACTIVATE, deactivate);
			
			stage.addEventListener(Event.RESIZE, onResize);
			
			// touch or gesture?
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			
			//var star:Starling = new Starling(Main, stage);
			//star.start();
		}
		
		
		
		protected function onResize(event:Event):void
		{
			stage.removeEventListener(Event.RESIZE, onResize);
			
			var star:Starling = new Starling(Main, stage);
			star.showStats = true;
			star.start();
		}		
		
		
		
		private function deactivate(e:Event):void 
		{
			// auto-close
			NativeApplication.nativeApplication.exit();
		}
	}
}