package  
{
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author Marcus Graf
	 */
	public class Aligner 
	{
		
		private var _width:int;
		private var _height:int;
		private var _lines:Vector.<Line>;
		private var _linesAmount:int;
		private var _cosines:Vector.<Number>;
		private var _sines:Vector.<Number>;
		private var _futureRotations:Vector.<Number>;
		private var _neighbourIndices:Vector.<Vector.<int>>;
		
		public function Aligner(width:int, height:int, lines:Vector.<Line>) 
		{
			this._width = width;
			this._height = height;
			this._lines = lines;
			
			_linesAmount = _lines.length;
			
			_neighbourIndices = new Vector.<Vector.<int>>();
			var index:int = 0;
			for (var y:int = 0; y < height; y++) {
				for (var x:int = 0; x < width; x++) {
					
					// each line
					var sourceLine:Line = lines[index];
					var neighbours:Vector.<int> = new Vector.<int>();
					for (var yo:int = -1; yo <= 1;yo++) {
						for (var xo:int = -1; xo <= 1; xo++) {
							
							var nx:int = x + xo;
							var ny:int = y + yo;
							if (nx >= 0 && nx < width && ny >= 0 && ny < height) {// include self && !(xo==0&&yo==0)) {
								var nIndex:int = ny * width + nx;
								neighbours.push(nIndex);// lines[nIndex]);
							}
							
						}
					}
					_neighbourIndices[index] = neighbours;
					
					
					index++;
				}
			}
			
			_cosines = new Vector.<Number>(_width * _height);
			_sines = new Vector.<Number>(_width * _height);
			_futureRotations = new Vector.<Number>(_width * _height);
		}
		
		
		public function align():int {
			var ti:int = getTimer();
			
			var index:int = 0;
			var x:int, y:int;
			var neighbours:Vector.<int>;
			var neighbourAmount:int;
			var neighbour:Line;
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
					rot = _lines[index].rotation;
					_cosines[index] = Math.cos(rot);
					_sines[index] = Math.sin(rot);
					index++;
				}
			}
			
			
			index = 0;
			for (y = 0; y < _height; y++) {
				for (x = 0; x < _width; x++) {
					
					rot = _lines[index].rotation;
					lx = Math.cos(rot);
					ly = Math.sin(rot);
					
					dx = dy = 0;
					neighbours = _neighbourIndices[index];
					neighbourAmount = neighbours.length;
					for (nIndex = 0; nIndex < neighbourAmount; nIndex++) {
						nnIndex = neighbours[nIndex];
						dx += _cosines[nnIndex];
						dy += _sines[nnIndex];
						//nRot = neighbours[nIndex].rotation;
						//dx += Math.cos(nRot); //TODO: calc all cosines and sines first. this might optimize quite a bit
						//dy += Math.sin(nRot);
						//dx +
					}
					
					fx = dx * 0.1 + lx * 0.9;
					fy = dy * 0.1 + ly * 0.9;
					
					_futureRotations[index] = Math.atan2(fy, fx);
					
					
					index++;
				}
			}
			
			
			for (index = 0; index < _linesAmount; index++) {
				_lines[index].rotation = _futureRotations[index];
			}
			
			
			
			return (getTimer() - ti);
		}
		
	}

}