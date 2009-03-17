package com.thetinyempire.lamech.cell
{
	import com.thetinyempire.lamech.tiles.Tile;
	
	import flash.geom.Point;
	
//	 '''A rectangular cell from a MapLayer.
//
//    Cell attributes:
//        i, j            -- index of this cell in the map
//        width, height   -- dimensions
//        properties      -- arbitrary properties
//        cell            -- cell from the MapLayer's cells
//
//    Read-only attributes:
//        x, y        -- bottom-left pixel
//        top         -- y pixel extent
//        bottom      -- y pixel extent
//        left        -- x pixel extent
//        right       -- x pixel extent
//        origin      -- (x, y) of bottom-left corner pixel
//        center      -- (x, y)
//        topleft     -- (x, y) of top-left corner pixel
//        topright    -- (x, y) of top-right corner pixel
//        bottomleft  -- (x, y) of bottom-left corner pixel
//        bottomright -- (x, y) of bottom-right corner pixel
//        midtop      -- (x, y) of middle of top side pixel
//        midbottom   -- (x, y) of middle of bottom side pixel
//        midleft     -- (x, y) of middle of left side pixel
//        midright    -- (x, y) of middle of right side pixel
//
//    Note that all pixel attributes are *not* adjusted for screen,
//    view or layer transformations.
//    '''

	public class RectCell extends Cell
	{	
		public function RectCell(i:uint, j:uint, w:uint, h:uint, properties:Object, tile:Tile)
		{
			super(i, j, w, h, properties, tile);
		}
		
		//  GETTER / SETTER  //
		
		public function get x():uint
		{
			return(_i * _width);
		}
		
		public function get y():uint
		{
			return(_j * _height);	
		}
		
		public function get origin():Point
		{
			return new Point(_i * _width, _j * _height);
		}
		
		public function get top():uint
		{
			return((_j + 1) * _height)
		}
		
		public function get bottom():uint
		{
			return(_j * _height);
		}
		
		public function get center():Point
		{
			var x:uint = Math.floor((_i * _width + _width) / 2);
			var y:uint = Math.floor((_h * _height + _height) / 2);
			return new Point(x,y);
		}
		
		public function get midTop():Point
		{
			var x:uint = Math.floor((_i * _width + _width) / 2);
			var y:uint = (_j+1) *_hieght;
			return new Point(x,y);
		}
		
		public function get midBottom():Point
		{
			var x:uint = Math.floor((_i * _width + _width) / 2);
			var y:uint = _j *_hieght;
			return new Point(x,y);
		}
		
		public function get left():uint
		{
			return( _i * _width)
		}
		
		public function get right():uint
		{
			return(_i + 1);
		}
		
		public function get topLeft():Point
		{
			var x:uint = _i * _width
			var y:uint = (_j + 1) * _height;
			return new Point(x,y);
		}
		
		public function get topRight():Point
		{
			var x:uint = (_i + 1) * _width
			var y:uint = (_j + 1) * _height;
			return new Point(x,y);
		}
		
		public function get bottomLeft():Point
		{
			var x:uint = _i * _height;
			var y:uint = _j * _height;
			return new Point(x,y);
		}
		
		public function get bottomRight():Point
		{
			var x:uint = (_i + 1) * _width;
			var y:uint = _j * _height;
			return new Point(x,y);
		}
		
		public function get midLeft():Point
		{
			var x:uint = _i * _width;
			var y:uint = Math.round((_j * _height + _height)/2);
			return new Point(x,y);
		}
		
		public function get midRight():Point
		{
			var x:uint = (_i + 1) * _width;
			var y:uint = Math.round((_j * _height + _height)/2);
			return new Point(x,y);
		}
	}
}