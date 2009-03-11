package com.thetinyempire.lamech.base
{
	import com.thetinyempire.lamech.Director;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	public class BaseLamechGrid
	{
		/*
		* A Scene that takes two scenes and makes a transition between them
		*/
		
		protected var _texture:BitmapData;
		protected var _active:Boolean;
		protected var _gridSize:Point;
		protected var _director:Director;
		protected var _width:uint
		protected var _height:uint;
		protected var _reuseGrid:uint;
		protected var _xStep:Number;
		protected var _yStep:Number;
		protected var _parent:BaseLamechNode;
		
		public function BaseLamechGrid(gridSize:Point, width:uint = 0, height:uint = 0)
		{
			_active = false;
			_reuseGrid = 0; // Number of times that this grid will be reused
			
			//
			
			_gridSize = gridSize;
			
			_director = Director.getInstance();
			
			_width = width == 0 ? _director.windowSize.x : width;
			_height = height == 0 ? _director.windowSize.y : height;
			
			_texture = new BitmapData(_width, _height, true, 0x00000000);
			
			_xStep = _width/_gridSize.x;
			_yStep = _height/_gridSize.y;
			
			_parent = null
		}
		
		public function beforeDraw():void
		{
			
		}
		
		public function afterDraw():void
		{
			
		}
		
		public function set active(a:Boolean):void
		{
			if(_active == a)
			{
				return
			}
			
			_active = a
			if(_active == true)
			{
				
			}
			else if(_active == false)
			{
				//  _vertexList.delete()
			}
			else
			{
				// throw error
			}
		}
		
		public function get active():Boolean
		{
			return _active;
		}
		
		public function set parent(p:BaseLamechNode):void
		{
			_parent = p
			_texture = p._BMD;
		}
	}
}