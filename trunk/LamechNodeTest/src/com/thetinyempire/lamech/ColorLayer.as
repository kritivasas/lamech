package com.thetinyempire.lamech
{
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.geom.Point;
	
	public class ColorLayer extends Layer
	{
		private var _RGBA:uint;
		private var _alpha:Number;
		
		private var _TBMD:BitmapData;
		
		public function ColorLayer(rgba:uint, width:uint=0, height:uint=0)
		{
			super();
			
			// batch = pyglet.graphics.batch() ?/
			
			var p:Point = Director.getInstance().windowSize;
			
			_width = width == 0 ? p.x : width;
			_height = height == 0 ? p.y : height;
			
			transformAnchor = new Point(p.x/2, p.y/2);
			
			_RGBA = rgba;
			//_scheduledLayer = false;
			
			_TBMD = new BitmapData(_width, _height, true, _RGBA);
		}
		
		override public function get myBitmapDrawable():IBitmapDrawable
		{
			return _TBMD;
		}
	}
}