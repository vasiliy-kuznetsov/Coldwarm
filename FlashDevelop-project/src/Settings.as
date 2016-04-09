package
{
	public class Settings 
	{		
		public static const WINDOW_MAX_WIDTH:int = 500;
		public static const WINDOW_MAX_HEIGHT:int = 500;
		
		public static const WINDOW_MIN_WIDTH:int = 60;
		public static const WINDOW_MIN_HEIGHT:int = 50;
		
		public static const PLATES_ONE_SIDE_MAX_QUANTITY:int = 5;
		public static const PLATES_RAW_MAX_QUANTITY:int = PLATES_ONE_SIDE_MAX_QUANTITY * 2 + 1;
		
		public static var plateOneSideQuantity:int = 2;
		public static var plateRawQuantity:int = plateOneSideQuantity * 2 + 1;
		
		public static var plateSize:int = 1;
		public static var plateIndent:int = 0;
		public static var plateBorderIndent:int = 5;
		
		public static var saturationRawDistanceMin:int = 2;
		public static var saturationRawDistanceMax:int = 8;
		public static var showSaturation:Boolean = true;
		
		public static var tempStepDistance:int = 12; 
		public static var lumaStepDistance:int = 12;
		
		public static var saturationMaxStep:Number = 1;
		public static var saturationHSB:Boolean = false;
		
		public static var frameLightColor:uint = 0xAAAAAA;
		public static var frameDarkColor:uint = 0x444444;
		
		public static const DOWN_ADDITIONAL_INDENT:int = 28;
		
		public function Settings() 
		{
			
		}		
	}
}