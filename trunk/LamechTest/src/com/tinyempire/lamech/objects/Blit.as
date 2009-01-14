package com.tinyempire.lamech.objects
{
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	import flash.geom.Matrix;
	
	import com.hexagonstar.util.debug.*;
	
	public class Blit 
	{
		private var _mapArr:Array;
		private var _curr:uint;
		private var _rate:uint = 2
		private var _rateCount:uint = 0;
		
		public function Blit()
		{
			//Debug.trace('NEW BLIT');
		}
		
		public function init(t_w:uint, t_h:uint, t_map:BitmapData, t_key:Array):void
		{
			_mapArr = new Array();
			_curr = 0;
			
			for each(var i in t_key)
			{
				var t_bmp:BitmapData = new BitmapData(t_w, t_h, false, 0x33889900);
				var t_trix:Matrix = new Matrix();
				// SOFT CODE THOSE 16's !!!
				t_trix.translate(-i.x * 16, -i.y * 16)
				t_bmp.draw(t_map, t_trix, null, null );//, t_rect);
				_mapArr.push(t_bmp);
			}
		}
		
		public function get nextBlit():BitmapData
		{
			if(_rateCount == _rate)
			{
				_curr == _mapArr.length -1 ? _curr = 0 : _curr++;
				_rateCount = 0;
			}
			else
			{
				_rateCount++;
			}
			return(_mapArr[_curr]);
		}
	}
}