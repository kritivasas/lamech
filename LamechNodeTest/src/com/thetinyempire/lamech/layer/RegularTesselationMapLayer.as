package com.thetinyempire.lamech.layer
{
	import com.thetinyempire.lamech.cell.Cell;
	
	// A class of MapLayer that has a regular array of Cells.
	public class RegularTesselationMapLayer extends MapLayer
	{
		public function RegularTesselationMapLayer()
		{
			super();
		}
		
		public function getCell(i:uint, j:uint):Cell
		{
			if(i < 0 || j < 0)
			{
				return null
			}
			else
			{
				return _cells.get(i, j);
			}
		}
	}
}