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
		
		public static const HEIGHT:int = 60;
		public static const WIDTH:int = 500;
		
		public function TextButton(text:String) 
		{
			var sprite:Sprite = new Sprite();
			
			
			var textField:TextField = new TextField();
			textField.embedFonts = true;
			textField.textColor = 0xffffffff;
			textField.background = true;
			textField.backgroundColor = 0xff222222;
			textField.width = WIDTH;
			textField.height = HEIGHT;
			textField.cacheAsBitmap = true;
			textField.selectable = false;
			
			textField.defaultTextFormat = AllTests.textFormatVerdana32;
			textField.text = text;
			textField.selectable = false;
			sprite.addChild(textField);
			
			super(sprite, sprite, sprite, sprite);
		}
		
	}

}