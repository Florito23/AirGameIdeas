package  
{
	import flash.geom.Point;
	import starling.display.Quad;
	
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class LineABQuad extends Quad 
	{
		public function LineABQuad(lineAb:LineAB) 
		{
			super(1, 1, 0x2233ff);
			
			var pts:Vector.<Point> = lineAb.getCornerPoints();
			
			mVertexData.setPosition(0, pts[0].x, pts[0].y);
			mVertexData.setPosition(1, pts[1].x, pts[1].y);
			mVertexData.setPosition(2, pts[2].x, pts[2].y);
			mVertexData.setPosition(3, pts[3].x, pts[3].y);
			
			onVertexDataChanged();
		}
		
	}

}