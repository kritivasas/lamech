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
	import de.polygonal.motor2.dynamics.joints.PulleyJoint;
	import de.polygonal.motor2.dynamics.joints.data.JointData;
	import de.polygonal.motor2.dynamics.joints.data.PulleyJointData;

	/**
	 * The pulley joint is connected to two bodies and two fixed ground points.
	 * The pulley ratio defines the total length of the pulley as: 
	 * <code>length1 + ratio * length2 <= constant.</code>
	 * The transmitted force is scaled by the ratio. 
	 */
	public class PulleyJoint extends Joint
	{
		public var ratio:Number;
		
		private var _impulse:Number;
		private var _limitImpulse1:Number;
		private var _limitImpulse2:Number;
		
		private var _total:Number;
		private var _maxlength1:Number;
		private var _maxlength2:Number;
		
		private var _limitMass1:Number;
		private var _limitMass2:Number;
		private var _pulleyMass:Number;
		
		private var _ground:RigidBody;
		
		private var _ux1:Number;
		private var _uy1:Number;
		private var _ux2:Number;
		private var _uy2:Number;
		
		private var _r1x:Number, _r2x:Number;
		private var _r1y:Number, _r2y:Number;
		
		private var _ga1x:Number, _ga1y:Number;
		private var _ga2x:Number, _ga2y:Number;
		
		private var _state:int;
		private var _limitState1:int;
		private var _limitState2:int;
		
		/**
		 * Creates a new PulleyJoint instance.
		 * 
		 * @param data The joint parameters.
		 */
		public function PulleyJoint(data:PulleyJointData)
		{
			super(data);
			
			var d:PulleyJointData = data as PulleyJointData;
			
			_ground = d.body1.world.getGroundBody();
			 
			la1x = d.anchor1.x;
			la1y = d.anchor1.y;
			
			la2x = d.anchor2.x;
			la2y = d.anchor2.y;
			
			_ga1x = d.groundAnchor1.x - _ground.x;
			_ga1y = d.groundAnchor1.y - _ground.y;
			
			_ga2x = d.groundAnchor2.x - _ground.x;
			_ga2y = d.groundAnchor2.y - _ground.y;
			
			if (d.ratio > 1e-8) 
				ratio = d.ratio;
			else
				throw new Error("division by zero");
			
			_total = d.length1 + ratio * d.length2;
			
			_maxlength1 = d.maxlength1 < (_total - ratio * d.minLength) ? d.maxlength1 : (_total - ratio * d.minLength);
			_maxlength2 = d.maxlength2 < ((_total - d.minLength)/ratio) ? d.maxlength2 : ((_total - d.minLength)/ratio);
			
			_impulse = _limitImpulse1 = _limitImpulse2 = 0;
		}
		
		/** @inheritDoc */
		override public function getReactionForce():Point
		{
			var t:Number = _impulse * _invdt;
			_reactionForce.x = _ux2 * t;
			_reactionForce.y = _uy2 * t;
			return _reactionForce;
		}
		
		/**
		 * Get the first ground anchor.
		 */
		public function getGroundAnchor1():Point
		{			
			var a:Point = new Point();
			a.x = _ga1x +_ground.x;
			a.y = _ga1y +_ground.y;
			return a;
		}
		
		/**
		 *  Get the second ground anchor.
		 */
		public function getGroundAnchor2():Point
		{
			var a:Point = new Point();
			a.x = _ga2x +_ground.x;
			a.y = _ga2y +_ground.y;
			return a;
		}
		
		/**
		 * Get the current length of the segment attached to body1.
		 */
		public function getLength1():Number
		{
			var tx:Number = body1.x + body1.r11 * la1x + body1.r12 * la1y - (_ground.x + _ga1x);
			var ty:Number = body1.y + body1.r21 * la1x + body1.r22 * la1y - (_ground.y + _ga1y);
			
			return Math.sqrt(tx*tx+ty*ty);
		}
		
		/**
		 * Get the current length of the segment attached to body2.
		 */
		public function getLength2():Number
		{
			var tx:Number = body2.x + body2.r11 * la2x + body2.r12 * la2y - (_ground.x + _ga2x);
			var ty:Number = body2.y + body2.r21 * la2x + body2.r22 * la2y - (_ground.y + _ga2y);
			
			return Math.sqrt(tx*tx+ty*ty);
		}
		
		/** @private */
		override public function preStep(dt:Number):void
		{
			super.preStep(dt);
			
			_r1x = body1.r11 * la1x + body1.r12 * la1y;
			_r1y = body1.r21 * la1x + body1.r22 * la1y;
			
			_r2x = body2.r11 * la2x + body2.r12 * la2y;
			_r2y = body2.r21 * la2x + body2.r22 * la2y;
			
			_ux1 = body1.x + _r1x - _ground.x - _ga1x;
			_uy1 = body1.y + _r1y - _ground.y - _ga1y;
			
			_ux2 = body2.x + _r2x - _ground.x - _ga2x;
			_uy2 = body2.y + _r2y - _ground.y - _ga2y;
			
			var l1:Number = Math.sqrt(_ux1 * _ux1 + _uy1 * _uy1);
			var l2:Number = Math.sqrt(_ux2 * _ux2 + _uy2 * _uy2);
			
			if (l1 > Constants.k_linSlop)
			{
				_ux1 /= l1;
				_uy1 /= l1;
			}
			else
			{
				_ux1 = 0;
				_uy1 = 0;
			}
			
			if (l2 > Constants.k_linSlop)
			{
				_ux2 /= l2;
				_uy2 /= l2;
			}
			else
			{
				_ux2 = 0;
				_uy2 = 0;
			}
			
			var C:Number = _total - l1 - ratio * l2;
			if (C > 0)
			{
				_state = LimitState.INACTIVE;
				_impulse = 0;
			}
			else
				_state = LimitState.UPPER;
		
			if (l1 < _maxlength1)
			{
				_limitState1 = LimitState.INACTIVE;;
				_limitImpulse1 = 0;
			}
			else
				_limitState1 = LimitState.UPPER;
		
			if (l2 < _maxlength2)
			{
				_limitState2 = LimitState.INACTIVE;
				_limitImpulse2 = 0;
			}
			else
				_limitState2 = LimitState.UPPER;
			
			var cr1u1:Number = (_r1x * _uy1 - _r1y * _ux1);
			var cr2u2:Number = (_r2x * _uy2 - _r2y * _ux2);
			
			
			var invMass1:Number = body1.invMass + body1.invI * cr1u1 * cr1u1;	
			var invMass2:Number = body2.invMass + body2.invI * cr2u2 * cr2u2;
			var invMass3:Number = invMass1 + ratio * ratio * invMass2;
			
			if (invMass1 > 1e-8)
				_limitMass1 = 1 / invMass1;
			else
				throw new Error("division by zero");
			
			if (invMass2 > 1e-8)
				_limitMass2 = 1 / invMass2;
			else
				throw new Error("division by zero");
			
			if (invMass3 > 1e-8)
				_pulleyMass = 1 / invMass3;
			else
				throw new Error("division by zero");
			
			if (World.doWarmStarting)
			{
				var px1:Number = -(_impulse +_limitImpulse1) * _ux1;
				var py1:Number = -(_impulse +_limitImpulse1) * _uy1;
				
				var px2:Number = (- ratio * _impulse -_limitImpulse2) * _ux2;
				var py2:Number = (- ratio * _impulse -_limitImpulse2) * _uy2;
				
				body1.vx += body1.invMass * px1;
				body1.vy += body1.invMass * py1;
				body1.w  += body1.invI * (_r1x * py1 - _r1y * px1);
				
				body2.vx += body2.invMass * px2;
				body2.vy += body2.invMass * py2;
				body2.w  += body2.invI * (_r2x * py2 - _r2y * px2);
			}
			else
				_impulse = .0;
				_limitImpulse1 = .0;
				_limitImpulse2 = .0;
		}
		
		/** @private */
		override public function solveVelConstraints(dt:Number, iterations:int):void
		{
			var v1x:Number = 0;
			var v1y:Number = 0;
			var v2x:Number = 0;
			var v2y:Number = 0;
			var Cdot:Number = 0;
			var newImpulse:Number = 0;
			var oldImpulse:Number = 0;
			var px1:Number = 0;
			var py1:Number = 0;
			var px2:Number = 0;
			var py2:Number = 0;
			
			if (_state == LimitState.UPPER)
			{
				v1x = body1.vx - body1.w * _r1y;
				v1y = body1.vy + body1.w * _r1x;
				
				v2x = body2.vx - body2.w * _r2y;
				v2y = body2.vy + body2.w * _r2x;
				
				Cdot = -(_ux1 * v1x + _uy1 * v1y) - ratio * (_ux2 * v2x + _uy2 * v2y);
				
				newImpulse = -_pulleyMass * Cdot;
				oldImpulse = _impulse;
				
				_impulse =	0 > (newImpulse + _impulse) ? 0 : (newImpulse + _impulse);
				newImpulse = _impulse - oldImpulse;
				
				px1 = - newImpulse * _ux1;
				py1 = - newImpulse * _uy1;
				px2 = - ratio * newImpulse * _ux2;
				py2 = - ratio * newImpulse * _uy2;
				
				body1.vx += body1.invMass * px1;
				body1.vy += body1.invMass * py1;
				body1.w  += body1.invI  * (_r1x * py1 - _r1y * px1);
				
				body2.vx += body2.invMass * px2;
				body2.vy += body2.invMass * py2;
				body2.w  += body2.invI  * (_r2x * py2 - _r2y * px2);
			}
			
			if (_limitState1 == LimitState.UPPER)
			{
				v1x = body1.vx - body1.w * _r1y;
				v1y = body1.vy + body1.w * _r1x;
				
				Cdot = -(_ux1 * v1x + _uy1 * v1y);
				
				newImpulse = -_limitMass1 * Cdot;
				oldImpulse = _limitImpulse1;
				
				_limitImpulse1 = 0 > (newImpulse + _limitImpulse1) ? 0 : (newImpulse + _limitImpulse1);
				newImpulse = _limitImpulse1 - oldImpulse;
				
				px1 = - newImpulse * _ux1;
				py1 = - newImpulse * _uy1;
						
				body1.vx += body1.invMass * px1;
				body1.vy += body1.invMass * py1;
				body1.w  += body1.invI  * (_r1x * py1 - _r1y * px1);
			}
			
			if (_limitState2 == LimitState.UPPER)
			{
				v2x = body2.vx - body2.w * _r2y;
				v2y = body2.vy + body2.w * _r2x;
				
				Cdot = -(_ux2 * v2x + _uy2 * v2y);
				
				newImpulse = -_limitMass2 * Cdot;
				oldImpulse = _limitImpulse2;
				
				_limitImpulse2 = 0 > (newImpulse + _limitImpulse2) ? 0 : (newImpulse + _limitImpulse2);
				newImpulse = _limitImpulse2 - oldImpulse;
				
				px2 = - newImpulse * _ux2;
				py2 = - newImpulse * _uy2;
				
				body2.vx += body2.invMass * px2;
				body2.vy += body2.invMass * py2;
				body2.w  += body2.invI  * (_r2x * py2 - _r2y * px2);
			}
		
		}
		
		/** @private */
		override public function solvePosConstraints():Boolean
		{
			var r1x:Number = body1.r11 * la1x + body1.r12 * la1y;
			var r1y:Number = body1.r21 * la1x + body1.r22 * la1y;
			
			var r2x:Number = body2.r11 * la2x + body2.r12 * la2y;
			var r2y:Number = body2.r21 * la2x + body2.r22 * la2y;
			
			_ux1 = body1.x + r1x - _ground.x - _ga1x;
			_uy1 = body1.y + r1y - _ground.y - _ga1y;
			
			_ux2 = body2.x + r2x - _ground.x - _ga2x;
			_uy2 = body2.y + r2y - _ground.y - _ga2y;
			
			var linearError:Number = 0;
			var l1:Number = 0;
			var l2:Number = 0;
			
			var C:Number = 0;
			
			var px1:Number = 0;
			var py1:Number = 0;
			var px2:Number = 0;
			var py2:Number = 0;
			
			var newImpulse:Number = 0;
			
			var x:Number = 0;
			var t:Number = 0;
			
			if (_state == LimitState.UPPER)
			{
				l1 = Math.sqrt(_ux1 * _ux1 + _uy1 * _uy1);
				l2 = Math.sqrt(_ux2 * _ux2 + _uy2 * _uy2);
				
				if (l1 > Constants.k_linSlop)
				{
					_ux1 /= l1;
					_uy1 /= l1;
				}
				else
				{
					_ux1 = 0;
					_uy1 = 0;
				}
				
				if (l2 > Constants.k_linSlop)
				{
					_ux2 /= l2;
					_uy2 /= l2;
				}
				else
				{
					_ux2 = 0;
					_uy2 = 0;
				}		
				
				C = _total - l1 - ratio * l2;
				
				linearError = linearError > -C ? linearError : -C;
				
				C = ((C + Constants.k_linSlop) < -Constants.k_maxLinCorrection) ? -Constants.k_maxLinCorrection : (((C + Constants.k_linSlop) > 0) ? 0 : (C + Constants.k_linSlop));
				newImpulse = -_pulleyMass * C;
				
				px1 = - newImpulse * _ux1;
				py1 = - newImpulse * _uy1;
				
				px2 = - ratio * newImpulse * _ux2;
				py2 = - ratio * newImpulse * _uy2;
				
				body1.x += body1.invMass * px1;
				body1.y += body1.invMass * py1;
				body1.r  += body1.invI * (_r1x * py1 - _r1y * px1);
				
				body2.x += body2.invMass * px2;
				body2.y += body2.invMass * py2;
				body2.r  += body2.invI * (_r2x * py2 - _r2y * px2);
				
				x = body1.r;				
				
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
			}
			if (_limitState1 == LimitState.UPPER)
			{
				l1 = Math.sqrt(_ux1 * _ux1 + _uy1 * _uy1);
				
				if (l1 > Constants.k_linSlop)
				{
					_ux1 /= l1;
					_uy1 /= l1;
				}
				else
				{
					_ux1 = 0;
					_uy1 = 0;
				}
				
				C = _maxlength1 - l1;
				
				linearError = linearError > -C ? linearError : -C;	
				C = ((C + Constants.k_linSlop) < -Constants.k_maxLinCorrection) ? -Constants.k_maxLinCorrection : (((C + Constants.k_linSlop) > 0) ? 0 : (C + Constants.k_linSlop));
				
				newImpulse = -_limitMass1 * C;
				
				px1 = - newImpulse * _ux1;
				py1 = - newImpulse * _uy1;
				
				body1.x += body1.invMass * px1;
				body1.y += body1.invMass * py1;
				body1.r  += body1.invI * (_r1x * py1 - _r1y * px1);
				
				x = body1.r;
				
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
			}
			
			if (_limitState2 == LimitState.UPPER)
			{
				l2 = Math.sqrt(_ux2 * _ux2 + _uy2 * _uy2);
				
				if (l2 > Constants.k_linSlop)
				{
					_ux2 /= l2;
					_uy2 /= l2;
				}
				else
				{
					_ux2 = 0;
					_uy2 = 0;
				}
				
				C = _maxlength2 - l2;
				
				linearError = linearError > -C ? linearError : -C;	
				C = ((C + Constants.k_linSlop) < -Constants.k_maxLinCorrection) ? -Constants.k_maxLinCorrection : (((C + Constants.k_linSlop) > 0) ? 0 : (C + Constants.k_linSlop));
				
				newImpulse = -_limitMass2 * C;
				
				px2 = - newImpulse * _ux2;
				py2 = - newImpulse * _uy2;
				
				body2.x += body2.invMass * px2;
				body2.y += body2.invMass * py2;
				body2.r  += body2.invI * (_r2x * py2 - _r2y * px2);
				
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
			}
			return linearError < Constants.k_linSlop;
		}
	}
}