package  
{
	import flash.desktop.NativeApplication;
	import flash.geom.Point;
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
		
		/*
		 * Hairfield drawing
		 */
		public var HAIR_DISTANCE:Number = 24;
		public static const HAIR_LENGTH:Number = 60;
		public static const HAIR_WIDTH:Number = 1;
		private var HAIR_ALPHA:Number = 1.0;
		private var BATCH_ALPHA:Number = 1.0;
		
		/*
		 * Hairfield data
		 */
		private var _yAmount:int, _xAmount:int;
		private var _lineAmount:int;
		private var _lines:Vector.<HairfieldLine>;
		private var _lineBatch:QuadBatch;
		
		/** Aligner **/
		private var _aligner:Aligner;
		
		/*
		 * GUI:
		 */
		private var _updatingStats:TextField;
		
		private var _showTouchButton:MyButton;
		private var _showUIButton:MyButton;
		private var _noAlphaButton:MyButton;
		private var _batchAlphaButton:MyButton;
		private var _hairAlphaButton:MyButton;
		private var _exitButton:MyButton;
		private var _decreaseButton:MyButton;
		private var _increaseButton:MyButton;
		private var _statSprite:Sprite;
		
		
		/*
		 * Points used for mapping stage to indices (for swiping)
		 */
		private var _stagePoint0:Point;
		private var _stagePoint1:Point;
		private var _indexPoint0:Point;
		private var _indexPoint1:Point;
		
		/** Finger drawer for interfacing with lines **/
		private var _fingerDrawer:FingerDrawer;
		
		
		public function Hairfield() 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			trace(this, "init", stage.stageWidth, stage.stageHeight);
			
			_fingerDrawer = new FingerDrawer();
			_fingerDrawer.addEventListener(FingerDrawer.TOUCH_MOVEMENT, fingerSwipe);
			addChild(_fingerDrawer);
			
			initGui();
			
			initLines();
			
			
			
			addEventListener(EnterFrameEvent.ENTER_FRAME, frame);
		}
		
		
		
		
		
		
		
		private function initLines():void {
			
			// get amounts from HAIR_DISTANCE
			_xAmount = int((stage.stageWidth-HAIR_DISTANCE) / HAIR_DISTANCE) + 1;
			_yAmount = int((stage.stageHeight - HAIR_DISTANCE) / HAIR_DISTANCE) + 1;
			
			// set the limiting points for the indices
			_indexPoint0 = new Point(0, 0);
			_indexPoint1 = new Point(_xAmount - 1, _yAmount - 1);
			
			_lineAmount = _yAmount * _xAmount;
			_lines = new Vector.<HairfieldLine>(_lineAmount);
			_lines.fixed = true;
			
			// numbers needed for calcing from stage to index coordinates
			var x0:Number, x1:Number, y0:Number, y1:Number;
			x0 = y0 = Number.MAX_VALUE;
			x1 = y1 = Number.MIN_VALUE;
			var xOffset:Number = (stage.stageWidth - (_xAmount-1) * HAIR_DISTANCE) / 2;
			var yOffset:Number = (stage.stageHeight - (_yAmount-1) * HAIR_DISTANCE) / 2;
			var index:int = 0;
			for (var yi:int = 0; yi < _yAmount; yi++) {
				for (var xi:int = 0; xi < _xAmount; xi++) {
					var l:HairfieldLine = new HairfieldLine(HAIR_LENGTH, HAIR_WIDTH, 0xf02208);
					l.x = xOffset + xi * HAIR_DISTANCE;
					l.y = yOffset + yi * HAIR_DISTANCE;
					x0 = Math.min(x0, l.x);
					y0 = Math.min(y0, l.y);
					x1 = Math.max(x1, l.x);
					y1 = Math.max(y1, l.y);
					l.blendMode = BlendMode.ADD;
					l.touchable = false;
					l.rotation = 2 * Math.PI * Math.random();// * 10;
					l.alpha = HAIR_ALPHA;
					_lines[index] = l;
					index++;
				}
			}
			_stagePoint0 = new Point(x0, y0);
			_stagePoint1 = new Point(x1, y1);
			
			_aligner = new Aligner(_xAmount, _yAmount, _lines);
			
			
			if (_lineBatch && getChildIndex(_lineBatch) >= 0) {
				removeChild(_lineBatch);
			}
			_lineBatch = new QuadBatch();
			//_lineBatch.blendMode = BlendMode.ADD;
			_lineBatch.alpha = BATCH_ALPHA;
			_lineBatch.touchable = false;
			addChildAt(_lineBatch, 0);
		}
		
		
		private function initGui():void {
			
			// UI
			var uiSprite:Sprite = new Sprite();
			
			//STATS
			_statSprite = new Sprite();
			var q:Quad = new Quad(120, 80, 0x000000);
			_updatingStats = new TextField(120, 80, "Stats", BitmapFont.MINI, BitmapFont.NATIVE_SIZE, 0xffffff);
			_updatingStats.hAlign = HAlign.LEFT;
			_updatingStats.vAlign = VAlign.TOP;
			_statSprite.addChild(q);
			_statSprite.addChild(_updatingStats);
			_statSprite.x = 2;
			_statSprite.y = 30;
			uiSprite.addChild(_statSprite);
			
			var bWidth:int = 120;
			var bHeight:int = 50;
			var bSpacing:int = 10;
			
			_showUIButton = new MyButton(bWidth, bHeight, 0xaaaaaa, "Hide UI", 0xffffff, function():void { 
				_showUIButton.unflatten();
				if (_showUIButton.alpha == 1) {
					_showUIButton.alpha = 0.2;
					_showUIButton.text = "Show UI";
					_statSprite.visible = false;
					_increaseButton.visible = _decreaseButton.visible = _exitButton.visible = false;
					_showTouchButton.visible = _hairAlphaButton.visible = _batchAlphaButton.visible = _noAlphaButton.visible = false;
				} else {
					_showUIButton.alpha = 1;
					_showUIButton.text = "Hide UI";
					_statSprite.visible = true;
					_increaseButton.visible = _decreaseButton.visible = _exitButton.visible = true;
					_showTouchButton.visible = _hairAlphaButton.visible = _batchAlphaButton.visible = _noAlphaButton.visible = true;
				}
				_showUIButton.flatten();
			} );
			_showUIButton.x = stage.stageWidth-bSpacing-bWidth;
			_showUIButton.y = bSpacing;
			_showUIButton.flatten();
			uiSprite.addChild(_showUIButton);
			
			_showTouchButton = new MyButton(bWidth, bHeight, 0xaaaaaa, "Show trace " + _fingerDrawer.drawOnScreen, 0xffffff, function():void {
				_fingerDrawer.drawOnScreen = !_fingerDrawer.drawOnScreen;
				trace("HIT");
				_showTouchButton.text = "Show finger " + _fingerDrawer.drawOnScreen;
			});
			_showTouchButton.x = stage.stageWidth - bWidth - bSpacing;
			_showTouchButton.y = _showUIButton.y + bHeight + bSpacing;
			uiSprite.addChild(_showTouchButton);
			
			
			_increaseButton = new MyButton(bWidth, bHeight, 0xaaaaaa, "Increase", 0xffffff, function():void { 
				HAIR_DISTANCE /= 1.05;
				initLines();
			} );
			_increaseButton.x = bSpacing;
			_increaseButton.y = stage.stageHeight - (bHeight+bSpacing)*3;
			uiSprite.addChild(_increaseButton);
			
			_decreaseButton = new MyButton(bWidth, bHeight, 0xaaaaaa, "Decrease", 0xffffff, function():void { 
				HAIR_DISTANCE *= 1.05;
				initLines();
			} );
			_decreaseButton.x = bSpacing;
			_decreaseButton.y = _increaseButton.y + bHeight + bSpacing;
			uiSprite.addChild(_decreaseButton);
			
			_exitButton = new MyButton(bWidth, bHeight, 0xaaaaaa, "Exit", 0xffffff, function():void { 
				NativeApplication.nativeApplication.exit();
			} );
			_exitButton.x = bSpacing;
			_exitButton.y = _decreaseButton.y + bHeight + bSpacing;
			uiSprite.addChild(_exitButton);
			
			_hairAlphaButton = new MyButton(bWidth, bHeight, 0xaaaaaa, "Hair alpha", 0xffffff, function():void { 
				HAIR_ALPHA = 0.5;
				BATCH_ALPHA = 1.0;
				initLines();
			});
			_hairAlphaButton.x = stage.stageWidth - bWidth - bSpacing;
			_hairAlphaButton.y = _increaseButton.y
			uiSprite.addChild(_hairAlphaButton);
			
			_batchAlphaButton = new MyButton(bWidth, bHeight, 0xaaaaaa, "Batch alpha", 0xffffff, function():void { 
				HAIR_ALPHA = 1.0;
				BATCH_ALPHA = 0.5;
				initLines();
			});
			_batchAlphaButton.x = _hairAlphaButton.x;
			_batchAlphaButton.y = _hairAlphaButton.y +bHeight + bSpacing;
			uiSprite.addChild(_batchAlphaButton);
			
			_noAlphaButton = new MyButton(bWidth, bHeight, 0xaaaaaa, "No alpha-ing", 0xffffff, function():void { 
				HAIR_ALPHA = 1.0;
				BATCH_ALPHA = 1.0;
				initLines();
			});
			_noAlphaButton.x = _hairAlphaButton.x;
			_noAlphaButton.y = _batchAlphaButton.y + bHeight + bSpacing;
			uiSprite.addChild(_noAlphaButton);
			
			addChild(uiSprite);
		}
		
		
		
		
		private function frame(e:EnterFrameEvent):void 
		{
			var alignTime:int = _aligner.align();
			var timePerHair:Number = alignTime / _lineAmount;
			
			_updatingStats.text = "STATS:\n\n" +
				"Dimension " + _xAmount + "x" + _yAmount + "\n" +
				"LineAmount = " + _lineAmount + "\n\n" +
				"Aligner " + alignTime + " ms\n" +
				"-> per hair " + timePerHair.toFixed(4) + " ms\n" +
				"SwipeCalc "+_fingerSwipeTime + "ms\n";
			_fingerSwipeTime = 0;
				
			_lineBatch.reset();
			for (var i:int = 0; i < _lineAmount; i++) {
				_lineBatch.addQuad(_lines[i]);
			}
		}
		
		
		
		/*
		 * 
		 * 
		 * FINGER SWIPE -> INTERFERE WITH FIELD
		 * 
		 * 
		 */
		
		private var _fingerSwipeTime:int = 0;
		
		
		
		private function fingerSwipe(e:Event):void 
		{
			
			//trace(this, "fingerSwipe()", "--------------------------------------------------------------------");
			
			// convert corner points to index points
			_fingerSwipeTime = getTimer();
			var lineAB:LineAB = e.data as LineAB;
			var cornerPoints:Vector.<Point> = lineAB.getCornerPoints();// Vector.<Point>;
			var indexCornerPoints:Vector.<Point> = convertSpriteToFieldIndex(cornerPoints);
			
			var indicesToModify:Vector.<int> = new Vector.<int>();
			var p00:Point = indexCornerPoints[0];
			var p10:Point = indexCornerPoints[1];
			var p01:Point = indexCornerPoints[2];
			var p11:Point = indexCornerPoints[3];
			
			var leftSideDistance:Number = Point.distance(p00, p01);
			var rightSideDistance:Number = Point.distance(p10, p11);
			var maxDistance:Number = Math.max(leftSideDistance, rightSideDistance);
			var stepPercentage:Number = 1.0 / maxDistance; // TODO * 0.5?
			
			// interpolate left side from "top" to "bottom" (p00 -> p01)
			// while interpolating right side from "top" to "bottom" (p10 -> p11);
			for (var vertPercentage:Number = 0; vertPercentage <= 1; vertPercentage += stepPercentage) {
				var leftSide:Point = Point.interpolate(p00, p01, vertPercentage);
				var rightSide:Point = Point.interpolate(p10, p11, vertPercentage);
				
				var hStepPercentage:Number = 1.0 / Point.distance(leftSide, rightSide); // TODO: *0.5?
				for (var horizPercentage:Number = 0; horizPercentage <= 1; horizPercentage += hStepPercentage) {
					
					var pointOnQuad:Point = Point.interpolate(leftSide, rightSide, horizPercentage);
					var fieldIndex:int = int(pointOnQuad.y) * _xAmount + int(pointOnQuad.x);
					if (indicesToModify.indexOf(fieldIndex) == -1) {
						indicesToModify.push(fieldIndex);
					}
					
				}
			}
			
			// now modify the hairs
			var amount:int = indicesToModify.length;
			for (var i:int = 0; i < amount; i++) {
				_lines[indicesToModify[i]].rotation = lineAB.direction;// -Math.PI / 2;
			}
			
			_fingerSwipeTime = getTimer() - _fingerSwipeTime;
		}
		
		private function convertSpriteToFieldIndex(cornerPoints:Vector.<Point>):Vector.<Point> 
		{
			var out:Vector.<Point> = new Vector.<Point>(cornerPoints.length);
			for (var i:int = 0; i < cornerPoints.length; i++) {
				out[i] = mapPoint(cornerPoints[i], _stagePoint0, _stagePoint1, _indexPoint0, _indexPoint1, true);
			}
			return out;
		}
		
		private static function mapPoint(v:Point, v0:Point, v1:Point, w0:Point, w1:Point, clip:Boolean = false):Point {
			var wx:Number = w0.x + (w1.x - w0.x) * (v.x - v0.x) / (v1.x - v0.x);
			var wy:Number = w0.y + (w1.y - w0.y) * (v.y - v0.y) / (v1.y - v0.y);
			if (clip) {
				wx = Math.max(w0.x, Math.min(w1.x, wx));
				wy = Math.max(w0.y, Math.min(w1.y, wy));
			}
			return new Point(wx, wy);
		}
	}

}