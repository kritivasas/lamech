package com.thetinyempire.lamech.action
{
	import com.thetinyempire.lamech.PhysWorld;
	
	import de.polygonal.motor2.dynamics.forces.Wind;
	
	import flash.geom.Point;
	
	public class ApplyForce extends InstantAction
	{
		private var _v:Point;
		
		public function ApplyForce(v:Point)
		{
			super();
			_v = v;
		}
		
		override public function start():void
		{
			var phys:PhysWorld = PhysWorld.getInstance();
			phys.applyForce(target.physRep, _v);
		}
	}
}