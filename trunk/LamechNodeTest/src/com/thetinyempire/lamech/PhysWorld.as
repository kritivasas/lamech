package com.thetinyempire.lamech
{
	import de.polygonal.motor2.World;
	import de.polygonal.motor2.collision.shapes.data.BoxData;
	import de.polygonal.motor2.dynamics.RigidBody;
	import de.polygonal.motor2.dynamics.RigidBodyData;
	import de.polygonal.motor2.dynamics.forces.Wind;
	import de.polygonal.motor2.math.AABB2;
	import de.polygonal.motor2.math.V2;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;

	import com.hexagonstar.util.debug.Debug;
	
	public class PhysWorld extends EventDispatcher
	{
		static private var _instance:PhysWorld
		private var _world:World;
		private var _eventLoop:EventLoop;
	
		public function PhysWorld(target:IEventDispatcher=null)
		{
			super(target);
			
			var win:Window = Window.getInstance();
			
			//all objects life inside a bounding box. this is the simulation space.
			//objects moving outside the box will be frozen.
			var simulationSpace:AABB2 = new AABB2(-50, -50, win.width + 50, win.height + 50);
			
			//if true, objects go to sleep if they are resting for some amount
			//of time. this will increase performance.
			var doSleep:Boolean = false;
			
			//the world represented by the physics engine.
			_world = new World(simulationSpace, doSleep);
			
			//the gravity vector
			_world.setGravity(0, 50);
			//
			
			var box:BoxData = new BoxData(0, win.width, 32);
			
			//like every shape is defined by a ShapeData, every RigidBody is
			//defined by a RigidBodyData object.
			//here we create a rigid body definition and add the box to it.
			//the rigid body's initial position is set to the stage center. 
			var rigidBodyData:RigidBodyData = new RigidBodyData(win.width / 2 , win.height - 32);
			rigidBodyData.addShapeData(box);
			_world.createBody(rigidBodyData);

			_eventLoop = EventLoop.getInstance();
			_eventLoop.addEventListener(EventLoop.TICK, update);
		}

		public static function getInstance() : PhysWorld
        {
            if ( _instance == null ) _instance = new PhysWorld();
            return _instance as PhysWorld;
        }
        
        public function createBox(pos:Point, density:uint = 0):RigidBody
        {
        	//every shape is defined by a 'template', implemented as a subclass of the ShapeData class.
			//this makes it easy to reuse the same definition for creating multiple shapes.
			//here we create a box definition with density=1 and size=40
			var box:BoxData = new BoxData(density, 32, 32);
			box.friction = 0.5
			
			//like every shape is defined by a ShapeData, every RigidBody is
			//defined by a RigidBodyData object.
			//here we create a rigid body definition and add the box to it.
			//the rigid body's initial position is set to the stage center. 
			var rigidBodyData:RigidBodyData = new RigidBodyData(pos.x, pos.y);
			rigidBodyData.addShapeData(box);
			
			//use the definition of the rigid body data to create a body inside the world  
			//_world.createBody(rigidBodyData);

			//this will be the ground 
//			box = new BoxData(0,300,20);
//			rigidBodyData = new RigidBodyData(550 / 2, 330);
//			rigidBodyData.addShapeData(box);
			return _world.createBody(rigidBodyData);
        }
        
        public function applyForce(b:RigidBody, v:Point):void
        {
        	//var v2:V2 = new V2(v.x,v.y);
        	//var w:Wind = new Wind(v2)
        	//_world.addForce(b, w);
        	//Debug.trace(b.x);
        	b.applyImpulse(v.x, v.y);
        }
        
        private function update(e:Event):void
		{
			if(_world.bodyList)
			{
				_world.step(e.target.dt * 2, 10);
			}
		}
	}
}