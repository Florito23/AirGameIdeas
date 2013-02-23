package 
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.system.Capabilities;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import starling.core.Starling;
	
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class Main extends Sprite 
	{
		
		private var starling:Starling;
		
		public function Main():void 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			// touch or gesture?
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			Starling.multitouchEnabled = true;  // useful on mobile devices
			var iOS:Boolean = Capabilities.manufacturer.indexOf("iOS") != -1;
            Starling.handleLostContext = !iOS;  // not necessary on iOS. Saves a lot of memory!
			
			starling = new Starling(Hairfield, stage);
			starling.simulateMultitouch = true;
			starling.showStats = true;
			starling.start();
			
			NativeApplication.nativeApplication.addEventListener(Event.ACTIVATE, function(e:*):void {
				starling.start();
			});
			
			NativeApplication.nativeApplication.addEventListener(Event.DEACTIVATE, function(e:*):void {
				starling.stop();
			});
		}
		
		
	}
	
}