package simplemixer 
{
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public interface SoundSource 
	{
		
		function set active(value:Boolean):void;
		function get active():Boolean;
		function set panning(value:Number):void;
		function get panning():Number;
		
		function getLeftAndRight(amount:int, targetLeft:Vector.<Number>, targetRight:Vector.<Number>):void
		
	}

}