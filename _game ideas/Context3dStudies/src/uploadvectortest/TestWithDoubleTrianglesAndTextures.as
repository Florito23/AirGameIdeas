package uploadvectortest 
{
	import com.adobe.utils.AGALMiniAssembler;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DBlendFactor;
	import flash.display3D.Context3DCompareMode;
	import flash.display3D.Context3DProgramType;
	import flash.display3D.Context3DRenderMode;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DVertexBufferFormat;
	import flash.display3D.IndexBuffer3D;
	import flash.display3D.Program3D;
	import flash.display3D.textures.Texture;
	import flash.display3D.VertexBuffer3D;
	import flash.events.Event;
	import flash.events.TouchEvent;
	import flash.geom.Matrix;
	import flash.geom.Matrix3D;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.getTimer;
	
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class TestWithDoubleTrianglesAndTextures extends Sprite 
	{
		private var context3D:Context3D;
		
		[Embed(source = "HairAnimAtlas-16x(16x128)-in-(256x128).png")]
		private const TextureBitmap:Class;
		private var texture:Texture;
		
		[Embed(source="VERDANAB.TTF", fontName = "Verdana Bold", fontWeight = "bold", embedAsCFF = 'false', mimeType="application/x-font")]
		private const VerdanaBold:Class;
		private var textField:TextField;
		private var textFormat:TextFormat;
		
		/*
		 * QUAD stuff
		 */
		
		private var QUAD_AMOUNT:int = 2048; //1024 all of a sudden good??? even 2048 is good//???
		private var VERTEX_AMOUNT:int = QUAD_AMOUNT * 4;
		private var DATA_PER_VERTEX:int = 6;
		
		private var vertexData:Vector.<Number> = new Vector.<Number>(VERTEX_AMOUNT * DATA_PER_VERTEX);
		private var vertexMovData:Vector.<Number> = new Vector.<Number>(VERTEX_AMOUNT * 2); // x and y
		private var vertexBuffer:VertexBuffer3D;
		
		private var INDICE_AMOUNT:int = QUAD_AMOUNT * 6;
		private var indexBuffer:IndexBuffer3D;
		
		private var quadProgramColor:Program3D;
		private var quadProgramTexture:Program3D;
		
		private var speedFac:Number = 0.5;
		
		/*
		 * fps stuff
		 */
		private var fpsVertices:int = 4;
		private var fpsParamsPerVertex:int = 5;
		private var fpsVertexData:Vector.<Number> = new Vector.<Number>(fpsVertices * fpsParamsPerVertex);
		private var fpsVertexBuffer:VertexBuffer3D;
		private var fpsIndexData:Vector.<uint> = Vector.<uint>([0, 1, 2, 2, 3, 0]);
		private var fpsIndexBuffer:IndexBuffer3D;
		private var fpsProgram:Program3D;
		
		
		private var matrix:Matrix3D;
		
		/*
		 * fps calc stuff
		 */
		private var lastTi:int = 0;
		private var avTime:Number = 0;
		private var avUploadTime:Number = 0;
		
		public function TestWithDoubleTrianglesAndTextures() 
		{
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			// touch or gesture?
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			stage.stage3Ds[0].addEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
			stage.stage3Ds[0].requestContext3D(Context3DRenderMode.AUTO);
			
			stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouch);
			stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouch);
			stage.addEventListener(TouchEvent.TOUCH_END, onTouch);
			
			addEventListener(Event.ENTER_FRAME, onFrame);
		}
		
		private function onTouch(e:TouchEvent):void 
		{
			speedFac = e.stageX / stage.stageWidth * 2;
		}
		
		private function onContextCreated(e:Event):void 
		{
		
			trace ("DRIVER", stage.stage3Ds[0].context3D.driverInfo);
			
			// init context
			context3D = stage.stage3Ds[0].context3D;
			context3D.configureBackBuffer(stage.stageWidth, stage.stageHeight, 0, false);
			
			setupQuadTexture();
			//setupQuadShaderForTexture();
			
			setupQuadShaderForColor();
			setupQuadVertices();
			
			setupFpsData();
			
			matrix = new Matrix3D();
			////context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA); // default blending
			//context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE); // additive blending
		}
		
		
		
		
		private function setupQuadTexture():void 
		{
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
		}
		
		
		
		
		
		private function setupQuadShaderForColor():void 
		{
			var vertexShaderAssembler : AGALMiniAssembler = new AGALMiniAssembler();
			vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,
				"m44 op, va0, vc0\n" + 	// 4x4 matrix transform to output clipspace
				"mov v0, va1" 			// pass color value to fragment program
			);			
			
			var fragmentShaderAssembler : AGALMiniAssembler = new AGALMiniAssembler();
			fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,
				"mov oc, v0"
			);
			
			quadProgramColor = context3D.createProgram();
			quadProgramColor.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
		}
		
		private function setupQuadShaderForTexture():void
		{
			var generateMipmaps:Boolean = true;
			
			// setup shader:
			var vertexShaderAssembler : AGALMiniAssembler = new AGALMiniAssembler();
			vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,
				"m44 op, va0, vc0\n" + 	// 4x4 matrix transform to output clipspace
				"mov v0, va1" 			// pass texture coordinates to fragment program
			);			
			
			var fragmentShaderAssembler : AGALMiniAssembler = new AGALMiniAssembler(); // http://www.adobe.com/devnet/flashplayer/articles/mipmapping.html
			var texFilteringOptions:String = generateMipmaps ? "<2d,linear,miplinear>" : "<2d,linear,mipnone>";
			fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,
				"tex ft1, v0, fs0 "+texFilteringOptions+"\n"+//<2d,linear,mipnone>\n" + generateMipmaps miplinear
				//"mul ft1, ft1, ft1.a\n" + // pre-multiply alpha
				"mov oc, ft1"
			);
			//"mul ft1, ft1, ft1.a\n" + // multiply alpha
			
			quadProgramTexture = context3D.createProgram();
			quadProgramTexture.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
		}
		
		
		
		private function setupFpsData():void {
			
			// setup vertices
			var index:int = 0;
			for (var i:int = 0; i < fpsVertices; i++) {
				var x:Number =  -0.9 + 0.3 * ((i == 0 || i == 3)?0:1);// 0..1..1..0
				var y:Number =   0.9 - 0.1 * ((i == 0 || i == 1)?0:1);// 0..0..1..1
				var z:Number = 0;
				var u:Number = ((i == 0 || i == 3)?0:1);
				var v:Number = ((i == 0 || i == 1)?0:1);
				//trace(new Point(x, y), "uv", new Point(u, v));
				fpsVertexData[index] = x;	index++;
				fpsVertexData[index] = y;	index++;
				fpsVertexData[index] = z;	index++;
				fpsVertexData[index] = u;	index++;
				fpsVertexData[index] = v;	index++;
			}
			fpsVertexBuffer = context3D.createVertexBuffer(fpsVertices, fpsParamsPerVertex);
			fpsVertexBuffer.uploadFromVector(fpsVertexData, 0, fpsVertices);
			
			// setup indices
			fpsIndexBuffer = context3D.createIndexBuffer(6);
			fpsIndexBuffer.uploadFromVector(fpsIndexData, 0, 6);
			
			//setup shaders
			var vertexShaderAssembler : AGALMiniAssembler = new AGALMiniAssembler();
			vertexShaderAssembler.assemble( Context3DProgramType.VERTEX,
				"m44 op, va0, vc0\n" + 	// 4x4 matrix transform to output clipspace
				"mov v0, va1" 			// pass texture coordinates to fragment program
			);
			var fragmentShaderAssembler : AGALMiniAssembler = new AGALMiniAssembler(); // http://www.adobe.com/devnet/flashplayer/articles/mipmapping.html
			fragmentShaderAssembler.assemble( Context3DProgramType.FRAGMENT,
				"tex ft1, v0, fs0 <2d, linear, mipnone> \n"+ //<2d,linear,mipnone> 
				//"mul ft1, ft1, ft1.a\n" + // pre-multiply alpha
				"mov oc, ft1"
			);
			fpsProgram = context3D.createProgram();
			fpsProgram.upload( vertexShaderAssembler.agalcode, fragmentShaderAssembler.agalcode);
			
			// setup textfield
			textField = new TextField();
			textField.embedFonts = true;
			textFormat = new TextFormat("Verdana Bold", 32, 0xffffff, true);
			textFormat.align = TextFormatAlign.LEFT;
			textField.defaultTextFormat = textFormat;
		}
		
		
		
		
		
		
		
		
		
		private function setupQuadVertices():void 
		{
			var dataIndex:int = 0; 	// 6 per vertex
			var movIndex:int = 0; 	// 2 per vertex (x,y)
			
			var generalScaling:Number = 0.05;
			
			for (var t:int = 0; t < QUAD_AMOUNT; t++) {
				
				// point zero: choose a random pos / color
				var vx:Number = Math.random() * 2 - 1;
				var vy:Number = Math.random() * 2 - 1;
				var vr:Number = Math.random(); // 0..1
				var vg:Number = Math.random();
				var vb:Number = Math.random();
				
				// four points per quad
				for (var v:int = 0; v < 4; v++) {
					
					var overScale:Boolean = Math.random() < 0.2;
					vx += (Math.random() * 2 - 1) * generalScaling * (overScale?2:1)
					vy += (Math.random() * 2 - 1) * generalScaling * (overScale?2:1);
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
			var avFps:Number = 0;
			if (lastTi != 0) {
				var dt:int = ti - lastTi;
				avTime = avTime * 0.95 + dt * 0.05;
				avFps = 1000.0 / avTime;
				//trace("fps", avFps.toFixed(1));
			}
			lastTi = ti;
			
			
			
			/*var percentageTenSeconds:Number = (getTimer() % 10000) / 10000.0;
			var rad:Number = percentageTenSeconds * 2 * Math.PI;
			var sin:Number = Math.sin(rad); // -1..1
			sin += 1; // 0..2
			sin *= 0.5; //	0..1
			var speedFac:Number = 0.1 + 0.9 * sin;*/
			
			var dataIndex:int = 0; // 6 per vertex
			var movIndex:int = 0; // 3 per vertex
			var v:int;
			var vx:Vector.<Number> = new Vector.<Number>(3);
			var vy:Vector.<Number> = new Vector.<Number>(3);
			for (var t:int = 0; t < QUAD_AMOUNT;t++) {
				for (v = 0; v < 4; v++) {
					vx[v] = vertexData[dataIndex] = vertexData[dataIndex] + vertexMovData[movIndex] * speedFac;
					dataIndex++; movIndex++;
					vy[v] = vertexData[dataIndex] = vertexData[dataIndex] + vertexMovData[movIndex] * speedFac;
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
			var uploadTime:int = 0;
			vertexBuffer.uploadFromVector(vertexData, 0, VERTEX_AMOUNT);
			uploadTime = getTimer() - ti;
			avUploadTime = avUploadTime * 0.95 + uploadTime * 0.05;
			//trace("uploadTime of "+VERTEX_AMOUNT+" vertices:", getTimer() - ti, "ms");
			
			
			
			
			context3D.clear(0, 0, 0, 0.1);
			context3D.setDepthTest(false, Context3DCompareMode.ALWAYS);
			
			
			
			
			
			/*
			 * DRAW QUADS
			 */
			
			context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE);
			
			context3D.setProgram(quadProgramColor);	// assign shader program
			context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, matrix, true);// , true);
			
			context3D.setVertexBufferAt (0, vertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);	// position to attribute register 0
			context3D.setVertexBufferAt(1, vertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_3);	// color to attribute register 1
			
			context3D.drawTriangles(indexBuffer);
			
			context3D.setVertexBufferAt(0, null);
			context3D.setVertexBufferAt(1, null);
			context3D.setTextureAt(0, null);
			
			
			/*
			 * DRAW FPS
			 */
			
			context3D.setBlendFactors(Context3DBlendFactor.SOURCE_ALPHA, Context3DBlendFactor.ONE_MINUS_SOURCE_ALPHA);
			
			var bmp:BitmapData = new BitmapData(256, 128, false, 0x222222);
			textField.width = 384;
			textField.height = 128;
			textField.textColor = 0xffffff;
			textField.text = 	"FPS = " + avFps.toFixed(1) + "\n" +
								"VERTICES = " + VERTEX_AMOUNT + "\n" + 
								"upload time = " + avUploadTime.toFixed(1) + "ms";
			var textfieldMatrix:Matrix = new Matrix();
			textfieldMatrix.scale(0.5, 1.0);
			bmp.draw(textField, textfieldMatrix);
			texture.uploadFromBitmapData(bmp);
			 
			context3D.setVertexBufferAt (0, fpsVertexBuffer, 0, Context3DVertexBufferFormat.FLOAT_3);	// xyz
			context3D.setVertexBufferAt (1, fpsVertexBuffer, 3, Context3DVertexBufferFormat.FLOAT_2);	// uv
			context3D.setTextureAt(0, texture);
			
			context3D.setProgram(fpsProgram);
			context3D.setProgramConstantsFromMatrix(Context3DProgramType.VERTEX, 0, matrix, true);
			context3D.drawTriangles(fpsIndexBuffer);
			
			context3D.setVertexBufferAt(0, null);
			context3D.setVertexBufferAt(1, null);
			context3D.setTextureAt(0, null);
			
			
			// present
			
			context3D.present();
			
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