	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import mx.core.UIComponent;
	import spark.primitives.Rect;
	import flash.display.StageScaleMode;
	import com.adobe.photoshop.Photoshop;
	
	private var _display:UIComponent;
	
	private var _coldWarm:ColdWarmPhotoshop  = new ColdWarmPhotoshop();
	
	private var _showPSColors:Boolean = false;
	private var _psColors:ColorsDisplay;
	
	public function load():void
	{		
		if (stage) init(null);
		else this.addEventListener(Event.ADDED_TO_STAGE, init);
	}
	
	public function init(e:Event):void
	{
		removeEventListener(Event.ADDED_TO_STAGE, init);
		
		//init display container
		_display = new UIComponent();
		_display.width = this.width;
		_display.height = this.height;
		_display.x = 0;
		_display.y = 0;
		this.addElement(_display);
		
		_psColors = new ColorsDisplay(_display);
		
		_coldWarm.load(_display);
		_display.addChild(_coldWarm);
		
		Photoshop.randomForegroundColor();
		
		this.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownListener);
		this.stage.addEventListener(KeyboardEvent.KEY_UP, keyUpListener);
		this.stage.addEventListener(Event.ENTER_FRAME, enterFrameListener);
	}
	
	private function enterFrameListener(e:Event):void 
	{
		if (_showPSColors)
		{
			_psColors.updateColors();
			if (!_display.contains(_psColors._foreground))
			{
				_display.addChild(_psColors._background);
				_display.addChild(_psColors._foreground);
			}
		}else
		{
			if (_display.contains(_psColors._foreground))
			{
				_display.removeChild(_psColors._foreground);
				_display.removeChild(_psColors._background);
			}
		}
	}
	
	private function keyDownListener(e:KeyboardEvent):void 
	{
		switch (e.keyCode) 
		{
			case Keyboard.R:
				Photoshop.randomForegroundColor();
				break;
			case Keyboard.S:
				_showPSColors = true;
				break;
			default:
		}
	}
	
	private function keyUpListener(e:KeyboardEvent):void 
	{
		switch (e.keyCode) 
		{
			case Keyboard.S:
				_showPSColors = false;
				break;
			default:
		}
	}