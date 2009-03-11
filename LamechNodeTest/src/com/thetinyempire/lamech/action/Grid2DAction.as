package com.thetinyempire.lamech.action
{
	import com.thetinyempire.lamech.base.BaseLamechGridAction;
	
	import flash.geom.Point;

	public class Grid2DAction extends BaseLamechGridAction
	{
		public function Grid2DAction(gridSize:Point=null, duration:Number=5)
		{
			super(gridSize, duration);
		}
		
		public function get grid():Object
		{
			return(_grid)
		}
		
		public function getVertex(x:Number, y:Number):Point
		{
			return _target.grid.getVertex(x, y);
		}
		
		public function getOriginalVertex(x:Number, y:Number):Point
		{
			return _target.grid.getOriginalVertex(x, y);
		}
		
		public function setVertex(x:Number, y:Number, v:Point):void
		{
			_target.grid.setVertex(x, y, v);
		}
	}
}