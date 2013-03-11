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
	public class Cube extends Platonic
	{
		
		public function Cube(cubeSize:Number) 
		{
			var hs:Number = cubeSize * 0.5;
			// x positive -> right
			// y positive -> down
			// z positive -> front
			
			var left:Number = -hs;
			var right:Number = hs;
			var top:Number = -hs;
			var bottom:Number = hs;
			var front:Number = hs;
			var back:Number = -hs;
			
			// all corners
			var A:Vector3D = new Vector3D(left, top, front);
			var B:Vector3D = new Vector3D(right, top, front);
			var C:Vector3D = new Vector3D(right, bottom, front);
			var D:Vector3D = new Vector3D(left, bottom, front);
			var E:Vector3D = new Vector3D(left, top, back);
			var F:Vector3D = new Vector3D(right, top, back);
			var G:Vector3D = new Vector3D(right, bottom, back);
			var H:Vector3D = new Vector3D(left, bottom, back);
			
			// uv
			var topLeft:Point = new Point(0, 0);
			var topRight:Point = new Point(1, 0);
			var bottomRight:Point = new Point(1, 1);
			var bottomLeft:Point = new Point(0, 1);
			
			// all triangles by reference
			triangles = new Vector.<Triangle>(6*2);// 6*2 by 3 triangles
			var index:int = 0;
			// front
			triangles[index++] = new Triangle( A, B, C, topLeft, topRight, bottomRight);
			triangles[index++] = new Triangle( C, D, A, bottomRight, bottomLeft, topLeft);
			// back
			triangles[index++] = new Triangle( F, E, H, topLeft, topRight, bottomRight);
			triangles[index++] = new Triangle( H, G, F, bottomRight, bottomLeft, topLeft);
			// right
			triangles[index++] = new Triangle( B, F, G, topLeft, topRight, bottomRight);
			triangles[index++] = new Triangle( G, C, B, bottomRight, bottomLeft, topLeft);
			// left
			triangles[index++] = new Triangle( E, A, D, topLeft, topRight, bottomRight);
			triangles[index++] = new Triangle( D, H, E, bottomRight, bottomLeft, topLeft);
			// top
			triangles[index++] = new Triangle( E, F, B, topLeft, topRight, bottomRight);
			triangles[index++] = new Triangle( B, A, E, bottomRight, bottomLeft, topLeft);
			// bottom
			triangles[index++] = new Triangle( D, C, G, topLeft, topRight, bottomRight);
			triangles[index++] = new Triangle( G, H, D, bottomRight, bottomLeft, topLeft);
		}
		
		
		
	}

}