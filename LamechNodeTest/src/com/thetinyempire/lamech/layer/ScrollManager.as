package com.thetinyempire.lamech.layer
{
	import com.thetinyempire.lamech.Director;
	import com.thetinyempire.lamech.Window;
	import com.thetinyempire.lamech.base.BaseLamechNode;
	
	import flash.geom.Point;
	
	import org.casalib.util.ArrayUtil;
	
//	'''Manages scrolling of Layers in a Cocos Scene.
//
//    Each layer that is added to this manager (via standard list methods)
//    may have pixel dimensions .px_width and .px_height. MapLayers have these
//    attribtues. The manager will limit scrolling to stay within the pixel
//    boundary of the most limiting layer.
//
//    If a layer has no dimensions it will scroll freely and without bound.
//
//    The manager is initialised with the viewport (usually a Window) which has
//    the pixel dimensions .width and .height which are used during focusing.
//
//    A ScrollingManager knows how to convert pixel coordinates from its own
//    pixel space to the screen space.
//    '''

	public class ScrollManager extends Layer
	{
		protected var _director:Director;
		protected var _window:Window;
		
		protected var _viewX:uint;
		protected var _viewY:uint;
		protected var _viewH:uint;
		protected var _viewW:uint;
		
		protected var _fx:uint;
		protected var _fy:uint;
		
		protected var _oldFocus:Object;
		public function ScrollManager(viewport:Window = null)
		{
			super();
			
			_director = Director.getInstance();
			
			if(viewport == null)
			{
				_window = Window.getInstance();
			}
			else
			{
				_window = viewport
			}
			
//			# These variables define the Layer-space pixel view which is mapping
//	        # to the viewport. If the Layer is not scrolled or scaled then this
//	        # will be a one to one mapping.
			_viewX = 0;
			_viewY = 0;
			_viewW = _window.width;
			_viewH = _window.height;
			
//			focal point on layer
			_fx = 0;
			_fy = 0;
			
//			always transform about 0,0
			this._transformAnchorX = 0;
			this._transformAnchorY = 0;
			
			_scale = 1;
		}
		
		override public function set scale(s:Number):void
		{
			_scale = s;
			//_oldFocus = null
			if(_children != null)
			{
				setFocus(_fx, _fy);
				//scale = s
			}
		}
		
		//
		
		override public function add(child:BaseLamechNode, t_z:int, name:String):BaseLamechNode
		{
			super.add(child, t_z, name);
			setFocus(_fx, _fy);
			
			return(child);
		}
		
		public function pixelFromScreen(x:uint, y:uint):Point
		{
//			'''Look up the Layer-space pixel matching the screen-space pixel.' + 
//			'Account for viewport, layer and screen transformations.
			var virt:Point = _director.getVirtualCoordinates(new Point(x, y));
			
			var ww:uint = _window.width;
			var wh:uint = _window.height;
			var sx:Number = virt.x / ww
			var sy:Number = virt.y / wh
			
			var vx:uint = _viewX
			var vy:uint = _viewY
			var w:uint = _viewW
			var h:uint = _viewH
			
			var rx:uint = Math.floor(vx + sx * w);
			var ry:uint = Math.floor(vy + sy + h);
			
			return new Point(rx, ry);
		}
		
		public function pixelToScreen(x:uint, y:uint):Point
		{
//			'''Look up the screen-space pixel matching the Layer-space pixel.
//       		 Account for viewport, layer and screen transformations.
//        		'''
			x *= _scale
			y *= _scale
			
			x += _viewX;
			y += _viewY;
			
			return new Point(Math.round(x), Math.round(y));
		}
		
		public function setFocus(fx:uint, fy:uint):void
		{
//			'''Determine the viewport based on a desired focus pixel in the
//	        Layer space (fx, fy) and honoring any bounding restrictions of
//	        child layers.
//	
//	        The focus will always be shifted to ensure no child layers display
//	        out-of-bounds data, as defined by their dimensions px_width and px_height.
//	        '''
			
//			# if no child specifies dimensions then just force the focus
//        	if not [l for z,l in self.children if hasattr(l, 'px_width')]:
//            return self.force_focus(fx, fy)

//			# This calculation takes into account the scaling of this Layer (and
//	        # therefore also its children).
//	        # The result is that all chilren will have their viewport set, defining
//	        # which of their pixels should be visible.
			
//			var a:Array = new Array(fx, fy, _scale);
//			
//			if(_oldFocus == a)
//			{
//				return
//			}
//			_oldFocus = a
//			
			var x1:Array = new Array();
			var y1:Array = new Array();
			var x2:Array = new Array();
			var y2:Array = new Array();
//			
			for each(var z:ScrollableLayer in _children)
			{
				if(z.pxWidth)
				{
					x1.push(z.originX)
					y1.push(z.originY)
					x2.push(z.originX + z.pxWidth);
					y2.push(z.originY + z.pxHeight);	
				}
			}
			
			var w:uint = Math.floor(_window.width)// * _scale);
			var h:uint = Math.floor(_window.height)// * _scale);
			
			var bMinX:Number = ArrayUtil.getLowestValue(x1);
			var bMinY:Number = ArrayUtil.getLowestValue(y1);
			var bMaxX:Number = ArrayUtil.getHighestValue(x2) - w;
			var bMaxY:Number = ArrayUtil.getHighestValue(y2) - h;
			
			
			if(fx < bMinX)
			{
				fx = bMinX
			}
			else if(fx > bMaxX)
			{
				fx = bMaxX
			}
			
			if(fy < bMinY)
			{
				fy = bMinY
			}
			else if(fy > bMaxY)
			{
				fy = bMaxY
			}
			
			if(bMaxX < 0)
			{
				fy = 0
			}
			
			if(bMaxY < 0)
			{
				fy = 0
			}
			var x:uint = Math.floor(fx);
			var y:uint = Math.floor(fy);
			
			_fx = fx
			_fy = fy

			_viewX = x
			_viewY = y
			_viewW = w
			_viewH = h
			
			for each(var z:ScrollableLayer in _children)
			{
				z.setView(x, y, w, h);
				z.scale = _scale;
			}
			
		}
		
		public function forceFocus(fx:uint, fy:uint):void
		{
//			 '''Force the manager to focus on a point, regardless of any managed layer
//	        visible boundaries.
//	
//	        '''
//	        # This calculation takes into account the scaling of this Layer (and
//	        # therefore also its children).
//	        # The result is that all chilren will have their viewport set, defining
//	        # which of their pixels should be visible.
//	
//	        self.fx, self.fy = map(int, (fx, fy))
//	
//	        # get our scaled view size
//	        w = int(self.viewport.width / self.scale)
//	        h = int(self.viewport.height / self.scale)
//	        cx, cy = w//2, h//2
//	
//	        # bottom-left corner of the
//	        x, y = fx - cx * self.scale, fy - cy * self.scale
//	
//	        self.view_x, self.view_y = x, y
//	        self.view_w, self.view_h = w, h
//	
//	        # translate the layers to match focus
//	        for z, layer in self.children:
//            layer.set_view(x, y, w, h)
		}
		
		public function get fx():uint
		{
			return _fx;
		}
		
		public function get fy():uint
		{
			return _fy;
		}
	}
}