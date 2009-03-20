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
		
//		override public function draw(...args):void
//		{
//			super.draw()
//			// but draw this instead?
//		}
		
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
		
		override public function get myBitmapDrawable():IBitmapDrawable
		{
//			if(_tmRes.ready && _ready)
//			{
//				this._updateSpriteSet();
//				return _BMD
				//Debug.trace(this._x);
				
				
//				// this should be elsewhere
//				_pxWidth = _cells.width * 32
//				_pxHeight = _cells.height * 32
//				//
//				
//				var bmd:BitmapData = new BitmapData(_pxWidth, _pxHeight, true, 0x00000000);
				var bmd2:BitmapData = new BitmapData(_view.width, _view.height, true, 0x00000000);
//				
//				for(var i:uint = 0; i < _cells.width; i++)
//				{
//					for(var j:uint = 0; j < _cells.height; j++)
//					{
//						var cell:Cell = _cells.get(i, j);
//						var matrix:Matrix = new Matrix();
//						matrix.translate(cell.i * 32, cell.j * 32);
//						bmd.draw(cell.tile.image, matrix, null, null, null);
//					}
//				}
				var matrix:Matrix = new Matrix();
				matrix.translate(_view.x, _view.y);
//				
				bmd2.copyPixels(_BMD,_view,new Point(0,0));
//				_BMD.draw(bmd2);
				return(bmd2);
//			}
//			else
//			{
//				return new BitmapData(50, 50, true, 0x55000000);
//			}
		}
	}
}