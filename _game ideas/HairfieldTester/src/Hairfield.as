package  
{
	import flash.desktop.NativeApplication;
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
	import starling.text.BitmapFont;
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
		
		private var _aligner:Aligner;
		
		private var _updatingStats:TextField;
		
		public function Hairfield() 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			trace(this, "init", stage.stageWidth, stage.stageHeight);
			
			initLines();
			
			stage.addEventListener(TouchEvent.TOUCH, onStageTouch);
			
			addEventListener(EnterFrameEvent.ENTER_FRAME, frame);
		}
		
		private function onStageTouch(e:TouchEvent):void 
		{
			if (e.getTouch(stage, TouchPhase.BEGAN)) {
				reInitialize();
			}
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
					l.rotation = 2 * Math.PI * Math.random();// * 10;
					l.alpha = HAIR_ALPHA;
					_lines[index] = l;
					index++;
				}
			}
			
			_aligner = new Aligner(_xAmount, _yAmount, _lines);
			
			
			_lineBatch = new QuadBatch();
			//_lineBatch.blendMode = BlendMode.ADD;
			_lineBatch.alpha = BATCH_ALPHA;
			_lineBatch.touchable = false;
			addChild(_lineBatch);
			
			
			
			//STATS
			var statSprite:Sprite = new Sprite();
			var q:Quad = new Quad(100, 100, 0x000000);
			_updatingStats = new TextField(100, 100, "Stats", BitmapFont.MINI, BitmapFont.NATIVE_SIZE, 0xffffff);
			_updatingStats.hAlign = HAlign.LEFT;
			_updatingStats.vAlign = VAlign.TOP;
			statSprite.addChild(q);
			statSprite.addChild(_updatingStats);
			statSprite.x = 2;
			statSprite.y = 200;
			addChild(statSprite);
			
			
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
			
			var _increaseButton:MyButton = new MyButton(bWidth, bHeight, 0xaaaaaa, "Increase", 0xffffff, function():void { 
				HAIR_DISTANCE /= 1.05;
				reInitialize();
			} );
			_increaseButton.x = bSpacing;
			_increaseButton.y = stage.stageHeight - (bHeight+bSpacing)*3;
			uiSprite.addChild(_increaseButton);
			
			var _decreaseButton:MyButton = new MyButton(bWidth, bHeight, 0xaaaaaa, "Decrease", 0xffffff, function():void { 
				HAIR_DISTANCE *= 1.05;
				reInitialize();
			} );
			_decreaseButton.x = bSpacing;
			_decreaseButton.y = _increaseButton.y + bHeight + bSpacing;
			uiSprite.addChild(_decreaseButton);
			
			var _exitButton:MyButton = new MyButton(bWidth, bHeight, 0xaaaaaa, "Exit", 0xffffff, function():void { 
				NativeApplication.nativeApplication.exit();
			} );
			_exitButton.x = bSpacing;
			_exitButton.y = _decreaseButton.y + bHeight + bSpacing;
			uiSprite.addChild(_exitButton);
			
			var _hairAlphaButton:MyButton = new MyButton(bWidth, bHeight, 0xaaaaaa, "Hair alpha", 0xffffff, function():void { 
				HAIR_ALPHA = 0.5;
				BATCH_ALPHA = 1.0;
				reInitialize();
			});
			_hairAlphaButton.x = stage.stageWidth - bWidth - bSpacing;
			_hairAlphaButton.y = _increaseButton.y
			uiSprite.addChild(_hairAlphaButton);
			
			var _batchAlphaButton:MyButton = new MyButton(bWidth, bHeight, 0xaaaaaa, "Batch alpha", 0xffffff, function():void { 
				HAIR_ALPHA = 1.0;
				BATCH_ALPHA = 0.5;
				reInitialize();
			});
			_batchAlphaButton.x = _hairAlphaButton.x;
			_batchAlphaButton.y = _hairAlphaButton.y +bHeight + bSpacing;
			uiSprite.addChild(_batchAlphaButton);
			
			var _noAlphaButton:MyButton = new MyButton(bWidth, bHeight, 0xaaaaaa, "No alpha-ing", 0xffffff, function():void { 
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
		
		
		private function frame(e:EnterFrameEvent):void 
		{
			var alignTime:int = _aligner.align();
			var timePerHair:Number = alignTime / _lineAmount;
			
			_updatingStats.text = "STATS:\n" +
				"Aligner " + alignTime + " ms\n" +
				"-> per hair " + timePerHair.toFixed(4)+" ms";
			
			_lineBatch.reset();
			for (var i:int = 0; i < _lineAmount; i++) {
				_lineBatch.addQuad(_lines[i]);
			}
		}
		
		
		
	}

}