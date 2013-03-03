package uploadvectortest 
{
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DRenderMode;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class TestWithDoubleTriangles extends Sprite 
	{
		private var context3D:Context3D;
		
		/*
		 * QUAD stuff
		 */
		
		private var QUAD_AMOUNT:int = 800;
		private var VERTEX_AMOUNT:int = QUAD_AMOUNT * 4;
		private var DATA_PER_VERTEX:int = 6;
		
		private var vertexData:Vector.<Number> = new Vector.<Number>(VERTEX_AMOUNT * DATA_PER_VERTEX);
		private var vertexMovData:Vector.<Number> = new Vector.<Number>(VERTEX_AMOUNT * 2); // x and y
		private var vertexBuffer:VertexBuffer3D;
		
		private var INDICE_AMOUNT:int = QUAD_AMOUNT * 6;
		private var indexBuffer:IndexBuffer3D;
		
		private var quadProgram:Program3D;
		
		private var textProgram:Program3D;
		
		
		private var matrix:Matrix3D;
		
		/*
		 * fps calc stuff
		 */
		private var lastTi:int = 0;
		private var avTime:Number = 0;
		
		public function TestWithDoubleTriangles() 
		{
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			// touch or gesture?
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
			stage.stage3Ds[0].requestContext3D(Context3DRenderMode.AUTO);
			
			addEventListener(Event.ENTER_FRAME, onFrame);
		}
		
		private function onContextCreated(e:Event):void 
		{
		
			trace ("DRIVER", stage.stage3Ds[0].context3D.driverInfo);
			
			// init context
			context3D = stage.stage3Ds[0].context3D;
			context3D.configureBackBuffer(stage.stageWidth, stage.stageHeight, 0, false);
			
			setupQuadShader();
			
			setupQuadVertices();
			
			matrix = new Matrix3D();
			////context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA); // default blending
			//context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE); // additive blending
		}
		
		
		
		
		
		private function setupQuadShader():void 
		{
			// setup shader:
			var vertexShaderAssembler : AGALMiniAssembler = new AGALMiniAssembler();
			vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,
				"m44 op, va0, vc0\n" + 	// 4x4 matrix transform to output clipspace
				"mov v0, va1" 			// pass color value to fragment program
			);			
			
			var fragmentShaderAssembler : AGALMiniAssembler = new AGALMiniAssembler();
			fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,
				"mov oc, v0"
			);
			
			quadProgram = context3D.createProgram();
			quadProgram.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
		}
		
		
		
		
		
		
		
		private function setupQuadVertices():void 
		{
			var dataIndex:int = 0; 	// 6 per vertex
			var movIndex:int = 0; 	// 2 per vertex (x,y)
			for (var t:int = 0; t < QUAD_AMOUNT; t++) {
				
				// point zero: choose a random pos / color
				var vx:Number = Math.random() * 2 - 1;
				var vy:Number = Math.random() * 2 - 1;
				var vr:Number = Math.random(); // 0..1
				var vg:Number = Math.random();
				var vb:Number = Math.random();
				
				// four points per quad
				for (var v:int = 0; v < 4; v++) {
					
					vx += (Math.random() * 2 - 1) * 0.05;
					vy += (Math.random() * 2 - 1) * 0.05;
					vr = Math.max(0, Math.min(1, vr + (Math.random() * 2 - 1) * 0.5));
					vg = Math.max(0, Math.min(1, vg + (Math.random() * 2 - 1) * 0.5));
					vb = Math.max(0, Math.min(1, vb + (Math.random() * 2 - 1) * 0.5));
					
					if (v == 3) {
						var linePoint1:Point = new Point(vertexData[dataIndex - 18], vertexData[dataIndex - 17]);
						var p:Point = new Point(vertexData[dataIndex - 12], vertexData[dataIndex - 11]);
						var linePoint2:Point = new Point(vertexData[dataIndex - 6], vertexData[dataIndex - 5]);
						var reflectPoint:Point = getReflectedPoint(p, linePoint1, linePoint2);
						vx = reflectPoint.x + (Math.random()*2-1) * 0.005;
						vy = reflectPoint.y + (Math.random()*2-1) * 0.005;
					}
					vertexData[dataIndex] = vx; 	dataIndex++;
					vertexData[dataIndex] = vy; 	dataIndex++;
					vertexData[dataIndex] = 0; 		dataIndex++;
					vertexData[dataIndex] = vr; 	dataIndex++;
					vertexData[dataIndex] = vg; 	dataIndex++;
					vertexData[dataIndex] = vb; 	dataIndex++;
					if (v == 0) {
						vertexMovData[movIndex] = (Math.random() * 2 - 1) * 0.01;	movIndex++;
						vertexMovData[movIndex] = (Math.random() * 2 - 1) * 0.01;	movIndex++;
					} else {
						vertexMovData[movIndex] = vertexMovData[movIndex - 2 * v] + (Math.random() * 2 - 1) * 0;	movIndex++;
						vertexMovData[movIndex] = vertexMovData[movIndex - 2 * v] + (Math.random() * 2 - 1) * 0;	movIndex++;
					}
					
				}
			}
			
			vertexBuffer = context3D.createVertexBuffer(VERTEX_AMOUNT, DATA_PER_VERTEX);
			vertexBuffer.uploadFromVector(vertexData, 0, VERTEX_AMOUNT);
			
			var indexData:Vector.<uint> = new Vector.<uint>(INDICE_AMOUNT);
			var index:int = 0;			// 6 per quad, i.e. 0,1,2,2,3,0
			var vertexIndex:int = 0;	// 4 per quad, i.e. 0 1 2 3
			for (var i:int = 0; i < QUAD_AMOUNT; i++) {
				trace("quad", index, vertexIndex);
				indexData[index] = vertexIndex;		index++;	vertexIndex++;	// vi=0
				indexData[index] = vertexIndex;		index++;	vertexIndex++;	// vi=1
				indexData[index] = vertexIndex;		index++;					// vi=2
				indexData[index] = vertexIndex;		index++;	vertexIndex++;	// vi=2
				indexData[index] = vertexIndex;		index++;	vertexIndex-=3;	// vi=3
				indexData[index] = vertexIndex;		index++;	vertexIndex+=4;	// vi=0 -> 4
			}
			
			indexBuffer = context3D.createIndexBuffer(INDICE_AMOUNT);
			indexBuffer.uploadFromVector(indexData, 0, INDICE_AMOUNT);
		}
		
		
		
		
		private function onFrame(e:Event):void 
		{
			if ( !context3D ) 
				return;
			
			var ti:int = getTimer();
			if (lastTi != 0) {
				var dt:int = ti - lastTi;
				avTime = avTime * 0.9 + dt * 0.1;
				var avFps:Number = 1000.0 / avTime;
				trace("fps", avFps.toFixed(1));
			}
			lastTi = ti;
			
			
			
			var dataIndex:int = 0; // 6 per vertex
			var movIndex:int = 0; // 3 per vertex
			var v:int;
			var vx:Vector.<Number> = new Vector.<Number>(3);
			var vy:Vector.<Number> = new Vector.<Number>(3);
			for (var t:int = 0; t < QUAD_AMOUNT;t++) {
				for (v = 0; v < 4; v++) {
					vx[v] = vertexData[dataIndex] = vertexData[dataIndex] + vertexMovData[movIndex];
					dataIndex++; movIndex++;
					vy[v] = vertexData[dataIndex] = vertexData[dataIndex] + vertexMovData[movIndex];
					dataIndex+=5; movIndex++;
				}
				if (vx[0] < -1 && vx[1] < -1 && vx[2] < -1 && vx[3] < -1) {
					vertexData[dataIndex - 24] += 2;
					vertexData[dataIndex - 18] += 2;
					vertexData[dataIndex - 12] += 2;
					vertexData[dataIndex - 6] += 2;
				}
				else if (vx[0] > 1 && vx[1] > 1 && vx[2] > 1 && vx[3] > 1) {
					vertexData[dataIndex - 24] -= 2;
					vertexData[dataIndex - 18] -= 2;
					vertexData[dataIndex - 12] -= 2;
					vertexData[dataIndex - 6] -= 2;
				}
				if (vy[0] < -1 && vy[1] < -1 && vy[2] < -1 && vy[3] < -1) {
					vertexData[dataIndex - 23] += 2;
					vertexData[dataIndex - 17] += 2;
					vertexData[dataIndex - 11] += 2;
					vertexData[dataIndex - 5] += 2;
				}
				else if (vy[0] > 1 && vy[1] > 1 && vy[2] > 1 && vy[3] > 1) {
					vertexData[dataIndex - 23] -= 2;
					vertexData[dataIndex - 17] -= 2;
					vertexData[dataIndex - 11] -= 2;
					vertexData[dataIndex - 5] -= 2;
				}
			}
			vertexData.fixed = true;
			
			ti = getTimer();
			vertexBuffer.uploadFromVector(vertexData, 0, VERTEX_AMOUNT);
			trace("uploadTime of "+VERTEX_AMOUNT+" vertices:", getTimer() - ti, "ms");
			
			
			
			
			context3D.clear(0, 0, 0);
			
			// position to attribute register 0
			context3D.setVertexBufferAt (0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			// color to attribute register 1
			context3D.setVertexBufferAt(1, vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_3);			
			// assign shader program
			context3D.setProgram(quadProgram);
			
			context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, matrix, true);// , true);
			
			context3D.drawTriangles(indexBuffer);
			
			context3D.present();
			/*context3D.setTextureAt(0, null);
			context3D.setVertexBufferAt(0, null);
			context3D.setVertexBufferAt(1, null);*/
		}
		
		
		
		
		
		
		/*
		 * 
		 * with two points x0/y0 and x1/y1 you can derive the formula y = a*x + c in the following way:
		 * a = dy / dx = (y1-y0) / (x1-x0)
		 * c = y0 - a * x0
		 * 
		Given (x, y) and a line y = ax + c we want the point (x', y') reflected on the line.
		Set d: = (x + (y - c) * a) / (1 + a ^ 2)
		Then x' = 2*d - x
		and y' = 2*d*a - y + 2c
		*/
		
		public static function getReflectedPoint(p:Point, linePoint0:Point, linePoint1:Point):Point {
			var x:Number = p.x;
			var y:Number = p.y;
			var x0:Number = linePoint0.x, y0:Number = linePoint0.y;
			var x1:Number = linePoint1.x, y1:Number = linePoint1.y;
			
			// create line formula:
			// y = a*x + c
			var dy:Number = (y1 - y0);
			var dx:Number = (x1 - x0);
			var a:Number = dy / dx;
			var c:Number = y0 - a * x0;
			
			var d:Number = (x + (y - c) * a) / (1 + a * a)
			var xOut:Number = 2 * d - x;
			var yOut:Number = 2 * d * a - y + 2 * c;
			return new Point(xOut, yOut);
		}
		
		/**Returns the point represent by reflecting point "p" across "mirrorLine"*/
		/*public static function getReflectedPoint(p:Point , linePoint1:Point, linePoint2:Point):Point {
			//vector y (the point)
			var y1:Number = p.x - linePoint1.x;// getX1();
			var y2:Number = p.y - linePoint1.y;// getY1();
		 
			//vector u (the line)
			var u1:Number = linePoint2.x - linePoint1.x;
			var u2:Number = linePoint2.y - linePoint1.y;
		 
			//orthogonal projection of y onto u
			var scale:Number = (y1 * u1 + y2 * u2) / (u1 * u1 + u2 * u2);
			var projX:Number = scale * u1 + linePoint1.x;
			var projY:Number = scale * u2 + linePoint1.y;
		 
			return new Point(2 * projX - p.x,2 * projY - p.y);
		}*/
		
	}

}