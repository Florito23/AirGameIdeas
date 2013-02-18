package 
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	
	/**
	 * ...
	 * @author Marcus Graf
	 */
	[SWF(frameRate="60")]
	public class Main extends Sprite 
	{
		
		private var MAX_MOUSE:Number = 50;
		
		private var DATA_AMOUNT:int = 150;
		private var DISPLAY_WIDTH:int = 300;
		private var DISPLAY_HEIGHT:int = 100;
		private var DISPLAY_SPACE:int = 40;
		
		private var rawX:DataDisplay, rawY:DataDisplay;
		private var dispLpfX:DataDisplay, dispLpfY:DataDisplay;
		private var dispHpfX:DataDisplay, dispHpfY:DataDisplay;
		private var dispHpfXYAdd:DataDisplay;
		private var dispRawDir:DataDisplay, dispLpfDir:DataDisplay, dispHpfDir:DataDisplay;
		
		private var lpfX:Filter, lpfY:Filter;
		private var hpfX:Filter, hpfY:Filter;
		
		private var drawSprite:Sprite;
		
		private var squareGesture:SquareGesture = new SquareGesture();
		
		public function Main():void 
		{
			// touch or gesture?
			Multitouch.inputMode = MultitouchInputMode.NONE;
			
			lpfX = new LPF(0.8); // higher values -> lower cutoff = more smoothing
			lpfY = new LPF(0.8);
			
			hpfX = new HPF(0.9);
			hpfY = new HPF(0.9);
			
			// entry point
			addEventListener(Event.ADDED_TO_STAGE, init);
			// new to AIR? please read *carefully* the readme.txt files!
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.DEACTIVATE, deactivate);
			
			rawX = new DataDisplay("rawX",DISPLAY_WIDTH, DISPLAY_HEIGHT, DATA_AMOUNT, -MAX_MOUSE, MAX_MOUSE);
			rawX.x = 10;
			rawX.y = DISPLAY_SPACE;
			addChild(rawX);
			
			rawY = new DataDisplay("rawY",DISPLAY_WIDTH, DISPLAY_HEIGHT, DATA_AMOUNT, -MAX_MOUSE, MAX_MOUSE);
			rawY.x = 10;
			rawY.y = DISPLAY_SPACE+1*(DISPLAY_HEIGHT+DISPLAY_SPACE);
			addChild(rawY);
			
			dispRawDir = new DataDisplay("raw dir", DISPLAY_WIDTH, DISPLAY_HEIGHT, DATA_AMOUNT, -Math.PI, Math.PI);
			dispRawDir.x = 10 + DISPLAY_WIDTH + DISPLAY_SPACE;
			dispRawDir.y = rawX.y + (DISPLAY_HEIGHT + DISPLAY_SPACE + DISPLAY_HEIGHT) / 2 - DISPLAY_HEIGHT / 2;
			dispRawDir.sticks = true;
			addChild(dispRawDir);
			
			
			
			
			dispLpfX = new DataDisplay("LPF X",DISPLAY_WIDTH, DISPLAY_HEIGHT, DATA_AMOUNT, -MAX_MOUSE, MAX_MOUSE, 0xff0000, 0.5);
			dispLpfX.x = 10;
			dispLpfX.y = DISPLAY_SPACE+2*(DISPLAY_HEIGHT+DISPLAY_SPACE);
			addChild(dispLpfX);
			
			dispLpfY = new DataDisplay("LPF Y",DISPLAY_WIDTH, DISPLAY_HEIGHT, DATA_AMOUNT, -MAX_MOUSE, MAX_MOUSE, 0xff0000, 0.5);
			dispLpfY.x = 10;
			dispLpfY.y = DISPLAY_SPACE+3*(DISPLAY_HEIGHT+DISPLAY_SPACE);
			addChild(dispLpfY);
			
			dispLpfDir = new DataDisplay("LPF dir", DISPLAY_WIDTH, DISPLAY_HEIGHT, DATA_AMOUNT, -Math.PI, Math.PI, 0xff0000, 0.5);
			dispLpfDir.x = 10 + DISPLAY_WIDTH + DISPLAY_SPACE;
			dispLpfDir.y = dispLpfX.y + (DISPLAY_HEIGHT + DISPLAY_SPACE + DISPLAY_HEIGHT) / 2 - DISPLAY_HEIGHT / 2;
			dispLpfDir.sticks = true;
			addChild(dispLpfDir);
			
			
			
			
			dispHpfX = new DataDisplay("                    HPF X",DISPLAY_WIDTH, DISPLAY_HEIGHT, DATA_AMOUNT, -MAX_MOUSE, MAX_MOUSE, 0x00aa00, 0.5, false);
			dispHpfX.x = 10;
			dispHpfX.y = DISPLAY_SPACE+2*(DISPLAY_HEIGHT+DISPLAY_SPACE);
			addChild(dispHpfX);
			
			dispHpfY = new DataDisplay("                    HPF Y",DISPLAY_WIDTH, DISPLAY_HEIGHT, DATA_AMOUNT, -MAX_MOUSE, MAX_MOUSE, 0x00aa00, 0.5, false);
			dispHpfY.x = 10;
			dispHpfY.y = DISPLAY_SPACE+3*(DISPLAY_HEIGHT+DISPLAY_SPACE);
			addChild(dispHpfY);
			
			dispHpfDir = new DataDisplay("                    HPF dir", DISPLAY_WIDTH, DISPLAY_HEIGHT, DATA_AMOUNT, -Math.PI, Math.PI, 0x00aa00, 0.5, false);
			dispHpfDir.x = 10 + DISPLAY_WIDTH + DISPLAY_SPACE;
			dispHpfDir.y = dispLpfX.y + (DISPLAY_HEIGHT + DISPLAY_SPACE + DISPLAY_HEIGHT) / 2 - DISPLAY_HEIGHT / 2;
			dispHpfDir.sticks = true;
			addChild(dispHpfDir);
			
			
			
			
			dispHpfXYAdd = new DataDisplay("HPF abs(x)+abs(y)",DISPLAY_WIDTH, DISPLAY_HEIGHT, DATA_AMOUNT, -MAX_MOUSE, MAX_MOUSE, 0x00aa00);
			dispHpfXYAdd.x = 10;
			dispHpfXYAdd.y = DISPLAY_SPACE+4*(DISPLAY_HEIGHT+DISPLAY_SPACE);
			addChild(dispHpfXYAdd);
			
			
			
			
			
			
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			
			addEventListener(Event.ENTER_FRAME, updateData);
		}
		
		
		private var lmX:Number, lmY:Number;
		private var mX:Number, mY:Number;
		private var down:Boolean = false;
		private function mouseDown(e:MouseEvent):void 
		{
			down = true;
			//squareGesture = new SquareGesture();
			mX = e.stageX;
			mY = e.stageY;
			lmX = lmY = -9999
			rawX.clear();
			rawY.clear();
			dispHpfX.clear();
			dispHpfY.clear();
			dispLpfX.clear();
			dispLpfY.clear();
			dispRawDir.clear();
			dispLpfDir.clear();
			dispHpfDir.clear();
			
			updateData();
			
			if (drawSprite && drawSprite.parent == this) {
				removeChild(drawSprite);
			}
			
			drawSprite = new Sprite();
			addChild(drawSprite);
			drawSprite.graphics.lineStyle(3, 0x0000ff, 0.5);
			drawSprite.graphics.moveTo(mX, mY);
		}
		private function mouseMove(e:MouseEvent):void 
		{
			if (down) {
				mX = e.stageX;
				mY = e.stageY;
				drawSprite.graphics.lineTo(mX, mY);
			}
		}
		private function mouseUp(e:MouseEvent):void 
		{
			mX = e.stageX;
			mY = e.stageY;
			down = false;
			lmX = lmY = -9999
		}
		
		
		
		

		
		
		private function updateData(e:Event = null):void 
		{
			if (!down) {
				//rawX.addData(0);
			} else {
				if (lmX != -9999) {
					var dx:Number = mX - lmX;
					var dy:Number = mY - lmY;
					rawX.addData(dx);
					rawY.addData(dy);
					dispRawDir.addData(Math.atan2(dy, dx));
					
					var ldx:Number = lpfX.calc(dx);
					var ldy:Number = lpfY.calc(dy)
					dispLpfX.addData(ldx);
					dispLpfY.addData(ldy);
					dispLpfDir.addData(Math.atan2(ldy, ldx));
					
					var hdx:Number = hpfX.calc(dx);
					var hdy:Number = hpfX.calc(dy);
					dispHpfX.addData(hdx);
					dispHpfY.addData(hdy);
					dispHpfDir.addData(Math.atan2(hdy, hdx));
					dispHpfXYAdd.addData(Math.abs(hdx) + Math.abs(hdy));
					
					
				}
				lmX = mX;
				lmY = mY;
			}
			
			squareGesture.detect(down, dx, dy, ldx, ldy, hdx, hdy);
		}
		
		
		private function deactivate(e:Event):void 
		{
			// auto-close
			NativeApplication.nativeApplication.exit();
		}
		
	}
	
}