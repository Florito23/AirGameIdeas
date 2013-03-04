package tests.soundlinegametest
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.media.SoundMixer;
	import starling.events.Event;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import starling.core.Starling;
	
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class SoundLineGameMain extends Sprite 
	{
		
		private var starling:Starling;
		private var game:SoundLineGame;
		
		public function SoundLineGameMain():void 
		{
			//stage.scaleMode = StageScaleMode.NO_SCALE;
			//stage.align = StageAlign.TOP_LEFT;
			//stage.addEventListener(Event.DEACTIVATE, deactivate);
			
			// touch or gesture?
			//Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			addEventListener(flash.events.Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:flash.events.Event):void 
		{
			removeEventListener(flash.events.Event.ADDED_TO_STAGE, init);
			
			// entry point
			Starling.handleLostContext = false;
			Starling.multitouchEnabled = true;
			starling = new Starling(SoundLineGame, stage);
			starling.showStats = true;
			starling.start();
			starling.addEventListener(starling.events.Event.ROOT_CREATED, onRootCreated);
			// new to AIR? please read *carefully* the readme.txt files!
		}
		
		private function onRootCreated(e:starling.events.Event):void 
		{
			game = starling.root as SoundLineGame;
			game.addEventListener("STOP_GAME", stopGame);
		}
		
		private function stopGame(e:starling.events.Event):void 
		{
			starling.stop();
			SoundMixer.stopAll();
			starling.dispose();
			starling = null;
			parent.removeChild(this);
		}
		
		/*private function deactivate(e:Event):void 
		{
			// auto-close
			NativeApplication.nativeApplication.exit();
		}*/
		
	}
	
}