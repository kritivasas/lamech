package com.thetinyempire.lamech
{
	import com.thetinyempire.lamech.base.BaseLamechNode;
	
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

		public function LamechSprite(image:Object, position:Point = null, rotation:Number = 0, ARGB:uint = 0x00000000, anchor:Object = null)
		{
			super();
			
			if(image is String)
			{
				//load the image from the rescource based on the "image" as a string id value
			}
			
			if(anchor = null)
			{
//				if(image is Image)
//				{
//					anchor = image.width / 2, image.height / 2
//				}
			}
			
			_imageAnchor = anchor
			_anchor = new Point(0,0);
			
			_group = null;
			_childrenGroup = null;
			_position = position != null ? position : new Point(0, 0);
			_rotation = rotation;
			_scale = scale;
			_ARGB = ARGB;
			
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
			imageANchorX = p.x;
			imageANchorY = p.y;
		}
		
		override public function draw(...args):void
		{
			// do some shit here!!!
		} 
	}
}