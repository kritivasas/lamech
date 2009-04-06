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
	import de.polygonal.motor2.dynamics.joints.Joint;
	import de.polygonal.motor2.dynamics.joints.LimitState;
	import de.polygonal.motor2.dynamics.joints.data.RevoluteJointData;	
	
	/**
	 * A revolute joint constrains to bodies to share a common point while
	 * they are free to rotate about the point. The relative rotation about
	 * the shared point is the joint angle. You can limit the relative
	 * rotation with a joint limit that specifies a lower and upper angle.
	 * You can use a motor to drive the relative rotation about the shared
	 * point. A maximum motor torque is provided so that infinite forces are
	 * not generated.
	 */
	public class RevoluteJoint extends Joint
	{
		/**
		 * Enable/disable the joint motor.
		 */
		public var enableMotor:Boolean;
		
		/**
		 * The motor speed in radians per second.
		 */
		public var motorSpeed:Number;
		
		/**
		 * The maximum motor torque.
		 */
		public var maxMotorTorque:Number;
		
		/**
		 * Enable/disable the joint limit.
		 */
		public var enableLimit:Boolean;
		
		/**
		 * The lower joint limit.
		 */
		public var lowerAngle:Number;
		
		/**
		 * The upper joint limit.
		 */
		public var upperAngle:Number;
		
		private var _referenceAngle:Number;

		private var _motorMass:Number;
		private var _motorImpulse:Number;
				
		private var _limitState:int;
		
		private var _impulseX:Number;
		private var _impulseY:Number;
		private var _impulseZ:Number;
		
		private var _r1x:Number, _r2x:Number;
		private var _r1y:Number, _r2y:Number;
		
		private var _k11:Number, _k12:Number, _k13:Number;
		private var _k21:Number, _k22:Number, _k23:Number;
		private var _k31:Number, _k32:Number, _k33:Number;
		
		/**
		 * Creates a new RevoluteJoint instance.
		 * 
		 * @param data The joint parameters.
		 */
		public function RevoluteJoint(data:RevoluteJointData)
		{
			super(data);
			
			var d:RevoluteJointData = data as RevoluteJointData;
			
			la1x = d.anchor1.x;
			la1y = d.anchor1.y;
			
			la2x = d.anchor2.x;
			la2y = d.anchor2.y;
			
			_referenceAngle = d.referenceAngle;
			
			lowerAngle     = d.lowerAngle;
			upperAngle     = d.upperAngle;
			
			maxMotorTorque = d.maxMotorTorque;
			motorSpeed     = d.motorSpeed;
			
			enableLimit    = d.enableLimit;
			enableMotor    = d.enableMotor;
			
			_impulseX = _impulseY = _impulseZ = 0;
			_motorImpulse = 0; 
		}
		
		/**
		 * Get the current joint angle in radians.
		 */
		public function getJointAngle():Number
		{
			return body2.r - body1.r - _referenceAngle;
		}
		
		/**
		 * Get the current joint angle speed in radians per second.
		 */
		public function getJointSpeed():Number
		{
			return body2.w - body1.w;
		}
		
		/**
		 * Get the current motor torque.
		 */
		public function getMotorTorque():Number
		{
			return _motorImpulse;
		}
		
		/**
		 * Set the lower and upper joint limit.
		 */
		public function setLimits(lower:Number, upper:Number):void
		{
			if (lower < upper)
			{
				lowerAngle = lower;
				upperAngle = upper;
			}
		}
		
		/** @inheritDoc */
		public override function getReactionForce():Point
		{
			_reactionForce.x = _impulseX * _invdt;
			_reactionForce.y = _impulseY * _invdt;
			
			return _reactionForce;
		}
		
		/** @inheritDoc */
		public override function getReactionTorque():Number
		{
			return _invdt * _impulseZ;
		}
	
		/** @private */
		override public function preStep(dt:Number):void
		{
			super.preStep(dt);
			
			var b1:RigidBody = body1;
			var b2:RigidBody = body2;
			
			_r1x = b1.r11 * la1x + b1.r12 * la1y;
			_r1y = b1.r21 * la1x + b1.r22 * la1y;
			
			_r2x = b2.r11 * la2x + b2.r12 * la2y;
			_r2y = b2.r21 * la2x + b2.r22 * la2y;
			
			var invMass1:Number = b1.invMass, invI1:Number = b1.invI;
			var invMass2:Number = b2.invMass, invI2:Number = b2.invI;
			
			_k11 = invMass1 + invMass2 + _r1y * _r1y * invI1 + _r2y * _r2y * invI2;
			_k12 = _k21 = -_r1y * _r1x * invI1 - _r2y * _r2x * invI2;
			_k31 = _k13 =  -_r1y * invI1 - _r2y * invI2;
			_k22 = invMass1 + invMass2 + _r1x * _r1x * invI1 + _r2x * _r2x * invI2;
			_k32 = _k23 = _r1x * invI1 + _r2x * invI2;
			_k33 = invI1 + invI2;		
			
			_motorMass = 1 / (invI1 + invI2);
			
			if (!enableMotor)
				_motorImpulse = 0;
			
			if (enableLimit)
			{
				var jointAngle:Number = b2.r - b1.r - _referenceAngle;
				var tmp:Number = upperAngle - lowerAngle;
				
				if ((tmp < 0 ? -tmp : tmp) < 2 * Constants.k_angSlop)
					_limitState = LimitState.EQUAL;
				else if (jointAngle <= lowerAngle)
				{
					if (_limitState != LimitState.LOWER)
						_impulseZ = 0;
					_limitState = LimitState.LOWER;
				}
				else if (jointAngle >= upperAngle)
				{
					if (_limitState != LimitState.UPPER)
						_impulseZ = 0;
					_limitState = LimitState.UPPER;
				}
				else
				{
					_limitState = LimitState.INACTIVE;
					_impulseZ = 0;
				}
			}
			
			if (World.doWarmStarting)
			{
				b1.vx -= invMass1 * _impulseX;
				b1.vy -= invMass1 * _impulseY;
				b1.w  -= invI1 * ((_r1x * _impulseY - _r1y * _impulseX) + (_motorImpulse + _impulseZ));
				
				b2.vx += invMass2 * _impulseX;
				b2.vy += invMass2 * _impulseY;
				b2.w  += invI2 * ((_r2x * _impulseY - _r2y * _impulseX) + (_motorImpulse + _impulseZ));
			}
			else
			{
				_impulseX = 0;
				_impulseY = 0;
				_impulseZ = 0;
				_motorImpulse = 0;
			}
		}
		
		/** @private */
		override public function solveVelConstraints(dt:Number, iterations:int):void
		{
			var vx1:Number = body1.vx;
			var vy1:Number = body1.vy;
			var vx2:Number = body2.vx;
			var vy2:Number = body2.vy;
			
			var w1:Number = body1.w;
			var w2:Number =	body2.w;
			
			var b1:RigidBody = body1;
			var b2:RigidBody = body2;
			
			_r1x = b1.r11 * la1x + b1.r12 * la1y;
			_r1y = b1.r21 * la1x + b1.r22 * la1y;
			
			_r2x = b2.r11 * la2x + b2.r12 * la2y;
			_r2y = b2.r21 * la2x + b2.r22 * la2y;
			
			var newImpulse:Number = 0;
			var det:Number = 0;
			var CX:Number = 0;
			var CY:Number = 0;
			var CZ:Number = 0;
			
			if (enableMotor && _limitState != LimitState.EQUAL)
			{
				var CdotA:Number = w2 - w1 - motorSpeed;
				newImpulse = - _motorMass * CdotA;
				var oldImpulse:Number = _motorImpulse;
				var maxImpulse:Number = dt * maxMotorTorque;
				
				_motorImpulse = ((_motorImpulse + newImpulse) < -maxImpulse) ? -maxImpulse : ((_motorImpulse + newImpulse) > maxImpulse) ? maxImpulse : (_motorImpulse + newImpulse);
				newImpulse = _motorImpulse - oldImpulse;
				
				w1 -= body1.invI * newImpulse;
				w2 += body2.invI * newImpulse;
			}
			
			if (enableLimit && _limitState != LimitState.INACTIVE)
			{
				CX = vx2 - w2 * _r2y - vx1 + w1 * _r1y; 
				CY = vy2 + w2 * _r2x - vy1 - w1 * _r1x;
				CZ = w2 - w1;
				
				var newImpulseX:Number; 
				var newImpulseY:Number;
				var newImpulseZ:Number;
				
				det = (_k22 * _k33 - _k32 * _k23) * _k11 + (_k32 * _k13 - _k12 * _k33) * _k21 + (_k12 * _k23 - _k22 * _k13) * _k31;
				if(det != 0)
					det = 1 / det;
				else
					throw new Error("division by zero");	
				
				newImpulseX = det * (- (_k22 * _k33 - _k32 * _k23) * CX - (_k32 * _k13 - _k12 * _k33) * CY - (_k12 * _k23 - _k22 * _k13) * CZ);
				newImpulseY = det * ((- CY * _k33 + CZ * _k23) * _k11 + (- CZ * _k13 + CX * _k33) * _k21 + (- CX * _k23 + CY * _k13) * _k31);
				newImpulseZ = det * ((- _k22 * CZ + _k32 * CY) * _k11 + (- _k32 * CX + _k12 * CZ) * _k21 + (- _k12 * CY + _k22 * CX) * _k31);
				
				if (_limitState == LimitState.EQUAL)
				{
					_impulseX += newImpulseX;
					_impulseY += newImpulseY;
					_impulseZ += newImpulseZ;
				}
				else
				if (_limitState == LimitState.LOWER)
				{
					newImpulse = _impulseZ + newImpulseZ;
					
					if (newImpulse < 0)
					{
						det = _k11 * _k22 - _k12 * _k21;
						if(det !=0)
							det = 1 / det;
						else
							throw new Error("division by zero");
						
						newImpulseX = det * (-_k22 * CX + _k12 * CY);
						newImpulseY = det * (-_k11 * CY + _k21 * CX);
						newImpulseZ = -_impulseZ;
						
						_impulseX += newImpulseX;
						_impulseY += newImpulseY;
						_impulseZ = 0;
					}
				}
				else if (_limitState == LimitState.UPPER)
				{
					newImpulse = _impulseZ + newImpulseZ;
					
					if (newImpulse > 0)
					{
						det = _k11 * _k22 - _k12 * _k21;
						if(det != 0 )
							det = 1 / det;
						else
							throw new Error("division by zero");
						
						newImpulseX = det * (-_k22 * CX + _k12 * CY);
						newImpulseY = det * (-_k11 * CY + _k21 * CX);
						newImpulseZ = -_impulseZ;
						
						_impulseX += newImpulseX;
						_impulseY += newImpulseY;
						_impulseZ = 0;
					}
				}
				
				vx1 -= body1.invMass * newImpulseX;
				vy1 -= body1.invMass * newImpulseY; 
				w1  -= body1.invI * ((_r1x * newImpulseY - _r1y * newImpulseX) + newImpulseZ);
				
				vx2 += body2.invMass * newImpulseX;
				vy2 += body2.invMass * newImpulseY; 
				w2  += body2.invI * ((_r2x * newImpulseY - _r2y * newImpulseX) + newImpulseZ);
			}
			else
			{
				CX = vx2 - w2 * _r2y - vx1 + w1 * _r1y; 
				CY = vy2 + w2 * _r2x - vy1 - w1 * _r1x;
				
				det = _k11 * _k22 - _k12 * _k21;
				if(det != 0)
					det = 1 / det;
				else
					throw new Error("division by zero");
				
				newImpulseX = det * (-_k22 * CX + _k12 * CY);
				newImpulseY = det * (-_k11 * CY + _k21 * CX);
				
				_impulseX += newImpulseX;
				_impulseY += newImpulseY;
				
				vx1 -= body1.invMass * newImpulseX;
				vy1 -= body1.invMass * newImpulseY; 
				w1  -= body1.invI * (_r1x * newImpulseY - _r1y * newImpulseX);
				
				vx2 += body2.invMass * newImpulseX;
				vy2 += body2.invMass * newImpulseY; 
				w2  += body2.invI * (_r2x * newImpulseY - _r2y * newImpulseX);
			}
			
			
			body1.vx = vx1;
			body1.vy = vy1;
			body1.w = w1;
			
			body2.vx = vx2;
			body2.vy = vy2;
			body2.w = w2;
		}
		
		/** @private */
		override public function solvePosConstraints():Boolean
		{
			var b1:RigidBody = body1;
			var b2:RigidBody = body2;
			
			var r1x:Number = b1.r11 * la1x + b1.r12 * la1y;
			var r1y:Number = b1.r21 * la1x + b1.r22 * la1y;
			
			var r2x:Number = b2.r11 * la2x + b2.r12 * la2y;
			var r2y:Number = b2.r21 * la2x + b2.r22 * la2y;
			
			var positionError:Number = 0;
			var angularError:Number = 0;
			
			var C:Number = 0;
			var CX:Number = 0;
			var CY:Number = 0;
			var tmp:Number = 0;
			
			var newImpulseX:Number = 0;
			var newImpulseY:Number = 0;
			
			if (enableLimit && _limitState != LimitState.INACTIVE)
			{
				var angle:Number = body2.r - body1.r - _referenceAngle;
				var limitImpulse:Number = 0;
				
				if (_limitState == LimitState.EQUAL)
				{					 
					C = ((angle) < (-Constants.k_maxAngCorrection)) ? (-Constants.k_maxAngCorrection) : ((angle) > (Constants.k_maxAngCorrection)) ? (Constants.k_maxAngCorrection) : (angle);
					limitImpulse = -_motorMass * C;
					angularError = C > 0 ? C : -C;
				}
				else 
				if (_limitState == LimitState.LOWER)
				{
					C = angle - lowerAngle;
					angularError = -C;		
					tmp = C + Constants.k_angSlop;
					C = ((tmp) < (-Constants.k_maxAngCorrection)) ? (-Constants.k_maxAngCorrection) : ((tmp) > (0)) ? (0) : (tmp);
				
					limitImpulse = - _motorMass * C;
				}
				else if (_limitState == LimitState.UPPER)
				{
					C = angle - upperAngle;
					angularError = C;		
					tmp = C - Constants.k_angSlop;
					C = ((tmp) < (0)) ? (0) : ((tmp) > (Constants.k_maxAngCorrection)) ? (Constants.k_maxAngCorrection) : (tmp);				
					
					limitImpulse = - _motorMass * C;
				}
				
				body1.r -= body1.invI * limitImpulse;
				body2.r += body2.invI * limitImpulse;
			}
			
			r1x = b1.r11 * la1x + b1.r12 * la1y;
			r1y = b1.r21 * la1x + b1.r22 * la1y;
			
			r2x = b2.r11 * la2x + b2.r12 * la2y;
			r2y = b2.r21 * la2x + b2.r22 * la2y;
			
			CX = body2.x + r2x - body1.x - r1x;
			CY = body2.y + r2y - body1.y - r1y;
			
			positionError = Math.sqrt(CX * CX + CY * CY);
						
			var allowed:Number = 10 * Constants.k_linSlop;
			var lsq:Number = CX * CX + CY * CY;
			
			if (lsq > allowed * allowed)
			{	
				lsq = 1 / Math.sqrt(lsq);
				
				//var ux:Number = CX * lsq;
				//var uy:Number = CY * lsq;
				
				var invMass:Number = body1.invMass + body2.invMass;
				if (invMass > 1e-8)
					var mass:Number = 1 / invMass;
				else
					throw new Error("division by zero");
				
				newImpulseX = -mass * CX;
				newImpulseY = -mass * CY;
				
				body1.x -= 0.5 * body1.invMass * newImpulseX;
				body1.y -= 0.5 * body1.invMass * newImpulseY;
				
				body2.x += 0.5 * body2.invMass * newImpulseX;
				body2.y += 0.5 * body2.invMass * newImpulseY;
				
				CX = body2.x + r2x - body1.x - r1x;
				CY = body2.y + r2y - body1.y - r1y;
			}
			
			_k11 = body1.invMass + body2.invMass + body1.invI * r1y * r1y + body2.invI * r2y * r2y;
			_k22 = body1.invMass + body2.invMass + body1.invI * r1x * r1x + body2.invI * r2x * r2x;
			_k21 = _k12 = - body1.invI * r1x * r1y - body2.invI * r2x * r2y;
			
			var det:Number = _k11 * _k22 - _k12 * _k21;
			if(det != 0)
				det = 1 / det;
			else
				throw new Error("division by zero");
			
			newImpulseX = det * (-_k22 * CX + _k12 * CY);
			newImpulseY = det * (-_k11 * CY + _k21 * CX);
			
			body1.x -= body1.invMass * newImpulseX;
			body1.y -= body1.invMass * newImpulseY;
			body1.r -= body1.invI * (r1x * newImpulseY - r1y * newImpulseX );
			
			body2.x += body2.invMass * newImpulseX;
			body2.y += body2.invMass * newImpulseY;
			body2.r += body2.invI * (r2x * newImpulseY - r2y * newImpulseX );
			
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
			
			return (positionError <= Constants.k_linSlop) && (angularError <= Constants.k_angSlop);
		}
	}
}