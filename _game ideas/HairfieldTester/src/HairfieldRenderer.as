package  
{
	import flash.desktop.NativeApplication;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.utils.getTimer;
	import hairfield.Hairfield;
	import starling.display.BlendMode;
	import starling.display.Button;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
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
	import starling.textures.Texture;
	import starling.utils.HAlign;
	import starling.utils.VAlign;
	
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class HairfieldRenderer extends Sprite 
	{
		
		private static const MODE_USE_BATCH:int = 0;
		private static const MODE_USE_SPRITES:int = 1;
		private var _mode:int = MODE_USE_SPRITES; //TODO: not sure, but I think USE_SPRITES is faster...
		
		//TODO: Analysis on Desktop (@ 80x60)
		// Packages: 	hairfield takes 1 ms
		//				starling takes 9 ms!!!
		//
		// bottom up:						flash	starling	hairfield
		// VertexData.copyTo 						11%
		// Hairfield.align 				 						6%
		// Matrix.rotate							 4%
		// VertexData.transformVertex				 4%
		// RenderSupport.set blendMode				 3%
		// Matrix.copyFrom						 3%
		// QuadBatch.addQuad						 2%
		
		
		/*
		 * Hairfield drawing
		 */
		public var HAIR_DISTANCE:Number = 35;// 12.7; // -> 80x60 on iPad
		public static const HAIR_LENGTH:Number = 60;
		public static const HAIR_WIDTH:Number = 1;
		private var HAIR_ALPHA:Number = 1.0;
		private var BATCH_ALPHA:Number = 1.0;
		
		private var hWidth:int;
		private var hHeight:int;
		
		
		//private var _lines:Vector.<HairfieldLine>;
		private var _lines:Vector.<HairfieldLineImage>;
		
		private var _lineAmount:int;
		private var _lineBatch:QuadBatch;
		private var _hairfieldSprite:Sprite;
		
		/*
		 * GUI:
		 */
		private var _statSprite:Sprite;
		private var _updatingStats:TextField;
		
		private var _showUIButton:MyButton;
		private var _showTouchButton:MyButton;
		
		private var _hairAlphaButton:MyButton;
		private var _batchAlphaButton:MyButton;
		private var _noAlphaButton:MyButton;
		
		private var _decreaseButton:MyButton;
		private var _increaseButton:MyButton;
		private var _exitButton:MyButton;
		
		/*
		 * Hairfield
		 */
		private var _field:Hairfield;
		
		/*
		 * Points used for mapping stage coords to indices (for swiping)
		 */
		private var _stagePoint0:Point;
		private var _stagePoint1:Point;
		private var _indexPoint0:Point;
		private var _indexPoint1:Point;
		
		/** Finger drawer for interfacing with lines **/
		private var _fingerDrawer:FingerDrawer;
		
		
		
		
		
		public function HairfieldRenderer() 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			trace(this, "init", stage.stageWidth, stage.stageHeight);
			
			initFingerDrawer();
			
			initLines();
			
			initGui();
			
			addEventListener(EnterFrameEvent.ENTER_FRAME, frame);
			
		}
		
		
		private function initFingerDrawer():void {
			_fingerDrawer = new FingerDrawer();
			_fingerDrawer.touchable = false;
			_fingerDrawer.addEventListener(FingerDrawer.TOUCH_MOVEMENT, fingerSwipe);
			addChild(_fingerDrawer);
		}
		
		
		private var _linesActuallyDrawn:int = 0;
		
		private function initLines():void {
			
			hWidth = int((stage.stageWidth - HAIR_DISTANCE) / HAIR_DISTANCE) + 1;
			hHeight = int((stage.stageHeight - HAIR_DISTANCE) / HAIR_DISTANCE) + 1;
			
			_field = new Hairfield(hWidth, hHeight);
			
			
			
			//_lines = new Vector.<HairfieldLine>();
			_lines = new Vector.<HairfieldLineImage>(hWidth*hHeight);
			
			// Create Drawable lines
			
			//perlin noise offset
			var bmp:BitmapData = new BitmapData(hWidth, hHeight);
			bmp.perlinNoise(hWidth, hHeight, 3, getTimer() * Math.random(), false, false, 7);
			/*var img:Image = new Image(Texture.fromBitmapData(bmp));
			img.width = stage.stageWidth;
			img.height = stage.stageHeight;
			addChildAt(img, 0);*/
			
			
			// numbers needed for calcing from stage to index coordinates
			var x0:Number, x1:Number, y0:Number, y1:Number;
			x0 = y0 = Number.MAX_VALUE;
			x1 = y1 = Number.MIN_VALUE;
			var xOffset:Number = (stage.stageWidth - (hWidth-1) * HAIR_DISTANCE) / 2;
			var yOffset:Number = (stage.stageHeight - (hHeight-1) * HAIR_DISTANCE) / 2;
			var index:int = 0;
			var noiseRed:Number, noiseGreen:Number;
			var noiseBlue:int;
			_linesActuallyDrawn = 0;
			for (var yi:int = 0; yi < hHeight; yi++) {
				for (var xi:int = 0; xi < hWidth; xi++) {
					//var l:HairfieldLine = new HairfieldLine(HAIR_LENGTH, HAIR_WIDTH, 0xf02208);
					noiseRed = ((bmp.getPixel(xi, yi)>>16 & 0xff)/255.0 - 0.5) * 2;
					noiseGreen = ((bmp.getPixel(xi, yi) >> 8 & 0xff) / 255.0 - 0.5) * 2;
					noiseBlue = bmp.getPixel(xi, yi) & 0xff;
					//trace(noiseRed, noiseGreen);
					var l:HairfieldLineImage = new HairfieldLineImage();// HAIR_LENGTH, HAIR_WIDTH, 0xf02208);
					if (noiseBlue < 50) {
						l.visible = false;
					} else {
						_linesActuallyDrawn++;
					}
					//else if (noiseBlue < 100) l.alpha = map(noiseBlue, 50, 99, 0, 1);
					l.x = xOffset + xi * HAIR_DISTANCE + noiseRed * HAIR_DISTANCE;
					l.y = yOffset + yi * HAIR_DISTANCE + noiseGreen * HAIR_DISTANCE;
					x0 = Math.min(x0, l.x);
					y0 = Math.min(y0, l.y);
					x1 = Math.max(x1, l.x);
					y1 = Math.max(y1, l.y);
					l.blendMode = BlendMode.ADD;
					l.touchable = false;
					l.alpha = HAIR_ALPHA;
					l.rotation = 2 * Math.PI * Math.random();
					_lines[index] = l;
					index++;
				}
			}
			_lineAmount = _lines.length;
			
			//_lines[int(_lineAmount / 2)].debug = true;
			
			
			// for scaling swipes to indices:
			
			// set the limiting points for the indices
			_indexPoint0 = new Point(0, 0);
			_indexPoint1 = new Point(hWidth, hHeight);
			// set the limiting points for the stage coordinates
			_stagePoint0 = new Point(x0, y0);
			_stagePoint1 = new Point(x1, y1);
			
			
			
			
			// reset hairfield sprite
			
			if (_hairfieldSprite && getChildIndex(_hairfieldSprite) >= 0) {
				removeChild(_hairfieldSprite);
				_hairfieldSprite.dispose();
			}
			_hairfieldSprite = new Sprite();
			_hairfieldSprite.touchable = false;
			addChildAt(_hairfieldSprite, 0);
			
			
			
			// reset batch
			
			if (_lineBatch) _lineBatch = null;
			if (_mode == MODE_USE_BATCH) {
				_lineBatch = new QuadBatch();
				_lineBatch.alpha = BATCH_ALPHA;
				_lineBatch.touchable = false;
			}
			
			
			var i:int;
			switch (_mode) {
				// add lines directly to hairfield sprite
				case MODE_USE_SPRITES:
					for (i = 0; i < _lineAmount; i++) {
						_hairfieldSprite.addChild(_lines[i]);
					}
					break;
					
				// add linebatch to hairfield sprite
				case MODE_USE_BATCH:
					for (i = 0; i < _lineAmount; i++) {
						_lineBatch.addQuad(_lines[i]);
					}
					_hairfieldSprite.addChild(_lineBatch);
					break;
			}
			
			
		}
		
		private static function map(v:int, v0:Number, v1:Number, w0:Number, w1:Number):Number 
		{
			return w0 + (w1 - w0) * (v - v0) / (v1 - v0);
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
			
			var BUTTON_COLOR:int = 0x222222;
			var BUTTON_TEXT_COLOR:int = 0x888888;
			
			// BUTTON: SHOW UI
			_showUIButton = new MyButton(bWidth, bHeight, BUTTON_COLOR, "Hide UI", BUTTON_TEXT_COLOR, function():void { 
				_showUIButton.unflatten();
				if (_showUIButton.alpha == 1) {
					_showUIButton.alpha = 0.2;
					_showUIButton.text = "Show UI";
					_statSprite.visible = false;
					_increaseButton.visible = _decreaseButton.visible = _exitButton.visible = false;
					_showTouchButton.visible = _hairAlphaButton.visible = _batchAlphaButton.visible = false;
					_noAlphaButton.alpha = 0.2;
				} else {
					_showUIButton.alpha = 1;
					_showUIButton.text = "Hide UI";
					_statSprite.visible = true;
					_increaseButton.visible = _decreaseButton.visible = _exitButton.visible = true;
					_showTouchButton.visible = _hairAlphaButton.visible = _batchAlphaButton.visible = true;
					_noAlphaButton.alpha = 1;
				}
				_showUIButton.flatten();
			} );
			_showUIButton.x = stage.stageWidth-bSpacing-bWidth;
			_showUIButton.y = bSpacing;
			_showUIButton.flatten();
			uiSprite.addChild(_showUIButton);
			
			// BUTTON: show finger trace
			_showTouchButton = new MyButton(bWidth, bHeight, BUTTON_COLOR, "Show trace " + _fingerDrawer.drawOnScreen, BUTTON_TEXT_COLOR, function():void {
				_fingerDrawer.drawOnScreen = !_fingerDrawer.drawOnScreen;
				_showTouchButton.text = "Show finger " + _fingerDrawer.drawOnScreen;
			});
			_showTouchButton.x = _showUIButton.x;
			_showTouchButton.y = _showUIButton.y + bHeight + bSpacing;
			uiSprite.addChild(_showTouchButton);
			
			
			_increaseButton = new MyButton(bWidth, bHeight, BUTTON_COLOR, "Increase", BUTTON_TEXT_COLOR, function():void { 
				HAIR_DISTANCE /= 1.05;
				initLines();
			} );
			_increaseButton.x = bSpacing;
			_increaseButton.y = stage.stageHeight - (bHeight+bSpacing)*3;
			uiSprite.addChild(_increaseButton);
			
			_decreaseButton = new MyButton(bWidth, bHeight, BUTTON_COLOR, "Decrease", BUTTON_TEXT_COLOR, function():void { 
				HAIR_DISTANCE *= 1.05;
				initLines();
			} );
			_decreaseButton.x = bSpacing;
			_decreaseButton.y = _increaseButton.y + bHeight + bSpacing;
			uiSprite.addChild(_decreaseButton);
			
			_exitButton = new MyButton(bWidth, bHeight, BUTTON_COLOR, "Exit", BUTTON_TEXT_COLOR, function():void { 
				NativeApplication.nativeApplication.exit();
			} );
			_exitButton.x = bSpacing;
			_exitButton.y = _decreaseButton.y + bHeight + bSpacing;
			uiSprite.addChild(_exitButton);
			
			_hairAlphaButton = new MyButton(bWidth, bHeight, BUTTON_COLOR, "Hair alpha", BUTTON_TEXT_COLOR, function():void { 
				HAIR_ALPHA = 0.5;
				BATCH_ALPHA = 1.0;
				initLines();
			});
			_hairAlphaButton.x = stage.stageWidth - bWidth - bSpacing;
			_hairAlphaButton.y = _increaseButton.y
			uiSprite.addChild(_hairAlphaButton);
			
			_batchAlphaButton = new MyButton(bWidth, bHeight, BUTTON_COLOR, "Batch alpha", BUTTON_TEXT_COLOR, function():void { 
				HAIR_ALPHA = 1.0;
				BATCH_ALPHA = 0.5;
				initLines();
			});
			_batchAlphaButton.x = _hairAlphaButton.x;
			_batchAlphaButton.y = _hairAlphaButton.y +bHeight + bSpacing;
			uiSprite.addChild(_batchAlphaButton);
			
			_noAlphaButton = new MyButton(bWidth, bHeight, BUTTON_COLOR, "No alpha-ing", BUTTON_TEXT_COLOR, function():void { 
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
		
			//trace(this, "frame");
			
			var i:int;
			var alignTime:int=0;
			var timePerHair:Number = 0;
			
			alignTime = _field.align(); //TODO: desktop: 8% of overall calculations @ 80x60
			timePerHair = alignTime / _lineAmount;
			
			var hLines:Vector.<Number> = _field.lines;
			for (i = 0; i < _lineAmount; i++) {
				_lines[i].rotation = hLines[i]; // TODO: desktop: 2% of overall calculations @ 80x60 (setting rotations)
				_lines[i].animate();
			}
			
			
			_updatingStats.text = "STATS:\n\n" +
				"Dimension " + hWidth + "x" + hHeight + "\n" +
				"LineAmount = " + _lineAmount + "\n" +
				"Lines actually drawn = " + _linesActuallyDrawn + "\n\n" +
				"Aligner " + alignTime + " ms\n" +
				"-> per hair " + int(timePerHair*10000)/1000.0 + " ms\n" + //.toFixed(4)
				"SwipeCalc "+_fingerSwipeTime + "ms\n";
			_fingerSwipeTime = 0;
			
			trace("lineAmount", _lineAmount, "lines actuall drawn", _linesActuallyDrawn);
				
			switch (_mode) {
				case MODE_USE_BATCH:
					_lineBatch.reset();
					for (i = 0; i < _lineAmount; i++) {
						_lineBatch.addQuad(_lines[i]);
					}
					break;
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
			
			//TODO: should i not check the width/height of the indices just to be sure???
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
				
				var hStepPercentage:Number = 1.0 / Point.distance(leftSide, rightSide); // TODO: * 0.5?
				for (var horizPercentage:Number = 0; horizPercentage <= 1; horizPercentage += hStepPercentage) {
					
					var pointOnQuad:Point = Point.interpolate(leftSide, rightSide, horizPercentage);
					var fx:int = int(pointOnQuad.x);
					var fy:int = int(pointOnQuad.y);
					fx = Math.max(0, Math.min(hWidth - 1, fx));
					fy = Math.max(0, Math.min(hHeight - 1, fy));
					var fieldIndex:int = fy * hWidth + fx;
					//var fieldIndex:int = int(pointOnQuad.y) * hWidth + int(pointOnQuad.x);
					if (indicesToModify.indexOf(fieldIndex) == -1) {
						indicesToModify.push(fieldIndex);
					}
					
				}
			}
			
			// now modify the hairs
			/*var amount:int = indicesToModify.length;
			for (var i:int = 0; i < amount; i++) {
				_lines[indicesToModify[i]].rotation = lineAB.direction;// -Math.PI / 2;
			}*/
			
			_field.setDirections(indicesToModify, lineAB.direction);
			var amount:int = indicesToModify.length;
			for (var i:int = 0; i < amount; i++) {
				_lines[indicesToModify[i]].touch();
			}
			
			_fingerSwipeTime = getTimer() - _fingerSwipeTime;
		}
		
		private function convertSpriteToFieldIndex(cornerPoints:Vector.<Point>):Vector.<Point> 
		{
			var out:Vector.<Point> = new Vector.<Point>(cornerPoints.length);
			for (var i:int = 0; i < cornerPoints.length; i++) {
				out[i] = mapPoint(cornerPoints[i], _stagePoint0, _stagePoint1, _indexPoint0, _indexPoint1, true);
				if (out[i].x < 0) out[i].x = 0;
				else if (out[i].x >= hWidth) out[i].x = hWidth - 1;
				if (out[i].y < 0) out[i].y = 0;
				else if (out[i].y >= hWidth) out[i].y = hHeight - 1;
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