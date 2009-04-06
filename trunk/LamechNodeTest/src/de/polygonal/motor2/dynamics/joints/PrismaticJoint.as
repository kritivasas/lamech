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
	import de.polygonal.motor2.dynamics.joints.PrismaticJoint;
	import de.polygonal.motor2.dynamics.joints.data.PrismaticJointData;	
	import de.polygonal.motor2.dynamics.joints.LimitState;
	
	/**
	 * A prismatic joint. This joint fixes the movemnt of the body along an axis
	 * relative to body1. Relative rotation is prevented. You can use a joint limit 
	 * to restrict the range of motion and a joint motor to	drive the motion.
	 */
	public class PrismaticJoint extends Joint
	{
		/**
		 * The maximum motor torque.
		 */
		public var maxMotorForce:Number;
		
		/**
		 * The lower joint limit.
		 */
		public var motorSpeed:Number;
		
		/**
		 * The lower joint limit.
		 */
		public var lowerTrans:Number;
		
		/**
		 * The desired motor speed.
		 */
		public var upperTrans:Number;
		
		/**
		 * Enable/disable the joint limit.
		 */
		public var enableLimit:Boolean;
		
		 /**
		 * A flag to enable the joint motor.
		 */
		public var enableMotor:Boolean;
		
		/**
		 * The local translation axis relative to body1.
		 */
		public var aXx:Number, aXy:Number; 
		
		private var _impulseX:Number;
		private var _impulseY:Number;
		private var _impulseZ:Number;
		
		private var _angle:Number;	
		
		private var _motorMass:Number;
		private var _motorImpulse:Number;
		private var _limitState:int;
		
		private var _ux:Number,_r1x:Number, _r2x:Number, _laXx:Number, _laYx:Number, _aYx:Number;
		private var _uy:Number,_r1y:Number, _r2y:Number, _laXy:Number, _laYy:Number, _aYy:Number;
		
		private var _a1:Number, _a2:Number;
		private var _s1:Number, _s2:Number;
		
		private var _k11:Number, _k12:Number, _k13:Number;
		private var _k21:Number, _k22:Number, _k23:Number;
		private var _k31:Number, _k32:Number, _k33:Number;
		
		/**
		 * Creates a new PrismaticJoint instance.
		 * 
		 * @param data The joint parameters.
		 */
		public function PrismaticJoint(data:PrismaticJointData)
		{
			super(data);
			
			var d:PrismaticJointData = data as PrismaticJointData;
			
			la1x = d.anchor1.x;
			la1y = d.anchor1.y;
			
			la2x = d.anchor2.x;
			la2y = d.anchor2.y;
			
			_laXx = d.axis.x;
			_laXy = d.axis.y;
			
			_laYx = - d.axis.y;
			_laYy = d.axis.x;
			
			_angle = d.angle;
			
			lowerTrans = d.lowerTrans;
			upperTrans = d.upperTrans;
			
			_impulseX = _impulseY = _impulseZ = 0;
			
			_motorMass = _motorImpulse = 0;
			motorSpeed = d.motorSpeed;
			maxMotorForce = d.maxMotorForce;
			
			enableMotor = d.enableMotor;
			enableLimit = d.enableLimit;
			
			
			aXx = aXy = _aYx = _aYy = 0;
		}
		
		/** @inheritDoc */	
		override public function getReactionForce():Point
		{
			var t1:Number = _impulseX * _invdt;
			var t2:Number = (_motorImpulse + _impulseZ) * _invdt;
			_reactionForce.x = _aYx * t1 + aXx * t2;
			_reactionForce.y = _aYy * t1 + aXy * t2;
			
			return _reactionForce;
		}
		
		/** @inheritDoc */	
		override public function getReactionTorque():Number
		{
			return _impulseY * _invdt;
		}
		
		/**
		 * Get the current joint translation.
		 */	
		public function getJointTranslation():Number
		{
			var p1x:Number, p2x:Number;
			var p1y:Number, p2y:Number;
			
			var ax:Number, ay:Number;
			
			p1x = body1.x + (body1.r11 * la1x + body1.r12 * la1y);
			p1y = body1.y + (body1.r21 * la1x + body1.r22 * la1y);
						
			p2x = body2.x + (body2.r11 * la2x + body2.r12 * la2y);
			p2y = body2.y + (body2.r21 * la2x + body2.r22 * la2y);
			
			ax = body1.r11 * aXx + body1.r12 * aXy;
			ay = body1.r21 * aXx + body1.r22 * aXy;
			
			var trans:Number = (p2x - p1x) * ax + (p2y - p1y) * ay;
			
			return trans;
		}
		
		/**
		 * Get the current joint translation speed.
		 */
		public function getJointSpeed():Number
		{
			var r1x:Number = body1.r11 * la1x + body1.r12 * la1y;
			var r1y:Number = body1.r21 * la1x + body1.r22 * la1y;
			
			var r2x:Number = body2.r11 * la2x + body2.r12 * la2y;
			var r2y:Number = body2.r21 * la2x + body2.r22 * la2y;
			
			var ax:Number = body1.r11 * aXx + body1.r12 * aXy;
			var ay:Number = body1.r21 * aXx + body1.r22 * aXy;
			
			var dx:Number = body2.x + r2x - body1.x - r1x;
			var dy:Number = body2.y + r2y - body1.y - r1y;
			
			var speed:Number =  - dx * (body1.w * ay) + dy * (body1.w *ax);
			
			speed += ax * (body2.vx - body2.w * r2y - body1.vx - body1.w * r1y) + ay * (body2.vx - body2.w * r2y - body1.vx - body1.w * r1y);     
			
			return speed;
		}
		
		/**
		 * Get the current motor force.
		 */
		public function getMotorForce():Number
		{
			return _motorImpulse;
		}
		
		/** @private */
		override public function preStep(dt:Number):void
		{
			super.preStep(dt);
			
			_r1x = body1.r11 * la1x + body1.r12 * la1y;
			_r1y = body1.r21 * la1x + body1.r22 * la1y;
			
			_r2x = body2.r11 * la2x + body2.r12 * la2y;
			_r2y = body2.r21 * la2x + body2.r22 * la2y;
			
			_ux = body2.x + _r2x - body1.x - _r1x;
			_uy = body2.y + _r2y - body1.y - _r1y;
				
			aXx = body1.r11 * _laXx + body1.r12 * _laXy;
			aXy = body1.r21 * _laXx + body1.r22 * _laXy;
			
			_aYx = body1.r11 * _laYx + body1.r12 * _laYy;
			_aYy = body1.r21 * _laYx + body1.r22 * _laYy;
			
			_a1 = (_ux + _r1x) * aXy - (_uy + _r1y) * aXx;
			_a2 = _r2x * aXy - _r2y *aXx;
			
			_s1 = (_ux + _r1x) * _aYy - (_uy + _r1y) * _aYx;
			_s2 = _r2x * _aYy - _r2y *_aYx;
			
			var invMass:Number = body1.invMass + body2.invMass + body1.invI * _a1 * _a1 + body2.invI * _a2 * _a2;
			
			if (invMass > 1e-8)
				_motorMass = 1 / invMass;
			else
				throw new Error("division by zero");
			
			_k11 = body1.invMass + body2.invMass + body1.invI * _s1 * _s1 + body2.invI * _s2 * _s2;
			_k12 = _k21 = body1.invI * _s1 + body2.invI * _s2;
			_k13 = _k31 = body1.invI * _s1 * _a1 + body2.invI * _s2 * _a2;
			_k22 = body1.invI + body2.invI;
			_k23 = _k32 = body1.invI * _a1 + body2.invI * _a2;
			_k33 = body1.invMass + body2.invMass + body1.invI * _a1 * _a1 + body2.invI * _a2 * _a2;
			
			if(enableLimit)
			{
				var trans:Number = aXx * _ux + aXy *_uy;
				
				if(((upperTrans - lowerTrans) > 0 ? (upperTrans - lowerTrans) : -(upperTrans - lowerTrans)) < 2 * Constants.k_linSlop)
					_limitState = LimitState.EQUAL;
				else
				if (trans <= lowerTrans)
				{
					if (_limitState != LimitState.LOWER)
					{
						_limitState = LimitState.LOWER;
						_impulseZ = 0;
					}
				}	
				else
				if (trans >= upperTrans)
				{
					if (_limitState != LimitState.UPPER)
					{
						_limitState = LimitState.UPPER;
						_impulseZ = 0;
					}
				}	
				else
				{
					_limitState = LimitState.INACTIVE;
					_impulseZ = 0;
				}										
			}
			
			if (!enableMotor)
				_motorImpulse = 0;
			
			if (World.doWarmStarting)
			{
				var px:Number = _impulseX * _aYx + (_motorImpulse + _impulseZ) * aXx;
				var py:Number = _impulseX * _aYy + (_motorImpulse + _impulseZ) * aXy;
				
				var l1:Number = _impulseX * _s1 + _impulseY + (_motorImpulse + _impulseZ) * _a1;
				var l2:Number = _impulseX * _s2 + _impulseY + (_motorImpulse + _impulseZ) * _a2;
				
				body1.vx -= body1.invMass * px;
				body1.vy -= body1.invMass * py;
				body1.w  -= body1.invI * l1;
				
				body2.vx += body2.invMass * px;
				body2.vy += body2.invMass * py;
				body2.w  += body2.invI * l2;
			}
			else
			{
				_impulseX = _impulseY = _impulseZ = 0;
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
			var det:Number = 0;
			var px:Number = 0;
			var py:Number = 0;	
			var l1:Number = 0;
			var l2:Number = 0;
			
			if (enableMotor && _limitState != LimitState.EQUAL)
			{				
				var CdotA:Number = (aXx * (vx2 - vx1) + aXy * (vy2 - vy1)) + _a2 * w2 - _a1 * w1;
				
				var newImpulse:Number = _motorMass * (motorSpeed - CdotA);
				var oldImpulse:Number = _motorImpulse;
				var maxImpulse:Number = dt * maxMotorForce;
				
				_motorImpulse = ((_motorImpulse + newImpulse) < -maxImpulse) ? -maxImpulse : ((_motorImpulse + newImpulse) > maxImpulse) ? maxImpulse : (_motorImpulse + newImpulse);
				newImpulse = _motorImpulse - oldImpulse;
				
				px = newImpulse * aXx;
				py = newImpulse * aXy;
				
				l1 = newImpulse * _a1;
				l2 = newImpulse * _a2;
				
				vx1 -= body1.invMass * px;
				vy1 -= body1.invMass * py;
				w1  -= body1.invI  * l1;
				
				vx2 += body2.invMass * px;
				vy2 += body2.invMass * py;
				w2  += body2.invI  * l2;
			}
			
			var CX:Number = (_aYx * (vx2 - vx1) + _aYy * (vy2 - vy1)) + _s2 * w2 - _s1 * w1; 
			var CY:Number = w2 - w1;
			
			
			if (enableLimit && _limitState != LimitState.INACTIVE)
			{
					var CZ:Number = (aXx * (vx2 - vx1) + aXy * (vy2 - vy1)) + _a2 * w2 - _a1 * w1;
					
					det = (_k22 * _k33 - _k32 * _k23) * _k11 + (_k32 * _k13 - _k12 * _k33) * _k21 + (_k12 * _k23 - _k22 * _k13) * _k31;
					if(det !=  0)
						det = 1 / det;
					else
						throw new Error("division by zero");
					
					var oldImpulseZ:Number = _impulseZ;
					
					//_impulseX += detA * (- (_k22 * _k33 - _k32 * _k23) * CX - (_k32 * _k13 - _k12 * _k33) * CY - (_k12 * _k23 - _k22 * _k13) * CZ);
					//_impulseY += detA * ((- CY * _k33 + CZ * _k23) * _k11 + (- CZ * _k13 + CX * _k33) * _k21 + (- CX * _k23 + CY * _k13) * _k31);
					_impulseZ += det * ((- _k22 * CZ + _k32 * CY) * _k11 + (- _k32 * CX + _k12 * CZ) * _k21 + (- _k12 * CY + _k22 * CX) * _k31);
					
					if (_limitState == LimitState.LOWER)
					{					
						_impulseZ = (_impulseZ > 0 ? _impulseZ : 0); 
					}
					else
					if (_limitState == LimitState.UPPER)
					{
						_impulseZ = (_impulseZ < 0 ? _impulseZ : 0);
					}
					
					var bx:Number = - CX - (_impulseZ - oldImpulseZ) * _k13;
					var by:Number = - CY - (_impulseZ - oldImpulseZ) * _k23;
					
					det = _k11 * _k22 - _k12 * _k21;
					if( det != 0)
						det = 1 / det;
					else
						throw new Error("division by zero");
					
					_impulseX = det * (_k22 * bx - _k12 * by);
					_impulseY = det * (_k11 * by - _k21 * bx);
					
					px = _impulseX * _aYx + (_impulseZ - oldImpulseZ) * aXx;
					py = _impulseX * _aYy + (_impulseZ - oldImpulseZ) * aXy;
					
					l1 = _impulseX * _s1 + _impulseY + (_impulseZ - oldImpulseZ) * _a1;
					l2 = _impulseX * _s2 + _impulseY + (_impulseZ - oldImpulseZ) * _a2;
					
					vx1 -= body1.invMass * px;
					vy1 -= body1.invMass * py;
					w1  -= body1.invI  * l1;
					
					vx2 += body2.invMass * px;
					vy2 += body2.invMass * py;
					w2  += body2.invI  * l2;
				}
				else
				{
					det = _k11 * _k22 - _k12 * _k21;
					if(det != 0)
						det = 1 / det;
					else
						throw new Error("division by zero");
					
					var dx:Number = det * (- _k22 * CX + _k12 * CY);
					var dy:Number = det * (- _k11 * CY + _k21 * CX);
					
					_impulseX += dx;
					_impulseY += dy;
					
					px = dx * _aYx;
					py = dx * _aYy;
					
					l1 = dx * _s1 + dy; 
					l2 = dx * _s2 + dy;
					
					vx1 -= body1.invMass * px;
					vy1 -= body1.invMass * py;
					w1  -= body1.invI  * l1;
					
					vx2 += body2.invMass * px;
					vy2 += body2.invMass * py;
					w2  += body2.invI  * l2;
				}
				
				body1.vx = vx1;
				body1.vy = vy1;
				body1.w  = w1;
				
				body2.vx = vx2;
				body2.vy = vy2;
				body2.w  = w2;
		}
		
		/** @private */
		override public function solvePosConstraints():Boolean
		{						
			var r1x:Number = body1.r11 * la1x + body1.r12 * la1y;
			var r1y:Number = body1.r21 * la1x + body1.r22 * la1y;
			
			var r2x:Number = body2.r11 * la2x + body2.r12 * la2y;
			var r2y:Number = body2.r21 * la2x + body2.r22 * la2y;
			
			_ux = body2.x + r2x - body1.x - r1x;
			_uy = body2.y + r2y - body1.y - r1y;
			
			var active:Boolean = false;	
			var CZ:Number = 0;
			var	linearError:Number = 0;
			var angularError:Number = 0;
			var det:Number;	
			
			if (enableLimit)
			{
				aXx = body1.r11 * _laXx + body1.r12 * _laXy;
				aXy = body1.r21 * _laXx + body1.r22 * _laXy;
				
				_a1 = (_ux + r1x) * aXy - (_uy + r1y) * aXx;
				_a2 = r2x * aXy - r2y * aXx; 
				
				var trans:Number = aXx * _ux + aXy * _uy;
				
				if(((upperTrans - lowerTrans) > 0 ? (upperTrans - lowerTrans) : -(upperTrans - lowerTrans)) < 2 * Constants.k_linSlop)
				{
					CZ = (trans < -Constants.k_maxLinCorrection) ? -Constants.k_maxLinCorrection : (trans > Constants.k_maxLinCorrection) ? Constants.k_maxLinCorrection : trans;
					linearError = (trans > 0 ? trans : - trans); 
					active = true;
				}
				else
				if (trans <= lowerTrans)
				{
					CZ = ((trans - lowerTrans + Constants.k_linSlop) < -Constants.k_maxLinCorrection) ? -Constants.k_maxLinCorrection : ((trans - lowerTrans + Constants.k_linSlop) > 0) ? 0 : (trans - lowerTrans + Constants.k_linSlop);
					linearError = lowerTrans - trans;
					active = true;
				}
				else
				if (trans >= upperTrans)
				{
					CZ = ((trans - upperTrans - Constants.k_linSlop) < 0) ? 0 : ((trans - upperTrans - Constants.k_linSlop) > Constants.k_maxLinCorrection) ? Constants.k_maxLinCorrection : (trans - upperTrans - Constants.k_linSlop);
					linearError = trans - upperTrans;
					active = true;
				}
			}
			
			_aYx = body1.r11 * _laYx + body1.r12 * _laYy;
			_aYy = body1.r21 * _laYx + body1.r22 * _laYy;
			
			_s1 = (_ux + _r1x) * _aYy - (_uy + _r1y) * _aYx;
			_s2 = _r2x * _aYy - _r2y *_aYx;
			
			var CX:Number = _aYx * _ux + _aYy * _uy;
			var CY:Number = body2.r - body1.r - _angle;
			
			linearError = linearError > (CX > 0 ? CX : - CX) ? linearError : (CX > 0 ? CX : - CX);
			angularError = CY > 0 ? CY : - CY;
			
			var newImpulseX:Number;
			var newImpulseY:Number;
			var newImpulseZ:Number;
			
			if (active)
			{
				
				_k11 = body1.invMass + body2.invMass + body1.invI * _s1 * _s1 + body2.invI * _s2* _s2;
				_k12 = _k21 = body1.invI * _s1 + body2.invI * _s2;
				_k13 = _k31 = body1.invI * _s1 * _a1 + body2.invI * _s2 * _a2;
				_k22 = body1.invI + body2.invI;
				_k23 = _k32 = body1.invI * _a1 + body2.invI * _a2;
				_k33 = body1.invMass + body2.invMass + body1.invI * _a1 * _a1 + body2.invI * _a2 * _a2;
				
				det = (_k22 * _k33 - _k32 * _k23) * _k11 + (_k32 * _k13 - _k12 * _k33) * _k21 + (_k12 * _k23 - _k22 * _k13) * _k31;
				
				if(det != 0)
					det = 1 / det;
				else
					throw new Error("division by zero");
					
				newImpulseX = det * (- (_k22 * _k33 - _k32 * _k23) * CX - (_k32 * _k13 - _k12 * _k33) * CY - (_k12 * _k23 - _k22 * _k13) * CZ);
				newImpulseY = det * ((- CY * _k33 + CZ * _k23) * _k11 + (- CZ * _k13 + CX * _k33) * _k21 + (- CX * _k23 + CY * _k13) * _k31);
				newImpulseZ = det * ((- _k22 * CZ + _k32 * CY) * _k11 + (- _k32 * CX + _k12 * CZ) * _k21 + (- _k12 * CY + _k22 * CX) * _k31);
			}			
			else
			{
				_k11 = body1.invMass + body2.invMass + body1.invI * _s1 * _s1 + body2.invI * _s2* _s2;
				_k12 = _k21 = body1.invI * _s1 + body2.invI * _s2;
				_k22 = body1.invI + body2.invI;
				_k13 = 0;
				_k23 = 0;
				
				det = _k11 * _k22 - _k12 * _k21; 
				if(det != 0)
					det = 1 / det;
				else
					throw new Error("division by zero");	
				
				newImpulseX	= det * (- _k22 * CX + _k12 * CY);
				newImpulseY	= det * (- _k11 * CY + _k21 * CX);
				
				newImpulseZ = 0;
			}
			
			var px:Number = newImpulseX * _aYx + newImpulseZ * aXx;  
			var py:Number = newImpulseX * _aYy + newImpulseZ * aXy;
			
			var l1:Number = newImpulseX * _s1 + newImpulseY + newImpulseZ * _a1;  
			var l2:Number = newImpulseX * _s2 + newImpulseY + newImpulseZ * _a2;			
			
			body1.x -= body1.invMass * px;
			body1.y -= body1.invMass * py;
			body1.r  -= body1.invI  * l1;
			
			body2.x += body2.invMass * px;
			body2.y += body2.invMass * py;
			body2.r  += body2.invI  * l2;	
			
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
			
			return linearError <= Constants.k_linSlop && angularError <= Constants.k_angSlop;
		}	
	}
}