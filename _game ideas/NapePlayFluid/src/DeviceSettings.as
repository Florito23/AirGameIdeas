package 
{
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	/**
	 * ...
	 * @author 0L4F
	 */
	
	
	public class DeviceSettings 
	{
		
		
		public function DeviceSettings()
		{
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
			NativeApplication.nativeApplication.addEventListener(KeyboardEvent.KEY_DOWN, handleKeyDown);
		}
		
		
		
		// ANDROID KeyboardEvents:
		
		private function handleKeyDown(e:KeyboardEvent) :void
		{
			switch(e.keyCode)
			{
				case Keyboard.BACK:
					NativeApplication.nativeApplication.exit();
					break;
		 
				case Keyboard.SEARCH:
				case Keyboard.MENU:
					e.preventDefault();
					break;
			}
		}
	}	
}