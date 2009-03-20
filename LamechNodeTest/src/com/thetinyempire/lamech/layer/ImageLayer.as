package com.thetinyempire.lamech.layer
{
	import com.thetinyempire.lamech.Director;
	import com.thetinyempire.lamech.Window;
	import com.thetinyempire.lamech.resource.ImageResource;
	
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class ImageLayer extends ScrollableLayer
	{
		private var _imgRes:ImageResource;
		private var _TBMD:BitmapData;
		private var _window:Window;
		
		public function ImageLayer(imgRes:ImageResource)
		{
			super();
			_window = Window.getInstance();
			
			_imgRes = imgRes
			
			if(_imgRes.ready)
			{
				init();
			}
			else
			{
				_imgRes.addEventListener(Event.COMPLETE, onComplete);
			}
			// batch = pyglet.graphics.batch() ?/
		}
		
		private function init():void
		{
			var p:Point = Director.getInstance().windowSize;
			
			_pxWidth = _imgRes.width
			_pxHeight = _imgRes.height
			
			transformAnchor = new Point(_width/2, _height/2);
			
			setView(0, 0, _window.width, _window.height);
			//_scheduledLayer = false;
			
			
		}
		
		private function onComplete(e:Event):void
		{
			init()
			_imgRes.removeEventListener(Event.COMPLETE, onComplete);
		}
		
		override public function get myBitmapDrawable():IBitmapDrawable
		{
			if(_imgRes.ready)
			{
				var bmd1:BitmapData = new BitmapData(_view.width, _view.height, true, 0x00000000);
				var bmd2:BitmapData = new BitmapData(_pxWidth, _pxHeight, true, 0x00000000);
				
				bmd2.draw(_imgRes.img,null,null,null,null,true);
				bmd1.copyPixels(bmd2, _view, new Point(0,0));
				return bmd1;
			}
			else
			{
				return new BitmapData(50, 50, true, 0x55000000);
			}
		}
	}
}