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
	import de.polygonal.motor2.dynamics.joints.DistanceJoint;
	import de.polygonal.motor2.dynamics.joints.data.DistanceJointData;

	/**
	 * A distance joint constrains two points on two bodies to remain at a fixed
	 * distance from each other. You can view this as a massless, rigid rod.
	 */
	public class DistanceJoint extends Joint
	{
		private var _frequencyHz:Number;
		private var _dampingRatio:Number;
		private var _gamma:Number;
		private var _bias:Number;

		private var _impulse:Number;
		private var _length:Number;
		private var _mass:Number;

		private var _ux:Number, _r1x:Number, _r2x:Number;
		private var _uy:Number, _r1y:Number, _r2y:Number;

		/**
		 * Creates a new DistanceJoint instance.
		 *
		 * @param data The joint parameters.
		 */
		public function DistanceJoint(data:DistanceJointData)
		{
			super(data);

			var d:DistanceJointData = data as DistanceJointData;

			la1x = d.anchor1.x;
			la1y = d.anchor1.y;

			la2x = d.anchor2.x;
			la2y = d.anchor2.y;

			_length       = d.length;
			_frequencyHz  = d.frequencyHz;
			_dampingRatio = d.dampingRatio;

			_gamma = _bias = _impulse = 0;
		}

		/** @inheritDoc */
		override public function getReactionForce():Point
		{
			var t:Number = _impulse * _invdt;
			_reactionForce.x = _ux * t;
			_reactionForce.y = _uy * t;
			return _reactionForce;
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

			var l:Number = Math.sqrt(_ux * _ux + _uy * _uy);
			if (l > Constants.k_linSlop)
			{
				_ux /= l;
				_uy /= l;
			}
			else
			{
				_ux = 0;
				_uy = 0;
			}

			var cr1u:Number = (_r1x * _uy - _r1y * _ux);
			var cr2u:Number = (_r2x * _uy - _r2y * _ux);

			var invMass:Number = body1.invMass + body1.invI * cr1u * cr1u + body2.invMass + body2.invI * cr2u * cr2u;

			if (invMass > 1e-8)
				_mass = 1 / invMass;
			else
				throw new Error("division by zero");

			if (_frequencyHz > 0)
			{
				var omega:Number = 2 * Math.PI * _frequencyHz;
				var k:Number = _mass * omega * omega;
				_gamma = 1 / (dt * ((2 * _mass * _dampingRatio * omega) + dt * k));
				_bias = (l - _length) * dt * k * _gamma;
				_mass = 1 / (invMass + _gamma);
			}

			if (World.doWarmStarting)
			{
				var px:Number = _impulse * _ux;
				var py:Number = _impulse * _uy;

				body1.vx -= body1.invMass * px;
				body1.vy -= body1.invMass * py;
				body1.w  -= body1.invI * (_r1x * py - _r1y * px);

				body2.vx += body2.invMass * px;
				body2.vy += body2.invMass * py;
				body2.w  += body2.invI * (_r2x * py - _r2y * px);
			}
			else
				_impulse = .0;
		}

		/** @private */
		override public function solveVelConstraints(dt:Number, iterations:int):void
		{
			var v1x:Number = body1.vx - body1.w * _r1y;
			var v1y:Number = body1.vy + body1.w * _r1x;

			var v2x:Number = body2.vx - body2.w * _r2y;
			var v2y:Number = body2.vy + body2.w * _r2x;

			var Cdot:Number = (_ux * (v2x - v1x) + _uy * (v2y - v1y));

			var newImpulse:Number = -_mass * (Cdot + _bias + _gamma * _impulse);
			_impulse += newImpulse;

			var px:Number = newImpulse * _ux;
			var py:Number = newImpulse * _uy;

			body1.vx -= body1.invMass * px;
			body1.vy -= body1.invMass * py;
			body1.w  -= body1.invI  * (_r1x * py - _r1y * px);

			body2.vx += body2.invMass * px;
			body2.vy += body2.invMass * py;
			body2.w  += body2.invI  * (_r2x * py - _r2y * px);
		}

		/** @private */
		override public function solvePosConstraints():Boolean
		{
			if (_frequencyHz > 0)
				return true;

			var r1x:Number = body1.r11 * la1x + body1.r12 * la1y;
			var r1y:Number = body1.r21 * la1x + body1.r22 * la1y;

			var r2x:Number = body2.r11 * la2x + body2.r12 * la2y;
			var r2y:Number = body2.r21 * la2x + body2.r22 * la2y;

			var dx:Number = body2.x + r2x - body1.x - r1x;
			var dy:Number = body2.y + r2y - body1.y - r1y;

			var l:Number = Math.sqrt(dx * dx + dy * dy);
			dx /= l;
			dy /= l;

			var C:Number = l - _length;

			C = (C < -Constants.k_maxLinCorrection) ? -Constants.k_maxLinCorrection : (C > Constants.k_maxLinCorrection) ? Constants.k_maxLinCorrection : C;

			var newImpulse:Number = -_mass * C;

			var Px:Number = newImpulse * (_ux = dx);
			var Py:Number = newImpulse * (_uy = dy);

			body1.x -= body1.invMass * Px;
			body1.y -= body1.invMass * Py;
			body1.r -= body1.invI * (r1x * Py - r1y * Px);

			body2.x += body2.invMass * Px;
			body2.y += body2.invMass * Py;
			body2.r += body2.invI * (r2x * Py - r2y * Px);

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

			return (C < 0 ? -C : C) < Constants.k_linSlop;
		}
	}
}