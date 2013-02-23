package  
{
	import flash.utils.getTimer;
	import starling.display.BlendMode;
	import starling.display.Button;
	import starling.display.Quad;
	import starling.display.QuadBatch;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class Hairfield extends Sprite 
	{
		
		public var HAIR_DISTANCE:Number = 40;
		public static const HAIR_LENGTH:Number = 60;
		public static const HAIR_WIDTH:Number = 2;
		
		private var HAIR_ALPHA:Number = 1.0;
		private var BATCH_ALPHA:Number = 1.0;
				
		
		private var _yAmount:int, _xAmount:int;
		
		private var _lineAmount:int;
		private var _lines:Vector.<Line>;
		private var _lineBatch:QuadBatch;
		
		//private var _initOnFrame:Boolean = false;
		//private var _decreaseOnInit:Boolean = false;
		
		public function Hairfield() 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			trace(this, "init", stage.stageWidth, stage.stageHeight);
			
			initLines();
			
			addEventListener(EnterFrameEvent.ENTER_FRAME, frame);
		}
		
		
		
		private function initLines():void {
			_xAmount = int((stage.stageWidth-HAIR_DISTANCE) / HAIR_DISTANCE) + 1;
			_yAmount = int((stage.stageHeight-HAIR_DISTANCE) / HAIR_DISTANCE) + 1;
			
			var xOffset:Number = (stage.stageWidth - (_xAmount-1) * HAIR_DISTANCE) / 2;
			var yOffset:Number = (stage.stageHeight - (_yAmount-1) * HAIR_DISTANCE) / 2;
			
			_lineAmount = _yAmount * _xAmount;
			_lines = new Vector.<Line>(_lineAmount);
			_lines.fixed = true;
			
			var index:int = 0;
			for (var yi:int = 0; yi < _yAmount; yi++) {
				for (var xi:int = 0; xi < _xAmount; xi++) {
					var l:Line = new Line(HAIR_LENGTH, HAIR_WIDTH, 0xf02208);
					l.x = xOffset + xi * HAIR_DISTANCE;
					l.y = yOffset + yi * HAIR_DISTANCE;
					l.blendMode = BlendMode.ADD;
					l.touchable = false;
					l.rotation = 2 * Math.PI * Math.random();
					l.alpha = HAIR_ALPHA;
					_lines[index] = l;
					index++;
				}
			}
			
			_lineBatch = new QuadBatch();
			//_lineBatch.blendMode = BlendMode.ADD;
			_lineBatch.alpha = BATCH_ALPHA;
			_lineBatch.touchable = false;
			addChild(_lineBatch);
			
			
			
			// UI
			var uiSprite:Sprite = new Sprite();
			var bWidth:int = 120;
			var bHeight:int = 50;
			var bSpacing:int = 10;
			
			var tf:TextField = new TextField(200, 40, "spacing=" + HAIR_DISTANCE.toFixed(1) + "\nx=" + _xAmount + ", y=" + _yAmount + ", amount=" + _lineAmount, "Verdana", 12, 0xffffff, true);
			tf.hAlign = HAlign.LEFT;
			tf.vAlign = VAlign.TOP;
			tf.x = stage.stageWidth - 200 - 10;
			uiSprite.addChild(tf);
			
			var _increaseButton:MyButton = new MyButton(bWidth, bHeight, 0xaaaaaa, "increase", 0xffffff, function():void { 
				HAIR_DISTANCE /= 1.05;
				reInitialize();
			} );
			_increaseButton.x = bSpacing;
			_increaseButton.y = stage.stageHeight - (bHeight+bSpacing)*3;
			uiSprite.addChild(_increaseButton);
			
			var _decreaseButton:MyButton = new MyButton(bWidth, bHeight, 0xaaaaaa, "decrease", 0xffffff, function():void { 
				HAIR_DISTANCE *= 1.05;
				reInitialize();
			} );
			_decreaseButton.x = bSpacing;
			_decreaseButton.y = _increaseButton.y + bHeight + 10;
			uiSprite.addChild(_decreaseButton);
			
			var _hairAlphaButton:MyButton = new MyButton(bWidth, bHeight, 0xaaaaaa, "hair alpha", 0xffffff, function():void { 
				HAIR_ALPHA = 0.3;
				BATCH_ALPHA = 1.0;
				reInitialize();
			});
			_hairAlphaButton.x = stage.stageWidth - bWidth - bSpacing;
			_hairAlphaButton.y = _increaseButton.y
			uiSprite.addChild(_hairAlphaButton);
			
			var _batchAlphaButton:MyButton = new MyButton(bWidth, bHeight, 0xaaaaaa, "batch alpha", 0xffffff, function():void { 
				HAIR_ALPHA = 1.0;
				BATCH_ALPHA = 0.3;
				reInitialize();
			});
			_batchAlphaButton.x = _hairAlphaButton.x;
			_batchAlphaButton.y = _hairAlphaButton.y +bHeight + bSpacing;
			uiSprite.addChild(_batchAlphaButton);
			
			var _noAlphaButton:MyButton = new MyButton(bWidth, bHeight, 0xaaaaaa, "no alpha", 0xffffff, function():void { 
				HAIR_ALPHA = 1.0;
				BATCH_ALPHA = 1.0;
				reInitialize();
			});
			_noAlphaButton.x = _hairAlphaButton.x;
			_noAlphaButton.y = _batchAlphaButton.y + bHeight + bSpacing;
			uiSprite.addChild(_noAlphaButton);
			
			addChild(uiSprite);
			uiSprite.flatten();
		}
		
		
		
		private function reInitialize():void {
			removeChildren(0,-1,true);
			initLines();
		}
		
		
		/*private function toggleAlpha():void {
			if (HAIR_ALPHA == 1) {
				HAIR_ALPHA = 0.3;
			} else {
				HAIR_ALPHA = 1;
			}
			trace("toggle alpha", HAIR_ALPHA);
			_initOnFrame = true;
		}*/
		
		
		private function frame(e:EnterFrameEvent):void 
		{
			/*if (_initOnFrame) {
				_initOnFrame = false;
				reInitialize(_decreaseOnInit);
			}*/
			
			_lineBatch.reset();
			for (var i:int = 0; i < _lineAmount; i++) {
				_lineBatch.addQuad(_lines[i]);
			}
		}
		
		
		
	}

}