package com.tinyempire.lamech.game
{
	import Box2D.Dynamics.b2ContactListener;
	import Box2D.Collision.*;
	import Box2D.Dynamics.Contacts.*;
	import Box2D.Collision.Shapes.b2Shape;
	import Box2D.Dynamics.b2Body;

	public class CollisionResponse extends b2ContactListener 
	{
		var _worldRef:PhysWorld;
		
		public function CollisionResponse(world:PhysWorld)
		{
			_worldRef = world;
		}

		/// Called when a contact point is added. This includes the geometry
		/// and the forces.
		public override function Add(point : b2ContactPoint) : void
		{
			var body1:b2Body = point.shape1.m_body;
			var body2:b2Body = point.shape2.m_body;
			
			var data1:GameObject = body1.GetUserData() as GameObject;
			var data2:GameObject = body2.GetUserData() as GameObject;
			
			data1.collisionResponseAdd(point.shape1, data2);
			data2.collisionResponseAdd(point.shape2, data1);
			
			/*////////////////////
			//  ROID ON ROID  //
			////////////////////
			if(data1.type == 'roid' && data2.type == 'roid' )
			{
				_worldRef.newCollision(point.position);
			}
			
			//////////////////////
			//  BULLET ON ROID  //
			//////////////////////
			if(data1.type == 'bullet' && data2.type == 'roid')
			{
				_worldRef.newCollision(point.position);
				var a_data:AsteroidVO = body2.GetUserData();
				a_data.detonate = true;
				body2.SetUserData(a_data);
				
				var b_data:BulletVO = body1.GetUserData() as BulletVO;
				b_data.detonate = true;
				body1.SetUserData(b_data);
			}
			
			if(data1.type == 'roid' && data2.type == 'bullet')
			{
				_worldRef.newCollision(point.position);
				var a_data2:AsteroidVO = body1.GetUserData();
				a_data2.detonate = true;
				body1.SetUserData(a_data2);
				
				var b_data2:BulletVO = body2.GetUserData() as BulletVO;
				b_data2.detonate = true;
				body2.SetUserData(b_data2);
			}
			
			///////////////////////////
			//  ROID ON FORCE_FIELD  //
			///////////////////////////
			if(data1.type == 'forceField' && data2.type == 'roid')
			{
				trace('FORCE FIELD COLLISION')
				_worldRef.newCollision(point.position);
				var data:AsteroidVO = body2.GetUserData();
				data.detonate = true;
				body2.SetUserData(data);
			}
			
			if(data1.type == 'roid' && data2.type == 'forceField')
			{
				trace('FORCE FIELD COLLISION')
				_worldRef.newCollision(point.position);
				var data:AsteroidVO = body1.GetUserData();
				data.detonate = true;
				body1.SetUserData(data);
			}
			
			////////////////////
			//  ROID ON SHIP  //
			////////////////////
			
			if(data1.type == 'playerShip' && data2.type == 'roid')
			{
				_worldRef.newCollision(point.position);
				
				var s_data:PlayerShipVO = body1.GetUserData() as PlayerShipVO;
				
				trace(s_data.hasMoved);
				if((s_data.age > 3) || s_data.hasMoved) 
				{
					 s_data.detonate = true;
				}
				body1.SetUserData(s_data);
			}
			
			if(data1.type == 'roid' && data2.type == 'playerShip')
			{
				_worldRef.newCollision(point.position);
				
				var s_data:PlayerShipVO = body2.GetUserData() as PlayerShipVO;
				
				if((s_data.age > 3) || s_data.hasMoved) 
				{
					 s_data.detonate = true;
				}
				body2.SetUserData(s_data);
			}*/
		};

		/// Called when a contact point persists. This includes the geometry
		/// and the forces.
		public override function Persist(point : b2ContactPoint) : void
		{
			
		};

		/// Called when a contact point is removed. This includes the last
		/// computed geometry and forces.
		public override function Remove(point : b2ContactPoint) : void
		{
			var body1:b2Body = point.shape1.m_body;
			var body2:b2Body = point.shape2.m_body;
			
			var data1:GameObject = body1.GetUserData() as GameObject;
			var data2:GameObject = body2.GetUserData() as GameObject;
			
			data1.collisionResponseRemove(point.shape1, data2);
			data2.collisionResponseRemove(point.shape2, data1);
		};

		/// Called after a contact point is solved.
		public override function Result(point : b2ContactResult) : void
		{
			
		};
	}
}
