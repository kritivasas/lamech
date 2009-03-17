package com.thetinyempire.lamech.cell
{
	import com.thetinyempire.lamech.tiles.Tile;
	
	import flash.geom.Point;
	
//	 '''Base class for cells from rect and hex maps.
//
//    Common attributes:
//        i, j            -- index of this cell in the map
//        width, height   -- dimensions
//        properties      -- arbitrary properties
//        cell            -- cell from the MapLayer's cells
//    '''
	public class Cell
	{
		protected var _i:uint;
		protected var _j:uint;
		protected var _width:uint
		protected var _height:uint
		protected var _properties:Object
		protected var _cell:Cell;
		protected var _tile:Tile;
		
		public function Cell(i:uint, j:uint, w:uint, h:uint, properties:Object, tile:Tile)
		{
			_width = w;
			_height = h;
			_i = i;
			_j = j;
			_properties = properties;
			_tile = tile;
		}
		
		public function asXML():XML
		{
			return new XML();
		}
		
		public function get i():uint
		{
			return _i;	
		}
		
		public function get j():uint
		{
			return _j;
		}
		
		public function get tile():Tile
		{
			return _tile;
		}
		
		public function get origin():Point
		{
			return new Point(i,j);
		}
	}
}