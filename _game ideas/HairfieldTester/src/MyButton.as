package  
{
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.text.Font;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import starling.display.Image;
	import starling.display.Quad;
	
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.display.Sprite;
	import starling.textures.Texture;
	import starling.utils.HAlign;
	
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class MyButton extends starling.display.Sprite 
	{
		//[Embed(source = "verdanab.ttf", fontFamily="Verdana Bold")]//, mimeType="application/x-font")]
		//private var VerdanaBold:Class;
		
		private var _touchFunc:Function;
		private var btf:TextField;
		
		public function MyButton(w:int, h:int, color:uint, text:String, tColor:uint, touchFunc:Function) 
		{
			//super();
			
			/*Font.registerFont(VerdanaBold);
			
			var rect:flash.display.Sprite = new flash.display.Sprite();
			rect.graphics.beginFill(color);
			rect.graphics.drawRect(0, 0, w, h);
			rect.graphics.endFill();
			
			var tff:TextFormat = new TextFormat();// "Verdana Bold", 12, tColor, true);
			tff.font = "Verdana Bold";
			tff.size = 12;
			tff.color = tColor;
			
			var tf:TextField = new TextField();
			tf.border = true;
			tf.embedFonts = true;
			tf.textColor = tColor;
			tf.text = text;
			tf.setTextFormat(tff);*/
			
			/*var bmp:BitmapData = new BitmapData(w, h);// , true, color);
			bmp.draw(rect);
			bmp.draw(tf);
			var texture:Texture = Texture.fromBitmapData(bmp);
			
			super(texture);*/
			//addChild(new Image(texture));
			addChild(new Quad(w, h, color));
			
			btf = new TextField(w, h, text, "Verdana", 12, tColor, true);
			btf.hAlign = HAlign.CENTER;
			addChild(btf);
			
			
			
			this._touchFunc = touchFunc;
			
			flatten();
			addEventListener(TouchEvent.TOUCH, onTouch);
		}
		
		public function set text(value:String):void {
			unflatten();
			btf.text = value;
			flatten();
		}
		
		private function onTouch(e:TouchEvent):void 
		{
			e.stopImmediatePropagation();
			
			var t:Touch = e.getTouch(this, TouchPhase.BEGAN);
			if (t) {
				_touchFunc.call();
			}
			
		}
		
	}

}