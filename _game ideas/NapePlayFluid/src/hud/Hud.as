package hud 
{
	import starling.display.Sprite;
	import starling.events.Event;
	
	/**
	 * ...
	 * @author 0L4F
	 */
	public class Hud extends Sprite 
	{
		private var score:int = 0;
		public var scoreDisplay:ScoreDisplay;
		
		public function Hud() 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			scoreDisplay = new ScoreDisplay();
			scoreDisplay.x = stage.stageWidth - 180;
			scoreDisplay.y = 64;
			scoreDisplay.touchable = false;
			addChild(scoreDisplay);
		}
		
		
		public function changeScore(amount:int):void 
		{
			score+=amount;
			scoreDisplay.update(score);
		}
		
	}

}