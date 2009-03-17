package com.thetinyempire.lamech.layer
{
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
			super.draw()
			// but draw this instead?
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
	}
}