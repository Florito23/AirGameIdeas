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
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class TestUploadVector extends Sprite 
	{
		private var context3D:Context3D;
		private var program:Program3D;
		
		private var matrix:Matrix3D;
		
		public function TestUploadVector() 
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
			
			setupShader();
			
			setupVertices();
			
			matrix = new Matrix3D();
			////context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA); // default blending
			//context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE); // additive blending
		}
		
		
		
		
		
		private function setupShader():void 
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
			
			program = context3D.createProgram();
			program.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
		}
		
		
		
		
		
		private var TRIANGLE_AMOUNT:int = 800;
		private var VERTEX_AMOUNT:int = TRIANGLE_AMOUNT * 3;
		private var DATA_PER_VERTEX:int = 6;
		private var vertexData:Vector.<Number> = new Vector.<Number>(VERTEX_AMOUNT * DATA_PER_VERTEX);
		private var vertexMovData:Vector.<Number> = new Vector.<Number>(VERTEX_AMOUNT * 2); // x and y
		private var vertexBuffer:VertexBuffer3D;
		private var indexBuffer:IndexBuffer3D;
		
		private function setupVertices():void 
		{
			var dataIndex:int = 0; // 6 per vertex
			var movIndex:int = 0; // 3 per vertex
			for (var t:int = 0; t < TRIANGLE_AMOUNT; t++) {
				var vx:Number = Math.random() * 2 - 1;
				var vy:Number = Math.random() * 2 - 1;
				var vr:Number = Math.random();
				var vg:Number = Math.random();
				var vb:Number = Math.random();
				for (var v:int = 0; v < 3; v++) {
					if (v > 0) {
						vx += (Math.random() * 2 - 1) * 0.05;
						vy += (Math.random() * 2 - 1) * 0.05;
						vr = Math.max(0, Math.min(1, vr + (Math.random() * 2 - 1) * 0.05));
						vg = Math.max(0, Math.min(1, vg + (Math.random() * 2 - 1) * 0.05));
						vb = Math.max(0, Math.min(1, vb + (Math.random() * 2 - 1) * 0.05));
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
			
			var indexData:Vector.<uint> = new Vector.<uint>(VERTEX_AMOUNT);
			for (v = 0; v < VERTEX_AMOUNT; v++) {
				indexData[v] = v;
			}
			
			indexBuffer = context3D.createIndexBuffer(VERTEX_AMOUNT);
			indexBuffer.uploadFromVector(indexData, 0, VERTEX_AMOUNT);
		}
		
		
		
		private var lastTi:int = 0;
		private var avTime:Number = 0;
		private function onFrame(e:Event):void 
		{
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
			for (var t:int = 0; t < TRIANGLE_AMOUNT;t++) {
				for (v = 0; v < 3; v++) {
					vx[v] = vertexData[dataIndex] = vertexData[dataIndex] + vertexMovData[movIndex];
					dataIndex++; movIndex++;
					vy[v] = vertexData[dataIndex] = vertexData[dataIndex] + vertexMovData[movIndex];
					dataIndex+=5; movIndex++;
				}
				if (vx[0] < -1 && vx[1] < -1 && vx[2] < -1) {
					vertexData[dataIndex - 18] += 2;
					vertexData[dataIndex - 12] += 2;
					vertexData[dataIndex - 6] += 2;
				}
				else if (vx[0] > 1 && vx[1] > 1 && vx[2] > 1) {
					vertexData[dataIndex - 18] -= 2;
					vertexData[dataIndex - 12] -= 2;
					vertexData[dataIndex - 6] -= 2;
				}
				if (vy[0] < -1 && vy[1] < -1 && vy[2] < -1) {
					vertexData[dataIndex - 17] += 2;
					vertexData[dataIndex - 11] += 2;
					vertexData[dataIndex - 5] += 2;
				}
				else if (vy[0] > 1 && vy[1] > 1 && vy[2] > 1) {
					vertexData[dataIndex - 17] -= 2;
					vertexData[dataIndex - 11] -= 2;
					vertexData[dataIndex - 5] -= 2;
				}
			}
			vertexData.fixed = true;
			
			ti = getTimer();
			vertexBuffer.uploadFromVector(vertexData, 0, VERTEX_AMOUNT);
			trace("uploadTime of "+VERTEX_AMOUNT+" vertices:", getTimer() - ti, "ms");
			
			
			if ( !context3D ) 
				return;
			
			context3D.clear(0, 0, 0);
			
			// position to attribute register 0
			context3D.setVertexBufferAt (0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			// color to attribute register 1
			context3D.setVertexBufferAt(1, vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_2);			
			// assign shader program
			context3D.setProgram(program);
			
			context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, matrix, true);// , true);
			
			context3D.drawTriangles(indexBuffer);
			
			context3D.present();
			/*context3D.setTextureAt(0, null);
			context3D.setVertexBufferAt(0, null);
			context3D.setVertexBufferAt(1, null);*/
		}
		
	}

}