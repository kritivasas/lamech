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
	
	public class Tile003 extends GameObject
	{
		public function Tile003()
		{
			//Debug.trace('NEW TILE 002');
			
			w = 16;
			h = 16;
			
			blitKey = [new Point(0,1)];
		}
		
		override public function construct(t_world:b2World):void
		{
			var groundBodyDef:b2BodyDef = new b2BodyDef();
			groundBodyDef.position.Set(x*PhysWorld.PHYS_SCALE, y*PhysWorld.PHYS_SCALE);
			
			groundBodyDef.userData = this;
			
			var groundBody:b2Body = t_world.CreateBody(groundBodyDef);
			physObj = groundBody;
			
			var groundShapeDef:b2PolygonDef = new b2PolygonDef();
			groundShapeDef.vertexCount = 3
			var t_w:Number = w/2*PhysWorld.PHYS_SCALE
			var t_h:Number = h/2*PhysWorld.PHYS_SCALE
			
			groundShapeDef.vertices[2].Set(-t_w, t_h)
			groundShapeDef.vertices[1].Set(t_w, t_h)
			groundShapeDef.vertices[0].Set(t_w, -t_h)
			
			//groundShapeDef.SetAsBox(w/2*PhysWorld.PHYS_SCALE, h/2*PhysWorld.PHYS_SCALE);
			
			groundShapeDef.density = 0;
			groundShapeDef.friction = .2//5;
			
			groundBody.CreateShape(groundShapeDef);
		}
	}
}