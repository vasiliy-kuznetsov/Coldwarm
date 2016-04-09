package com.adobe.photoshop 
{
	/**
	 * ...
	 * @author 
	 */
	public class Photoshop 
	{
		public static const app:Application = new Application();
		
		public function Photoshop() 
		{
		}
		
		public static function randomForegroundColor():void
		{
			app.foregroundColor.rgb.red = KMath.randomRangeInt(0, 255);
			app.foregroundColor.rgb.green = KMath.randomRangeInt(0, 255);
			app.foregroundColor.rgb.blue = KMath.randomRangeInt(0, 255);
		}
	}

}