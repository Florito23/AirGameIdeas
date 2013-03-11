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
	public class Platonic extends PrimitiveBase
	{
		
		internal var triangles:Vector.<Triangle>;
		
		public function Platonic() 
		{
			
		}
		
		/**
		 * @inheritDoc
		 */
		protected override function buildGeometry(target : CompactSubGeometry):void
		{
			trace(this, "buildGeometry"); 
			
			var data : Vector.<Number>;
			var indices : Vector.<uint>;
			
			var numVerts:uint = triangles.length * 3;// cornerVertices.length;
			var stride:uint = target.vertexStride;
			var skip:uint = stride - 3; // just XYZ, normals and tangents are auto derived
			
			if (numVerts == target.numVertices) {
				data = target.vertexData;
				indices = target.indexData || new Vector.<uint>(triangles.length * 3, true);
			}
			else {
				data = new Vector.<Number>(triangles.length * 3 * stride, true);// numVerts * stride, true);
				indices = new Vector.<uint>(triangles.length * 3, true);
				invalidateUVs();
			}
			
			// Indices
			var vidx:uint = target.vertexOffset;
			var fidx:uint = 0;
			
			// vertex data
			/*var i:int;
			for (i = 0; i < cornerVertices.length; i++) {
				data[vidx++] = cornerVertices[i].x;
				data[vidx++] = cornerVertices[i].y;
				data[vidx++] = cornerVertices[i].z;
				vidx += skip;
			}*/
			
			var i:int;
			var vIndex:int = 0;
			for (i = 0; i < triangles.length; i++) {
				data[vidx++] = triangles[i].a.x;
				data[vidx++] = triangles[i].a.y;
				data[vidx++] = triangles[i].a.z;
				indices[fidx++] = vIndex++;
				vidx += skip;
				data[vidx++] = triangles[i].b.x;
				data[vidx++] = triangles[i].b.y;
				data[vidx++] = triangles[i].b.z;
				indices[fidx++] = vIndex++;
				vidx += skip;
				data[vidx++] = triangles[i].c.x;
				data[vidx++] = triangles[i].c.y;
				data[vidx++] = triangles[i].c.z;
				indices[fidx++] = vIndex++;
				vidx += skip;
			}
			
			// vertex data
			// index data
			/*for (i = 0; i < triangles.length; i++) {
				var A:Vector3D = triangles[i].a;
				var B:Vector3D = triangles[i].b;
				var C:Vector3D = triangles[i].c;
				var indexOfA:uint = cornerVertices.indexOf(A);
				var indexOfB:uint = cornerVertices.indexOf(B);
				var indexOfC:uint = cornerVertices.indexOf(C);
				indices[fidx++] = indexOfA;
				indices[fidx++] = indexOfB;
				indices[fidx++] = indexOfC;
			}*/
			
			target.autoDeriveVertexNormals = true; 
			target.autoDeriveVertexTangents = true;
			target.updateData(data);
			target.updateIndexData(indices);
		}
		
		/**
		 * @inheritDoc
		 */
		override protected function buildUVs(target : CompactSubGeometry) : void
		{
			trace(this, "buildUVs");
			var i : uint, j : uint, uidx : uint;
			var data : Vector.<Number>;
			var stride:uint = target.UVStride;
			var numUvs : uint = triangles.length * 3 * 2; // 3 vectors, 2 params (u/v)
			var skip:uint = stride - 2;
			
			data = target.UVData;
			/*if (target.UVData && numUvs == target.UVData.length)
				data = target.UVData;
			else {
				data = new Vector.<Number>(numUvs, true);
				invalidateGeometry();
			}*/
			
			uidx = target.UVOffset;
			for (i = 0; i < triangles.length; i++) {
				var uvA:Point = triangles[i].uvA; 
				var uvB:Point = triangles[i].uvB;
				var uvC:Point = triangles[i].uvC;
				data[uidx++] = uvA.x;
				data[uidx++] = uvA.y;
				uidx += skip;
				data[uidx++] = uvB.x;
				data[uidx++] = uvB.y;
				uidx += skip;
				data[uidx++] = uvC.x;
				data[uidx++] = uvC.y;
				uidx += skip;
			}
			
		}
	}

}