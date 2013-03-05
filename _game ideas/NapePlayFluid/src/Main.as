package  
{
	import animations.Explosion;
	import animations.Sparkle;
	import com.greensock.TweenMax;
	import hud.Hud;
	
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	
	import nape.callbacks.*;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Material;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	import nape.space.Space;
	
	import starling.core.Starling;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.ResizeEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.utils.deg2rad;
	
	/**
	 * ...
	 * @author 0L4F 
	*/
	
	
	public class Main extends Sprite
	{
		//[Embed(source="media/textures/back.png")]
		[Embed(source="media/textures/backMetalGate.png")]
		private var back:Class;
		
		private var space:Space;
		private var player:Body;
		
		private var interactionListener:InteractionListener;
		private var ballToBallInteractionListener:InteractionListener;
        private var wallCollisionType:CbType = new CbType();
        private var ballCollisionType:CbType = new CbType();
        private var playerCollisionType:CbType = new CbType();
		
		private var sw:uint;
		private var sh:uint;
		
		//private var accelero:AccelerometerHandler;
		
		private var sparkle:Sparkle;
		private var explosion:Explosion;
		private var _hud:Hud;
		private var charge:uint;
		private var startTime:int;
		private var napeGraphics:Sprite;
		
		
		
		public function Main() 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			//accelero = new AccelerometerHandler();
			
			addChild(Image.fromBitmap(new back()));
			
			napeGraphics = new Sprite();
			addChild(napeGraphics);
			_hud = new Hud();
			addChild(_hud);
			
			//sparkle = new Sparkle();
			
			explosion = new Explosion();
			
			//space = new Space(new Vec2(0, 100));
			space = new Space(new Vec2(0, 100));
			
			interactionListener=new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, wallCollisionType, ballCollisionType, ballToWall);
            space.listeners.add(interactionListener);
			
			ballToBallInteractionListener=new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, ballCollisionType, ballCollisionType, ballToBall);
            space.listeners.add(ballToBallInteractionListener);
			
			var floor:Body = new Body(BodyType.STATIC);
			floor.shapes.add(new Polygon(Polygon.rect(0, 800, 480, 1)));
			floor.space = space;
			floor.cbTypes.add(wallCollisionType);
			
			/*
			var ceiling:Body = new Body(BodyType.STATIC);
			ceiling.shapes.add(new Polygon(Polygon.rect(0, 0, 480, 1)));
			ceiling.space = space;
			ceiling.cbTypes.add(wallCollisionType);
			*/
			
			var ceilingL:Body = new Body(BodyType.STATIC);
			ceilingL.shapes.add(new Polygon(Polygon.rect(0, 0, 200, 8)));
			ceilingL.space = space;
			ceilingL.cbTypes.add(wallCollisionType);
			
			var ceilingR:Body = new Body(BodyType.STATIC);
			ceilingR.shapes.add(new Polygon(Polygon.rect(280, 0, 200, 8)));
			ceilingR.space = space;
			ceilingR.cbTypes.add(wallCollisionType);
			
			var wallLeft:Body = new Body(BodyType.STATIC);
			wallLeft.shapes.add(new Polygon(Polygon.rect(0, 0, 1, 800)));
			wallLeft.space = space;
			wallLeft.cbTypes.add(wallCollisionType);
			
			var wallRight:Body = new Body(BodyType.STATIC);
			wallRight.shapes.add(new Polygon(Polygon.rect(480, 0, 1, 800)));
			wallRight.space = space;
			wallRight.cbTypes.add(wallCollisionType);
			
			
			var waterShape:Polygon = new Polygon(Polygon.rect(0, 0, 480, 800));
			waterShape.fluidEnabled = true;
			waterShape.fluidProperties.density = 0;
			waterShape.fluidProperties.viscosity = 0.25;
			
			var waterBody:Body = new Body(BodyType.STATIC);
			waterBody.shapes.add(waterShape);
			waterBody.space = space;
			
			//space.bodies.add(waterBody);
			
			
			addPlayer();
			
			for (var i:int = 0; i < 32; i++) 
			{
				addBall();
			}
			
			
			stage.addEventListener(ResizeEvent.RESIZE, onResize);
			
			addEventListener(TouchEvent.TOUCH, onTouch);
			
			addEventListener(Event.ENTER_FRAME, loop);
		}
		
		
		
		private function addPlayer():void 
		{
			player = new Body(BodyType.DYNAMIC, new Vec2(480 >> 1, 800 >> 1));
			player.shapes.add(new Circle(64, null, new Material(1000)));
			player.allowRotation = false;
			player.space = space;
			player.cbTypes.add(playerCollisionType);
			player.userData.graphic = new Player();
			player.userData.graphicUpdate = updatePlayerGraphics;
			napeGraphics.addChild(player.userData.graphic);
		}
		
		
		
		private function loop(event:Event):void 
		{
			//space.gravity = new Vec2(accelero.accelX * 256, accelero.accelY * 256);
			
			space.step(1 / 60);
			
			space.liveBodies.foreach(function (b:Body):void {
				if (b.userData.graphicUpdate != null)
					b.userData.graphicUpdate(b);
			});
			
			//if (Math.random() < 0.002) addBall();
		}
		
		
		
		private function addBall():void 
		{
			//_hud.changeScore(1);
			
			var posX:int = Math.random() * 480;
			var posY:int = Math.random() * 800;
			var size:uint = 25 + Math.random() * 50;
			
			var ball:Body = new Body(BodyType.DYNAMIC, new Vec2(posX, posY));
			//ball.shapes.add(new Circle(size * 0.5, null, new Material(1, 1, 2, 1/size)));
			ball.shapes.add(new Circle(size * 0.5, null, new Material(16)));
			ball.allowRotation = false;
			ball.space = space;
			ball.cbTypes.add(ballCollisionType);
			ball.userData.graphic = new Ball(size);
			ball.userData.graphicUpdate = updateGraphics;
			napeGraphics.addChild(ball.userData.graphic);
			
			/*
			sparkle.x = posX;
			sparkle.y = posY;
			sparkle.scaleX = sparkle.scaleY = Math.sqrt(ball.mass);
			sparkle.rotation = deg2rad(Math.random()*360);
			addChild(sparkle);
			sparkle.start();
			*/
		}
		
		
		private function updateGraphics(b:Body):void 
		{
			if (b.position.y < b.userData.graphic.height * -1)
			{
				napeGraphics.removeChild(b.userData.graphic);
				space.bodies.remove(b);
				_hud.changeScore(b.userData.graphic.height);
			}
			
			b.userData.graphic.x = b.position.x;
			b.userData.graphic.y = b.position.y;
			b.userData.graphic.rotation = b.rotation;
		}
		
		
		private function updatePlayerGraphics(b:Body):void 
		{
			b.userData.graphic.x = b.position.x;
			b.userData.graphic.y = b.position.y;
			b.userData.graphic.rotation = b.rotation;			
		}
		
		
		
		private function onTouch(te:TouchEvent):void
		{
			if (te.getTouch(stage, TouchPhase.BEGAN))
			{
				startTime = flash.utils.getTimer(); // Milliseconds since flash player started
			}
			
 			else var touch:Touch = te.getTouch(stage, TouchPhase.ENDED);
			
			if (touch)
			{
				charge = (flash.utils.getTimer() - startTime) * 0.1;
				
				if (charge > 128) charge = 128;
				
				var impulse:Vec2 = new Vec2((player.position.x - touch.globalX) * charge, (player.position.y - touch.globalY) * charge);
				player.applyImpulse(impulse);
			}
		}
		
		
		
		private function updatePlayerPos(b:Body):void 
		{
			b.position.x = b.userData.graphic.x; 
			b.position.y = b.userData.graphic.y; 
		}
		
		
		
		private function ballToWall(collision:InteractionCallback):void 
		{
			/*
			var body:Body = collision.int2.castBody;
			
			explosion.x = body.position.x;
			explosion.y = body.position.y;
			explosion.rotation = deg2rad(Math.random()*360);
			addChild(explosion);
			explosion.start();
			
			// destroying it and removing its graphic asset if dynamic
			// we don't want to remove the floor although it's outside the stage
			if (body.type==BodyType.DYNAMIC) {
				removeChild(body.userData.graphic);
				space.bodies.remove(body);
			}
			*/
			
			//addBall();
        }
		
		
		private function ballToBall(collision:InteractionCallback):void 
		{
			
			var body1:Body = collision.int1.castBody;
			var body2:Body = collision.int2.castBody;
			
			var body:Body = (body1.mass < body2.mass)? body1 : body2;
			
			explosion.x = body.position.x;
			explosion.y = body.position.y;
			explosion.scaleX = explosion.scaleY = Math.sqrt(body.mass);
			explosion.rotation = deg2rad(Math.random()*360);
			addChild(explosion);
			explosion.start();
			
			// destroying it and removing its graphic asset if dynamic
			// we don't want to remove the floor although it's outside the stage
			if (body.type==BodyType.DYNAMIC) {
				removeChild(body.userData.graphic, true);
				space.bodies.remove(body);
				
				//_hud.changeScore(-1);
			}
			
        }
		
		
		
		private function onResize(e:ResizeEvent):void
		{			
			sw = e.width;
			sh = e.height;
			
			// set rect dimmensions
			var rect:Rectangle = new Rectangle();
			rect.width = sw, rect.height = sh;
			
			// resize the viewport
			Starling.current.viewPort = rect;
			
			// assign the new stage width and height
			stage.stageWidth = sw;
			stage.stageHeight = sh;
		}
		
		public function setSize(sw:uint, sh:uint):void
		{
			// set rect dimmensions
			var rect:Rectangle = new Rectangle();
			rect.width = sw, rect.height = sh;
			
			// resize the viewport
			Starling.current.viewPort = rect;
			
			// assign the new stage width and height
			stage.stageWidth = sw;
			stage.stageHeight = sh;
		}
		
	}

}