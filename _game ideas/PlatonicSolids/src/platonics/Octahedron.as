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
	public class Octahedron extends Platonic
	{
		
		public function Octahedron(cubeSize:Number, textureSize:int = 0) 
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
			var A:Vector3D = new Vector3D(0, top, 0);
			var B:Vector3D = new Vector3D(left, 0, 0);
			var C:Vector3D = new Vector3D(0, 0, front);
			var D:Vector3D = new Vector3D(right, 0, 0);
			var E:Vector3D = new Vector3D(0, 0, back);
			var F:Vector3D = new Vector3D(0, bottom, 0);
			
			// uv
			var corner0:Point = new Point(0, 0);
			var corner1:Point = new Point(0.8660234375, 0.5);//	0 / 1);
			var corner2:Point = new Point(0, 1);
			// point one pixel inward
			if (textureSize>0) {
				var cornerAv:Point = new Point((corner0.x + corner1.x + corner2.x) / 3, (corner0.y + corner1.y + corner2.y) / 3);
				var all:Vector.<Point> = Vector.<Point>([corner0, corner1, corner2]);
				var scl:Number = ((textureSize / 2)-1) / (textureSize / 2);
				for (var i:int = 0; i < 3; i++) {
					all[i] = all[i].subtract(cornerAv);
					all[i].x *= scl;
					all[i].y *= scl;
					all[i] = all[i].add(cornerAv);
				}
				corner0 = all[0];
				corner1 = all[1];
				corner2 = all[2];
			}
			
			// all triangles by reference
			triangles = new Vector.<Triangle>(8);// 6*2 by 3 triangles
			var index:int = 0;
			// front
			triangles[index++] = new Triangle( A, C, B, corner0, corner1, corner2);
			triangles[index++] = new Triangle( A, D, C, corner0, corner1, corner2);
			triangles[index++] = new Triangle( A, E, D, corner0, corner1, corner2);
			triangles[index++] = new Triangle( A, B, E, corner0, corner1, corner2);
			triangles[index++] = new Triangle( F, C, D, corner0, corner1, corner2);
			triangles[index++] = new Triangle( F, B, C, corner0, corner1, corner2);
			triangles[index++] = new Triangle( F, E, B, corner0, corner1, corner2);
			triangles[index++] = new Triangle( F, D, E, corner0, corner1, corner2);
			
		}
		
		
		
	}

}