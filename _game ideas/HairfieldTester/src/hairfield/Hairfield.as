package hairfield 
{
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class Hairfield 
	{
		
		private static var _SMOOTH:Number = 0.985;
		private static var _INV_SMOOTH:Number = 1.0 - SMOOTH;
		
		
		/*
		 * Hairfield data
		 */
		private var _width:int, _height:int;
		private var _lineAmount:int;
		private var _lines:Vector.<Number>; // rotation
		
		private var _cosines:Vector.<Number>;
		private var _sines:Vector.<Number>;
		private var _futureRotations:Vector.<Number>;
		private var _neighbourIndices:Vector.<Vector.<int>>;
		
		/** Aligner **/
		//private var _aligner:Aligner;
		
		public function Hairfield(width:int, height:int) 
		{
			_height = width;
			_width = height;
			_lineAmount = _width * _height;
			
			// create all lines
			_lines = new Vector.<Number>(_lineAmount);
			for (var i:int = 0; i < _lineAmount; i++) {
				_lines[i] = 2 * Math.PI * Math.random();
			}
			
			// create neighbour references
			_neighbourIndices = new Vector.<Vector.<int>>();
			var index:int = 0;
			for (var y:int = 0; y < height; y++) {
				for (var x:int = 0; x < width; x++) {
					
					// each line
					//var sourceLine:Number = _lines[index];
					var neighbours:Vector.<int> = new Vector.<int>();
					for (var yo:int = -1; yo <= 1;yo++) {
						for (var xo:int = -1; xo <= 1; xo++) {
							
							var nx:int = x + xo;
							var ny:int = y + yo;
							
							// ignore wall neighbors
							if (nx >= 0 && nx < width && ny >= 0 && ny < height) {// include self && !(xo==0&&yo==0)) {
								var nIndex:int = ny * width + nx;
								neighbours.push(nIndex);// lines[nIndex]);
							}
							
							//clip over edge neighbors:
							/*if (nx < 0) nx += width; 
							else if (nx >= width) nx -= width;
							if (ny < 0) ny += height;
							else if (ny >= height) ny -= height;
							var nIndex:int = ny * width + nx;
							neighbours.push(nIndex);*/
							
						}
					}
					_neighbourIndices[index] = neighbours;
					
					
					index++;
				}
			}
			
			// init vectors
			_cosines = new Vector.<Number>(_width * _height);
			_sines = new Vector.<Number>(_width * _height);
			_futureRotations = new Vector.<Number>(_width * _height);
			
			//_aligner = new Aligner(_height, _width, _lines);
		}
		
		
		
		public function align():int {
			var ti:int = getTimer();
			
			var index:int = 0;
			var x:int, y:int;
			var neighbours:Vector.<int>;
			var neighbourAmount:int;
			var neighbour:HairfieldLine;
			var rot:Number, lx:Number, ly:Number;
			var nRot:Number, dx:Number, dy:Number;
			var fx:Number, fy:Number;
			var avRot:Number;
			var nIndex:int = 0;
			var nnIndex:int;
			
			// calc all lines rotation sines/cosines
			// this optimizes performance from about 0.0021ms to 0.0009ms per hair
			// on Samsung Tab: from 0.0075ms to 0.0029ms
			index = 0;
			for (y = 0; y < _height; y++) {
				for (x = 0; x < _width; x++) {
					rot = _lines[index];
					_cosines[index] = Math.cos(rot); //TODO: align(): on Desktop: 1% of total calc @ 80x60
					_sines[index] = Math.sin(rot);   //TODO: align(): on Desktop: 1% of total calc @ 80x60
					index++;
				}
			}
			
			
			index = 0;
			for (y = 0; y < _height; y++) {
				for (x = 0; x < _width; x++) {
					
					lx = _cosines[index];
					ly = _sines[index];
					
					dx = dy = 0;
					neighbours = _neighbourIndices[index];
					neighbourAmount = neighbours.length;
					for (nIndex = 0; nIndex < neighbourAmount; nIndex++) {
						nnIndex = neighbours[nIndex];
						dx += _cosines[nnIndex];
						dy += _sines[nnIndex];
					}
					
					fx = dx * _INV_SMOOTH + lx * _SMOOTH;
					fy = dy * _INV_SMOOTH + ly * _SMOOTH;
					
					_futureRotations[index] = Math.atan2(fy, fx); //TODO: align(): on Desktop: 1% of total calc @ 80x60
					
					
					index++;
				}
			}
			
			
			for (index = 0; index < _lineAmount; index++) {
				_lines[index] = _futureRotations[index];
			}
			
			
			
			return (getTimer() - ti);
		}
		
		public function setDirections(indicesToModify:Vector.<int>, direction:Number):void 
		{
			var amount:int = indicesToModify.length;
			for (var i:int = 0; i < amount; i++) {
				_lines[indicesToModify[i]] = direction;
			}
		}
		
		
		public function get lines():Vector.<Number> 
		{
			return _lines;
		}
		
		
		static public function set SMOOTH(value:Number):void 
		{
			_SMOOTH = value;
			_INV_SMOOTH = 1.0 - value;
		}
		
		static public function get SMOOTH():Number 
		{
			return _SMOOTH;
		}
	}

}