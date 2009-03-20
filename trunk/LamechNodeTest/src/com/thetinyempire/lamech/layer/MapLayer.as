package com.thetinyempire.lamech.layer
{
	import com.thetinyempire.lamech.cell.Cell;
	
	import de.polygonal.ds.Array2;
	
	import flash.display.BitmapData;
	import flash.display.MovieClip;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
//	'''Base class for Maps.
//
//    Maps are comprised of tiles and can figure out which tiles are required to
//    be rendered on screen.
//
//    Both rect and hex maps have the following attributes:
//
//        id              -- identifies the map in XML and Resources
//        (width, height) -- size of map in cells
//        (px_width, px_height)      -- size of map in pixels
//        (tw, th)        -- size of each cell in pixels
//        (origin_x, origin_y, origin_z)  -- offset of map top left from origin in pixels
//        cells           -- array [i][j] of Cell instances
//        debug           -- display debugging information on cells
//
//    The debug flag turns on textual display of data about each visible cell
//    including its cell index, origin pixel and any properties set on the cell.
	public class MapLayer extends ScrollableLayer
	{
		protected var _debug:Boolean = false;
		protected var _cells:Array2;
		protected var _ready:Boolean;
		
		public function MapLayer()
		{
			super();
			
			_ready = false;
		}
		
		public function setDirty():void
		{
			//_updateSpriteSet();
		}
		
		override public function setView(x:uint, y:uint, w:uint, h:uint):void
		{
			super.setView(x, y, w, h);
			if(_ready)
			{
				//_updateSpriteSet();
			}
		}
		
		public function get visibleCells():Array2
		{
			return getInRegion(_view.x, _view.y, _view.width, _view.height);
		}
		
		protected function getInRegion(x1:uint, y1:uint, x2:uint, y2:uint):Array2
		{
			return _cells;
		}
		
		public function set debug(d:Boolean):void
		{
			_debug = d
			//_updateSpriteSet();
		}
		
		protected function _updateSpriteSet():void
		{
			
		}
	}
}