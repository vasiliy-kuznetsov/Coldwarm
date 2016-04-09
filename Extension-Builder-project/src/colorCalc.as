package 
{
	import flash.display.BitmapData;
	import spark.effects.interpolation.RGBInterpolator;
	public class colorCalc extends Object
	{
		
		public function colorCalc() 
		{
			
		}
		
		/**
		 * Сравнивает два цваета, возврашает сумму разницы каналов.
		 * @param	colorA
		 * @param	colorB
		 * @return
		 */
		public static function compareTwoColors24(colorOne:uint, colorTwo:uint):int
		{
			var colorA:uint = colorOne;
			var colorB:uint = colorTwo;
			
			var red:int    = getRed24(colorA) - getRed24(colorB);
			var green:int  = Math.abs(getGreen24(colorA) - getGreen24(colorB));
			var blue:int   = Math.abs(getBlue24 (colorA) - getBlue24 (colorB));
			
			if (red   < 0){ red   = -red }
			if (green < 0){ green = -green }
			if (blue  < 0){ blue  = -blue }
			
			return red + green + blue;
		}
		
		public static function getRandomColorInRange(minChannel:uint, maxChannel:uint):uint
		{
			if (minChannel < 0 || maxChannel > 255 || minChannel > maxChannel)
			{
				throw("Error: getRandomColorInRange");
			}
			var r:uint = KMath.randomRangeInt(minChannel, maxChannel);
			var g:uint = KMath.randomRangeInt(minChannel, maxChannel);
			var b:uint = KMath.randomRangeInt(minChannel, maxChannel);
			
			return combineTo24(r, g, b);
		}
		
		/**
		 * Сдвиг цвета по насыщенности в пространстве HSB. Двигает относительно текущего положения.
		 * @param	color Цвет который нужно сдвинуть.
		 * @param	value Значение от -1 до 1. 1 - максимально насыщенный, -1 серый, 0.5 -- на пол пути к максимально насыщенному.
		 * @return Новый цвет.
		 */
		public static function saturationHSBMove(color:uint, value:Number):uint
		{
			var resultColor:uint;
			
			var rgb:Array = [getRed24(color), getGreen24(color), getBlue24(color)];
			
			//Индексы массива
			var red:int = 0;
			var green:int = 1;
			var blue:int = 2;
			
			//Если серый -- нечего делать. Если насыщенность 100% -- нечего делать. Если изменение 0 -- нечего делать. Если отключили свет -- нечего делать.
			var isGray:Boolean = (rgb[red] == rgb[green] && rgb[red] == rgb[blue] && rgb[green] == rgb[blue]);
			var isSaturationMax:Boolean = (rgb[red] == 0 || rgb[blue] == 0 || rgb[green] == 0) && value > 0;
			
			if (isGray || isSaturationMax ||  value == 0 )
			{
				return color;
			}else
			{
				if (value > 1) { value = 1; } else
				if (value < -1) { value = -1; }
			}
			
			//trace("2: " + "R: " + rgb[red] + "   G: " + rgb[green] + "   B: " + rgb[blue]);
			var h:int = (rgb[red] > rgb[green]) ? red : green;
			h = (rgb[h] > rgb[blue]) ? h : blue;
			
			var l:int = (rgb[red] < rgb[green]) ? red : green;
			l = (rgb[l] > rgb[blue]) ? blue : l;
			
			var m:int = (rgb[red] > rgb[green] && rgb[red] < rgb[blue]) || (rgb[red] > rgb[blue] && rgb[red] < rgb[green]) ? red 
						: ((rgb[green] > rgb[red] && rgb[green] < rgb[blue]) || (rgb[green] > rgb[blue] && rgb[green] < rgb[red])) ? green : blue;
			//trace("3: " + "H: " + h + "   M: " + m + "   L: " + l);
			
			if (value > 0)
			{
				//От среднего отнимаем часть пропорциональную разнице H и M к разнице H и S.
				rgb[m] -= (rgb[h] - rgb[m]) / (rgb[h] - rgb[l]) * rgb[l] * value;
				rgb[l] -= rgb[l] * value;
			}else
			{
				//Подтягиваем слабые каналы к сильному
				rgb[m] += (rgb[h] - rgb[m]) * -value;
				rgb[l] += (rgb[h] - rgb[l]) * -value;
			}
			
			return combineTo24(rgb[red], rgb[green], rgb[blue]);
		}
		
		/**
		 * Сдвиг цвета по насыщенности. Двигает относительно текущего положения. По сравнению с saturationHSBMove есть корректировки
		 * так что визуально это более похоже на Ctrl + U в ФШ.
		 * @param	color Цвет который нужно сдвинуть.
		 * @param	value Значение от -1 до 1. 1 - максимально насыщенный, -1 серый.
		 * @return Новый цвет.
		 */
		public static function saturationMove(color:uint, value:Number):uint
		{
			var resultColor:uint;
			
			var rgb:Array = [getRed24(color), getGreen24(color), getBlue24(color)];
			
			//Индексы массива
			var red:int = 0;
			var green:int = 1;
			var blue:int = 2;
			
			//Если серый -- нечего делать. Если насыщенность 100% -- нечего делать. Если изменение 0 -- нечего делать. Если отключили свет -- нечего делать.
			var isGray:Boolean = (rgb[red] == rgb[green] && rgb[red] == rgb[blue] && rgb[green] == rgb[blue]);
			var isSaturationMax:Boolean = (rgb[red] == 0 || rgb[blue] == 0 || rgb[green] == 0) && value > 0;
			
			if (isGray || isSaturationMax ||  value == 0 )
			{
				return color;
			}else
			{
				if (value > 1) { value = 1; } else
				if (value < -1) { value = -1; }
			}
			
			//trace("2: " + "R: " + rgb[red] + "   G: " + rgb[green] + "   B: " + rgb[blue]);
			var h:int = (rgb[red] > rgb[green]) ? red : green;
			h = (rgb[h] > rgb[blue]) ? h : blue;
			
			var l:int = (rgb[red] < rgb[green]) ? red : green;
			l = (rgb[l] > rgb[blue]) ? blue : l;
			
			var m:int = (rgb[red] > rgb[green] && rgb[red] < rgb[blue]) || (rgb[red] > rgb[blue] && rgb[red] < rgb[green]) ? red 
						: ((rgb[green] > rgb[red] && rgb[green] < rgb[blue]) || (rgb[green] > rgb[blue] && rgb[green] < rgb[red])) ? green : blue;
			//trace("3: " + "H: " + h + "   M: " + m + "   L: " + l);
			
			var medium:int = getLumaGray(color);
			
			if (value > 0)
			{
				//От среднего отнимаем часть пропорциональную разнице H и M к разнице H и S.
				rgb[m] -= (rgb[h] - rgb[m]) / (rgb[h] - rgb[l]) * rgb[l] * value;
				rgb[l] -= rgb[l] * value;
			}else
			{
				//Считаем яркость этого цвета и "идем" всеми каналами к ней.
				rgb[l] += (rgb[l] - medium) * value;
				rgb[m] += (rgb[m] - medium) * value;
				rgb[h] += (rgb[h] - medium) * value;				
			}
			
			return combineTo24(rgb[red], rgb[green], rgb[blue]);
		}
		
		/**
		 * Добавляет значение ко всем каналам.
		 * @param	color Оригинальный цвет.
		 * @param	value Значение, может быть отрицательным.
		 * @return получившийся цвет.
		 */
		public static function addToAllChannels(color:uint, value:int):uint
		{
			var r:int = getRed24(color) + value;
			var g:int = getGreen24(color) + value;
			var b:int = getBlue24(color) + value;
			
			if (r > 255) {  r = 255; };
			if (g > 255) {	g = 255; };
			if (b > 255) {	b = 255; };
			if (r < 0) { r = 0; }
			if (g < 0) { g = 0; }
			if (b < 0) { b = 0; }
			
			return combineTo24(r, g, b);
		}
		
		//1 Выбор и присваивание разных каналов изображению
		
		//2 HSV и обратно
		
		/**
		 * Возвращяет цвет теплее или холоднее заданного.
		 * @param	color заданный цвет.
		 * @param	distance степень утепления, если  отрицательное - степень холоднения
		 * @return
		 */
		public static function getWarmerColor(color:uint, distance:int):uint
		{
			var r:int = colorCalc.getRed24(color);
			var g:int = colorCalc.getGreen24(color);
			var b:int = colorCalc.getBlue24(color);
			
			r += distance;
			b -= distance;
			
			if (r > 255) {  r = 255; };
			if (b > 255) {	b = 255; };
			if (r < 0) { r = 0; }
			if (b < 0) { b = 0; }
			
			return colorCalc.combineTo24(r, g, b);
		}
		public static function getWarmerColorBrightnessFix(color:uint, distance:int):uint
		{
			var r:int = colorCalc.getRed24(color);
			var g:int = colorCalc.getGreen24(color);
			var b:int = colorCalc.getBlue24(color);
			
			var startBrightness:Number = getLumaGray(color);
			
			r += distance;
			b -= distance;
			
			if (r > 255) {  r = 255; };
			if (b > 255) {	b = 255; };
			if (r < 0) { r = 0; }
			if (b < 0) { b = 0; }
			
			var result:uint = combineTo24(r, g, b);
			var endBrightness:Number = getLumaGray(result);
			//trace("2: " + (endBrightness - startBrightness));
			result = addToAllChannels(result, (startBrightness - endBrightness) * 2);
			
			return result;
		}
		
		
		public static function getBlackAndWhite(bitmapData:BitmapData):BitmapData
		{
			var source:BitmapData = bitmapData;
			var result:BitmapData = new BitmapData(source.width, source.height);
			var sourcePixel:uint;
			var newPixel:uint;
			
			for (var i:int = 0; i < source.width; i++) 
			{
				for (var j:int = 0; j < source.height; j++) 
				{
					sourcePixel = source.getPixel32(i, j);
					newPixel = setAllEqualChannels(getRed32(sourcePixel) * 0.3 + getGreen32(sourcePixel) * 0.6 + getBlue32(sourcePixel) * 0.1);
					newPixel = setAlpha(newPixel, getAlpha32(sourcePixel));
					result.setPixel32(i, j, newPixel);
				}
			}
			
			return result;
		}
		
		//1 getRedChannelAsGrey
		
		public static function getRedChannelAsRed(bitmapData:BitmapData):BitmapData
		{
			var source:BitmapData = bitmapData;
			var result:BitmapData = new BitmapData(source.width, source.height);
			var sourcePixel:uint;
			var newPixel:uint;
			
			for (var i:int = 0; i < source.width; i++) 
			{
				for (var j:int = 0; j < source.height; j++) 
				{
					sourcePixel = source.getPixel32(i, j);
					newPixel = setRed(newPixel, getRed32(sourcePixel));
					newPixel = setAlpha(newPixel, getAlpha32(sourcePixel));
					result.setPixel32(i, j, newPixel);
				}
			}
			
			return result;
		}
		
		public static function getRedChannelAsRedFast(bitmapData:BitmapData):BitmapData
		{
			var result:BitmapData = bitmapData;
			for (var i:int = 0; i < result.width; i++) 
			{
				for (var j:int = 0; j < result.height; j++) 
				{
					result.setPixel(i, j, combineTo24(getRed24(result.getPixel(i, j)), 0, 0));
				}
			}
			return result;
		}
		
		/**
		 * Делает из одноканального серого, RGB серый.
		 * @param	color серый от 0 до 255.
		 * @return серый от 0 до 255 в RGB.
		 */
		public static function getGray(color:uint):uint
		{
			return combineTo24(color, color, color);
		}
		
		/**
		 * Возвращает яркость(0-255) RGB цвета.
		 * @param	color RGB цвет.
		 * @return Одноканальная яркость цвета, число от 0 до 255.
		 */
		public static function getLumaGray(color:uint):uint
		{
			var r:int = colorCalc.getRed24(color);
			var g:int = colorCalc.getGreen24(color);
			var b:int = colorCalc.getBlue24(color);
			
			return (0.2126 * r) + (0.7152 * g) + (0.0722 * b);
		}
		
		public static function getRed24(color:uint):uint
		{
			return color >>> 16;
		}
		
		public static function getGreen24(color:uint):uint
		{
			return color >>> 8 & 0xFF;
		}
		
		
		public static function getBlue24(color:uint):uint
		{
			return color & 0xFF;
		}
		
		public static function getAlpha32(color:uint):uint
		{
			return color >>> 24;
		}
		
		public static function getRed32(color:uint):uint
		{
			return color >>> 16 & 0xFF;
		}
		
		public static function getGreen32(color:uint):uint
		{
			return color >>> 8 & 0xFF;
		}
		
		public static function getBlue32(color:uint):uint
		{
			return color & 0xFF;
		}
		
		public static function setAlpha(Color:uint, value:uint):uint
		{
			return (Color & 0x00ffffff) | (value << 24);
		}
		
		public static function setRed(Color:uint, value:uint):uint
		{
			return (Color & 0xff00ffff) | (value << 16);
		}
		
		public static function setGreen(Color: uint, value:uint):uint
		{
			return (Color & 0xffff00ff) | (value << 8);
		}
		
		public static function setBlue(Color: uint, value:uint):uint
		{
			return (Color & 0xffffff00) | value;
		}
		
		public static function setAllEqualChannels(value:uint):uint
		{
			var result:uint = 0;
			result = setRed(result, value);
			result = setGreen(result, value);
			result = setBlue(result, value);
			return result;
		}
		
		public static function combineTo24(red:uint, green:uint, blue:uint):uint
		{
			return red << 16 | green << 8 | blue;
		}
		
		public static function combineTo32(alpha:uint, red:uint, green:uint, blue:uint):uint
		{
			return alpha << 24 | red << 16 | green << 8 | blue;
		}
	}

}