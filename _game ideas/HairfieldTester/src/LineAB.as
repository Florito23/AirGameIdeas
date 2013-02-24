package  
{
	import flash.geom.Point;
	import starling.display.Quad;
	
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class LineAB 
	{
		
		private var _direction:Number;
		
		private var cp0:Point = new Point();
		private var cp1:Point = new Point();
		private var cp2:Point = new Point();
		private var cp3:Point = new Point();
		
		private var fourPoints:Vector.<Point>;
		
		public function LineAB(ax:Number, ay:Number, bx:Number, by:Number, lineWidth:Number) 
		{
			
			// vector full length & calculate direction
			var dirVec:Point = new Point(bx - ax, by - ay);
			_direction = Math.atan2(dirVec.y, dirVec.x);
			
			// now normalize to halfLineWidth
			var halfLineWidth:Number = lineWidth * 0.5;
			dirVec.normalize(halfLineWidth);
			
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
			cp0.x = ax + dirVec.x; cp0.y = ay - dirVec.y;
			cp1.x = bx + dirVec.x; cp1.y = by - dirVec.y;
			cp2.x = ax - dirVec.x; cp2.y = ay + dirVec.y;
			cp3.x = bx - dirVec.x; cp3.y = by + dirVec.y;
			
			fourPoints = new <Point>[
				cp0,cp1,cp2,cp3
			];
		}
		
		
		
		/*var preExtend:Point = fullLenNorm.clone();
		preExtend.normalize( -lineWidth / 2);
		var postExtend:Point = fullLen.clone();
		postExtend.normalize( lineWidth / 2);*/
		
		/*var preExtend:Point = new Point(flx * -halfLine, fly * -halfLine);
		var postExtend:Point = new Point(flx * halfLine, fly * halfLine);
		
		var startPoint:Point = new Point(ax, ay);
		startPoint = startPoint.add(preExtend);
		var endPoint:Point = new Point(bx, by);
		endPoint = endPoint.add(postExtend);
		
		ax = startPoint.x;
		ay = startPoint.y;
		bx = endPoint.x;
		by = endPoint.y;*/
		
		/**
		 * Corner points: (top-left, top-right, bottom-left, bottom-right)
		 * <pre>
		 * 0*******1
		 * *       *
		 * *       *
		 * 2*******3
		 * </pre>
		 * @return
		 */
		public function getCornerPoints():Vector.<Point> {
			return fourPoints;
		}
		
		public function get direction():Number 
		{
			return _direction;
		}
		
	}

}