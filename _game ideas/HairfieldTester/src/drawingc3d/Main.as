package drawingc3d 
{
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.textures.Texture;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.geom.Matrix3D;
	import flash.geom.Vector3D;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.getTimer;
	
	/**
	 * modified from http://www.adobe.com/devnet/flashplayer/articles/hello-triangle.html
	 * @author Marcus Graf
	 */
	public class Main extends Sprite 
	{
		
		[Embed(source="HairAnimAtlas-16x(16x128)-in-(256x128).png")]
		private const TextureBitmap:Class;
		private var texture:Texture
		
		private var stageToGlSpaceX:Number;
		private var stageToGlSpaceY:Number;
		
		private var context3D:Context3D;
		private var vertexbuffer:VertexBuffer3D;
		private var indexbuffer:IndexBuffer3D;
		private var program:Program3D;
		
		public function Main() 
		{
			stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
			stage.stage3Ds[0].requestContext3D();
			
			addEventListener(Event.ENTER_FRAME, onFrame);
		}
		
		private var QUAD_AMOUNT:int = 3000;
		
		private var VERTICES_PER_QUAD:int = 4;
		private var PARAMS_PER_VERTEX:int = 5; // x, y, z, u, v;
		//private var PARAMS_PER_TWO_VERTICES:int = PARAMS_PER_VERTEX*2;
		//private var PARAMS_PER_THREE_VERTICES:int = PARAMS_PER_VERTEX * 3;
		private var VERTEX_AMOUNT:int = QUAD_AMOUNT * VERTICES_PER_QUAD;
		private var PARAMS_PER_QUAD:int = VERTICES_PER_QUAD * PARAMS_PER_VERTEX; // 20
		
		private var INDICES_PER_QUAD:int = 6; // 0, 1, 2, 2, 3, 0
		private var VERTEX_INDICES_PER_QUAD:int = 4; // 0, 1, 2, 3
		
		private var stageToGLMatrix:Matrix3D;
		
		private var singleQuadVertexParams:Vector.<Number> = Vector.<Number>([
			 -8,	  8,	0, 		0, 		1, // x, y, z, u, v
			120,	  8, 	0, 		0,		0,
			120,	 -8,	0, 		0.0625, 0,
			 -8,	 -8, 	0, 		0.0625, 1,
		]);
		
		private var ANIMATION_PARAMS_PER_FRAME:int = 8;
		private var animatedTextureCoordinates:Vector.<Number> = Vector.<Number>([
			//u		v		u		v		u		v		u		v
			0.0000,	1,		0.0000,	0,		0.0625,	0,		0.0625,	1, 	// frame 0
			0.0625,	1,		0.0625,	0,		0.1250,	0,		0.1250,	1,	// frame 1
			0.1250,	1,		0.1250,	0,		0.1875,	0,		0.1875,	1,	// frame 2
			0.1875,	1,		0.1875,	0,		0.2500,	0,		0.2500,	1,	// frame 3
			0.2500,	1,		0.2500,	0,		0.3125,	0,		0.3125,	1,	// frame 4
			0.3125,	1,		0.3125,	0,		0.3750,	0,		0.3750,	1,	// frame 5
			0.3750,	1,		0.3750,	0,		0.4375,	0,		0.4375,	1,	// frame 6
			0.4375,	1,		0.4375,	0,		0.5000,	0,		0.5000,	1,	// frame 7
			0.5000,	1,		0.5000,	0,		0.5625,	0,		0.5625,	1,	// frame 8
			0.5625,	1,		0.5625,	0,		0.6250,	0,		0.6250,	1,	// frame 9
			0.6250,	1,		0.6250,	0,		0.6875,	0,		0.6875,	1,	// frame 10
			0.6875,	1,		0.6875,	0,		0.7500,	0,		0.7500,	1,	// frame 11
			0.7500,	1,		0.7500,	0,		0.8125,	0,		0.8125,	1,	// frame 12
			0.8125,	1,		0.8125,	0,		0.8750,	0,		0.8750,	1,	// frame 13
			0.8750,	1,		0.8750,	0,		0.9375,	0,		0.9375,	1,	// frame 14
			0.9375,	1,		0.9375,	0,		1.0000,	0,		1.0000,	1,	// frame 15
		]);
				
		private var singleQuadIndices:Vector.<uint> = Vector.<uint>([
			0, 1, 2,
			2, 3, 0
		]);
		
		private var screenX:Vector.<Number>;
		private var screenY:Vector.<Number>;
		
		private var originalVertices:Vector.<Number>;
		private var originalIndices:Vector.<uint>;
		
		private var frameVertices:Vector.<Number>;
		
		private var deltaRotationPerQuad:Vector.<Number>;
		private var rotationPerQuad:Vector.<Number>;
		
		private var animationFramePerQuad:Vector.<Number>;
		private var animationDeltaFramePerQuad:Vector.<Number>;
		
		
		
		private function onContextCreated(e:Event):void 
		{
			trace("context3d created", stage.stageWidth, stage.stageHeight);
			context3D = stage.stage3Ds[0].context3D;
			context3D.configureBackBuffer(stage.stageWidth, stage.stageHeight, 1, false);// , 1, true);
			
			// setup space coordinates
			stageToGlSpaceX = 2 / stage.stageWidth;
			stageToGlSpaceY = -2 / stage.stageHeight;
			
			// setup spac matrix
			stageToGLMatrix = new Matrix3D();
			stageToGLMatrix.appendScale(stageToGlSpaceX, stageToGlSpaceY, 1);
			stageToGLMatrix.appendTranslation( -1, 1, 0); // top left
			
			// upload texture:
			var bitmap:Bitmap = new TextureBitmap();
			var bmp:BitmapData = bitmap.bitmapData;
			texture = context3D.createTexture(bmp.width, bmp.height, Context3DTextureFormat.BGRA, true);
			texture.uploadFromBitmapData(bmp);		
			
			// setup shader:
			var vertexShaderAssembler : AGALMiniAssembler = new AGALMiniAssembler();
			vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,
				"m44 op, va0, vc0\n" + 	// 4x4 matrix transform to output clipspace
				"mov v0, va1" 			// pass texture coordinates to fragment program
			);			
			
			
			var fragmentShaderAssembler : AGALMiniAssembler= new AGALMiniAssembler();
			fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,
				"tex ft1, v0, fs0 <2d,linear,mipnone>\n" +
				//"mul ft1, ft1, ft1.a\n" + // pre-multiply alpha
				"mov oc, ft1"
				//"tex oc, v0, fs0 <2d>"
				
				//"tex  oc,  v0, fs0 <???> \n"  // sample texture 0
			);
			//"mul ft1, ft1, ft1.a\n" + // multiply alpha
			program = context3D.createProgram();
			program.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
			
			// blending
			//context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA); // default blending
			context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE);
			
			// init screen x / screen y
			screenX = new Vector.<Number>(QUAD_AMOUNT);
			screenY = new Vector.<Number>(QUAD_AMOUNT);
			for (var qq:int = 0; qq < QUAD_AMOUNT; qq++) {
				screenX[qq] = stage.stageWidth * Math.random();
				screenY[qq] = stage.stageHeight * Math.random();
			}
			
			
			var i:int
			var q:int;
			var v:int;
			var p:int;
			
			
			// create vertices:
			originalVertices = new Vector.<Number>();// QUAD_AMOUNT * VERTICES_PER_QUAD * PARAMS_PER_VERTEX);
			deltaRotationPerQuad = new Vector.<Number>(QUAD_AMOUNT);
			rotationPerQuad = new Vector.<Number>(QUAD_AMOUNT);
			
			animationFramePerQuad = new Vector.<Number>(QUAD_AMOUNT);
			animationDeltaFramePerQuad = new Vector.<Number>(QUAD_AMOUNT);
			
			for (q = 0; q < QUAD_AMOUNT; q++) {
				
				// copy full quad array
				originalVertices = originalVertices.concat(singleQuadVertexParams);
				
				animationFramePerQuad[q] = int(Math.random() * 16);
				animationDeltaFramePerQuad[q] = 0.25 + Math.random() * 0.75;
				
				deltaRotationPerQuad[q] = 2 * Math.PI * (Math.random() - 0.5) / 120.0;
				rotationPerQuad[q] = 2 * Math.PI * Math.random();
				
			}
			
			// Create VertexBuffer3D. 4 vertices, of 5 Numbers each
			vertexbuffer = context3D.createVertexBuffer(VERTEX_AMOUNT, PARAMS_PER_VERTEX);
			// Upload VertexBuffer3D to GPU. Offset 0, 4 vertices
			vertexbuffer.uploadFromVector(originalVertices, 0, VERTEX_AMOUNT);		
			
			// create indices
			var indexCount:int = QUAD_AMOUNT * INDICES_PER_QUAD; //
			originalIndices = new Vector.<uint>();
			var indexOffset:int;
			var vertexIndexOffset:int;
			for (q = 0; q < QUAD_AMOUNT; q++) {
				// copy full index array
				originalIndices = originalIndices.concat(singleQuadIndices);
				
				indexOffset = q * INDICES_PER_QUAD;
				vertexIndexOffset = q * VERTEX_INDICES_PER_QUAD;
				for (i = 0; i < INDICES_PER_QUAD; i++) {
					originalIndices[indexOffset + i] += vertexIndexOffset;
				}
				
			}
			
			
			// Create IndexBuffer3D. Total of 6 indices. 2 triangles of 6 vertices
			indexbuffer = context3D.createIndexBuffer(indexCount);			
			// Upload IndexBuffer3D to GPU. Offset 0, count 3
			indexbuffer.uploadFromVector (originalIndices, 0, indexCount);
			
			
			
			tf = new TextField();
			tf.width = 300;
			tf.selectable = false;
			tf.x = 20;
			tf.y = 20;
			tf.textColor = 0xffffff;
			var f:TextFormat = new TextFormat("Verdana", 12, 0xffffff, true);
			tf.setTextFormat(f);
			tf.text = "Hello Hello!";
			addChild(tf);
			
			
			lastFrame = getTimer();
		
		}
		
		private var tf:TextField;
		
		
		private function onFrame(e:Event):void 
		{
			if ( !context3D ) 
				return;
			
			context3D.clear(0, 0, 0);// , 1);// ( 1, 1, 1, 1 );
			
			
			frameVertices = originalVertices.concat();
			//TODO: modify vertex buffer
			
			var paramIndexX0:int, paramIndexY0:int;
			var paramIndexX1:int, paramIndexY1:int;
			var paramIndexX2:int, paramIndexY2:int;
			var paramIndexX3:int, paramIndexY3:int;
			var paramIndexU0:int, paramIndexV0:int;
			var paramIndexU1:int, paramIndexV1:int;
			var paramIndexU2:int, paramIndexV2:int;
			var paramIndexU3:int, paramIndexV3:int;
			var rot:Number, rotCos:Number, rotSin:Number;
			var origX:Number, origY:Number;
			var animationFrame:int, animParamIndex:int;
			
			for (var q:int = 0; q < QUAD_AMOUNT; q++) {
				
				paramIndexX0 = q * PARAMS_PER_QUAD;
				paramIndexY0 = paramIndexX0 + 1;
				paramIndexU0 = paramIndexX0 + 3;
				paramIndexV0 = paramIndexX0 + 4;
				paramIndexX1 = paramIndexX0 + PARAMS_PER_VERTEX;
				paramIndexY1 = paramIndexY0 + PARAMS_PER_VERTEX;
				paramIndexU1 = paramIndexX1 + 3;
				paramIndexV1 = paramIndexX1 + 4;
				paramIndexX2 = paramIndexX1 + PARAMS_PER_VERTEX;
				paramIndexY2 = paramIndexY1 + PARAMS_PER_VERTEX;
				paramIndexU2 = paramIndexX2 + 3;
				paramIndexV2 = paramIndexX2 + 4;
				paramIndexX3 = paramIndexX2 + PARAMS_PER_VERTEX;
				paramIndexY3 = paramIndexY2 + PARAMS_PER_VERTEX;
				paramIndexU3 = paramIndexX3 + 3;
				paramIndexV3 = paramIndexX3 + 4;
				
				// animate
				animationFramePerQuad[q] += animationDeltaFramePerQuad[q];
				animationFramePerQuad[q] %= 16;
				animationFrame = int(animationFramePerQuad[q]);
				animParamIndex = ANIMATION_PARAMS_PER_FRAME * animationFrame;
				frameVertices[paramIndexU0] = animatedTextureCoordinates[animParamIndex];
				frameVertices[paramIndexV0] = animatedTextureCoordinates[animParamIndex + 1];
				frameVertices[paramIndexU1] = animatedTextureCoordinates[animParamIndex + 2];
				frameVertices[paramIndexV1] = animatedTextureCoordinates[animParamIndex + 3];
				frameVertices[paramIndexU2] = animatedTextureCoordinates[animParamIndex + 4];
				frameVertices[paramIndexV2] = animatedTextureCoordinates[animParamIndex + 5];
				frameVertices[paramIndexU3] = animatedTextureCoordinates[animParamIndex + 6];
				frameVertices[paramIndexV3] = animatedTextureCoordinates[animParamIndex + 7];
				
				
				
				// calc sines/cosines for rotation
				rotationPerQuad[q] += deltaRotationPerQuad[q];
				rot = rotationPerQuad[q];
				rotCos = Math.cos(rot);
				rotSin = Math.sin(rot);
				
				// rotate
				origX = frameVertices[paramIndexX0];
				origY = frameVertices[paramIndexY0];
				frameVertices[paramIndexX0] = origX * rotCos - origY * rotSin;
				frameVertices[paramIndexY0] = origY * rotCos + origX * rotSin;
				origX = frameVertices[paramIndexX1];
				origY = frameVertices[paramIndexY1];
				frameVertices[paramIndexX1] = origX * rotCos - origY * rotSin;
				frameVertices[paramIndexY1] = origY * rotCos + origX * rotSin;
				origX = frameVertices[paramIndexX2];
				origY = frameVertices[paramIndexY2];
				frameVertices[paramIndexX2] = origX * rotCos - origY * rotSin;
				frameVertices[paramIndexY2] = origY * rotCos + origX * rotSin;
				origX = frameVertices[paramIndexX3];
				origY = frameVertices[paramIndexY3];
				frameVertices[paramIndexX3] = origX * rotCos - origY * rotSin;
				frameVertices[paramIndexY3] = origY * rotCos + origX * rotSin;
				
				// move to screen pos
				frameVertices[paramIndexX0] += screenX[q];
				frameVertices[paramIndexY0] += screenY[q];
				frameVertices[paramIndexX1] += screenX[q];
				frameVertices[paramIndexY1] += screenY[q];
				frameVertices[paramIndexX2] += screenX[q];
				frameVertices[paramIndexY2] += screenY[q];
				frameVertices[paramIndexX3] += screenX[q];
				frameVertices[paramIndexY3] += screenY[q];
			}
			
			
			// Upload VertexBuffer3D to GPU. Offset 0, 4 vertices
			vertexbuffer.uploadFromVector(frameVertices, 0, VERTEX_AMOUNT);		
			
			//TODO: maybe use a seperate buffer for texture coordinates?
			
			/*var amount:int = originalVertices.length;
			for (var i:int = 0; i < 20; i++) {
				originalVertices[int(Math.random() * amount)] = Math.random() * 200 - 100;
			}*/
			

			// vertex position to attribute register 0
			context3D.setVertexBufferAt (0, vertexbuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			// UV to attribute register 1
			context3D.setVertexBufferAt(1, vertexbuffer, 3, Context3DVertexBufferFormat.FLOAT_2);
			// assign texture to texture sampler 0
			context3D.setTextureAt(0, texture);				
			// assign shader program
			context3D.setProgram(program);
			
			/*
			 * mTransformationMatrix.a = mScaleX;
				mTransformationMatrix.b = 0.0;
				mTransformationMatrix.c = 0.0;
				mTransformationMatrix.d = mScaleY;
				mTransformationMatrix.tx = mX – mPivotX;
				mTransformationMatrix.ty = mY – mPivotY;
			*/
			/*var m:Matrix3D = new Matrix3D();
			
			
			m.appendScale(stageToGlSpaceX, stageToGlSpaceY, 1);
			m.appendRotation(getTimer() / 10, Vector3D.Z_AXIS);
			//TODO: translate
			m.appendTranslation( -1, 1, 0);*/
			
			/*m.appendTranslation(0, 0.8 - 0.125, 0);
			m.appendRotation(getTimer()/40, Vector3D.Z_AXIS);
			m.appendTranslation( -1, 1, 0);*/ // move coordinate system to top left corner
			
			context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, stageToGLMatrix, true);// , true);
			
			context3D.drawTriangles(indexbuffer);
			
			context3D.present();	
			
			
			//trace(getChildIndex(tf), numChildren);
			
			var ti:int = getTimer();
			var dt:int = ti - lastFrame;
			avTime = avTime * 0.9 + dt * 0.1;
			
			tf.text = "Animated Quads: " + QUAD_AMOUNT + "\n" +
				"Framerate=" + (1000.0 / avTime).toFixed(1);
			//trace(stage.frameRate);
			
			lastFrame = ti;
		}
		
		private var lastFrame:int;
		private var avTime:Number = 0;
		
	}

}