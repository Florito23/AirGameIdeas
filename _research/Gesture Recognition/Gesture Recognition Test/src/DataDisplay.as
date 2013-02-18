package  
{
	import flash.display.CapsStyle;
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class DataDisplay extends Sprite
	{
		
		private var _height:Number;
		private var dataRecorder:DataRecorder;
		private var dataSprite:Sprite;
		private var mappedValues:Vector.<Number>;
		private var valueIndexToX:Number;
		private var drawColor:int = 0x000000;
		private var drawAlpha:Number = 1.0;
		
		private var _stickWidth:Number;
		private var _sticks:Boolean = false;
		
		public function DataDisplay(name:String, width:Number, height:Number, dataAmount:int, minValue:Number, maxValue:Number, color:uint=0x000000, alpha:Number = 1.0, border:Boolean=true) 
		{
			super();
			
			_height = height;
			var tf:TextField = new TextField();
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.text = name;
			tf.x = 0;
			tf.y = -20;
			var tff:TextFormat = new TextFormat("Verdana", 12, color, true);
			tf.setTextFormat(tff);
			addChild(tf);
			
			mappedValues = new Vector.<Number>(dataAmount);
			valueIndexToX = width / dataAmount;
			_stickWidth = valueIndexToX;
			
			dataRecorder = new DataRecorder(dataAmount, minValue, maxValue, 0, height);
			dataRecorder.clear();
			
			drawColor = color;
			drawAlpha = alpha;
			
			dataSprite = new Sprite();
			addChild(dataSprite);
			
			if (border) {
				var borderSprite:Sprite = new Sprite();
				addChild(borderSprite);
				borderSprite.graphics.lineStyle(2);
				borderSprite.graphics.beginFill(0xdddddd);
				borderSprite.graphics.drawRect(0, 0, width, height);
				borderSprite.graphics.endFill();
			}
			
		}
		
		public function clear():void {
			dataRecorder.clear();
		}
		
		public function addData(value:Number):void {
			dataRecorder.addValue(value);
			dataRecorder.getMappedValues(mappedValues);
			
			removeChild(dataSprite);
			dataSprite = new Sprite();
			addChild(dataSprite);
			
			var g:Graphics = dataSprite.graphics;
			
			var i:int, xx:Number;
			if (_sticks) {
				g.lineStyle(_stickWidth, drawColor, drawAlpha, false, "normal", CapsStyle.NONE);
				for (i = 0; i < mappedValues.length; i++) {
					xx = valueIndexToX * i;
					g.moveTo(xx, _height / 2);
					g.lineTo(xx, mappedValues[i]);
				}
			} else {
				g.lineStyle(1, drawColor, drawAlpha);
				for (i = 0; i < mappedValues.length; i++) {
					if (i == 0) {
						g.moveTo(valueIndexToX * i, mappedValues[i]);
					} else {
						g.lineTo(valueIndexToX * i, mappedValues[i]);
					}
				}
			}
			
		}
		
		public function set sticks(value:Boolean):void 
		{
			_sticks = value;
		}
		
	}

}