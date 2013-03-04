package tests 
{
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import tests.soundchaintest.SoundChainTest;
	
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class AllTests extends Sprite 
	{
		
		private var buttons:Sprite = new Sprite();
		private var chainTestButton:TextButton = new TextButton("SoundChain test");
		private var soundChainTest:SoundChainTest = new SoundChainTest();
		
		public function AllTests() 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			soundChainTest.addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event):void {
				buttons.visible = true;
			});
			
			chainTestButton.x = 20;
			chainTestButton.y = 20;
			chainTestButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				trace("chain button click");
				buttons.visible = false;
				addChild(soundChainTest);
			});
			buttons.addChild(chainTestButton);
			
			addChild(buttons);
		}
		
	}

}