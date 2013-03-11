package 
{
	import away3d.containers.View3D;
	import away3d.debug.AwayStats;
	import away3d.entities.Mesh;
	import away3d.materials.TextureMaterial;
	import away3d.primitives.CubeGeometry;
	import away3d.primitives.PlaneGeometry;
	import away3d.utils.Cast;
	import caurina.transitions.Tweener;
	import flash.desktop.NativeApplication;
	import flash.display.BlendMode;
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.getTimer;
	import platonics.Cube;
	import platonics.Dodecahedron;
	import platonics.Icosahedron;
	import platonics.Octahedron;
	import platonics.Tetrahedron;
	
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class Main extends Sprite 
	{
		public var hasMoved:Boolean = false;
		
		[Embed(source="platonics/textures/Cube1.png")]
		private var CubeTexture:Class;
		
		[Embed(source="platonics/textures/Tetrahedron1.png")]
		private var TetrahedronTexture:Class; //corners: 0/0	0.8660234375/0.5	0/1
		
		[Embed(source="platonics/textures/Pentagon.png")]
		private var PentagonTexture:Class;
		
		
		private var _view:View3D;
		private var _plane:Mesh;
		
		private var _cube:Mesh;
		private var _tetrahedron:Mesh;
		private var _octahedron:Mesh;
		private var _icosahedron:Mesh;
		private var _dodecahedron:Mesh;
		
		private var expanded:Boolean = false;
		
		private var camRadians:Number = 0;
		private var camRotAdd:Number = 0;
		
		private var camTargetPosY:Number = 300;
		private var camPosY:Number = 300;
		
		private var camTargetRotAdd:Number = 0;
		private var camLookAt:Vector3D = new Vector3D();
		
		private var mouseIsDown:Boolean = false;
		private var lastStageX:Number, lastStageY:Number;
		
		
		public function Main():void 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.DEACTIVATE, deactivate);
			
			// touch or gesture?
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			// entry point
			addEventListener(Event.ADDED_TO_STAGE, init);
			// new to AIR? please read *carefully* the readme.txt files!
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// setup 3d
			_view = new View3D();
			addChild(_view);
			
			//setup the camera
			_view.camera.y = camPosY;
			_view.camera.lookAt(camLookAt);
			
			//setup the scene
			/*_plane = new Mesh(new PlaneGeometry(700, 700));
			_plane.material.bothSides = true;
			_plane.y = -100;
			_view.scene.addChild(_plane);*/
			
			
			var tm:TextureMaterial;
			
			// cube
			tm = new TextureMaterial(Cast.bitmapTexture(CubeTexture));
			tm.alphaBlending = true;
			tm.blendMode = BlendMode.ADD;
			tm.bothSides = true;
			_cube = new Mesh(new Cube(100), tm);
			_view.scene.addChild(_cube);
			
			// tetrahedron
			tm = new TextureMaterial(Cast.bitmapTexture(TetrahedronTexture));
			tm.alphaBlending = true;
			tm.blendMode = BlendMode.ADD;
			tm.bothSides = true;
			_tetrahedron = new Mesh(new Tetrahedron(100, 256), tm);
			_view.scene.addChild(_tetrahedron);
			
			// octahedron
			tm = new TextureMaterial(Cast.bitmapTexture(TetrahedronTexture));
			tm.alphaBlending = true;
			tm.blendMode = BlendMode.ADD;
			tm.bothSides = true;
			_octahedron = new Mesh(new Octahedron(100, 256), tm);
			_view.scene.addChild(_octahedron);
			
			// icosahedron
			tm = new TextureMaterial(Cast.bitmapTexture(TetrahedronTexture));
			tm.alphaBlending = true;
			tm.blendMode = BlendMode.ADD;
			tm.bothSides = true;
			_icosahedron = new Mesh(new Icosahedron(100, 256), tm);
			_view.scene.addChild(_icosahedron);
			
			// dodecahedron
			tm = new TextureMaterial(Cast.bitmapTexture(PentagonTexture));
			tm.alphaBlending = true;
			tm.blendMode = BlendMode.ADD;
			tm.bothSides = true;
			_dodecahedron = new Mesh(new Dodecahedron(100, 256), tm);// , tm);
			_view.scene.addChild(_dodecahedron);
			
			tweenObjects();
			
			var awayStats:AwayStats = new AwayStats(_view);
			addChild(awayStats);
			
			addEventListener(Event.ENTER_FRAME, frame);
			stage.addEventListener(MouseEvent.MOUSE_DOWN, mouseDown);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			stage.addEventListener(MouseEvent.RIGHT_CLICK, onRightClick);
		}
		
		private function onRightClick(e:MouseEvent = null):void 
		{
			_cube.material.bothSides = !_cube.material.bothSides;
			_tetrahedron.material.bothSides = !_tetrahedron.material.bothSides;
			_octahedron.material.bothSides = !_octahedron.material.bothSides;
			_icosahedron.material.bothSides = !_icosahedron.material.bothSides;
			_dodecahedron.material.bothSides = !_dodecahedron.material.bothSides;
		}
		
		
		private function mouseMove(e:MouseEvent):void 
		{
			if (mouseIsDown) {
				hasMoved = true;
				var dx:Number = e.stageX - lastStageX;
				var dy:Number = e.stageY - lastStageY;
				lastStageX = e.stageX;
				lastStageY = e.stageY;
				
				camTargetPosY += dy;
				//_view.camera.y += dy;
				camTargetRotAdd = dx * 0.0015;
				//camRadians += dx * 0.002;
			}
		}
		
		private function mouseUp(e:MouseEvent):void 
		{
			var ti:int = getTimer();
			var dt:int = ti - lti;
			if (!hasMoved && dt>500) {
				onRightClick();
			}
			mouseIsDown = false;
		}
		
		private var lti:int = 0;
		private function mouseDown(e:MouseEvent):void 
		{
			hasMoved = false;
			var ti:int = getTimer();
			var dt:int = ti - lti;
			if (dt < 250) {
				tweenObjects();
			}
			lti = ti;
			
			mouseIsDown = true;
			lastStageX = e.stageX;
			lastStageY = e.stageY;
		}
		
		private function tweenObjects():void 
		{
			var ti:Number = 2.0;
			if (!expanded) {
				Tweener.addTween(_cube, { time:ti, x: -200 } );
				Tweener.addTween(_octahedron, { time:ti, x: 200 } );
				Tweener.addTween(_icosahedron, { time:ti, z: 200 } );
				Tweener.addTween(_dodecahedron, { time:ti, z: -200 } );
				expanded = true;
			} else {
				Tweener.addTween(_cube, { time:ti, x: 0 } );
				Tweener.addTween(_octahedron, { time:ti, x: 0 } );
				Tweener.addTween(_icosahedron, { time:ti, z: 0 } );
				Tweener.addTween(_dodecahedron, { time:ti, z: 0 } );
				expanded = false;
			}
		}
		
		
		private function frame(e:Event):void 
		{
			
			if (!mouseIsDown) {
				camTargetRotAdd = Math.PI * 2 / 360 / 2;
				//camRadians += Math.PI * 2 / 360 / 2;
			} else {
				//camTargetRotAdd = 0;
			}
			
			if (Math.abs(camTargetRotAdd) > Math.abs(camRotAdd)) {
				camRotAdd = 0.5 * camRotAdd + 0.5 * camTargetRotAdd;
			} else {
				camRotAdd = 0.95 * camRotAdd + 0.05 * camTargetRotAdd;
			}
			camRadians += camRotAdd;
			
			camPosY = 0.95 * camPosY + 0.05 * camTargetPosY;
			
			
			_view.camera.z = -400 * Math.cos(camRadians);
			_view.camera.x = -400 * Math.sin(camRadians);
			_view.camera.y = camPosY;
			_view.camera.lookAt(camLookAt);
			
			_view.render();
		}
		
		private function deactivate(e:Event):void 
		{
			// auto-close
			NativeApplication.nativeApplication.exit();
		}
		
	}
	
}