package com.thetinyempire.lamech.action
{
	import com.hexagonstar.util.debug.Debug;
	import com.thetinyempire.lamech.Window;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	public class Liquid extends Grid2DAction
	{
		private var _amp:uint;
		private var _waves:uint;
		private var _ampRate:uint;
		
		public function Liquid(waves:uint = 2, amp:uint = 20, gridSize:Point=null, duration:Number=5)
		{
			super(gridSize, duration);
			
			_waves = waves
			_amp = amp;
			_ampRate = 1;
		}
		
		override public function update(t:Number):void
		{
			for(var i:uint = 0; i < _gridSize.x + 1; i++)
			{
				for(var j:uint = 0; j < _gridSize.y + 1; j++)
				{
					var oVert:Point = getOriginalVertex(i,j)
                	var xPos:Number = (oVert.x + (Math.sin(t * Math.PI * _waves * 2 + oVert.x * .01) * _amp * _ampRate));
                	var yPos:Number = (oVert.y + (Math.sin(t * Math.PI * _waves * 2 + oVert.y * .01) * _amp * _ampRate));
                	setVertex(i, j, new Point(xPos,yPos));
				}
			}
		}
	}
}