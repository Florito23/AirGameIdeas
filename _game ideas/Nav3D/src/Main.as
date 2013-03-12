package 
{
	import away3d.Away3D;
	import away3d.cameras.Camera3D;
	import away3d.cameras.lenses.FreeMatrixLens;
	import away3d.cameras.lenses.LensBase;
	import away3d.cameras.lenses.ObliqueNearPlaneLens;
	import away3d.cameras.lenses.OrthographicLens;
	import away3d.cameras.lenses.OrthographicOffCenterLens;
	import away3d.cameras.lenses.PerspectiveLens;
	import away3d.containers.View3D;
	import away3d.controllers.ControllerBase;
	import away3d.controllers.FirstPersonController;
	import away3d.core.math.Plane3D;
	import away3d.core.partition.QuadTree;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.PlaneGeometry;
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import flash.system.Capabilities;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.Dictionary;
	
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class Main extends Sprite 
	{
		
		private var _view:View3D;
		
		//http://www.dakmm.com/?p=272
		private var KEY_MOVE:uint = 		32; 	// SPACE
		private var KEY_YAW_LEFT:uint = 	37; 	// left arrow
		private var KEY_YAW_RIGHT:uint = 	39; 	// right arrow
		private var KEY_PITCH_UP:uint = 	40; 	// down arrow
		private var KEY_PITCH_DOWN:uint = 	38; 	// right arrow
		private var KEY_ROLL_RIGHT:uint = 	34; 	// page down
		private var KEY_ROLL_LEFT:uint = 	46; 	// delete
		
		public function Main():void 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.DEACTIVATE, deactivate);
			
			// touch or gesture?
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			// entry point
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			_view = new View3D();
			addChild(_view);
			
			//_cameraController = new FirstPersonController(_view.camera);
			
			_view.camera.z = 0; // -1000 default
			_view.camera.lookAt(new Vector3D(0,0,1));
			_view.camera.lens = new PerspectiveLens(60);
			//_view.camera.
			
			for (var i:int = 0; i < 1000; i++) {
				var m:Mesh = new Mesh(new CubeGeometry(10, 10, 10));
				m.x = (Math.random() - 0.5) * 5000;
				m.y = (Math.random() - 0.5) * 5000;
				m.z = (Math.random() - 0.5) * 5000;
				_view.scene.addChild(m);
			}
			
			var awayStats:AwayStats = new AwayStats(_view);
			addChild(awayStats);
			
			if (!isMobile()) {
				// mouse to touch listeners
				trace("Making mouse to touch listeners");
				stage.addEventListener(MouseEvent.MOUSE_DOWN, function(me:MouseEvent):void {
					var te:TouchEvent = new TouchEvent(TouchEvent.TOUCH_BEGIN, true, false, 0, false, me.stageX, me.stageY);
					stage.dispatchEvent(te);
				});
				stage.addEventListener(MouseEvent.MOUSE_MOVE, function(me:MouseEvent):void {
					var te:TouchEvent = new TouchEvent(TouchEvent.TOUCH_MOVE, true, false, 0, false, me.stageX, me.stageY);
					stage.dispatchEvent(te);
				});
				stage.addEventListener(MouseEvent.MOUSE_UP, function(me:MouseEvent):void {
					var te:TouchEvent = new TouchEvent(TouchEvent.TOUCH_END, true, false, 0, false, me.stageX, me.stageY);
					stage.dispatchEvent(te);
				});
			}
			
			stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
			stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);
			
			addEventListener(Event.ENTER_FRAME, frame);
			addEventListener(MouseEvent.CLICK, onClick);
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
			stage.addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
		}
		
		
		
		
		/*
		 * 
		 * TOUCHING
		 * 
		 */
		
		 //TODO two-finger rolling
		  
		private var touches:Array = new Array();
		private var touchesDown:int = 0;
		 
		private function onTouchBegin(e:TouchEvent):void 
		{
			touches["id" + e.touchPointID] = new Point(e.stageX, e.stageY);
			touchesDown++;
			
			if (touchesDown == 1) {
				targetSpeed = SPEED_MAX;
			}
		}
		private function onTouchMove(e:TouchEvent):void 
		{
			var identifier:String = "id" + e.touchPointID;
			if (touches[identifier]) {
				
				if (touchesDown == 1) {
					
					var point:Point = new Point(e.stageX, e.stageY);
					var deltaPoint:Point = point.subtract(touches[identifier] as Point);
					targetYawAngle = deltaPoint.x / stage.stageWidth * 6;
					targetPitchAngle = deltaPoint.y / stage.stageWidth * 6;
					//touches[identifier] = point;
					//invalidateYaw = true;
					
				}
				
			}
		}
		private function onTouchEnd(e:TouchEvent):void 
		{
			touches["id" + e.touchPointID] = null;
			touchesDown--;
			
			if (touchesDown == 0) {
				targetSpeed = 0;
				targetYawAngle = 0;
				targetPitchAngle = 0;
			}
		}
			
		
		
		
		
		
		private function onKeyDown(e:KeyboardEvent):void 
		{
			changeCam(e.keyCode, true);
		}
		private function onKeyUp(e:KeyboardEvent):void 
		{
			changeCam(e.keyCode, false);
		}
		
		
		
		private var CAM_SMOOTH:Number = 0.98;
		
		private var SPEED_MAX:Number = 10;
		private var targetSpeed:Number = 0, speed:Number = 0;
		
		private var YAW_SMOOTH:Number = 0.97;
		private var YAW_MAX:Number = 1;
		private var targetYawAngle:Number = 0;
		private var yawAngle:Number = 0;
		//private var invalidateYaw:Boolean = false;
		
		private var PITCH_SMOOTH:Number = 0.97;
		private var PITCH_MAX:Number = 1;
		private var targetPitchAngle:Number = 0;
		private var pitchAngle:Number = 0;
		
		private var ROLL_MAX:Number = 1;
		private var targetRollAngle:Number = 0;
		private var rollAngle:Number = 0;
		
		private function changeCam(keyCode:uint, press:Boolean):void 
		{
			switch(keyCode) {
				case KEY_MOVE:
					targetSpeed = press ? 		SPEED_MAX:0; 	break;
				case KEY_YAW_LEFT:
					targetYawAngle = press ? 	-YAW_MAX:0;		break;
				case KEY_YAW_RIGHT:
					targetYawAngle = press ? 	YAW_MAX:0;		break;
				case KEY_PITCH_UP:
					targetPitchAngle = press ? 	-PITCH_MAX:0;	break;
				case KEY_PITCH_DOWN:
					targetPitchAngle = press ? 	PITCH_MAX:0;	break;
				case KEY_ROLL_LEFT:
					targetRollAngle = press ? 	ROLL_MAX:0;		break;
				case KEY_ROLL_RIGHT:
					targetRollAngle = press ? 	-ROLL_MAX:0;	break;
			}
		}
		
		
		
		private function frame(e:Event):void 
		{
			var c:Camera3D = _view.camera;
			
			yawAngle = YAW_SMOOTH * yawAngle + (1 - YAW_SMOOTH) * targetYawAngle;
			pitchAngle = PITCH_SMOOTH * pitchAngle + (1 - PITCH_SMOOTH) * targetPitchAngle;
			rollAngle = CAM_SMOOTH * rollAngle + (1 - CAM_SMOOTH) * targetRollAngle;
			
			speed = CAM_SMOOTH * speed + (1 - CAM_SMOOTH) * targetSpeed;
			
			c.yaw(yawAngle);
			c.pitch(pitchAngle);
			c.roll(rollAngle);
			c.moveForward(speed);
			
			/*if (invalidateYaw) {
				invalidateYaw = false;
				targetYawAngle = 0;
			}*/
			
			_view.render();
		}
		
		
		private function onClick(e:MouseEvent):void 
		{
			
		}
		
		private function deactivate(e:Event):void 
		{
			// auto-close
			NativeApplication.nativeApplication.exit();
		}
		
		private static function isMobile():Boolean 
		{
			return isAndroid() || isIOS();
		}
		
		private static function isAndroid():Boolean
		{
			return (Capabilities.version.substr(0,3).toUpperCase() == "AND"); 
		}
		private static function isIOS():Boolean
		{
			return (Capabilities.version.substr(0,3).toUpperCase() == "IOS");
		}
		
	}
	
}