package com.thetinyempire.lamech.base
{
	import com.thetinyempire.lamech.Grid2D;
	import com.thetinyempire.lamech.action.IntervalAction;
	
	import flash.geom.Point;
	
	public class BaseLamechGridAction extends IntervalAction
	{
		protected var _gridSize:Point;
		protected var _grid:Grid2D;
		
		public function BaseLamechGridAction(gridSize:Point = null, duration:Number = 5)
		{
			super();
			
			_duration = duration
			if (gridSize == null)
			{
				gridSize = new Point(4, 4);
			}
			_gridSize = gridSize;
		}
		
		override public function start():void
		{
			//var newGrid:Point = this.get_grid();
			if(_target.grid && _target.grid.reuseGrid > 0)
			{
				if(_target.grid.active && _gridSize == _target.grid.gridSize)
				{
					_target.grid.vertexPoints = _target.grid.vertexList.vertices.concat();
					
					_target.grid.reuseGrid -= 1;
					_target.grid.reuseGrid = Math.max(0, _target.grid.reuseGrid);
				}
				else
				{
					// throw exception
				}
			}
			else
			{
				if(_target.grid && _target.grid.active)
				{
					_target.grid.active = false
				}
				
				_target.grid = new Grid2D(_gridSize);
				//_target.grid.init(grid);
				_target.grid.active = true;
			}
		}
		
		override public function stop():void
		{
			if(_target.grid && _target.grid.active)
			{
				_target.grid.active = false
			}
		}
	}
}