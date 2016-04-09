package  
{
	import flash.geom.Rectangle;
	public class KMath extends Object 
	{
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
		
		public static function distance(x1:Number, y1:Number, x2:Number, y2:Number):Number
		{
			var dx:Number = x2 - x1;
			var dy:Number = y2 - y1;
			return Math.sqrt(dx * dx + dy * dy);
		}
		
		public static function roundToDecimal(base:Number, numbersAfterZero:int):Number
		{
			var eraser:int = 1;
			for (var i:int = 0; i < numbersAfterZero; i++) 
			{
				eraser *= 10;
			}
			return Math.round(base * eraser) / eraser;
		}
		
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
	}
}