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
package de.polygonal.motor2.dynamics
{
	import de.polygonal.motor2.World;
	import de.polygonal.motor2.collision.nbody.Proxy;
	import de.polygonal.motor2.collision.shapes.ShapeSkeleton;
	import de.polygonal.motor2.collision.shapes.data.ShapeData;
	import de.polygonal.motor2.dynamics.RigidBodyData;
	import de.polygonal.motor2.dynamics.contact.ContactNode;
	import de.polygonal.motor2.dynamics.joints.Joint;
	import de.polygonal.motor2.dynamics.joints.JointNode;
	import de.polygonal.motor2.math.V2;
	
	import flash.geom.Point;		

	/**
	 * A rigid body.
	 *
	 * Internal computations are done in term of the center of mass position.
	 * The center of mass may be offset from the body's origin.
	 */
	public class RigidBody
	{
		public static const k_bitStatic:int     = 0x01;
		public static const k_bitFrozen:int     = 0x02;
		public static const k_bitSleep:int      = 0x04;
		public static const k_bitAllowSleep:int = 0x08;
		public static const k_bitDestroy:int    = 0x10;
		public static const k_bitIsland:int     = 0x20;
		
		public var next:RigidBody;
		public var prev:RigidBody;

		public var x:Number, vx:Number, fx:Number;
		public var y:Number, vy:Number, fy:Number;
		public var r:Number,  w:Number,  t:Number;

		public var userData:*;
		
		/* mass & inertia */
		public var mass:Number;
		public var invMass:Number;
		public var I:Number;
		public var invI:Number;

		/* 2x2 column rotation matrix */
		public var r11:Number, r12:Number;
		public var r21:Number, r22:Number;

		/* local vector from client origin to cm */
		public var cx:Number, cy:Number;

		public var linDamping:Number;
		public var angDamping:Number;

		public var shapeCount:int;

		public var world:World;
		public var shapeList:ShapeSkeleton;
		public var jointList:JointNode;
		public var contactList:ContactNode;

		public var stateBits:int;
		public var sleepTime:Number;

		public function RigidBody(world:World, data:RigidBodyData)
		{
			init(world, data);
		}

		public function deconstruct():void
		{
			prev = next = null;
			var s:ShapeSkeleton = shapeList;
			var t:ShapeSkeleton;
			while (s)
			{
				t = s;
				s = s.next;
				t.deconstruct();
			}
		}
		
		public function getCenter(out:V2):void
		{
			out.x = x;
			out.y = y;
		}

		public function setCenter(x:Number, y:Number, rot:Number):void
		{
			if ((stateBits & k_bitFrozen) == 0)
			{
				r = rot;
				var c:Number = Math.cos(r);
				var s:Number = Math.sin(r);
				r11 = c; r12 = -s;
				r21 = s; r22 =  c;

				this.x = x;
				this.y = y;

				var shape:ShapeSkeleton = shapeList;
				while (shape)
				{
					shape.update();
					shape = shape.next;
				}
				//TODO flush broadphase
			}
		}

		public function getOrigin(out:V2):void
		{
			out.x = x - (r11 * cx + r12 * cy);
			out.y = y - (r21 * cx + r22 * cy);
		}

		public function setOrigin(x:Number, y:Number, rot:Number):void
		{
			if ((stateBits & k_bitFrozen) == 0)
			{
				r = rot;
				var c:Number = Math.cos(r);
				var s:Number = Math.sin(r);
				r11 = c; r12 = -s;
				r21 = s; r22 =  c;

				this.x = x + (r11 * cx + r12 * cy);
				this.y = y + (r21 * cx + r22 * cy);

				var shape:ShapeSkeleton = shapeList;
				while (shape)
				{
					shape.update();
					shape = shape.next;
				}

				//TODO reset broadphase
				//m_world.m_broadPhase.Flush();
			}
		}

		public function rotate(deg:Number):void
		{
			//wrap input angle to 0..2PI
			if (deg < 0)
				deg += 360;
			else
			if (deg > 360)
				deg -= 360;

			r = deg * (Math.PI / 180);

			updateShapes();
		}
		
		public function applyForce(fx:Number, fy:Number):void
		{
			if ((stateBits & k_bitSleep) == 0)
			{
				this.fx += fx;
				this.fy += fy;
			}
		}

		public function applyForceAt(fx:Number, fy:Number, px:Number, py:Number):void
		{
			if ((stateBits & k_bitSleep) == 0)
			{
				this.fx += fx;
				this.fy += fy;
				t += (px - x) * fy - (py - y) * fx;
			}
		}

		public function applyTorque(torque:Number):void
		{
			if ((stateBits & k_bitSleep) == 0)
				t += torque;
		}

		public function applyImpulse(ix:Number, iy:Number):void
		{
			if ((stateBits & k_bitSleep) == 0)
			{
				vx += invMass * ix;
				vy += invMass * iy;
			}
		}

		public function applyImpulseAt(ix:Number, iy:Number, px:Number, py:Number):void
		{
			if ((stateBits & k_bitSleep) == 0)
			{
				vx += invMass * ix;
				vy += invMass * iy;
				w += invI * (px - x) * iy - (py - y) * ix;
			}
		}

		/**
		 * Transforms a point from the rigid body's modeling-space into world space coordinates.
		 * This directly modifies the input point p if no parameter q is given. Otherwise the result
		 * is stored in the second parameter.
		 *
		 * @see RigidBody#getLocalPoint
		 * @param p The local-space coordinates.		 * @param q The world-space coordinates.
		 */
		public function getWorldPoint(p:Point, q:Point = null):void
		{
			if (q)
			{
				q.x = x + (r11 * p.x + r12 * p.y);
				q.y = y + (r21 * p.x + r22 * p.y);
			}
			else
			{
				var t:Number = p.x;
				p.x = x + (r11 * t + r12 * p.y);
				p.y = y + (r21 * t + r22 * p.y);
			}
		}

		/**
		 * Transforms a direction vector in the rigid body's modeling space frame into world space.
		 * This directly modifies the input direction d if no parameter q is given. Otherwise the
		 * result is stored in the second parameter.
		 *
		 * @see RigidBody#getLocalDirection
		 * @param d the local-space direction.
		 * @param q the world-space direction.
		 */
		public function getWorldDirection(d:Point, q:Point = null):void
		{
			if (q)
			{
				q.x = r11 * d.x + r12 * d.y;
				q.y = r21 * d.x + r22 * d.y;
			}
			else
			{
				var t:Number = d.x;
				d.x = r11 * t + r12 * d.y;
				d.y = r21 * t + r22 * d.y;
			}
		}

		/**
		 * Transforms a point given in world space coordinates into the body's
		 * local space. Directly modifies the input point p if no parameter q is
		 * given. Otherwise the result is written into the second parameter.
		 *
		 * @see RigidBody#getWorldPoint
		 * @param p The input coordinates.
		 * @param q The output coordinates.
		 */
		public function getModelPoint(p:Point, q:Point = null):void
		{
			if (q)
			{
				q.x = r11 * (p.x - x) + r21 * (p.y - y);
				q.y = r12 * (p.x - x) + r22 * (p.y - y);
			}
			else
			{
				var t:Number = p.x;
				p.x = r11 * (t - x) + r21 * (p.y - y);
				p.y = r12 * (t - x) + r22 * (p.y - y);
			}
		}

		/**
		 * Transforms a direction vector in world-space coordinates into the body's local space.
		 * This directly modifies the input direction d if no parameter q is given. Otherwise the
		 * result is stored in the second parameter.
		 *
		 * @see RigidBody#getWorldDirection
		 * @param d the world-space direction.
		 * @param q the local-space direction.
		 */
		public function getModelDirection(d:Point, q:Point = null):void
		{
			if (q)
			{
				q.x = r11 * d.x + r21 * d.y;
				q.y = r12 * d.x + r22 * d.y;
			}
			else
			{
				var t:Number = d.x;
				d.x = r11 * t + r21 * d.y;
				d.y = r12 * t + r22 * d.y;
			}
		}

		/**
		 * Checks if the body is static. A static object is a fixed object. It
		 * has an infinitive mass (the inverse mass is zero).
		 */
		public function isStatic():Boolean
		{
			return (stateBits & k_bitStatic) == k_bitStatic;
		}

		/**
		 * Checks if the body is frozen. A body gets frozen if it moves beyond
		 * the world's boundaries.
		 */
		public function isFrozen():Boolean
		{
			return (stateBits & k_bitFrozen) == k_bitFrozen;
		}

		public function isSleeping():Boolean
		{
			return (stateBits & k_bitSleep) == k_bitSleep;
		}

		public function allowSleeping(flag:Boolean):void
		{
			if (flag)
				stateBits |= k_bitAllowSleep;
			else
			{
				stateBits &= ~k_bitAllowSleep;
				wakeUp();
			}
		}

		public function wakeUp():void
		{
			stateBits &= ~k_bitSleep;
			sleepTime = 0;
		}

		public function putToSleep():void
		{
			stateBits |= k_bitSleep;
			sleepTime = 0;
			vx = vy = w = fx = fy = t = 0;
		}

		public function updateShapes(forceWCS:Boolean = false):Boolean
		{
			var cos:Number = Math.cos(r);
			var sin:Number = Math.sin(r);
			r11 = cos; r12 = -sin;
			r21 = sin; r22 =  cos;
			
			var insideBounds:Boolean = true;
			var sd:ShapeSkeleton = shapeList;
			while (sd)
			{
				if (!sd.update())
				{
					insideBounds = false;
					break;
				}
				
				if (forceWCS)
					sd.toWorldSpace();
				
				sd = sd.next;
			}
			
			//failure freeze body and destroy all proxies
			if (!insideBounds)
			{
				freeze();
				
				sd = shapeList;
				while (sd)
				{
					if (sd.proxyId != Proxy.NULL_PROXY)
					{
						world.getBroadPhase().destroyProxy(sd.proxyId);
						sd.proxyId = Proxy.NULL_PROXY;
					}
					sd = sd.next;
				}
				return false;
			}
			return true;
		}
		
		public function refreshProxy():void
		{
			var s:ShapeSkeleton = shapeList;
			while (s)
			{
				s.refreshProxy();
				s = s.next;
			}
		}
		
		/**
		 * This is used to prevent connected bodies from colliding,
		 * It may lie, depending on the collideConnected flag.
		 */
		public function isConnected(other:RigidBody):Boolean
		{
			for (var jn:JointNode = jointList; jn; jn = jn.next)
			{
				if (jn.other == other)
					return jn.joint.collideConnected == false;				
			}

			return false;
		}

		public function freeze():void
		{
			stateBits |= k_bitFrozen;
			vx = vy = w = 0;
		}
		
		private function init(world:World, bd:RigidBodyData):void
		{
			var c:Number, s:Number, shapeMass:Number;

			var rx:Number;
			var ry:Number;

			var sd:ShapeData, shape:ShapeSkeleton;
			var shapeClass:Class;

			this.world = world;

			x = bd.x;
			y = bd.y;
			r = bd.r;

			c = Math.cos(r);
			s = Math.sin(r);

			r11 = c; r12 = -s;
			r21 = s; r22 =  c;

			vx = vy = w = 0;
			fx = fy = t = 0;

			mass = invMass = I = invI = 0;
			cx = cy = 0;

			linDamping = 1 - bd.linDamping;
			linDamping = (linDamping < 0) ? 0 : (linDamping > 1) ? 1 : linDamping;

			angDamping = 1 - bd.angDamping;
			angDamping = (angDamping < 0) ? 0 : (angDamping > 1) ? 1 : angDamping;

			shapeCount = 0;
			stateBits  = 0;
			sleepTime  = 0;

			if (bd.allowSleep) stateBits |= k_bitAllowSleep;
			if (bd.isSleeping) stateBits |= k_bitSleep;

			jointList   = null;
			contactList = null;
			next = prev = null;

			sd = bd.shapeDataList;
			while (sd)
			{
				shapeMass = sd.getMass();

				mass += shapeMass;
				cx   += shapeMass * (sd.mx + sd.getCM().x);
				cy   += shapeMass * (sd.my + sd.getCM().y);

				shapeCount++;
				sd = sd.next;
			}

			//compute cm & shift origin to cm.
			if (mass > 0)
			{
				cx /= mass;
				cy /= mass;
				x += r11 * cx + r12 * cy;
				y += r21 * cx + r22 * cy;
			}
			else
				stateBits |= k_bitStatic;

			//compute total moment of inertia
			if (!bd.preventRotation)
			{
				sd = bd.shapeDataList;
				while (sd)
				{
					I += sd.getInertia();
					rx = sd.mx + sd.getCM().x - cx;
					ry = sd.my + sd.getCM().y - cy;
					I += sd.getMass() * (rx * rx + ry * ry);

					sd = sd.next;
				}
				if (I > 0) invI = 1 / I;
			}

			invMass = (mass > 0) ? (1 / mass) : 0;

			if (!bd.isSleeping && invMass > 0)
			{
				vx = bd.vx + -bd.w * cy;
				vy = bd.vy +  bd.w * cy;
				w  = bd.w;
			}

			sd = bd.shapeDataList;
			while (sd)
			{
				shapeClass = sd.getShapeClass();
				shape = new shapeClass(sd, this);
				shape.next = shapeList;
				shapeList = shape;
				sd = sd.next;
			}
		}
	}
}