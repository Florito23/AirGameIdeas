package  
{
	import flash.desktop.NativeApplication;
	import flash.geom.Vector3D;
	import flash.utils.Dictionary;
	import flash.utils.getTimer;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.EnterFrameEvent;
	import starling.events.Event;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.utils.Color;
	import traer.physics.Particle;
	import traer.physics.ParticleSystem;
	import traer.physics.Spring;
	
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class SoundLineGame extends Sprite 
	{
		
		private var physics:ParticleSystem;
		private var A:Particle;
		private var B:Particle;
		private var particleQuadDictionary:Dictionary = new Dictionary();
		private var quadParticleDictionary:Dictionary = new Dictionary();
		private var springLineDictionary:Dictionary = new Dictionary();
		private var particleWereFixedDictionary:Dictionary = new Dictionary();
		
		private var PARTICLE_SCREEN_SIZE:Number = 40;
		private var PARTICLE_FIXED_COLOR:uint = 0xffff0000;
		private var PARTICLE_FREE_COLOR:uint = 0xff0088ff;
		
		private var SPRING_AMOUNT:int = 12;
		private var SPRING_CONSTANT:Number = 0.5;
		private var SPRING_DAMPING:Number = 0.2;
		
		private var DOUBLE_TOUCH_TIME:int = 200;
		
		private var draggingQuads:Array = new Array();
		
		public function SoundLineGame() 
		{
			addEventListener(Event.ADDED_TO_STAGE, init);
			
		}
		
		private function init(e:Event):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// init physics
			physics = new ParticleSystem(new Vector3D(0, 2, 0), 0.15);
			
			// create two points
			var aPos:Vector3D = new Vector3D(stage.stageWidth * 0.15, stage.stageHeight * 0.5, 0);
			var bPos:Vector3D = new Vector3D(stage.stageWidth * 0.85, stage.stageHeight * 0.5, 0);
			A = physics.makeParticle(0.5, aPos);
			B = physics.makeParticle(0.5, bPos);
			A.fixed = true;
			B.fixed = true;
			particleWereFixedDictionary[A] = true;
			particleWereFixedDictionary[B] = true;
			
			// create multiple particles / springs inbetween
			var springCount:int = SPRING_AMOUNT;
			var particleCount:int = springCount - 1;
			var ab:Vector3D = new Vector3D(B.position.x - A.position.x, B.position.y - A.position.y);
			var dx:Number = ab.x;
			var dy:Number = ab.y;
			var dStepX:Number = dx / springCount;
			var dStepY:Number = dy / springCount;
			var stepLen:Number = Math.sqrt(dStepX * dStepX + dStepY * dStepY);
			
			var particles:Vector.<Particle> = new Vector.<Particle>();
			var springs:Vector.<Spring> = new Vector.<Spring>();
			var particle:Particle;
			for (var i:int = 0; i < particleCount; i++) {
				var x:Number = aPos.x + dStepX * (i + 1);
				var y:Number = aPos.y + dStepY * (i + 1);
				particle = physics.makeParticle(0.5, new Vector3D(x, y));
				particles.push(particle);
				particleWereFixedDictionary[particle] = false;
				
				var a:Particle, b:Particle;
				if (i == 0) {
					a = A;
					b = particles[i];
				} else {
					a = particles[i-1];
					b = particles[i]
				}
				springs.push(physics.makeSpring(a, b, SPRING_CONSTANT, SPRING_DAMPING, stepLen));
				if (i == particleCount - 1) {
					springs.push(physics.makeSpring(particles[i], B, SPRING_CONSTANT, SPRING_DAMPING, stepLen));
				}
				
			}
			
			// link springs to quadLines
			for each (var s:Spring in springs) {
				springLineDictionary[s] = createAndAddQuadLine(s.getOneEnd().position, s.getTheOtherEnd().position, 10, 0xff555555);
			}
			
			// link particles to quads
			particleQuadDictionary[A] = createAndAddQuad(PARTICLE_SCREEN_SIZE, PARTICLE_FIXED_COLOR);
			quadParticleDictionary[particleQuadDictionary[A]] = A;
			for each (particle in particles) {
				particleQuadDictionary[particle] = createAndAddQuad(PARTICLE_SCREEN_SIZE, PARTICLE_FREE_COLOR);
				quadParticleDictionary[particleQuadDictionary[particle]] = particle;
			}
			particleQuadDictionary[B] = createAndAddQuad(PARTICLE_SCREEN_SIZE, PARTICLE_FIXED_COLOR);
			quadParticleDictionary[particleQuadDictionary[B]] = B;
			
			
			// add interactivity
			for (var o:Object in quadParticleDictionary) {
				var quad:Quad = o as Quad;
				particle = quadParticleDictionary[o] as Particle;
				quad.addEventListener(TouchEvent.TOUCH, onQuadTouch);
			}
			
			stage.addEventListener(TouchEvent.TOUCH, onStageTouch);
			
			
			
			addEventListener(EnterFrameEvent.ENTER_FRAME, frame);
			
		}
		
		
		private var stageTouchTimes:Array = new Array();
		
		private function onStageTouch(e:TouchEvent):void 
		{
			// Detect double touch
			var touches:Vector.<Touch>;
			var touchAmount:int, i:int;
			var touchId:int;
			var lastTouchTime:int, currentTime:int, deltaTime:int;
			
			var draggingQuadsAmount:int = draggingQuads.length;
			var j:int;
			var quad:Quad, particle:Particle, fixed:Boolean;
			
			touches = e.getTouches(stage, TouchPhase.BEGAN);
			touchAmount = touches.length;
			currentTime = getTimer();
			for (i = 0; i < touchAmount; i++) {
				touchId = touches[i].id;
				if (!stageTouchTimes[touchId]) {
					stageTouchTimes[touchId] = currentTime;
				} else {
					// evaluate difference;
					lastTouchTime = stageTouchTimes[touchId];
					deltaTime = currentTime-lastTouchTime;
					stageTouchTimes[touchId] = currentTime;
					if (deltaTime < DOUBLE_TOUCH_TIME) {
						
						for (j = 0; j < draggingQuadsAmount; j++) {
							quad = draggingQuads[j];
							if (quad) {
								particle = quadParticleDictionary[quad];
								fixed = particleWereFixedDictionary[particle] = !particleWereFixedDictionary[particle];
								quad.color = fixed ? PARTICLE_FIXED_COLOR : PARTICLE_FREE_COLOR;
							}
						}
						
					}
				}
			}
		}
		
		
		
		private function onQuadTouch(e:TouchEvent):void 
		{
			var quad:Quad = e.target as Quad;
			var touches:Vector.<Touch>;
			var touchAmount:int, i:int;
			var particle:Particle;
			var touchId:int;
			
			// register quad touch down
			touches = e.getTouches(quad, TouchPhase.BEGAN);
			touchAmount = touches.length;
			for (i = 0; i < touchAmount; i++) {
				if (draggingQuads.indexOf(quad) == -1) {
					draggingQuads[touches[i].id] = quad;
					particle = quadParticleDictionary[quad] as Particle;
					particle.position.x = touches[i].globalX;
					particle.position.y = touches[i].globalY;
					particleWereFixedDictionary[particle] = particle.fixed;
					particle.makeFixed();
				}
			}
			
			touches = e.getTouches(quad, TouchPhase.MOVED);
			touchAmount = touches.length;
			for (i = 0; i < touchAmount; i++) {
				touchId = touches[i].id;
				quad = draggingQuads[touchId];
				if (quad) {
					particle = quadParticleDictionary[quad] as Particle;
					particle.position.x = touches[i].globalX;
					particle.position.y = touches[i].globalY;
				}
			}
			
			touches = e.getTouches(quad, TouchPhase.ENDED);
			touchAmount = touches.length;
			for (i = 0; i < touchAmount; i++) {
				touchId = touches[i].id;
				quad = draggingQuads[touchId];
				if (quad) {
					particle = quadParticleDictionary[quad] as Particle;
					particle.fixed = particleWereFixedDictionary[particle];
					draggingQuads[touchId] = null;
				}
			}
		}
		
		
		
		private function createAndAddQuadLine(a:Vector3D, b:Vector3D, thickness:Number, color:uint):QuadLine {
			var out:QuadLine = new QuadLine(a.x, a.y, b.x, b.y, thickness, color);
			out.touchable = false;
			addChild(out);
			return out;
		}
		
		private function createAndAddQuad(size:Number, color:uint):Quad {
			var out:Quad = new Quad(size, size, color);
			out.pivotX = size / 2;
			out.pivotY = size / 2;
			addChild(out);
			return out;
		}
		
		private function frame(e:EnterFrameEvent):void 
		{
			
			physics.tick();
			
			// draw quads:
			var particle:Particle;
			var quad:Quad;
			var o:Object;
			for (o in particleQuadDictionary) {
				particle = o as Particle;
				quad = particleQuadDictionary[o] as Quad;
				quad.x = particle.position.x;
				quad.y = particle.position.y;
			}
			
			// draw springs;
			var spring:Spring;
			var line:QuadLine;
			for (o in springLineDictionary) {
				spring = o as Spring;
				line = springLineDictionary[o] as QuadLine;
				line.updatePoints(spring.getOneEnd().position, spring.getTheOtherEnd().position);
			}
			
			// check all free
			var n:int = physics.numberOfParticles();
			var allFree:Boolean = true;
			var i:int;
			for (i = 0; i < n; i++) {
				particle = physics.getParticle(i);
				allFree = allFree && !particle.fixed;
				if (!allFree) {
					break;
				}
			}
			if (allFree) {
				var minY:int = int.MAX_VALUE;
				for (i = 0; i < n; i++) {
					particle = physics.getParticle(i);
					minY = Math.min(minY, particle.position.y);
				}
				trace(minY);
				if (minY > stage.stageHeight + PARTICLE_SCREEN_SIZE) {
					NativeApplication.nativeApplication.exit(0);
				}
			}
			
		}
		
		
		
		
	}

}