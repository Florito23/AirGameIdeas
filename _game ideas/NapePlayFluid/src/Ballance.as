package 
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.display.MovieClip;
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
	
	public class Ballance extends MovieClip 
	{
		
		public function Ballance():void 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.DEACTIVATE, deactivate);
			
			// touch or gesture?
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			
			var star:Starling = new Starling(Main, stage);
			star.start();
		}
		
		
		private function deactivate(e:Event):void 
		{
			// auto-close
			NativeApplication.nativeApplication.exit();
		}
		
	}
	
}