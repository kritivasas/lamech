package
{
	import com.tinyempire.lamech.game.*;
	import com.tinyempire.lamech.objects.*;
	
	import com.hexagonstar.util.debug.*;
	
	import Box2D.Dynamics.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Dynamics.Joints.*;
	import Box2D.Dynamics.Contacts.*;
	import Box2D.Common.*;
	import Box2D.Common.Math.*;
	
	import flash.geom.Point;
	
	public class Tile002 extends GameObject
	{
		public function Tile002()
		{
			//Debug.trace('NEW TILE 002');
			
			w = 16;
			h = 16;
			
			blitKey = [new Point(4,1)];
		}
	}
}