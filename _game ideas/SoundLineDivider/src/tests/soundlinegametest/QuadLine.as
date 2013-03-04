package tests.soundlinegametest
{
	import flash.geom.Point;
	import flash.geom.Vector3D;
	import starling.display.Quad;
	
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class QuadLine extends Quad 
	{
		
		private var _thickness:Number;
		
		public function QuadLine(x0:Number, y0:Number, x1:Number, y1:Number, thickness:Number, color:uint) 
		{
			super(Math.abs(x1 - x0), Math.abs(y1 - y0), color);
			_thickness = thickness;
			updatePoints(new Vector3D(x0, y0), new Vector3D(x1, y1));
		}
		
		public function updatePoints(A:Vector3D, B:Vector3D):void
		{
			
			var ax:Number = A.x, ay:Number = A.y;
			var bx:Number = B.x, by:Number = B.y;
			
			// vector full length & calculate direction
			var dirVec:Point = new Point(bx - ax, by - ay);
			
			// now normalize to halfLineWidth
			dirVec.normalize(_thickness * 0.5);
			
			// and extend a-b with half line width
			var extendX:Number = dirVec.x;
			var extendY:Number = dirVec.y;
			ax = ax - extendX;
			ay = ay - extendY;
			bx = bx + extendX;
			by = by + extendY;
			
			// rotate dir vec (swap x/y) for use as "line width"
			var tmp:Number = dirVec.x;
			dirVec.x = dirVec.y;
			dirVec.y = tmp;
			
			// and make those points
			var cp0x:Number = ax + dirVec.x, cp0y:Number = ay - dirVec.y;
			var cp1x:Number = bx + dirVec.x, cp1y:Number = by - dirVec.y;
			var cp2x:Number = ax - dirVec.x, cp2y:Number = ay + dirVec.y;
			var cp3x:Number = bx - dirVec.x, cp3y:Number = by + dirVec.y;
			
			mVertexData.setPosition(0, cp0x, cp0y);
			mVertexData.setPosition(1, cp1x, cp1y);
			mVertexData.setPosition(2, cp2x, cp2y);
			mVertexData.setPosition(3, cp3x, cp3y);
			
			onVertexDataChanged();
		}
		
	}

}