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
package de.polygonal.motor2.dynamics.contact.solver
{
	import de.polygonal.motor2.Constants;
	import de.polygonal.motor2.World;
	import de.polygonal.motor2.dynamics.RigidBody;
	import de.polygonal.motor2.dynamics.contact.Contact;
	import de.polygonal.motor2.dynamics.contact.ContactPoint;
	import de.polygonal.motor2.dynamics.contact.Manifold;	

	/**
	 * Sequential impulses with accumulated clamping by Erin Catto from Box2D
	 * @see http://www.gphysics.com/archives/28
	 */
	public class SIContactSolver
	{
		public var contacts:Vector.<Contact>;
		public var contactCount:int;

		private var _linSlop:Number;
		private var _velThreshold:Number;
		private var _maxLinCorrection:Number;

		public function SIContactSolver():void
		{
			_linSlop          = Constants.k_linSlop;
			_velThreshold     = Constants.k_velocityThreshold;
			_maxLinCorrection = Constants.k_maxLinCorrection;
		}

		public function setContacts(contacts:Vector.<Contact>, contactCount:int):void
		{
			this.contacts = contacts;
			this.contactCount = contactCount;
		}

		public function preStep():void
		{
			var i:int, j:int, k:int;

			var b1:RigidBody;
			var b2:RigidBody;

			var nx:Number, Px:Number, r1x:Number, r2x:Number;
			var ny:Number, Py:Number, r1y:Number, r2y:Number;

			var t1:Number;
			var t2:Number;

			var nRelVel:Number;

			var c:Contact, m:Manifold, cp:ContactPoint;

			for (i = 0; i < contactCount; i++)
			{
				c = contacts[i];

				b1 = c.body1 = c.shape1.body;
				b2 = c.body2 = c.shape2.body;

				for (j = 0; j < c.manifoldCount; j++)
				{
					m  = c.manifolds[j];
					nx = m.nx;
					ny = m.ny;

					for (k = 0; k < m.pointCount; k++)
					{
						cp = m.points[k];

						/*/////////////////////////////////////////////////////////
						// precompute contact mass
						/////////////////////////////////////////////////////////*/

						//radius vectors, body --> contact
						r1x = cp.x - b1.x; r1y = cp.y - b1.y;
						r2x = cp.x - b2.x; r2y = cp.y - b2.y;

						if (World.doPositionCorrection)
						{
							//anchors in local space (ROT^1 * r)
							cp.l_r1x = b1.r11 * r1x + b1.r21 * r1y; cp.l_r1y = b1.r12 * r1x + b1.r22 * r1y;
							cp.l_r2x = b2.r11 * r2x + b2.r21 * r2y; cp.l_r2y = b2.r12 * r2x + b2.r22 * r2y;
						}

						//anchors in world space
						cp.w_r1x = r1x; cp.w_r1y = r1y;
						cp.w_r2x = r2x; cp.w_r2y = r2y;

						//m1^-1 + m2^-1 + [I1^-1 (r1 x n) x r1 + I2^-1 (r2 x n) x r2] . n
						//using a direct 2d derivation (see chris hecker eq.9) is faster:
						//m1^-1 + m2^-1 + I1^-1 (perp(rAP) . n)^2 + I2^-1 (perp(rBP) . n)^2
						t1 = (r1x * ny - r1y * nx);
						t2 = (r2x * ny - r2y * nx);
						cp.nMass = 1 / ((b1.invMass + b2.invMass) + b1.invI * t1 * t1 + b2.invI * t2 * t2);

						t1 = (r1x * -nx - r1y * ny);
						t2 = (r2x * -nx - r2y * ny);
						cp.tMass = 1 / ((b1.invMass + b2.invMass) + b1.invI * t1 * t1 + b2.invI * t2 * t2);

						/*/////////////////////////////////////////////////////////
						// setup a velocity bias for restitution
						/////////////////////////////////////////////////////////*/

						//relative velocity at contact point:
						//vRel = [v2 + (w x r2)] - [v1 - (w1 x r1)]
						//relative normal velocity is the component of relative velocity
						//in the direction of the collision normal: dot(vRel, N)

						nRelVel = nx * (b2.vx - b2.w * r2y - b1.vx + b1.w * r1y) + ny * (b2.vy + b2.w * r2x - b1.vy - b1.w * r1x);
						cp.velBias = nRelVel < -_velThreshold ? -c.restitution * nRelVel : 0;

						/*/////////////////////////////////////////////////////////
						// warm-start the solver
						/////////////////////////////////////////////////////////*/
						//use accumulated impulse from the previous timestep
						//as an initial guess for the new timestep
						if (World.doWarmStarting)
						{
							//apply normal & friction impulse
							Px = cp.Pn * nx + cp.Pt * ny;
							Py = cp.Pn * ny + cp.Pt *-nx;

							//v1 = v1' - P/m1;
							//w1 = w1' - I^-1 (r1 x P) (-> eq. perp(r1).P)
							b1.vx -= b1.invMass * Px;
							b1.vy -= b1.invMass * Py;
							b1.w  -= b1.invI * (r1x * Py - r1y * Px);

							//v2 = v2' + P/m2;
							//v2 = w2' + I^-1 r2 x P (-> eq. perp(r2).P)
							b2.vx += b2.invMass * Px;
							b2.vy += b2.invMass * Py;
							b2.w  += b2.invI * (r2x * Py - r2y * Px);
						}
						else
							cp.Pn = cp.Pt = 0;

						// always reset position impulse
						cp.Pp = 0;
					}
				}
			}
		}

		public function solveVelConstraints():void
		{
			var i:int, j:int, k:int;

			var c:Contact, m:Manifold, cp:ContactPoint;

			var b1:RigidBody, invMass1:Number, invI1:Number, vx1:Number, vy1:Number, w1:Number;
			var b2:RigidBody, invMass2:Number, invI2:Number, vx2:Number, vy2:Number, w2:Number;

			var nx:Number, Px:Number, dvx:Number;
			var ny:Number, Py:Number, dvy:Number;

			var r1x:Number, r1y:Number;
			var r2x:Number, r2y:Number;

			var newImpulse:Number;
			var lambda:Number;
			var maxFriction:Number;

			for (i = 0; i < contactCount; i++)
			{
				c = contacts[i];

				b1 = c.body1;
				b2 = c.body2;

				invMass1 = b1.invMass;
				invI1    = b1.invI;
				invMass2 = b2.invMass;
				invI2    = b2.invI;

				vx1 = b1.vx; vy1 = b1.vy; w1 = b1.w;
				vx2 = b2.vx; vy2 = b2.vy; w2 = b2.w;

				for (j = 0; j < c.manifoldCount; j++)
				{
					m = c.manifolds[j];

					nx = m.nx;
					ny = m.ny;

					for (k = 0; k < m.pointCount; k++)
					{
						cp = m.points[k];

						r1x = cp.w_r1x; r1y = cp.w_r1y;
						r2x = cp.w_r2x; r2y = cp.w_r2y;

						/*/////////////////////////////////////////////////////////
						// solve normal constraints
						/////////////////////////////////////////////////////////*/

						//relative velocity
						//dv = [v2 + (w x r2)] - [v1 - (w1 x r1)]
						dvx = vx2 - (w2 * r2y) - vx1 + (w1 * r1y);
						dvy = vy2 + (w2 * r2x) - vy1 - (w1 * r1x);

						//normal impulse
						lambda = -cp.nMass * ((dvx * nx + dvy * ny) - cp.velBias);

						//clamp accumulated impulse
						newImpulse = cp.Pn + lambda;
						if (newImpulse < 0) newImpulse = 0;
						lambda = newImpulse - cp.Pn;

						//apply contact impulse
						Px = lambda * nx;
						Py = lambda * ny;

						//v1 = v1' - Pn/m1;
						//w1 = w1' - I^-1 (r1 x Pn) (-> eq. perp(r1).P)
						vx1 -= invMass1 * Px;
						vy1 -= invMass1 * Py;
						w1  -= invI1 * (r1x * Py - r1y * Px);

						//v2 = v2' + Pn/m2;
						//v2 = w2' + I^-1 r2 x Pn (-> eq. perp(r2).P)
						vx2 += invMass2 * Px;
						vy2 += invMass2 * Py;
						w2  += invI2 * (r2x * Py - r2y * Px);

						cp.Pn = newImpulse;

						/*/////////////////////////////////////////////////////////
						// solve tangent constraints
						/////////////////////////////////////////////////////////*/

						dvx = vx2 - (w2 * r2y) - vx1 + (w1 * r1y);
						dvy = vy2 + (w2 * r2x) - vy1 - (w1 * r1x);

						//tangent impulse
						lambda = cp.tMass * -ny * dvx + nx * dvy;

						//clamp accumulated impulse
						maxFriction = c.friction * cp.Pn;

						newImpulse = cp.Pt + lambda;
						newImpulse = (newImpulse < -maxFriction) ? -maxFriction : (newImpulse > maxFriction) ? maxFriction : newImpulse;
						lambda = newImpulse - cp.Pt;

						//apply contact impulse
						Px = lambda * ny;
						Py = lambda *-nx;

						vx1 -= invMass1 * Px;
						vy1 -= invMass1 * Py;
						w1  -= invI1 * (r1x * Py - r1y * Px);

						vx2 += invMass2 * Px;
						vy2 += invMass2 * Py;
						w2  += invI2 * (r2x * Py - r2y * Px);

						cp.Pt = newImpulse;
					}
				}

				b1.vx = vx1; b1.vy = vy1; b1.w = w1;
				b2.vx = vx2; b2.vy = vy2; b2.w = w2;
			}
		}

		public function solvePosConstraints(beta:Number):Boolean
		{
			var i:int, j:int, k:int;

			var c:Contact, m:Manifold, cp:ContactPoint;

			var b1:RigidBody, b2:RigidBody;

			var separation:Number;
			var minSeparation:Number = 0;

			var nx:Number, Px:Number, dpx:Number, r1x:Number, r2x:Number;
			var ny:Number, Py:Number, dpy:Number, r1y:Number, r2y:Number;

			var cos:Number, sin:Number, t:Number, min:Number, max:Number, C:Number, dImpulse:Number, impulse0:Number;

			for (i = 0; i < contactCount; i++)
			{
				c = contacts[i];

				b1 = c.body1;
				b2 = c.body2;

				for (j = 0; j < c.manifoldCount; j++)
				{
					m = c.manifolds[j];

					nx = m.nx;
					ny = m.ny;

					//solve normal constraints
					for (k = 0; k < m.pointCount; k++)
					{
						cp = m.points[k];

						//transform achors from local to world space
						r1x = b1.r11 * cp.l_r1x + b1.r12 * cp.l_r1y;
						r1y = b1.r21 * cp.l_r1x + b1.r22 * cp.l_r1y;
						r2x = b2.r11 * cp.l_r2x + b2.r12 * cp.l_r2y;
						r2y = b2.r21 * cp.l_r2x + b2.r22 * cp.l_r2y;

						//position of contact point
						dpx = (b2.x + r2x) - (b1.x + r1x);
						dpy = (b2.y + r2y) - (b1.y + r1y);

						//approximate the current separation
						separation = (dpx * nx + dpy * ny) + cp.sep;

						//track max constraint error
						minSeparation = minSeparation < separation ? minSeparation : separation;

						//prevent large corrections and allow slop
						t = separation + _linSlop;
						min =-_maxLinCorrection;
						max = 0;
						C = beta * ( (t < min) ? min : (t > max) ? max : t );

						//compute normal impulse
						dImpulse =-cp.nMass * C;
						impulse0 = cp.Pp;

						cp.Pp = impulse0 + dImpulse;
						if (cp.Pp < 0) cp.Pp = 0;
						dImpulse = cp.Pp - impulse0;

						Px = dImpulse * nx;
						Py = dImpulse * ny;

						b1.x -= b1.invMass * Px;
						b1.y -= b1.invMass * Py;
						b1.r -= b1.invI * (r1x * Py - r1y * Px);

						//TODO replace with approx
						cos = Math.cos(b1.r);
						sin = Math.sin(b1.r);

						b1.r11 = cos; b1.r12 = -sin;
						b1.r21 = sin; b1.r22 =  cos;

						b2.x += b2.invMass * Px;
						b2.y += b2.invMass * Py;
						b2.r += b2.invI * (r2x * Py - r2y * Px);

						cos = Math.cos(b2.r);
						sin = Math.sin(b2.r);

						b2.r11 = cos; b2.r12 = -sin;
						b2.r21 = sin; b2.r22 =  cos;
					}
				}
			}
			return minSeparation >= -_linSlop;
		}
	}
}