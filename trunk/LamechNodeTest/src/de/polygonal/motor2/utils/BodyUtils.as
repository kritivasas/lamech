package de.polygonal.motor2.utils 
{
	import de.polygonal.motor2.dynamics.RigidBody;	

	public class BodyUtils 
	{
		public static function copyState(source:RigidBody, dest:RigidBody):void
		{
			dest.x = source.x; dest.vx = source.vx; dest.fx = source.fx;
			dest.y = source.y; dest.vy = source.vy; dest.fy = source.fy;
			dest.r = source.r; dest.w = source.w; dest.t = source.t;
		}
	}
}