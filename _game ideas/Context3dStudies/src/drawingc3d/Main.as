package drawingc3d 
{
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DRenderMode;
	import flash.display3D.Context3DTriangleFace;
	import flash.events.MouseEvent;
	import flash.events.TouchEvent;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	//import flash.text.TextField;
	//import flash.text.TextFormat;
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
	
	import flash.utils.getTimer;
	
	/**
	 * RENDER CYCLE:
	 * - define/compile/upload program
	 * - upload vertices and textures
	 * - begin render loop
	 * - - begin object loop
	 * - - - set program
	 * - - - set constants
	 * - - - set input buffers and textures
	 * - - - call drawTriangles()
	 * - - - set input buffers and textures to null
	 * - - end object loop
	 * - - call present()
	 * - end render loop
	 * 
	 * 
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
		
		private var fpsVertexBuffer:VertexBuffer3D;
		private var fpsIndexBuffer:IndexBuffer3D;
		private var fpsProgram:Program3D;
		
		public function Main() 
		{
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
			
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
			stage.stage3Ds[0].requestContext3D(Context3DRenderMode.AUTO);
			
			//stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin); //TODO: why not touch event???
			stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			
			addEventListener(Event.ENTER_FRAME, onFrame);
		}
		
		private function onMouseDown(e:MouseEvent):void 
		{
			if (e.stageX < stage.stageWidth / 2) {
				QUAD_AMOUNT = int(QUAD_AMOUNT / 1.2);
			} else {
				QUAD_AMOUNT = int(QUAD_AMOUNT * 1.2);
			}
			initializeLines();
		}
		
		/*private function onTouchBegin(e:TouchEvent):void 
		{
			if (e.stageX < stage.stageWidth / 2) {
				QUAD_AMOUNT = int(QUAD_AMOUNT / 1.2);
			} else {
				QUAD_AMOUNT = int(QUAD_AMOUNT * 1.2);
			}
			initializeLines();
		}*/
		
		
		
		/**
		 * The full Hairfield app gives me: 600 lines -> 60fps, 800 lines 30fps
		 */
		private var QUAD_AMOUNT:int = 512;
		
		//TODO: stil slower than hairfield with 600, maybe generate mipmaps???
		//TODO: could it be that a power of 2 for uploads is best???
		
		private const VERTICES_PER_QUAD:int = 4;
		private const PARAMS_PER_VERTEX:int = 5; // x, y, z, u, v;
		private const INDICES_PER_QUAD:int = 6; // 0, 1, 2, 2, 3, 0
		private const VERTEX_INDICES_PER_QUAD:int = 4; // 0, 1, 2, 3
		
		private var VERTEX_AMOUNT:int;
		private var PARAMS_PER_QUAD:int;
		
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
			
			
			trace ("DRIVER",stage.stage3Ds[0].context3D.driverInfo);
			lastFrame = 0;
			avTime = 0;
			
			// get context
			context3D = stage.stage3Ds[0].context3D;
			//context3D.enableErrorChecking = true;
			//.context3D.configureBackBuffer(stage.stageWidth, stage.stageHeight, 0, false);// , 1, true);
			context3D.configureBackBuffer(stage.stageWidth, stage.stageHeight, 0, false);// , 1, true);
			//context3D.configureBackBuffer(stage.fullScreenWidth, stage.fullScreenHeight, 0, false);// , 1, true);
			//trace(stage.stageWidth, stage.stageHeight);
			//trace(stage.width, stage.height);
			//trace(stage.fullScreenWidth, stage.fullScreenHeight);
			//trace(stage.stageWidth, stage.stageHeight);
			//trace(stage.fullScreenWidth, stage.fullScreenHeight);
			//context3D.configureBackBuffer(stage.width, stage.height, 0, false, true);// , 1, true);
			
			// setup space coordinates
			stageToGlSpaceX = 2 / stage.stageWidth;
			stageToGlSpaceY = -2 / stage.stageHeight;
			
			// setup space matrix
			stageToGLMatrix = new Matrix3D();
			stageToGLMatrix.appendScale(stageToGlSpaceX, stageToGlSpaceY, 1);
			stageToGLMatrix.appendTranslation( -1, 1, 0); // top left
			
			
			/*
			 * 
			 * SETUP CONTEXT STUFF FOR LINES
			 * - texture
			 * - shader
			 * 
			 */
			
			 
			// upload texture:
			var bitmap:Bitmap = new TextureBitmap();
			var bmp:BitmapData = bitmap.bitmapData;
			texture = context3D.createTexture(bmp.width, bmp.height, Context3DTextureFormat.BGRA, false);
			texture.uploadFromBitmapData(bmp);
			
			var generateMipmaps:Boolean = true;
			if (generateMipmaps && bmp.width > 1 && bmp.height > 1)
            {
                var currentWidth:int  = bmp.width  >> 1;
                var currentHeight:int = bmp.height >> 1;
                var level:int = 1;
                var canvas:BitmapData = new BitmapData(currentWidth, currentHeight, true, 0);
                var transform:Matrix = new Matrix(.5, 0, 0, .5);
                var bounds:Rectangle = new Rectangle();
                
                while (currentWidth >= 1 || currentHeight >= 1)
                {
                    bounds.width = currentWidth; bounds.height = currentHeight;
                    canvas.fillRect(bounds, 0);
                    canvas.draw(bmp, transform, null, null, null, true);
                    texture.uploadFromBitmapData(canvas, level++);
                    transform.scale(0.5, 0.5);
                    currentWidth  = currentWidth  >> 1;
                    currentHeight = currentHeight >> 1;
                }
                
                canvas.dispose();
            }
			
			// setup shader:
			var vertexShaderAssembler : AGALMiniAssembler = new AGALMiniAssembler();
			vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,
				"m44 op, va0, vc0\n" + 	// 4x4 matrix transform to output clipspace
				"mov v0, va1" 			// pass texture coordinates to fragment program
			);			
			
			var fragmentShaderAssembler : AGALMiniAssembler = new AGALMiniAssembler();
			// http://www.adobe.com/devnet/flashplayer/articles/mipmapping.html
			var texFilteringOptions:String = generateMipmaps ? "<2d,linear,miplinear>" : "<2d,linear,mipnone>";
			fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,
				"tex ft1, v0, fs0 "+texFilteringOptions+"\n"+//<2d,linear,mipnone>\n" + generateMipmaps miplinear
				//"mul ft1, ft1, ft1.a\n" + // pre-multiply alpha
				"mov oc, ft1"
			);
			//"mul ft1, ft1, ft1.a\n" + // multiply alpha
			
			program = context3D.createProgram();
			program.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
						
			// blending
			//context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA); // default blending
			context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE); // additive blending
			
			
			
			
			
			
			
			
			/*
			 * 
			 * SETUP CONTEXT STUFF FOR FPS COUNTER
			 * - shader
			 * - buffers (vertex & index)
			 * 
			 */
			
			// shader
			var fpsVertexShaderAssembler : AGALMiniAssembler = new AGALMiniAssembler();
				fpsVertexShaderAssembler.assemble( Context3DProgramType.VERTEX,
					"m44 op, va0, vc0\n" + // pos to clipspace
					"mov v0, va1" // copy color
				);			
			var fpsFragmentShaderAssembler : AGALMiniAssembler= new AGALMiniAssembler();
				fpsFragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,
					"mov oc, v0 "
				);
			fpsProgram = context3D.createProgram();
			fpsProgram.upload( fpsVertexShaderAssembler.agalcode, fpsFragmentShaderAssembler.agalcode);

			// setup buffers
			fpsVertexBuffer = context3D.createVertexBuffer(8, 6); // 8 vertices of 6 numbers each
			fpsIndexBuffer = context3D.createIndexBuffer(12); // 4 triangles of 3 indices
			var fpsIndices:Vector.<uint> = Vector.<uint>([
				0, 1, 2, 2, 3, 0,
				4, 5, 6, 6, 7, 4,
			]);
			fpsIndexBuffer.uploadFromVector(fpsIndices, 0, fpsIndices.length); //offset 0, coutn 12
			
		
			
			
			/*
			 * 
			 * INIT LINES
			 * 
			 */
			
			initializeLines();
			
		}
		
		
		
		
		
		
		
		private function initializeLines():void {
			
			trace(QUAD_AMOUNT);
			
			
			
			VERTEX_AMOUNT = QUAD_AMOUNT * VERTICES_PER_QUAD;
			PARAMS_PER_QUAD = VERTICES_PER_QUAD * PARAMS_PER_VERTEX; // 20
		
			
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
			
			frameVertices = new Vector.<Number>(originalVertices.length); //TODO: maybe here is the slowness? fixed vector?
			frameVertices.fixed = true;
			// Create VertexBuffer3D. 4 vertices, of 5 Numbers each
			
			vertexbuffer = context3D.createVertexBuffer(VERTEX_AMOUNT, PARAMS_PER_VERTEX);
			// Upload VertexBuffer3D to GPU. Offset 0, 4 vertices
			//vertexbuffer.uploadFromVector(originalVertices, 0, VERTEX_AMOUNT);		
			
			//vertexbuffer.uploadFromByteArray(
			//TODO: upload from byte array faster?
			
			
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
		}
		
		
		
		
		
		/*
		 * 
		 * 
		 * FRAME
		 * 
		 * 
		 */
		
		private function onFrame(e:Event):void 
		{
			if ( !context3D ) 
				return;
			
			trace("frame");
			//mContext.setDepthTest(false, Context3DCompareMode.ALWAYS);
			
			
			context3D.clear(0, 0, 0);// , 1);// ( 1, 1, 1, 1 );
			
			context3D.setDepthTest(false, Context3DCompareMode.ALWAYS);
			
			//frameVertices = originalVertices.concat();
			//frameVertices = new Vector.<Number>(originalVertices.length);
			//TODO: modify vertex buffer
			
			//TODO: Prollay what is going on that uploading only happens once, then the rest is done with the vertex shader. (rotations etx..)
			
			var paramIndexX0:int, paramIndexY0:int, paramIndexZ0:int;
			var paramIndexU0:int, paramIndexV0:int;
			var paramIndexX1:int, paramIndexY1:int, paramIndexZ1:int;
			var paramIndexU1:int, paramIndexV1:int;
			var paramIndexX2:int, paramIndexY2:int, paramIndexZ2:int;
			var paramIndexU2:int, paramIndexV2:int;
			var paramIndexX3:int, paramIndexY3:int, paramIndexZ3:int;
			var paramIndexU3:int, paramIndexV3:int;
			
			var rot:Number, rotCos:Number, rotSin:Number;
			var origX:Number, origY:Number;
			var animationFrame:int, animParamIndex:int;
			
			var index:int = 0;
			
			for (var q:int = 0; q < QUAD_AMOUNT; q++) {
				
				index = q * PARAMS_PER_QUAD;
				paramIndexX0 = index; index++;
				paramIndexY0 = index; index++;
				paramIndexZ0 = index; index++;
				paramIndexU0 = index; index++;
				paramIndexV0 = index; index++;
				
				paramIndexX1 = index; index++;
				paramIndexY1 = index; index++;
				paramIndexZ1 = index; index++;
				paramIndexU1 = index; index++;
				paramIndexV1 = index; index++;
				
				paramIndexX2 = index; index++;
				paramIndexY2 = index; index++;
				paramIndexZ2 = index; index++;
				paramIndexU2 = index; index++;
				paramIndexV2 = index; index++;
				
				paramIndexX3 = index; index++;
				paramIndexY3 = index; index++;
				paramIndexZ3 = index; index++;
				paramIndexU3 = index; index++;
				paramIndexV3 = index; index++;
				
				// calc sines/cosines for rotation
				rotationPerQuad[q] += deltaRotationPerQuad[q];
				rot = rotationPerQuad[q];
				rotCos = Math.cos(rot);
				rotSin = Math.sin(rot);
				
				/*for (var j:int = 0; j < PARAMS_PER_QUAD; j++) {
					frameVertices.push(0);
				}*/
				frameVertices.fixed = true;
				// rotate & move
				origX = originalVertices[paramIndexX0];
				origY = originalVertices[paramIndexY0];
				frameVertices[paramIndexX0] = origX * rotCos - origY * rotSin + screenX[q];
				frameVertices[paramIndexY0] = origY * rotCos + origX * rotSin + screenY[q];
				frameVertices[paramIndexZ0] = 0;
				origX = originalVertices[paramIndexX1];
				origY = originalVertices[paramIndexY1];
				frameVertices[paramIndexX1] = origX * rotCos - origY * rotSin + screenX[q];
				frameVertices[paramIndexY1] = origY * rotCos + origX * rotSin + screenY[q];
				frameVertices[paramIndexZ1] = 0;
				origX = originalVertices[paramIndexX2];
				origY = originalVertices[paramIndexY2];
				frameVertices[paramIndexX2] = origX * rotCos - origY * rotSin + screenX[q];
				frameVertices[paramIndexY2] = origY * rotCos + origX * rotSin + screenY[q];
				frameVertices[paramIndexZ2] = 0;
				origX = originalVertices[paramIndexX3];
				origY = originalVertices[paramIndexY3];
				frameVertices[paramIndexX3] = origX * rotCos - origY * rotSin + screenX[q];
				frameVertices[paramIndexY3] = origY * rotCos + origX * rotSin + screenY[q];
				frameVertices[paramIndexZ3] = 0;
				
				
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
				
			}
			
			
			
			// Upload VertexBuffer3D to GPU. Offset 0, 4 vertices
			//vertexbuffer.dispose();
			//vertexbuffer = context3D.createVertexBuffer(VERTEX_AMOUNT, PARAMS_PER_VERTEX);
			
			context3D.setDepthTest(false, Context3DCompareMode.ALWAYS);
            context3D.setCulling(Context3DTriangleFace.NONE);
			
			
			trace("uploadFromVector", VERTEX_AMOUNT);
			
			var t:int = getTimer();
			frameVertices.fixed = true;
			vertexbuffer.uploadFromVector(frameVertices, 0, VERTEX_AMOUNT);	
			trace("in", (getTimer() - t), "ms");
			//trace(frameVertices.length, VERTEX_AMOUNT);
			
			// vertex position to attribute register 0
			context3D.setVertexBufferAt (0, vertexbuffer, 0, Context3DVertexBufferFormat.FLOAT_3);
			// UV to attribute register 1
			context3D.setVertexBufferAt(1, vertexbuffer, 3, Context3DVertexBufferFormat.FLOAT_2);
			// assign texture to texture sampler 0
			context3D.setTextureAt(0, texture);				
			// assign shader program
			context3D.setProgram(program);
			
			context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, stageToGLMatrix, true);// , true);
			
				
			
			context3D.drawTriangles(indexbuffer);
			
			// set input buffers and texture buffers to null!
			context3D.setTextureAt(0, null);
			context3D.setVertexBufferAt(0, null);
			context3D.setVertexBufferAt(1, null);
			
			
			//vertexbuffer.dispose();
			
			/*
			 * FPS counter drawing
			 */
			
			 /*
			  * the problem is that this vertex buffer will remain in memory after the drawTriangles() call 
			  * and when you’ll draw the next object, the GPU will expect the shader to use it and crash if it doesn’t
			  */
			 
			var ti:int = getTimer();
			var dt:int = ti - lastFrame;
			if (lastFrame == 0) {
				dt = 1000.0 / stage.frameRate;//S 1000.0 / stage.frameRate
			}
			
			avTime = avTime * 0.9 + dt * 0.1;
			var avFps:Number = 1000.0 / avTime;
			
			var fpsPercentageOfRequested:Number = avFps / stage.frameRate;
			
			trace("fps", avFps);
			
			var showFpsGui:Boolean = true;
			if (showFpsGui) {
			
				var FPS_X:Number = 10;
				var FPS_Y:Number = 10;
				var FPS_WIDTH:Number = 50;
				var FPS_HEIGHT:Number = 10;
				
				var x0:Number = FPS_X, x1:Number = FPS_X + FPS_WIDTH, y0:Number = FPS_Y, y1:Number = FPS_Y + FPS_HEIGHT;
				
				var fx0:Number = FPS_X + 1, fx1:Number = FPS_X + 1 + (FPS_WIDTH - 2) * fpsPercentageOfRequested;
				var fy0:Number = FPS_Y + 1, fy1:Number = FPS_Y + 1 + FPS_HEIGHT - 2;
				
				var rr:Number = 1.0 - fpsPercentageOfRequested;	//1->0
				var gg:Number = fpsPercentageOfRequested; 		// 0-->1
				var bb:Number = 0;
				
				var fpsVertices:Vector.<Number> = Vector.<Number>([
					x0,		y0,		0,				0.5,	0.5,	0.5,
					x1,		y0,		0,				0.5,	0.5,	0.5,
					x1,		y1,		0,				0.5,	0.5,	0.5,
					x0,		y1,		0,				0.5,	0.5,	0.5,
					 
					fx0,	fy0,	0,				rr,	gg,	bb,
					fx1,	fy0,	0,				rr,	gg,	bb,
					fx1,	fy1,	0,				rr,	gg,	bb,
					fx0,	fy1,	0,				rr,	gg,	bb
				]);
				fpsVertexBuffer.uploadFromVector(fpsVertices, 0, 8);
				context3D.setVertexBufferAt(0, fpsVertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3); //position at register 0
				context3D.setVertexBufferAt(1, fpsVertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_3); //color at register 1
				context3D.setProgram(fpsProgram);
				context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, stageToGLMatrix, true);
				context3D.drawTriangles(fpsIndexBuffer);
				
				context3D.setTextureAt(0, null);
				context3D.setVertexBufferAt(0, null);
				context3D.setVertexBufferAt(1, null);
						
			}
			
			context3D.present();	
			//context3D.
			//context3D.dispose();
			//trace(getChildIndex(tf), numChildren);
			
			
			
			//var fps:String = (1000.0 / avTime).toFixed(1);
			/*tf.text = "Animated Quads: " + QUAD_AMOUNT + "\n" +
				"Framerate=" + fps;*/
			
			//trace(stage.frameRate);
			
			lastFrame = ti;
		}
		
		private var lastFrame:int = -1;
		private var avTime:Number = 0;
		
		
	}

}