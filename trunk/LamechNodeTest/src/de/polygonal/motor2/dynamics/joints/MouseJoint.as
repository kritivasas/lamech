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
	
	import de.polygonal.motor2.dynamics.RigidBody;
	import de.polygonal.motor2.dynamics.joints.Joint;
	import de.polygonal.motor2.dynamics.joints.data.MouseJointData;	

	/**
	 * A mouse joint is used to make a point on a body track a specified world
	 * point. This a soft constraint with a maximum force. This allows the
	 * constraint to stretch and without applying huge forces.
	 */
	public class MouseJoint extends Joint
	{
		private const _target:Point = new Point();
		
		private var _px:Number, _tx:Number, _cx:Number, _rx:Number;
		private var _py:Number, _ty:Number, _cy:Number, _ry:Number;
		
		private var _mr11:Number, _mr12:Number;
		private var _mr21:Number, _mr22:Number;
		
		private var _beta:Number;
		private var _gamma:Number;
		
		public var maxForce:Number;
		
		/**
		 * Create a new MouseJoint instance.
		 * 
		 * @param data the mouse joint definition.
		 */
		public function MouseJoint(data:MouseJointData)
		{
			super(data);
			
			var d:MouseJointData = data as MouseJointData;
			
			setTarget(d.target.x, d.target.y);
			
			la1x = ((_tx - body2.x) * body2.r11 + (_ty - body2.y) * body2.r21);
			la1y = ((_tx - body2.x) * body2.r12 + (_ty - body2.y) * body2.r22);
			
			maxForce = d.maxForce;
			
			_px = 0;
			_py = 0;
			
			var omega:Number = 2 * Math.PI * d.frequencyHz;
			var damp:Number  = 2 * body2.mass * d.dampingRatio * omega;
			var k:Number     = (d.timeStep * body2.mass) * (omega * omega);
			
			_gamma = 1 / (damp + k);
			_beta  = k / (damp + k);
		}
		
		/**
		 * Returns the attachment point.
		 */
		public function getTarget():Point
		{
			return _target;
		}

		/**
		 * Updates the attachment point.
		 */
		public function setTarget(x:Number, y:Number):void
		{
			if (body2.isSleeping())
				body2.wakeUp();
			_tx = _target.x = x;
			_ty = _target.y = y;
		}
		
		/** @inheritDoc */
		override public function getAnchor1():Point
		{
			return _target;
		}
		
		/** @inheritDoc */
		override public function getAnchor2():Point
		{
			_anchor2.x = body2.x + body2.r11 * la1x + body2.r12 * la1y;
			_anchor2.y = body2.y + body2.r21 * la1x + body2.r22 * la1y;
			return _anchor2;
		}
		
		/** @inheritDoc */
		override public function getReactionForce():Point
		{
			_reactionForce.x = _px;			_reactionForce.y = _py;
			return _reactionForce;
		}
		
		/** @private */
		override public function preStep(dt:Number):void
		{
			super.preStep(dt);
			
			var b:RigidBody = body2;
			
			_rx = b.r11 * la1x + b.r12 * la1y;
			_ry = b.r21 * la1x + b.r22 * la1y;
			
			var invMass:Number = b.invMass, invI:Number = b.invI;
			
			var kr11:Number = invMass + (invI * _ry * _ry) + 0;
			var kr21:Number =-invI * _rx * _ry;
			var kr12:Number =-invI * _rx * _ry;
			var kr22:Number = invMass + (invI * _rx * _rx) + 0;
			
			kr11 += _gamma;
			kr22 += _gamma;
			
			var det:Number = 1 / (kr11 * kr22 - kr12 * kr21);
			_mr11 = det * kr22; _mr12 =-det * kr12;
			_mr21 =-det * kr21; _mr22 = det * kr11;
			
			_cx = b.x + _rx - _tx;
			_cy = b.y + _ry - _ty;
			
			b.w *= 0.98;
			
			var px:Number = _px * dt;			var py:Number = _py * dt;
			
			b.vx += invMass * px;
			b.vy += invMass * py;
			b.w  += invI * (_rx * py - _ry * px);
		}
		
		/** @private */
		override public function solveVelConstraints(dt:Number, iterations:int):void
		{
			var b:RigidBody = body2;
			
			var cdotx:Number = b.vx + (-b.w * _ry);
			var cdoty:Number = b.vy + ( b.w * _rx);
			
			var tx:Number = cdotx + (_beta * _invdt) * _cx + dt * (_gamma * _px);
			var ty:Number = cdoty + (_beta * _invdt) * _cy + dt * (_gamma * _py);
			var fx1:Number = -(_mr11 * tx + _mr12 * ty);
			var fy1:Number = -(_mr21 * tx + _mr22 * ty);
			var fx0:Number = _px;			var fy0:Number = _py;
			
			_px += fx1;			_py += fy1;
			
			var forceMagnitude:Number = Math.sqrt(_px * _px + _py * _py);
			if (forceMagnitude > maxForce)
			{
				var tmp:Number = maxForce / forceMagnitude; 
				_px *= tmp;
				_py *= tmp;
			}
			
			fx1 = _px - fx0;			fy1 = _py - fy0;
		
			var px:Number = dt * fx1;			var py:Number = dt * fy1;
			
			b.vx += b.invMass * px;
			b.vy += b.invMass * py;
			b.w  += b.invI * (_rx * py - _ry * px);
		}
	}
}