package com.tinyempire.lamech.game
{
	import com.tinyempire.lamech.objects.*;
	
	import com.hexagonstar.util.debug.*;
	
	import flash.display.BitmapData;
	import flash.geom.Point;
	
	import Box2D.Dynamics.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Dynamics.Joints.*;
	import Box2D.Dynamics.Contacts.*;
	import Box2D.Common.*;
	import Box2D.Common.Math.*;
	
	public class GameObject
	{
		private var _id:String;
		private var _x:Number;
		private var _y:Number;
		private var _w:uint;
		private var _h:uint;
		private var _blit:Blit;
		private var _blitKey:Array;
		private var _physObj:b2Body;
		private var _input:InputObject;
		
		
		/////////////////////////////////////////////////////////////////////////////////////////////////
		//                                                                                CONSTRUCTOR  //
		/////////////////////////////////////////////////////////////////////////////////////////////////
		
		public function GameObject()
		{
			//Debug.trace('NEW GAME OBJECT');
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////
		//                                                                              PUBLIC METHOD  //
		/////////////////////////////////////////////////////////////////////////////////////////////////
		
		public function update():void
		{
			if(_physObj)
			{
				var vect:b2Vec2 = _physObj.GetPosition();
				_x = vect.x / PhysWorld.PHYS_SCALE;
				_y = vect.y / PhysWorld.PHYS_SCALE;
			}
			
			updateInput()
		}
		
		public function updateInput():void
		{
			
		}
		
		public function construct(t_world:b2World):void
		{
			var groundBodyDef:b2BodyDef = new b2BodyDef();
			groundBodyDef.position.Set(x*PhysWorld.PHYS_SCALE, y*PhysWorld.PHYS_SCALE);
			
			groundBodyDef.userData = this;
			
			var groundBody:b2Body = t_world.CreateBody(groundBodyDef);
			physObj = groundBody;
			
			var groundShapeDef:b2PolygonDef = new b2PolygonDef();
			groundShapeDef.SetAsBox(w/2*PhysWorld.PHYS_SCALE, h/2*PhysWorld.PHYS_SCALE);
			
			groundShapeDef.density = 0;
			groundShapeDef.friction = .5;
			
			groundBody.CreateShape(groundShapeDef);
		}
		
		public function collisionResponseAdd(t_body:b2Shape, t_obj:GameObject):void
		{
			
		}
		
		public function collisionResponseRemove(t_body:b2Shape, t_obj:GameObject):void
		{
			
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////
		//                                                                            GETTER / SETTER  //
		/////////////////////////////////////////////////////////////////////////////////////////////////
		public function get x():Number
		{
			return(_x);
		}
		public function set x(t_x:Number):void
		{
			_x = t_x
		}
		public function get y():Number
		{
			return(_y);
		}
		public function set y(t_y:Number):void
		{
			_y = t_y
		}
		public function get w():Number
		{
			return(_w)
		}
		public function set w(t_w:Number):void
		{
			_w = t_w
		}
		public function get h():Number
		{
			return(_h)
		}
		public function set h(t_h:Number):void
		{
			_h = t_h
		}
		public function get id():String
		{
			return(_id)
		}
		public function set id(t_id:String):void
		{
			_id = t_id
		}
		public function get physObj():b2Body
		{
			return(_physObj);
		}
		public function set physObj(t_obj:b2Body):void
		{
			_physObj = t_obj;
		}
		public function get input():InputObject
		{
			return (_input);
		}
		public function set input(t_input:InputObject):void
		{
			_input = t_input
		}
		public function get blitKey():Array
		{
			return (_blitKey);
		}
		public function set blitKey(t_arr:Array):void
		{
			_blitKey = t_arr;
		}
		public function set blitSource(t_map:BitmapData):void
		{
			_blit = new Blit();
			_blit.init(_w, _h, t_map, blitKey);
		}
		public function get blit():Blit
		{
			return(_blit);
		}
	}
}