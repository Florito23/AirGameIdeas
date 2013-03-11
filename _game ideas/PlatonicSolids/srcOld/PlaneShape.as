package platonics 
{
	import flash.geom.Point;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class PlaneShape 
	{
		
		public static const TYPE_CUBE_FRONT:String = "cubeFront";
		public static const TYPE_CUBE_BACK:String = "cubeBack";
		public static const TYPE_CUBE_RIGHT:String = "cubeRight";
		public static const TYPE_CUBE_LEFT:String = "cubeLeft";
		public static const TYPE_CUBE_TOP:String = "cubeTop";
		public static const TYPE_CUBE_BOTTOM:String = "cubeBottom";
		
		//private var _triangleVertices
		//private var _vertices:Vector.<Vector3D> = new Vector.<Vector3D>();
		//private var _triangleIndices:Vector.<Vector.<uint>> = new Vector.<Vector.<uint>>();
		//private var _uv:Vector.<Point> = new Vector.<Point>();
		
		//private var _
		
		public function PlaneShape() 
		{
		}
		
		public static function createSquare(size:Number, type:String):PlaneShape
		{
			var out:PlaneShape = new PlaneShape();
			
			var s2:Number = size * 0.5;
			
			// x positive: right
			// y positive: down
			// z positive: front
			
			// order: topleft, topright, bottomright, bottomleft when facing plane
			
			// make front plane
			switch (type) {
				case TYPE_CUBE_FRONT:
					out._vertices.push(new Vector3D( -s2, -s2, s2));
					out._vertices.push(new Vector3D( s2, -s2, s2));
					out._vertices.push(new Vector3D( s2, s2, s2));
					out._vertices.push(new Vector3D( -s2, s2, s2));
					break;
				case TYPE_CUBE_BACK:
					out._vertices.push(new Vector3D( s2, -s2, -s2));
					out._vertices.push(new Vector3D( -s2, -s2, -s2));
					out._vertices.push(new Vector3D( -s2, s2, -s2));
					out._vertices.push(new Vector3D( s2, s2, -s2));
					break;
				case TYPE_CUBE_RIGHT:
					out._vertices.push(new Vector3D( s2, -s2, s2 ));
					out._vertices.push(new Vector3D( s2, -s2, -s2 ));
					out._vertices.push(new Vector3D( s2, s2, 	-s2 ));
					out._vertices.push(new Vector3D( s2, s2, 	s2 ));
					break;
				case TYPE_CUBE_LEFT:
					out._vertices.push(new Vector3D( -s2, -s2, -s2 ));
					out._vertices.push(new Vector3D( -s2, -s2, s2 ));
					out._vertices.push(new Vector3D( -s2, s2,	s2 ));
					out._vertices.push(new Vector3D( -s2, s2,	-s2 ));
					break;
				case TYPE_CUBE_TOP:
					out._vertices.push(new Vector3D( -s2, -s2, -s2));
					out._vertices.push(new Vector3D( s2,  -s2, -s2));
					out._vertices.push(new Vector3D( s2,  -s2, s2));
					out._vertices.push(new Vector3D( -s2, -s2, s2));
					break;
				case TYPE_CUBE_BOTTOM:
					out._vertices.push(new Vector3D( -s2, s2, s2));
					out._vertices.push(new Vector3D( s2,  s2, s2));
					out._vertices.push(new Vector3D( s2,  s2, -s2));
					out._vertices.push(new Vector3D( -s2, s2, -s2));
					break;
			}
			
			// build triangles
			//out._triangleIndices.push(Vector.<uint>([0,1,2]));
			//out._triangleIndices.push(Vector.<uint>([2,3,0]));
			
			// uv
			out._uv.push(new Point(0, 0));
			out._uv.push(new Point(1, 0));
			out._uv.push(new Point(1, 1));
			out._uv.push(new Point(0, 1));
			
			return out;
			
		}
		
		public function get vertices():Vector.<Vector3D> 
		{
			return _vertices;
		}
		
		/*public function get triangleIndices():Vector.<Vector.<uint>> 
		{
			return _triangleIndices;
		}*/
		
		public function get uv():Vector.<Point> 
		{
			return _uv;
		}
		
		
		
	}

}