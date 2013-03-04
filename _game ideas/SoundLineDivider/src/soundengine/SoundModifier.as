package soundengine 
{
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public interface SoundModifier 
	{
		
		function get active():Boolean;
		function set active(value:Boolean):void;
		
		function process(amount:int, inputLeft:Vector.<Number>, inputRight:Vector.<Number>, outputLeft:Vector.<Number>, outputRight:Vector.<Number>):void;
		
	}

}