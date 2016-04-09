package 
{
	//Закомментировать в FD
	import com.adobe.csawlib.photoshop.Photoshop;
	import com.adobe.photoshop.*;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.net.SharedObject;
	import flash.ui.Keyboard;
	
	import mx.accessibility.UIComponentAccProps;
	import mx.core.UIComponent;
	
	import spark.primitives.Rect;
	
	public class ColdWarmPhotoshop extends Sprite
	{
		private static var app:Application = Photoshop.app;
		
		private var _displayParent:UIComponent;
		private var _mainSquare:UIComponent;
		private var _saturationDisplay:UIComponent;
		private var _upDisplay:UIComponent;
		
		private var _colors:Vector.<Vector.<int>>;
		private var _bitmaps:Vector.<Vector.<Bitmap>>;
		
		private var _saturationColors:Vector.<int>;
		private var _saturationBitmaps:Vector.<Bitmap>;
		private var _currentSaturationDistance:int;
		
		private var _plateSize:int = Settings.plateSize;
		private var _mainSquareSize:int = Settings.plateSize * Settings.plateRawQuantity;
		
		private var _foregroundColor:uint;
		private var _backgroundColor:uint;
		
		private var _windowWidth:int;
		private var _windowHeight:int;
		
		private var _newWindowWidth:int;
		private var _newWindowHeight:int;
		
		private var _sharedData:SharedObject;
		
		//Ui
		private var _centerColorFrame:Shape;
		private var _saturationFrame:Shape;
		
		public function load(display:UIComponent):void
		{
			//init(null);
			_displayParent = display;
			if (this.stage) init(null);
			else this.addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		public function init(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			//Stage
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			
			_windowWidth = stage.width;
			_windowHeight = stage.height;
			
			//Подгружаем foreground цвет
			_foregroundColor = loadForegroundColor();
			
			//Display
			_mainSquare = new UIComponent();
			_displayParent.addChild(_mainSquare);
			
			_saturationDisplay = new UIComponent();
			_displayParent.addChild(_saturationDisplay);
			
			_upDisplay = new UIComponent()
			_displayParent.addChild(_upDisplay);
			
			_mainSquare.x = Settings.plateBorderIndent;
			_mainSquare.y = Settings.plateBorderIndent;
			
			_saturationDisplay.y = Settings.plateBorderIndent;
			
			_sharedData = SharedObject.getLocal("ColdWarm");
			
			loadSettings();
			initColorsVectors();
			initBitmaps();
			initFrames();
			resizeListener(null);
			
			initSaturationVector();
			initSaturationBitmaps();
			refresh();
			
			if (!Settings.showSaturation)
			{
				hideSaturation();
			}
			
			this.stage.addEventListener(MouseEvent.CLICK, click);
			_displayParent.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownListener);
			_displayParent.stage.addEventListener(KeyboardEvent.KEY_UP, keyUpListener);
			stage.addEventListener(Event.ENTER_FRAME, enterFrameListener);
			stage.addEventListener(Event.RESIZE, resizeListener);
			//this.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveListener);
		}
		
		private function keyUpListener(e:KeyboardEvent):void 
		{
			var save:Boolean = (e.keyCode == Keyboard.S ||
										e.keyCode == Keyboard.NUMBER_1 || e.keyCode == Keyboard.NUMBER_2 ||
										e.keyCode == Keyboard.NUMBER_3 || e.keyCode == Keyboard.NUMBER_4 ||
										e.keyCode == Keyboard.NUMBER_5 || e.keyCode == Keyboard.NUMBER_6)
			if(save)
			{
				saveSettings();
			}
		}
		
		private function keyDownListener(e:KeyboardEvent):void 
		{
			switch (e.keyCode) 
			{
				case Keyboard.S:
					if (Settings.showSaturation)
					{
						hideSaturation();
					}else
					{
						showSaturation();
					}
					break;
				case Keyboard.A:
					//Settings.saturationHSB = !Settings.saturationHSB;
					//refresh();
					break;
				case Keyboard.NUMBER_1:
					removePlates();
					refresh();
					break;
				case Keyboard.NUMBER_2:
					addPlates();
					refresh();
					break;
				case Keyboard.NUMBER_3:
					Settings.lumaStepDistance -= 1;
					Settings.tempStepDistance -= 1; 
					refresh();
					break;
				case Keyboard.NUMBER_4:
					Settings.lumaStepDistance += 1;
					Settings.tempStepDistance += 1;
					refresh();
					break;
				case Keyboard.NUMBER_5:
					decreaseSaturation();
					refresh();
					break;
				case Keyboard.NUMBER_6:
					increaseSaturation();
					refresh();
					break;
				case Keyboard.E:
					_sharedData.clear();
					break;
			}
		}
		
		private function enterFrameListener(e:Event):void 
		{
			var currentForegroundInPS:uint = loadForegroundColor();
			if(currentForegroundInPS != _foregroundColor)
			{
				_foregroundColor = currentForegroundInPS;
				refresh();
			}
		}
		
		private function initColorsVectors():void
		{
			_colors = new Vector.<Vector.<int>>;
			
			
			for (var i:int = 0; i < Settings.PLATES_RAW_MAX_QUANTITY; i++) 
			{
				_colors[i] = new Vector.<int>;
				
				for (var j:int = 0; j < Settings.PLATES_RAW_MAX_QUANTITY; j++) 
				{
					_colors[i][j] = _foregroundColor;
				}
			}
		}
		
		private function initSaturationVector():void
		{
			_saturationColors = new Vector.<int>;
			
			for (var i:int = 0; i < Settings.PLATES_RAW_MAX_QUANTITY; i++) 
			{
				_saturationColors[i] = _foregroundColor;
			}
		}
		
		private function initBitmaps():void
		{
			_bitmaps = new Vector.<Vector.<Bitmap>>;
			for (var i:int = 0; i < Settings.PLATES_RAW_MAX_QUANTITY; i++) 
			{
				_bitmaps[i] = new Vector.<Bitmap>;
				
				for (var j:int = 0; j < Settings.PLATES_RAW_MAX_QUANTITY; j++) 
				{
					_bitmaps[i][j] = new Bitmap(new BitmapData(1, 1, false, _colors[i][j]));
					_bitmaps[i][j].x = Settings.plateSize * i + Settings.plateIndent * i;
					_bitmaps[i][j].y = Settings.plateSize * j + Settings.plateIndent * j;
					if (i < Settings.plateRawQuantity && j < Settings.plateRawQuantity)
					{
						_mainSquare.addChild(_bitmaps[i][j]);
					}
				}
			}
		}
		
		private function initSaturationBitmaps():void
		{
			_saturationBitmaps = new Vector.<Bitmap>;
			
			for (var i:int = 0; i < Settings.PLATES_RAW_MAX_QUANTITY; i++) 
			{				
				_saturationBitmaps[i] = new Bitmap(new BitmapData(1, 1, false, _saturationColors[i]));
				_saturationBitmaps[i].y = i;
				if (i < Settings.plateRawQuantity)
				{
					_saturationDisplay.addChild(_saturationBitmaps[i]);
				}
			}
		}
		
		private function initFrames():void
		{
			_centerColorFrame = new Shape();
			_upDisplay.addChild(_centerColorFrame);
			
			_saturationFrame = new Shape();
			_upDisplay.addChild(_saturationFrame);
		}
		
		private function refreshColors():void
		{
			var currentTemp:int = - (Settings.tempStepDistance * Settings.plateOneSideQuantity);
			var currentLightness:int =  (Settings.lumaStepDistance * Settings.plateOneSideQuantity);
			
			for (var i:int = 0; i < Settings.plateRawQuantity; i++) 
			{
				for (var j:int = 0; j < Settings.plateRawQuantity; j++) 
				{
					_colors[i][j] = colorCalc.getWarmerColorBrightnessFix(colorCalc.addToAllChannels(_foregroundColor, currentLightness), currentTemp);
					
					//update display
					_bitmaps[i][j].bitmapData.setPixel(0, 0, _colors[i][j]);
					
					currentLightness -= Settings.lumaStepDistance;
				}
				currentTemp += Settings.tempStepDistance;
				currentLightness =  (Settings.lumaStepDistance * Settings.plateOneSideQuantity);
			}
		}
		
		private function refresh():void
		{
			refreshColors();
			if (Settings.showSaturation)
			{
				refreshSaturation();
			}
		}
		
		private function refreshSaturation():void
		{
			var currentSaturationStep:Number = Settings.saturationMaxStep;
			
			var saturationDecreaseStep:Number = Settings.saturationMaxStep / Settings.plateOneSideQuantity;
			
			
			for (var i:int = 0; i < Settings.plateRawQuantity; i++) 
			{
				if (Settings.saturationHSB)
				{
					_saturationColors[i] = colorCalc.saturationHSBMove(_foregroundColor, currentSaturationStep);
				}else
				{
					_saturationColors[i] = colorCalc.saturationMove(_foregroundColor, currentSaturationStep);
				}
				_saturationBitmaps[i].bitmapData.setPixel(0, 0, _saturationColors[i]);
				
				currentSaturationStep -= saturationDecreaseStep;
			}
		}
		
		private function refreshFrames():void
		{
			_centerColorFrame.graphics.clear();
			_centerColorFrame.graphics.lineStyle(1, Settings.frameLightColor, 1);
			_centerColorFrame.graphics.lineTo(0, _plateSize);
			_centerColorFrame.graphics.lineTo(_plateSize, _plateSize);
			_centerColorFrame.graphics.lineTo(_plateSize, 0);
			_centerColorFrame.graphics.lineTo(0, 0);
			_centerColorFrame.graphics.lineStyle(1, Settings.frameDarkColor, 1);
			_centerColorFrame.graphics.moveTo( -1, -1);
			_centerColorFrame.graphics.lineTo( -1, _plateSize + 1);
			_centerColorFrame.graphics.lineTo( _plateSize + 1, _plateSize + 1);
			_centerColorFrame.graphics.lineTo( _plateSize + 1, -1);
			_centerColorFrame.graphics.lineTo( -1, -1);
			
			_centerColorFrame.x = Settings.plateBorderIndent + _plateSize * Settings.plateOneSideQuantity;
			_centerColorFrame.y = Settings.plateBorderIndent + _plateSize * Settings.plateOneSideQuantity;
			
			if (Settings.showSaturation)
			{
				_saturationFrame.graphics.copyFrom(_centerColorFrame.graphics);
				_saturationFrame.y = _centerColorFrame.y;
				_saturationFrame.x = Settings.plateBorderIndent + _currentSaturationDistance + _plateSize * Settings.plateRawQuantity;
			}
		}
		
		private function click(e:Event):void
		{			
			var localMouseX:int = this.mouseX - _mainSquare.x;
			var localMouseY:int = this.mouseY - _mainSquare.y;
			
			var currentBitmapX:int;
			var currentBitmapY:int;
			
			for (var i:int = 0; i < Settings.plateRawQuantity; i++) 
			{
				for (var j:int = 0; j < Settings.plateRawQuantity; j++) 
				{
					currentBitmapX = _bitmaps[i][j].x;
					currentBitmapY = _bitmaps[i][j].y;
					if (localMouseX > currentBitmapX * _mainSquare.scaleX && localMouseX <= (currentBitmapX + 1) * _mainSquare.scaleX &&
						localMouseY > currentBitmapY * _mainSquare.scaleY && localMouseY <= (currentBitmapY + 1) * _mainSquare.scaleY)
					{
						
						setForegroundColor(_colors[i][j]);
						refreshColors();
						if (Settings.showSaturation)
						{
							refreshSaturation();
						}
						return void;
					}
				}
			}
			
			// saturation
			if (Settings.showSaturation)
			{
				localMouseX = this.mouseX - _saturationDisplay.x;
				if (localMouseX < 0 || localMouseX > _plateSize) { trace("2: " + "out X"); return void; }
				if (localMouseY < 0 || localMouseY > _plateSize * Settings.plateRawQuantity) { trace("2: " + "out Y"); return void; }
				
				var clickPos:int = localMouseY / _plateSize;
				setForegroundColor(_saturationColors[clickPos]);
				
				refresh();
			}
		}
		
		private function resizeListener(e:Event):void 
		{	
			_windowWidth = stage.stageWidth;
			_windowHeight = stage.stageHeight;
			calculateScale();
		}
		
		private function calculateScale():void
		{
			var windowWidthCorrected:int = _windowWidth - Settings.plateBorderIndent * 2;
			var windwoHeightCorrected:int = _windowHeight - Settings.plateBorderIndent * 2;
			
			var _plateXSize:int;
			if (Settings.showSaturation)
			{
				_currentSaturationDistance = (windowWidthCorrected - Settings.WINDOW_MIN_WIDTH) / Settings.WINDOW_MAX_WIDTH * (Settings.saturationRawDistanceMax - Settings.saturationRawDistanceMin) + Settings.saturationRawDistanceMin;
				
				windowWidthCorrected -= _currentSaturationDistance;
				_plateXSize = windowWidthCorrected / (Settings.plateRawQuantity + 1);
			}else
			{
				_plateXSize  = windowWidthCorrected / Settings.plateRawQuantity;
			}
			
			var _plateYSize:int = windwoHeightCorrected / (Settings.plateRawQuantity);
			
			_plateSize = (_plateXSize < _plateYSize) ? _plateXSize : _plateYSize;
			
			_mainSquare.scaleX = _plateSize;
			_mainSquare.scaleY = _plateSize;
			
			if (Settings.showSaturation)
			{
				_saturationDisplay.x = _plateSize * Settings.plateRawQuantity + Settings.plateBorderIndent + _currentSaturationDistance;
				_saturationDisplay.scaleX = _plateSize;
				_saturationDisplay.scaleY = _plateSize;
			}
			
			refreshFrames();
		}
		
		private function loadSettings():void
		{
			if (_sharedData.data.plateOneSideQuantity != undefined)
			{
				Settings.plateOneSideQuantity = _sharedData.data.plateOneSideQuantity;
				Settings.plateRawQuantity = Settings.plateOneSideQuantity * 2 + 1;
			}
			if (_sharedData.data.tempStep != undefined) { Settings.tempStepDistance = _sharedData.data.tempStep;}
			if (_sharedData.data.lumaStep != undefined) { Settings.lumaStepDistance = _sharedData.data.lumaStep}
			if (_sharedData.data.saturationMaxStep != undefined) { Settings.saturationMaxStep = _sharedData.data.saturationMaxStep}
			if (_sharedData.data.showSaturation != undefined) { Settings.showSaturation = _sharedData.data.showSaturation}
		}
		
		private function saveSettings():void
		{
			_sharedData.data.lumaStep = Settings.lumaStepDistance;
			_sharedData.data.tempStep = Settings.tempStepDistance;
			_sharedData.data.saturationMaxStep = Settings.saturationMaxStep;
			_sharedData.data.showSaturation = Settings.showSaturation;
			_sharedData.data.plateOneSideQuantity = Settings.plateOneSideQuantity;
			_sharedData.flush();
		}
		
		private function hideSaturation():void
		{
			Settings.showSaturation = false;
			for (var i:int = 0; i < Settings.plateRawQuantity; i++) 
			{
				_saturationDisplay.removeChild(_saturationBitmaps[i]);
			}
			_upDisplay.removeChild(_saturationFrame);
			
			resizeListener(null);
		}
		
		private function showSaturation():void
		{
			Settings.showSaturation = true;
			for (var i:int = 0; i < Settings.plateRawQuantity; i++) 
			{
				_saturationDisplay.addChild(_saturationBitmaps[i]);
			}
			_upDisplay.addChild(_saturationFrame);
			refresh();
			resizeListener(null);
		}
		
		private function addPlates():void
		{
			if (Settings.plateOneSideQuantity >= Settings.PLATES_ONE_SIDE_MAX_QUANTITY) { return void; }
			
			for (var i:int = 0; i < Settings.plateRawQuantity; i++) 
			{
				for (var j:int = Settings.plateRawQuantity; j < Settings.plateRawQuantity + 2; j++) 
				{
					_mainSquare.addChild(_bitmaps[i][j]);
				}
			}
			
			for (var k:int = Settings.plateRawQuantity; k < Settings.plateRawQuantity + 2; k++) 
			{
				for (var l:int = 0; l < Settings.plateRawQuantity + 2; l++) 
				{
					_mainSquare.addChild(_bitmaps[k][l]);
				}
			}
			
			if(Settings.showSaturation)
			{
				for (var m:int = Settings.plateRawQuantity; m < Settings.plateRawQuantity + 2; m++) 
				{
					_saturationDisplay.addChild(_saturationBitmaps[m]);
				}
			}
			
			Settings.plateOneSideQuantity += 1;
			Settings.plateRawQuantity = Settings.plateOneSideQuantity * 2 + 1;
			resizeListener(null);
			refresh();
		}
		
		private function removePlates():void
		{
			if (Settings.plateOneSideQuantity <= 1) { return void; }
			
			for (var i:int = 0; i < Settings.plateRawQuantity; i++) 
			{
				for (var j:int = 0; j < Settings.plateRawQuantity; j++) 
				{
					_mainSquare.removeChild(_bitmaps[i][j]);
				}
				
				if(Settings.showSaturation)
				{
					_saturationDisplay.removeChild(_saturationBitmaps[i]);
				}
			}
			
			Settings.plateOneSideQuantity -= 1;
			Settings.plateRawQuantity = Settings.plateOneSideQuantity * 2 + 1;
			
			for (i = 0; i < Settings.plateRawQuantity; i++) 
			{
				for (j = 0; j < Settings.plateRawQuantity; j++) 
				{
					_mainSquare.addChild(_bitmaps[i][j]);
				}
				
				if(Settings.showSaturation)
				{
					_saturationDisplay.addChild(_saturationBitmaps[i]);
				}
			}
			
			resizeListener(null);
			refresh();
		}
		
		private function increaseSaturation():void
		{
			Settings.saturationMaxStep += 0.1;
			if (Settings.saturationMaxStep > 1) { Settings.saturationMaxStep = 1; }
		}
		
		private function decreaseSaturation():void
		{
			Settings.saturationMaxStep -= 0.1;
			if (Settings.saturationMaxStep < -1) { Settings.saturationMaxStep = -1; }
		}
		
		public static function setForegroundColor(newColor:uint):void
		{
			var color:SolidColor = new SolidColor();
			color.rgb.blue = colorCalc.getBlue24(newColor);
			color.rgb.red = colorCalc.getRed24(newColor);
			color.rgb.green = colorCalc.getGreen24(newColor);
			app.foregroundColor = color;
		}
		
		private static function loadForegroundColor():uint
		{
			var color:SolidColor = app.foregroundColor;
			return colorCalc.combineTo24(color.rgb.red, color.rgb.green, color.rgb.blue);
		}
		
		public static function setBackgroundColor(newColor:uint):void
		{
			var color:SolidColor = new SolidColor();
			color.rgb.blue = colorCalc.getBlue24(newColor);
			color.rgb.red = colorCalc.getRed24(newColor);
			color.rgb.green = colorCalc.getGreen24(newColor);
			app.backgroundColor = color;
		}
		
		private static function loadBackgroundColor():uint
		{
			var color:SolidColor = app.backgroundColor;
			return colorCalc.combineTo24(color.rgb.red, color.rgb.green, color.rgb.blue);
		}
	}
}