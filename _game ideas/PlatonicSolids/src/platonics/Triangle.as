package platonics 
{
	import flash.geom.Point;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class Triangle 
	{
		
		public var a:Vector3D, b:Vector3D, c:Vector3D, uvA:Point, uvB:Point, uvC:Point;
		
		public function Triangle(a:Vector3D, b:Vector3D, c:Vector3D, uvA:Point, uvB:Point, uvC:Point) 
		{
			this.a = a;
			this.b = b;
			this.c = c;
			this.uvA = uvA;
			this.uvB = uvB;
			this.uvC = uvC;
		}
		
		public function calculateCenter():Vector3D {
			var out:Vector3D = (new Vector3D()).add(a).add(b).add(c);
			out.scaleBy(1 / 3.0);
			return out;
		}
		
		public function hasVertex(vertex:Vector3D):Boolean {
			return vertex.equals(a) || vertex.equals(b) || vertex.equals(c);
		}
		
		public function getAVertexThatIsNot(vertex:Vector3D):Vector3D 
		{
			if (!a.equals(vertex)) {
				return a;
			} else if (!b.equals(vertex)) {
				return b;
			} else if (!c.equals(vertex)) {
				return c;
			} else {
				return null;
			}
		}
		
		public function getOtherVertex(v0:Vector3D, v1:Vector3D):Vector3D 
		{
			var all:Vector.<Vector3D> = Vector.<Vector3D>([a, b, c]);
			var indices:Vector.<int> = Vector.<int>([0, 1, 2]);
			var i0:int = all.indexOf(v0); if (i0 == -1) throw new Error("Does not contain v0");
			var i1:int = all.indexOf(v1); if (i1 == -1) throw new Error("Does not contain v1");
			indices.splice(i0, 1);
			indices.splice(i1, 1);
			return all[indices[0]];
		}
		
		private static const digits:int = 2;
		private static const delim:String = "\t\t";
		public function toString():String
		{
			var out:String = "";
			out += "A " + a.x.toFixed(digits) + ", " + a.y.toFixed(digits) + ", " + a.z.toFixed(digits) + delim;
			out += "B " + b.x.toFixed(digits) + ", " + b.y.toFixed(digits) + ", " + b.z.toFixed(digits) + delim;
			out += "C " + c.x.toFixed(digits) + ", " + c.y.toFixed(digits) + ", " + c.z.toFixed(digits);
			return out;
		}
	}

}