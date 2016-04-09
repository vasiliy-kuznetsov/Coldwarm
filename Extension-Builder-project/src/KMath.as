package  
{
	import flash.geom.Rectangle;
	public class KMath extends Object 
	{
		//Нужно для XORrandom
		private static const MAX_RATIO:Number = 1 / uint.MAX_VALUE;
        private static var r:uint = Math.random() * uint.MAX_VALUE;
		
		public static var RadToGrad:Number = 57.295779513;
		
		public function KMath() 
		{
			
		}
		
        public static function randomRangeInt(min:int, max:int):int 
        {
            return int(random() * (max - min + 1)) + min;
        }
        
        public static function randomRangeNumber(min:Number, max:Number):Number 
        {
            return random() * (max - min) + min;
        }
        
        public static function random():Number
        {
            r ^= (r << 21);
            r ^= (r >>> 35);
            r ^= (r << 4);
            return r * MAX_RATIO;
        }
		
		public static function segmentSuperposition(a1:Number, b1:Number, a2:Number, b2:Number):Number
		{
			var beginMax:Number = (a1 > a2) ? a1 : a2;
			var endMax:Number = (b1 > b2) ? b2 : b1;
			return endMax - beginMax;
		}
		
		/**
		 * Рассчитывает дистанцию между двумя точками.
		 * 
		 * @param x1, y1 - координаты первой точки.
		 * @param x2, y2 - коордианты второй точки.
		 * 
		 * @return дистанция.
		 */
		public static function distance(x1:Number, y1:Number, x2:Number, y2:Number):Number
		{
			var dx:Number = x2 - x1;
			var dy:Number = y2 - y1;
			return Math.sqrt(dx * dx + dy * dy);
		}
		
		/**
		 * Возвращает округленное Number число, знак округления задается.
		 * 
		 * @param base - число для округления.
		 * @param numbersAfterZero - знак после запятой, на котором происходит округление.
		 * 
		 * @return округленный Number.
		 */
		public static function roundToDecimal(base:Number, numbersAfterZero:int):Number
		{
			var eraser:int = 1;
			for (var i:int = 0; i < numbersAfterZero; i++) 
			{
				eraser *= 10;
			}
			return Math.round(base * eraser) / eraser;
		}
		
		/**
		 * Возвращает угол между двумя точками радианах.
		 * 
		 * @param x1, y1 - координаты первой точки.
		 * @param x2, y2 - координаты второй точки.
		 * 
		 * @return угол между двумя точками в радианах.
		 */
		public static function getAngle(x1:Number, y1:Number, x2:Number, y2:Number, norm:Boolean = true):Number
		{
			var dx:Number = x2 - x1;
			var dy:Number = y2 - y1;
			var angle:Number = Math.atan2(dy, dx);
			
			if (norm)
			{
				if (angle < 0)
				{
					angle = (Math.PI * 2) + angle;
				}
				else if (angle >= Math.PI * 2)
				{
					angle = angle - Math.PI * 2;
				}
			}
			
			return angle;
		}
		
		public static function normalizeAnlgeRad(inputAngle:Number):Number
		{
			var outPutAngle:Number = inputAngle;
			if (outPutAngle < 0)
			{
				outPutAngle = (Math.PI * 2) + outPutAngle;
			}
			else if (outPutAngle >= Math.PI * 2)
			{
				outPutAngle = outPutAngle - Math.PI * 2;
			}
			return outPutAngle;
		}
		
		
		//1 Коллизия прямоугольников и кругов
		/*
		public static function collisionCenteredRects(objectA:Rectangle, objectB:Rectangle):Boolean
		{
			if (   objectA.x + objectA._halfWidth  >  objectB.x - objectB._halfWidth
			    && objectA.x - objectA._halfWidth  <= objectB.x + objectB._halfWidth
				&& objectA.y + objectA._halfHeight >  objectB.y - objectB._halfHeight
				&& objectA.y - objectA._halfHeight <= objectB.y + objectB._halfHeight)
			{
				trace("3: " + "Collison");
			}
		}*/
		
	}
}