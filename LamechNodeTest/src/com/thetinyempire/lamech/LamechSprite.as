package com.thetinyempire.lamech
{
	import com.thetinyempire.lamech.base.BaseLamechNode;
	
	import flash.display.IBitmapDrawable;
	import flash.geom.Point;

	public class LamechSprite extends BaseLamechNode
	{
//		'''Initialize the sprite
//
//        :Parameters:
//                `image` : string or image
//                    name of the image resource or a pyglet image.
//                `position` : tuple
//                    position of the anchor. Defaults to (0,0)
//                `rotation` : float
//                    the rotation (degrees). Defaults to 0.
//                `scale` : float
//                    the zoom factor. Defaults to 1.
//                `opacity` : int
//                    the opacity (0=transparent, 255=opaque). Defaults to 255.
//                `color` : tuple
//                    the color to colorize the child (RGB 3-tuple). Defaults to (255,255,255).
//                `anchor` : (float, float)
//                    (x,y)-point from where the image will be positions, rotated and scaled in pixels. For example (image.width/2, image.height/2) is the center (default).
//        '''

		private var _imageAnchor:Point;
		private var _ARGB:uint;
		private var _group:Object;
		private var _childrenGroup:Object;
		private var _position:Point;
		private var _image:Object;
		
		public function LamechSprite(image:Object, position:Point = null, rotation:Number = 0, ARGB:uint = 0x00000000, anchor:Object = null, density:uint = 0)
		{
			super();
			
			if(image is String)
			{
				//load the image from the rescource based on the "image" as a string id value
			}
			else
			{
				_image = image
			}
			
//			if(anchor = null)
//			{
//				if(image is Image)
//				{
//					anchor = image.width / 2, image.height / 2
//				}
//			}
			
			//_imageAnchor = anchor
			this.anchor = new Point(position.x, position.y);
			
			_group = null;
			_childrenGroup = null;
			_position = position != null ? position : new Point(0, 0);
			_rotation = rotation;
			//this.scale = scale;
			_ARGB = ARGB;
			
			_physRep = _physWorld.createBox(this.anchor, density);
			
		}
		
		public function set imageAnchorX(n:Number):void
		{
			_image.anchorX = n;
//			_updatePosition()
		}
		
		public function get imageAnchorX():Number
		{
			return _image.anchorX;
		}
		
		public function set imageAnchorY(n:Number):void
		{
			_image.anchorY = n;
//			_updatePosition()
		}
		
		public function get imageAnchorY():Number
		{
			return _image.anchorY;
		}
		
		public function set imageAnchor(p:Point):void
		{
			imageAnchorX = p.x;
			imageAnchorY = p.y;
		}
		
//		override public function draw(...args):void
//		{
//			// do some shit here!!!
//		} 

		// MY_BITMAP_DRAWABLE
		override public function get myBitmapDrawable():IBitmapDrawable
		{
			//var matrix:Matrix = new Matrix();
			//matrix.rotate(_physRep.r);
			//matrix.translate(_physRep.x, _physRep.y);
			//Debug.trace(_physRep.x + ' ,  '+ _physRep.y);
			//var bmd:BitmapData = new BitmapData(32, 32, true, 0xffffffff);
			//bmd.draw(_image as IBitmapDrawable, matrix);
			
			anchor = new Point(_physRep.x, _physRep.y);
			this._rotation = _physRep.r;
			return _image as IBitmapDrawable
		}
	}
}