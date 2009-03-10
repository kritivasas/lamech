package com.thetinyempire.lamech.action
{
	import flash.geom.Point;
	
	public class Place extends InstantAction
	{
		private var _position:Point;
		
		public function Place(position:Point)
		{
			super();
			_position = position;
		}
		
		override public function start():void
		{
			target.anchor = _position;
		}
	}
}