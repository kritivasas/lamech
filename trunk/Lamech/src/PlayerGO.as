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
	
	public class PlayerGO extends GameObject
	{
		
		private var _input:InputObject;
		private var _motor:b2RevoluteJoint;
		private var _boxBody:b2Body;
		private var _circleBody:b2Body;
		private var _maxForceX:Number = 25000;
		private var _maxForceY:Number = 110000;
		
		private var _sensor_left:b2Shape;
		private var _sensor_right:b2Shape;
		private var _sensor_top:b2Shape;
		private var _sensor_bottom:b2Shape;
		
		private var _hitTop:uint = 0;
		private var _hitBottom:uint = 0;
		private var _hitLeft:uint = 0;
		private var _hitRight:uint = 0;
		private var _collisions:Array;
		
		public function PlayerGO()
		{
			Debug.trace('NEW PLAYER GAME OBJECT');
			
			w = 16;
			h = 32;
			
			blitKey = [new Point(0, 1)];
			_collisions = new Array();
		}
		
		override public function update():void
		{
			if(physObj)
			{
				var vect:b2Vec2 = physObj.GetPosition();
				x = vect.x / PhysWorld.PHYS_SCALE;
				y = (vect.y) / PhysWorld.PHYS_SCALE;
			}
			
			updateInput()
		}
		
		override public function updateInput():void
		{
			for each(var i in input.keyList)
			{
				switch(i)
				{
					case InputObject.KEY_ARROW_UP:
						//_pc.y -= 1;
					break;
					case InputObject.KEY_ARROW_DOWN:
						//_pc.y += 1;
					break;
					case InputObject.KEY_ARROW_LEFT:
						pcLeft();
					break;
					case InputObject.KEY_ARROW_RIGHT:
						pcRight();
					break;
					case InputObject.KEY_SPACE:
						pcUp();
					break;
				}
			}
		}
		
		override public function construct(t_world:b2World):void
		{
			
			//
			
			var _circleBodyDef:b2BodyDef = new b2BodyDef();
			_circleBodyDef.position.Set(x*PhysWorld.PHYS_SCALE, y*PhysWorld.PHYS_SCALE);
			
			
			_circleBodyDef.fixedRotation = true;
			
			_circleBodyDef.userData = this;
			_circleBodyDef.isBullet = true;
			
			_circleBody = t_world.CreateBody(_circleBodyDef);
			
			//
			
			var def:b2CircleDef;

			var circleDef:b2CircleDef = new b2CircleDef();
			circleDef.radius = w/2 * PhysWorld.PHYS_SCALE;
			circleDef.localPosition.Set(0.0 * PhysWorld.PHYS_SCALE, -((1/4)*h)*PhysWorld.PHYS_SCALE);
			
			circleDef.density = 1.0;
			circleDef.friction = .9;
			
			_circleBody.CreateShape(circleDef);
			
			circleDef.localPosition.Set(0.0*PhysWorld.PHYS_SCALE, ((1/4)*h)*PhysWorld.PHYS_SCALE);
			_circleBody.CreateShape(circleDef);
			
			///////////////
			//  SENSORS  //
			///////////////
			
			
			var boxDef:b2PolygonDef = new b2PolygonDef();
			boxDef.isSensor = true;
			
			boxDef.SetAsOrientedBox((w/2) * PhysWorld.PHYS_SCALE -2, 8, new b2Vec2(0.0, -(h/2) * PhysWorld.PHYS_SCALE));
			_sensor_top = _circleBody.CreateShape(boxDef);
			
			boxDef.SetAsOrientedBox((w/2) * PhysWorld.PHYS_SCALE -2, 8, new b2Vec2(0.0, (h/2) * PhysWorld.PHYS_SCALE));
			_sensor_bottom = _circleBody.CreateShape(boxDef);
			
			boxDef.SetAsOrientedBox(8, (h/2) * PhysWorld.PHYS_SCALE -35, new b2Vec2(-(w/2) * PhysWorld.PHYS_SCALE), 0.0);
			_sensor_left = _circleBody.CreateShape(boxDef);
			
			boxDef.SetAsOrientedBox(8, (h/2) * PhysWorld.PHYS_SCALE -35, new b2Vec2((w/2) * PhysWorld.PHYS_SCALE), 0.0);
			_sensor_right = _circleBody.CreateShape(boxDef);
			
			///////////////////
			//  END SENSORS  //
			///////////////////
			
			_circleBody.SetMassFromShapes();
			physObj = _circleBody;
			
		}
		
		override public function collisionResponseAdd(t_shape:b2Shape, t_obj:GameObject):void
		{
			switch(t_shape)
			{
				case _sensor_top:
					_hitTop ++;
				break;
				case _sensor_bottom:
					_hitBottom ++;
				break;
				case _sensor_left:
					_hitLeft ++;
				break;
				case _sensor_right:
					_hitRight ++;
				break;
			}
			/*var t_hit:Number = _collisions.indexOf(t_obj);
			if(t_hit==-1)
			{
				_collisions.push(t_obj);
			}*/
		}
		
		override public function collisionResponseRemove(t_shape:b2Shape, t_obj:GameObject):void
		{
			switch(t_shape)
			{
				case _sensor_top:
					_hitTop--;
				break;
				case _sensor_bottom:
					_hitBottom --;
				break;
				case _sensor_left:
					_hitLeft --;
				break;
				case _sensor_right:
					_hitRight --;
				break;
			}
			/*var t_hit:Number = 0;//_collisions.indexOf(t_obj);
			var i:uint = 0;
			
			do
			{
				_collisions[i] == t_obj ? t_hit = -1 : i++;
			}
			while(i < _collisions.length && t_hit != -1);
			
			t_hit == -1 ? _collisions.splice(i, 1) : {};*/
		}
		
		public function pcLeft():void
		{
			if(_hitLeft == 0)
			{
				var t_perc:Number = Math.abs(physObj.GetLinearVelocity().x/200);
				t_perc = 1 - t_perc
				physObj.ApplyImpulse(new b2Vec2(-_maxForceX * t_perc,0), new b2Vec2(0,0))
				
				//_motor.SetMotorSpeed(-100)
				/*var t_vec:b2Vec2 = new b2Vec2();
				t_vec.x = 300
				t_vec.y = 0
				_circleBody.SetAngularVelocity(-30);*/
			}
		}
		
		public function pcRight():void
		{
			if(_hitRight == 0)
			{
				var t_perc:Number = Math.abs(physObj.GetLinearVelocity().x/200);
				//Debug.trace(t_perc);
				t_perc = 1 - t_perc
				physObj.ApplyImpulse(new b2Vec2(_maxForceX * t_perc,0), new b2Vec2(0,0))
				
				//_motor.SetMotorSpeed(100)
				/*var t_vec:b2Vec2 = new b2Vec2();
				t_vec.x = -300
				t_vec.y = 0
				_circleBody.SetAngularVelocity(30);*/
			}
		}
		
		public function pcUp():void
		{
			if(_hitBottom > 0)
			{
				var t_perc:Number = Math.abs(physObj.GetLinearVelocity().x/200);
				//Debug.trace(t_perc);
				t_perc = 1 - t_perc
				physObj.ApplyImpulse(new b2Vec2(0, -_maxForceY * t_perc), new b2Vec2(0,0))
				//physObj.ApplyImpulse(new b2Vec2(0,-100000), new b2Vec2(0,0))
				/*var t_vec:b2Vec2 = physObj.GetLinearVelocity();
				t_vec.y = -7500;
				physObj.SetLinearVelocity(t_vec);*/
			}
		}
	}
}