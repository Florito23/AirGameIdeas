package tests 
{
	import flash.display.DisplayObject;
	import flash.display.SimpleButton;
	import flash.display.Sprite;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class TextButton extends SimpleButton 
	{
		
		[Embed(source="VERDANAB.TTF", fontName="Verdana Bold", mimeType="application/x-font-truetype", embedAsCFF="false")]
		private var VerdanaClass:Class;
		
		public function TextButton(text:String) 
		{
			var sprite:Sprite = new Sprite();
			
			Font.registerFont(VerdanaClass);
			var textField:TextField = new TextField();
			textField.embedFonts = true;
			textField.textColor = 0xffffffff;
			textField.background = true;
			textField.backgroundColor = 0xff222222;
			textField.width = 300;
			textField.height = 40;
			var format:TextFormat = new TextFormat("Verdana Bold", 24, 0xdddddd);// true);
			format.align = TextFormatAlign.CENTER;
			textField.defaultTextFormat = format;
			textField.text = text;
			textField.selectable = false;
			sprite.addChild(textField);
			
			super(sprite, sprite, sprite, sprite);
		}
		
	}

}