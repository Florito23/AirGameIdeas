package tests 
{
	import flash.desktop.NativeApplication;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.Font;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import tests.recursivetest.RecursiveFilterTest;
	import tests.soundchaintest.SoundChainTest;
	import tests.soundenginetest.SimpleMixerTest;
	import tests.soundlinegametest.SoundLineGameMain;
	import tests.soundpitchingtest.SoundPitching;
	
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class AllTests extends Sprite 
	{
		
		
		[Embed(source="VERDANAB.TTF", fontName="Verdana Bold", mimeType="application/x-font-truetype", embedAsCFF="false")]
		private static const VerdanaClass:Class;
		
		public static var textFormatVerdana32:TextFormat;
		{
			Font.registerFont(VerdanaClass);
			textFormatVerdana32 = new TextFormat("Verdana Bold", 32, 0xdddddd);// true);
			textFormatVerdana32.align = TextFormatAlign.CENTER;
		}
		
		private var buttons:Sprite = new Sprite();
		
		private var mixerButton:TextButton = new TextButton("Pitched channel mixer");
		private var mixerTest:SimpleMixerTest;
		
		private var soundPitchingButton:TextButton = new TextButton("Sound pitching");
		private var soundPitching:SoundPitching = new SoundPitching();
		
		private var chainTestButton:TextButton = new TextButton("SoundChain test");
		private var soundChainTest:SoundChainTest = new SoundChainTest();
		
		private var recursiveFilterButton:TextButton = new TextButton("Recursive filters");
		private var recursiveFilterTest:RecursiveFilterTest = new RecursiveFilterTest();
		
		private var soundGameButton:TextButton = new TextButton("Sound game");
		
		public function AllTests() 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.DEACTIVATE, function(e:Event):void {
				NativeApplication.nativeApplication.exit();
			});
			
			// touch or gesture?
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			
			var spacing:Number = 30;
			var xPos:Number = (stage.stageWidth - TextButton.WIDTH) * 0.5;
			var yPos:Number = spacing;
			
			mixerButton.x = xPos;
			mixerButton.y = yPos;
			mixerButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				e.stopImmediatePropagation();
				buttons.visible = false;
				mixerTest = new SimpleMixerTest();
				mixerTest.addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event):void {
					buttons.visible = true;
				});
				addChild(mixerTest);
			});
			buttons.addChild(mixerButton);
			
			yPos += TextButton.HEIGHT + spacing;
			
			
			
			soundPitchingButton.x = xPos;
			soundPitchingButton.y = yPos;
			soundPitchingButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				e.stopImmediatePropagation();
				buttons.visible = false;
				addChild(soundPitching);
			});
			buttons.addChild(soundPitchingButton);
			soundPitching.addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event):void {
				buttons.visible = true;
			});
			yPos += TextButton.HEIGHT + spacing;
			
			
			
			chainTestButton.x = xPos;
			chainTestButton.y = yPos;
			chainTestButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				e.stopImmediatePropagation();
				buttons.visible = false;
				addChild(soundChainTest);
			});
			buttons.addChild(chainTestButton);
			soundChainTest.addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event):void {
				buttons.visible = true;
			});
			yPos += TextButton.HEIGHT + spacing;
			
			
			
			recursiveFilterButton.x = xPos;
			recursiveFilterButton.y = yPos;
			recursiveFilterButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				e.stopImmediatePropagation();
				buttons.visible = false;
				addChild(recursiveFilterTest);
			});
			buttons.addChild(recursiveFilterButton);
			recursiveFilterTest.addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event):void {
				buttons.visible = true;
			});
			yPos += TextButton.HEIGHT + spacing;
			
			
			
			soundGameButton.x = xPos;
			soundGameButton.y = yPos;
			soundGameButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				e.stopImmediatePropagation();
				buttons.visible = false;
				var soundGame:SoundLineGameMain = new SoundLineGameMain();
				addChild(soundGame);
				soundGame.addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event):void {
					buttons.visible = true;
				});
			});
			buttons.addChild(soundGameButton);
			yPos += TextButton.HEIGHT + spacing;
			
			
			
			yPos += TextButton.HEIGHT + spacing;
			var exitButton:TextButton = new TextButton("exit");
			exitButton.x = xPos;
			exitButton.y = yPos;
			exitButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
				NativeApplication.nativeApplication.exit(0);
			});
			buttons.addChild(exitButton);
			
			addChild(buttons);
		}
		
	}

}