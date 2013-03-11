package platonics 
{
	import away3d.core.base.CompactSubGeometry;
	import away3d.primitives.PrimitiveBase;
	
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class Tetrahedron extends PrimitiveBase 
	{
		
		public function Tetrahedron(cubeBase:Number) 
		{
			super();
		}
		
		protected override function buildGeometry(target : CompactSubGeometry):void
		{
			
			target.autoDeriveVertexNormals = true;
			target.autoDeriveVertexTangents = true;
			
			/**
			 * Updates the vertex data. All vertex properties are contained in a single Vector, and the order is as follows:
			 * 0 - 2: vertex position X, Y, Z
			 * 3 - 5: normal X, Y, Z
			 * 6 - 8: tangent X, Y, Z
			 * 9 - 10: U V
			 * 11 - 12: Secondary U V
			 */
			target.updateData(data);
			target.updateIndexData(indices);
		}
	}

}