package  
{
	import com.adobe.photoshop.Photoshop;
	import com.adobe.photoshop.SolidColor;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	import mx.core.IUIComponent;
	import mx.core.UIComponent;
	
	public class ColorsDisplay extends Sprite 
	{
		public var _foreground:Bitmap;
		public var _background:Bitmap;
		private var _display:UIComponent;
		
		private var _rect:Rectangle;
		
		public function ColorsDisplay(display:UIComponent) 
		{
			_display = display;
			_rect = new Rectangle(0, 0, 30, 30);
			
			_background = new Bitmap(new BitmapData(30, 30, false, 0x00));
			_background.x = 20;
			_background.y = 20;
			
			_foreground = new Bitmap(new BitmapData(30, 30, false, 0x00));
			_foreground.x = 10;
			_foreground.y = 10;
		}
		
		public function updateColors():void
		{
			var solidColor:SolidColor = Photoshop.app.backgroundColor;
			var backColor:uint = colorCalc.combineTo24(solidColor.rgb.red, solidColor.rgb.green, solidColor.rgb.blue);
			_background.bitmapData.fillRect(_rect, backColor);
			
			solidColor = Photoshop.app.foregroundColor;
			var frontColor:uint = colorCalc.combineTo24(solidColor.rgb.red, solidColor.rgb.green, solidColor.rgb.blue);
			_foreground.bitmapData.fillRect(_rect, frontColor);
		}
	}
}