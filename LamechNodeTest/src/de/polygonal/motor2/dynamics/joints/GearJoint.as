/*
 * Copyright (c) 2007-2008, Michael Baczynski
 * Based on Box2D by Erin Catto, http://www.box2d.org
 * 
 * All rights reserved.
 * 
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 * 
 * * Redistributions of source code must retain the above copyright notice,
 *   this list of conditions and the following disclaimer.
 * * Redistributions in binary form must reproduce the above copyright notice,
 *   this list of conditions and the following disclaimer in the documentation
 *   and/or other materials provided with the distribution.
 * * Neither the name of the polygonal nor the names of its contributors may be
 *   used to endorse or promote products derived from this software without specific
 *   prior written permission.
 * 
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 * "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 * LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 * A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
 * EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
 * PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
 * PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
 * LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 * SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package de.polygonal.motor2.dynamics.joints
{
	import flash.geom.Point;
	
	import de.polygonal.motor2.Constants;
	import de.polygonal.motor2.World;
	import de.polygonal.motor2.dynamics.RigidBody;
	import de.polygonal.motor2.dynamics.joints.GearJoint;
	import de.polygonal.motor2.dynamics.joints.data.GearJointData;

	/**
	 * A gear joint connects two joints. Think of them as cogs with a fixed number of teeth, 
	 * so they have a gear ratio. If for example two revolute joints are used the ratio is used to
	 * calculated the ratio between the angles of the 'cogs', if one is rotated by 2 degrees the other one
	 * is rotated by 4 if the ratio is 2. With prismatic joints the ratio specifies the ratio between the translated
	 * distances. 
	 */		
	public class GearJoint extends Joint
	{

		public var ratio:Number;

		private var _joint1:Joint;
		private var _joint2:Joint;
		
		private var _type1:int;
		private var _type2:int;
		
		private var _ground1:RigidBody;
		private var _ground2:RigidBody;		
		
		private var _impulse:Number;
		private var _mass:Number;

		private var _ux:Number;
		private var _uy:Number;
		
		private var _r1x:Number, _r2x:Number;
		private var _r1y:Number, _r2y:Number;
		
		private var _ga1x:Number, _ga2x:Number;
		private var _ga1y:Number, _ga2y:Number;
		
		private var _w1:Number, _w2:Number;		
		private var _v1x:Number, _v1y:Number;
		private var _v2x:Number, _v2y:Number;
		
		private var _total:Number;
		
		/**
		 * Creates a new GearJoint instance.
		 * 
		 * @param data The joint parameters.
		 */
		public function GearJoint(data:GearJointData)
		{
			super(data);
			
			var d:GearJointData = data as GearJointData;
			
			_type1 = d.joint1.type;
			_type2 = d.joint2.type;
			
			_joint1 = d.joint1;
			_joint2 = d.joint2;

			if(_type1 != JointTypes.PRISMATIC && _type1 != JointTypes.REVOLUTE)
				throw new Error("first joint should be prismatic or revolute");
			else if(_type2 != JointTypes.PRISMATIC && _type2 != JointTypes.REVOLUTE)
				throw new Error("second joint should be prismatic or revolute");	
			
			if(!_joint1.body1.isStatic() || !_joint2.body1.isStatic())
			    throw new Error("ground bodies are not static");
			
			_ground1 = _joint1.body1;
			_ground2 = _joint2.body1;

			var coord1:Number, coord2:Number;		
			
			if (_type1 == JointTypes.REVOLUTE)
			{
				var joint1A:RevoluteJoint =  _joint1 as RevoluteJoint;
				_ga1x = joint1A.la1x;
				_ga1y = joint1A.la1y;
								
				la1x = joint1A.la2x;
				la1y = joint1A.la2y;				
				
				coord1 = joint1A.getJointAngle();
			}
			else if(_type1 == JointTypes.PRISMATIC)
			{
				var joint1B:PrismaticJoint = _joint1 as PrismaticJoint;  
				_ga1x = joint1B.la1x;
				_ga1y = joint1B.la1y;
				
				la1x = joint1B.la2x;
				la1y = joint1B.la2y;	
				
				coord1 = joint1B.getJointTranslation();				
			}			
			
			if (_type2 == JointTypes.REVOLUTE)
			{
				var joint2A:RevoluteJoint =  _joint2 as RevoluteJoint;
				_ga2x = joint2A.la1x;
				_ga2y = joint2A.la1y;
				
				la2x = joint2A.la2x;
				la2y = joint2A.la2y;			
				
				coord2 = joint2A.getJointAngle();
			}
			else if(_type2 == JointTypes.PRISMATIC)
			{
				var joint2B:PrismaticJoint =  _joint2 as PrismaticJoint;

				_ga2x = joint2B.la1x;
				_ga2y = joint2B.la1y;
				
				la2x = joint2B.la2x;
				la2y = joint2B.la2y;
								
				coord2 = joint2B.getJointTranslation();				
			}
			
			ratio = d.ratio;

			_total = coord1 + ratio * coord2;

			_impulse = 0;
		}
		
		/**
		 * @inheritDoc
		 */
		override public function getReactionForce():Point
		{				
			var t:Number = _impulse * _invdt;
			_reactionForce.x = _v2x * t;
			_reactionForce.y = _v2y * t;
			return _reactionForce;
		}
		
		
		/**
		 * @inheritDoc
		 */
		override public function getReactionTorque():Number
		{
			var rx:Number = body2.r11 * la2x + body2.r12 * la2y;
			var ry:Number = body2.r21 * la2x + body2.r22 * la2y;
			
			var L:Number = _impulse * _w2 - rx * _impulse * _v2x + ry * _impulse * _v2y; 
			return  _invdt * L;
		}
		
		/**
		 * @private
		 */
		override public function preStep(dt:Number):void
		{
			super.preStep(dt);
			
			var K:Number = 0;
			
			_w1 = 0;
			_w2 = 0;	
			_v1x = 0;
			_v1y = 0;
			_v2x = 0;
			_v2y = 0;
			
			var cross:Number;
			
			if(_type1 == JointTypes.REVOLUTE)
			{
				_w1 = -1;
				K += body1.invI;				
			}
			else
			{								
				_ux = _ground1.r11 * PrismaticJoint(_joint1).aXx + _ground1.r12 * PrismaticJoint(_joint1).aXy;
				_uy = _ground1.r21 * PrismaticJoint(_joint1).aXx + _ground1.r22 * PrismaticJoint(_joint1).aXy;
				
				_r1x = body1.r11 * la1x + body1.r12 * la1y;
				_r1y = body1.r21 * la1x + body1.r22 * la1y;				
				
				_v1x = -_ux;
				_v1y = -_uy;			
				cross = _r1x * _uy - _r1y * _ux;	
				_w1 = -cross; 				
				
				K += body1.invMass + body1.invI * cross * cross;				
			}
			
			if(_type2 == JointTypes.REVOLUTE)
			{
				_w2 = -ratio;
				K += ratio * ratio * body2.invI;		
			}
			else
			{				

				_ux = _ground2.r11 * PrismaticJoint(_joint2).aXx + _ground2.r12 * PrismaticJoint(_joint2).aXy;
				_uy = _ground2.r21 * PrismaticJoint(_joint2).aXx + _ground2.r22 * PrismaticJoint(_joint2).aXy;
				
				_r2x = body2.r11 * la2x + body2.r12 * la2y;
				_r2y = body2.r21 * la2x + body2.r22 * la2y;				
				
				_v2x = -ratio * _ux;
				_v2y = -ratio * _uy;
							
				cross = _r2x * _uy - _r2y * _ux;	
				_w2 = -ratio * cross; 				
				
				K +=  ratio * ratio * (body2.invMass + body2.invI * cross * cross);																				
			}
			
			if(K < 0)
			{
				throw new Error("negative mass"); 
			} 

			_mass = 1 / K;
		
			if (World.doWarmStarting)
			{				
				body1.vx += body1.invMass * _impulse * _v1x;
				body1.vy += body1.invMass * _impulse * _v1y;
				body1.w += body1.invI *_impulse * _w1;
				
				body2.vx += body2.invMass * _impulse * _v2x;
				body2.vy += body2.invMass * _impulse * _v2y;
				body2.w += body2.invI *_impulse * _w2;			
			}
			else
			{
				_impulse = 0;
			}
		}
		
		/**
		 * @private
		 */
		override public function solveVelConstraints(dt:Number, iterations:int):void
		{
			var Cdot:Number = _v1x * body1.vx + _v1y * body1.vy + _w1 * body1.w + _v2x * body2.vx + _v2y * body2.vy + body2.w * _w2;  
			var newImpulse:Number = - _mass * Cdot;
			
			_impulse += newImpulse;	

			body1.vx += body1.invMass * newImpulse * _v1x;
			body1.vy += body1.invMass * newImpulse * _v1y;
			body1.w  += body1.invI * newImpulse * _w1;
			
			body2.vx += body2.invMass * newImpulse * _v2x;
			body2.vy += body2.invMass * newImpulse * _v2y;
			body2.w  += body2.invI  * newImpulse * _w2;
		}
		
		/**
		 * @private
		 */
		override public function solvePosConstraints():Boolean
		{
			var linearError:Number = 0;
			var coord1:Number = 0, coord2:Number = 0;
			
			if (_type1 == JointTypes.REVOLUTE)
			{
				coord1 = RevoluteJoint(_joint1).getJointAngle();				
			}
			else if(_type1 == JointTypes.PRISMATIC)
			{
				coord1 = PrismaticJoint(_joint1).getJointTranslation();			
			}
		
			if (_type2 == JointTypes.REVOLUTE)
			{
				coord2 = RevoluteJoint(_joint2).getJointAngle();				
			}
			else if(_type2 == JointTypes.PRISMATIC)
			{
				coord2 = PrismaticJoint(_joint2).getJointTranslation();			
			}

			var C:Number = _total - (coord1 + ratio * coord2);

			var newImpulse:Number = - _mass * C;

			body1.x += body1.invMass * newImpulse * _v1x;
			body1.y += body1.invMass * newImpulse * _v1y;
			body1.r += body1.invI * newImpulse * _w1;
			
			body2.x += body2.invMass * newImpulse * _v2x;
			body2.y += body2.invMass * newImpulse * _v2y;
			body2.r += body2.invI * newImpulse * _w2;
			
			var x:Number = body1.r;
			var t:Number;
			
			if (x < -3.14159265) x += 6.28318531;
			else
			if (x >  3.14159265) x -= 6.28318531;
			
			if (x < 0)
			{
				t = 1.27323954 * x + .405284735 * x * x;
				if (t < 0)
					t = .225 * (t *-t - t) + t;
				else
					t = .225 * (t * t - t) + t;
			}
			else
			{
				t = 1.27323954 * x - 0.405284735 * x * x;
				if (t < 0)
					t = .225 * (t *-t - t) + t;
				else
					t = .225 * (t * t - t) + t;
			}
			
			body1.r21 = t;
			body1.r12 =-t;
			
			x += 1.57079632;
			if (x >  3.14159265) x -= 6.28318531;
			
			if (x < 0)
			{
				t = 1.27323954 * x + 0.405284735 * x * x;
				if (t < 0)
					t = .225 * (t *-t - t) + t;
				else
					t = .225 * (t * t - t) + t;
			}
			else
			{
				t = 1.27323954 * x - 0.405284735 * x * x;
				if (t < 0)
					t = .225 * (t *-t - t) + t;
				else
					t = .225 * (t * t - t) + t;
			}
			
			body1.r11 = t;
			body1.r22 = t;
			
			x = body2.r;
			
			if (x < -3.14159265) x += 6.28318531;
			else
			if (x >  3.14159265) x -= 6.28318531;
			
			if (x < 0)
			{
				t = 1.27323954 * x + .405284735 * x * x;
				if (t < 0)
					t = .225 * (t *-t - t) + t;
				else
					t = .225 * (t * t - t) + t;
			}
			else
			{
				t = 1.27323954 * x - 0.405284735 * x * x;
				if (t < 0)
					t = .225 * (t *-t - t) + t;
				else
					t = .225 * (t * t - t) + t;
			}
			
			body2.r21 = t;
			body2.r12 =-t;
			
			x += 1.57079632;
			if (x >  3.14159265) x -= 6.28318531;
			
			if (x < 0)
			{
				t = 1.27323954 * x + 0.405284735 * x * x;
				if (t < 0)
					t = .225 * (t *-t - t) + t;
				else
					t = .225 * (t * t - t) + t;
			}
			else
			{
				t = 1.27323954 * x - 0.405284735 * x * x;
				if (t < 0)
					t = .225 * (t *-t - t) + t;
				else
					t = .225 * (t * t - t) + t;
			}
			
			body2.r11 = t;
			body2.r22 = t;
						
			return linearError < Constants.k_linSlop;
		}
	}
}
