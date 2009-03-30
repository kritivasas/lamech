package com.thetinyempire.lamech.layer
{
	import com.thetinyempire.lamech.Director;
	import com.thetinyempire.lamech.Window;
	import com.thetinyempire.lamech.resource.ImageResource;
	
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.events.Event;
	import flash.geom.Matrix;
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
		
		override public function draw(...args):void
		{
			var matrix:Matrix = new Matrix();
			
//			matrix.translate(-this._width/2 -16, -this._height/2 -16);
//			matrix.rotate(_rotation);
			
//			var tfp:Sprite = new Sprite();
//			tfp.graphics.beginFill(0xff0000);
//			tfp.graphics.drawCircle(0,0,5);
//			tfp.graphics.endFill();
			
			//_parent._BMD.draw(tfp, matrix, null, BlendMode.NORMAL);
			
//			matrix.translate(this._width/2 +16, this._height/2 +16);
			matrix.translate(_x, _y);
			
			
			
			
			if(_grid && _grid.active)
			{
				var ibmd:IBitmapDrawable =  _grid.blit() as IBitmapDrawable;
				_parent._BMD.draw(ibmd, matrix, null);
			}
			else
			{
				var tbmd:BitmapData;
			
				if(_imgRes.ready)
				{
					var bmd1:BitmapData = new BitmapData(_view.width, _view.height, true, 0x00000000);
					var bmd2:BitmapData = new BitmapData(_pxWidth, _pxHeight, true, 0x00000000);
					
					bmd2.draw(_imgRes.img,null,null,null,null,true);
					bmd1.copyPixels(bmd2, _view, new Point(0,0));
					tbmd= bmd1;
				}
				else
				{
					tbmd = new BitmapData(50, 50, true, 0x55000000);
				}
			
				_parent._BMD.draw(tbmd, matrix, null);
			}
		}
		
		private function onComplete(e:Event):void
		{
			init()
			_imgRes.removeEventListener(Event.COMPLETE, onComplete);
		}
	}
}