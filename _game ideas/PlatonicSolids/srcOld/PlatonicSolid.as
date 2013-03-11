package platonics 
{
	import away3d.core.base.CompactSubGeometry;
	import away3d.primitives.PrimitiveBase;
	import flash.geom.Point;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class PlatonicSolid extends PrimitiveBase
	{
		
		public static const CUBE:String = "cube";
		
		//private var planeShapes:Vector.<PlaneShape>;
		private var _vertices:Vector.<Vector3D> = new Vector.<Vector3D>();
		private var _indices:Vector.<uint> = new Vector.<uint>();
		private var _uv:Vector.<Point> = new Vector.<Point>();
		
		public function PlatonicSolid(type:String, size:Number) 
		{
			
			var planeShapes:Vector.<PlaneShape> = new Vector.<PlaneShape>();
			
			switch (type) {
				case CUBE:
					planeShapes.push(PlaneShape.createSquare(size, PlaneShape.TYPE_CUBE_FRONT));
					planeShapes.push(PlaneShape.createSquare(size, PlaneShape.TYPE_CUBE_BACK));
					planeShapes.push(PlaneShape.createSquare(size, PlaneShape.TYPE_CUBE_RIGHT));
					planeShapes.push(PlaneShape.createSquare(size, PlaneShape.TYPE_CUBE_LEFT));
					planeShapes.push(PlaneShape.createSquare(size, PlaneShape.TYPE_CUBE_TOP));
					planeShapes.push(PlaneShape.createSquare(size, PlaneShape.TYPE_CUBE_BOTTOM));
					break;
			}
			
			//TODO: delete vertices that are the same and update indices
			createData(planeShapes, _indices, _vertices, _uv);
			
			
			
		}
		
		private function createData(
			planeShapes:Vector.<PlaneShape>, 
			indices:Vector.<uint>, 
			vertices:Vector.<Vector3D>, 
			uvs:Vector.<Point>):void 
		{
			var planeShape:PlaneShape;
			var triangleAmount:int;
			var t:int;
			var triangle:Vector.<uint>;
			var v:int;
			
			var index:int;
			var vertex:Vector3D;
			var uv:Point;
			
			var targetIndex:int = 0;
			
			trace("planeShapeAmount", planeShapes.length);
			for (var i:int = 0; i < planeShapes.length; i++) {
				
				planeShape = planeShapes[i];
				triangleAmount = planeShape.triangleIndices.length;
				//trace(i, "triangleAmount", triangleAmount);
				for (t = 0; t < triangleAmount; t++) {
					
					triangle = planeShape.triangleIndices[t];
					
					for (v = 0; v < 3; v++) {
						index = triangle[v];
						vertex = planeShape.vertices[index];
						uv = planeShape.uv[index];
						
						indices.push(targetIndex++);
						vertices.push(vertex);
						uvs.push(uv);
					}
				}
			}
		}
		
		/**
		 * @inheritDoc
		 */
		protected override function buildGeometry(target : CompactSubGeometry):void
		{
			
			var data:Vector.<Number>;
			var indices:Vector.<uint>;
			
			var stride:int = target.vertexStride;
			
			var numVerts:uint = _indices.length;
			data = target.vertexData;
			indices = target.indexData;
			if (numVerts == target.numVertices) {
				data = target.vertexData;
				indices = target.indexData || new Vector.<uint>(_indices.length, true);
			} else {
				data = new Vector.<Number>(numVerts * stride, true);
				indices = new Vector.<uint>(_indices.length, true);
				invalidateUVs();
			}
			
			/**
			 * Updates the vertex data. All vertex properties are contained in a single Vector, and the order is as follows:
			 * 0 - 2: vertex position X, Y, Z
			 * 3 - 5: normal X, Y, Z
			 * 6 - 8: tangent X, Y, Z
			 * 9 - 10: U V
			 * 11 - 12: Secondary U V
			 */
			
			var skip:int = stride - 3; // only XYZ
			var index:int;
			var vidx:int = target.vertexOffset;
			var fidx:int = 0;
			for (var v:int = 0; v < numVerts; v++) {
				
				indices[fidx++] = index = _indices[v];
				
				data[vidx++] = _vertices[index].x;
				data[vidx++] = _vertices[index].y;
				data[vidx++] = _vertices[index].z;
				vidx += skip;
				
			}
			
			
			
			target.autoDeriveVertexNormals = true; 
			target.autoDeriveVertexTangents = true;
			
			target.updateData(data);
			target.updateIndexData(indices);
			
			throw new Error("bla");
		}
		
		/**
		 * @inheritDoc
		 */
		protected override function buildUVs(target : CompactSubGeometry) : void
		{
			var data : Vector.<Number>;
			var stride:uint = target.UVStride;
			var skip:uint = stride - 2;
			var numUvs:uint = _uv.length;
			
			data = target.UVData;
			/*if (target.UVData && numUvs == target.UVData.length)
				data = target.UVData;
			else {
				data = new Vector.<Number>(numUvs, true);
				invalidateGeometry();
			}*/
			
			trace("data", data.length);
			
			var uidx:int = target.UVOffset;
			
			trace("numUvs", numUvs, _uv.length);
			
			for (var i:int = 0; i < numUvs; i++) {
				data[uidx++] = _uv[i].x;
				data[uidx++] = _uv[i].y;
				uidx += skip;
			}
			
			target.updateData(data);
		}
		
	}

}