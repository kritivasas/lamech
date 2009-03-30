package com.thetinyempire.lamech.layer
{
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	
//	A Cocos Layer that is scrollable in a Scene.
//
//    Scrollable layers have a view which identifies the section of the layer
//    currently visible.
//
//    The scrolling is usually managed by a ScrollingManager.
	public class ScrollableLayer extends Layer
	{
		protected var _view:Rectangle;
		protected var _origin:Point;
		
		protected var _pxWidth:uint;
		protected var _pxHeight:uint;
		
		public function ScrollableLayer()
		{
			super();
			//self.batch = pyglet.graphics.Batch();
			_origin=new Point(0,0);
			_scale = 1;
			setView(0,0,50,50);
		}
		
		public function setView(x:uint, y:uint, w:uint, h:uint):void
		{
			_view = new Rectangle(x, y, w, h);
			//x -= _origin.x;
			//y -= _origin.y;
			//this.anchor = new Point(-x, -y);
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
			
			var bmd2:BitmapData = new BitmapData(_view.width, _view.height, true, 0x00000000);
			bmd2.copyPixels(_BMD, _view, new Point(0,0));
			
			if(_grid && _grid.active)
			{
				var ibmd:IBitmapDrawable =  _grid.blit() as IBitmapDrawable;
				_parent._BMD.draw(ibmd, matrix, null);
			}
			else
			{
				_parent._BMD.draw(bmd2, matrix, null);
			}
		}
		
		public function get originX():uint
		{
			return _origin.x
		}
		
		public function get originY():uint
		{
			return _origin.y
		}
		
		public function get pxWidth():uint
		{
			return _pxWidth;
		}
		
		public function get pxHeight():uint
		{
			return _pxHeight;
		}
		
		public function get view():Rectangle
		{
			return(_view);
		}
	}
}