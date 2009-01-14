package com.tinyempire.lamech.game
{
    import org.casalib.util.StageReference;
	
	import com.hexagonstar.util.debug.*;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;

	import flash.display.Sprite;
	import flash.display.Stage;
	
	import Box2D.Dynamics.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Dynamics.Joints.*;
	import Box2D.Dynamics.Contacts.*;
	import Box2D.Common.*;
	import Box2D.Common.Math.*;
	
	public class PhysWorld
	{
		private var _gameWorld:GameWorld;
		private var _world:b2World;
		private var timeStep:Number = 1.0 / 5.0;
		private var iterations:Number = 10;
		public static const PHYS_SCALE:uint = 3;
		
		public function PhysWorld(t_gameWorld:GameWorld)
		{
			Debug.trace('NEW PHYS WORLD');
			
			_gameWorld = t_gameWorld;
			
			//_collisions = new Array();
			
			var worldAABB : b2AABB = new b2AABB();
			worldAABB.lowerBound.Set(-25 * 3, -25 * 3);
			worldAABB.upperBound.Set(_gameWorld.w * 3 + (25 * 3), _gameWorld.h * 3 + (25 * 3));
			
			var gravity : b2Vec2 = new b2Vec2(0.0, 20.0);
			var doSleep:Boolean = true;
			
			// Construct a world object
			_world = new b2World(worldAABB, gravity, doSleep);
			var _contactListener:CollisionResponse = new CollisionResponse(this);
			_world.SetContactListener(_contactListener);
		}
		
		public function createStaticTile(t_gameObject:GameObject):void
		{
			
			t_gameObject.construct(_world);
		}
		
		public function createDynamicTile(t_gameObject:GameObject):void
		{
			t_gameObject.construct(_world);
		}
		
		public function update():void
		{
			_world.Step(timeStep, iterations);
		}
		
		public function doDebug():void
		{
			var t_stage:Stage = StageReference.getStage();
			var t_pane:Sprite = new Sprite();
			t_stage.addChild(t_pane);
			t_pane.x = 525
			t_pane.y = 35
			
			var dbgDraw:b2DebugDraw = new b2DebugDraw();
 
			dbgDraw.m_sprite = t_pane;
			dbgDraw.m_drawScale = 2/5;
			dbgDraw.m_fillAlpha = 0.3;
			dbgDraw.m_lineThickness = 1.0;
			dbgDraw.m_drawFlags = b2DebugDraw.e_aabbBit | b2DebugDraw.e_shapeBit | b2DebugDraw.e_jointBit | b2DebugDraw.e_coreShapeBit | b2DebugDraw.e_aabbBit | b2DebugDraw.e_obbBit | b2DebugDraw.e_pairBit | b2DebugDraw.e_centerOfMassBit ;
			_world.SetDebugDraw(dbgDraw);
		}
	}
}