package soundengine 
{
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public interface SoundSource 
	{
		
		function set active(value:Boolean):void;
		function get active():Boolean;
		
		function generate(amount:int, outputLeft:Vector.<Number>, outputRight:Vector.<Number>):void
		
	}

}