/*
 * Copyright (c) 2007-2008, Michael Baczynski
 * Based on the Box2D Engine by Erin Catto, http://www.box2d.org
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
package de.polygonal.motor2
{
	import de.polygonal.motor2.collision.nbody.*;
	import de.polygonal.motor2.collision.shapes.ShapeSkeleton;
	import de.polygonal.motor2.collision.shapes.data.ShapeData;
	import de.polygonal.motor2.dynamics.Island;
	import de.polygonal.motor2.dynamics.RigidBody;
	import de.polygonal.motor2.dynamics.RigidBodyData;
	import de.polygonal.motor2.dynamics.contact.Contact;
	import de.polygonal.motor2.dynamics.contact.ContactFilter;
	import de.polygonal.motor2.dynamics.contact.ContactManager;
	import de.polygonal.motor2.dynamics.contact.ContactNode;
	import de.polygonal.motor2.dynamics.forces.Buoyancy;
	import de.polygonal.motor2.dynamics.forces.ForceGenerator;
	import de.polygonal.motor2.dynamics.forces.ForceRegistry;
	import de.polygonal.motor2.dynamics.joints.Joint;
	import de.polygonal.motor2.dynamics.joints.JointNode;
	import de.polygonal.motor2.dynamics.joints.data.JointData;
	import de.polygonal.motor2.math.AABB2;
	
	import flash.events.EventDispatcher;
	import flash.geom.Point;	

	public class World extends EventDispatcher
	{
		public static var stats_SepAxisQueryCount:int = 0;
		public static var stats_timeSimStep:int = 0;

		public static var doPositionCorrection:Boolean = true;
		public static var doWarmStarting:Boolean = true;

		private var _worldBounds:AABB2;
		
		private var _groundBody:RigidBody;
		
		public var doSleep:Boolean;
		
		public var gravity:Point;

		public var bodyList:RigidBody;
		public var jointList:Joint;

		public var bodyDestroyList:RigidBody;
		
		public var contactCount:int;
		public var contactList:Contact;

		private var _bodyCount:int;
		private var _shapeCount:int;
		private var _jointCount:int;

		private var _contactManager:ContactManager;
		private var _broadPhase:BroadPhase;
		private var _forceRegistry:ForceRegistry;
		private var _island:Island;
		private var _callback:WorldCallback;

		public function World(worldBounds:AABB2, doSleep:Boolean = true)
		{
			if (worldBounds.isEmpty()) throw new Error("invalid world bounds");
			
			_worldBounds = worldBounds.copy();
			_worldBounds.xmin = int(_worldBounds.xmin);			_worldBounds.ymin = int(_worldBounds.ymin);			_worldBounds.xmax = int(_worldBounds.xmax);			_worldBounds.ymax = int(_worldBounds.ymax);
			
			this.doSleep = doSleep;
			
			setGravity(0, 100);
			setCallback(new NullCallback());
			
			_contactManager = new ContactManager(this);
			_contactManager.setFilter(new ContactFilter());
			_groundBody = new RigidBody(this, new RigidBodyData());
			_forceRegistry = new ForceRegistry();
			_island = new Island();
		}

		public function deconstruct():void
		{
			destroyBody(_groundBody);
			_broadPhase = null;
			//TODO deconstruct all
		}
		
		public function setGravity(x:Number, y:Number):void
		{
			if (gravity == null)
				gravity = new Point();
			
			gravity.x = x;
			gravity.y = y;
		}
		
		public function setCallback(callback:WorldCallback):void
		{
			_callback = callback;
		}
		
		public function setContactFilter(filter:ContactFilter):void
		{
			_contactManager.setFilter(filter);
		}
		
		public function getBodyCount():int
		{
			return _bodyCount;
		}
		
		/**
		 * Returns a list of all bodies in vector format.
		 */
		public function getBodyList():Vector.<RigidBody>
		{
			var v:Vector.<RigidBody> = new Vector.<RigidBody>(_bodyCount, true);
			var i:int = 0;
			var b:RigidBody = bodyList;
			if (b == null) return v;
			
			while (b != null)
			{
				v[i++] = b;
				b = b.next;
			}
			
			return v;
		}
		
		public function getShapeCount():int
		{
			return _shapeCount;
		}

		/**
		 * Returns a list of all shapes in vector format.
		 */
		public function getShapeList():Vector.<ShapeSkeleton>
		{
			var v:Vector.<ShapeSkeleton> = new Vector.<ShapeSkeleton>(_shapeCount, true);
			var i:int = 0;
			var b:RigidBody = bodyList;
			if (b == null) return v;
			
			var s:ShapeSkeleton = b.shapeList;
			
			while (true)
			{
				if (s != null)
				{
					v[i++] = s;
					s = s.next;
				}
				else
				{
					b = b.next;
					if (b != null)
					{
						s = b.shapeList;
						v[i++] = s;
						s = s.next;
					}
					else
						break;
				}
			}
			
			return v;
		}

		/**
		 * A single static ground body with no collision shapes.
		 * You can use this to simplify the creation of joints and static shapes.
		 */
		public function getGroundBody():RigidBody
		{
			return _groundBody;
		}

		public function getWorldBounds():AABB2
		{
			return _worldBounds;
		}

		/**
		 * Access the current broad phase algorithm.
		 */
		public function getBroadPhase():BroadPhase
		{
			return _broadPhase;
		}

		/**
		 * Assign a new broad phase strategy for all bodies in the world.
		 */
		public function setBroadPhase(broadPhase:BroadPhase):void
		{
			if (_bodyCount == 0)
			{
				_broadPhase = broadPhase;
				_broadPhase.setWorldBounds(_worldBounds);
				_broadPhase.setPairHandler(_contactManager);
			}
			else
			{
				var shapes:Vector.<ShapeSkeleton> = getShapeList();
				var shape:ShapeSkeleton;
				for (var i:int = 0; i < shapes.length; i++)
				{
					shape = shapes[i];
					_broadPhase.destroyProxy(shape.proxyId);
					shape.proxyId = Proxy.NULL_PROXY;
					shape.broadPhase = null;
				}
				
				_broadPhase.deconstruct();
				
				_broadPhase = broadPhase;
				_broadPhase.setWorldBounds(_worldBounds);
				_broadPhase.setPairHandler(_contactManager);
				
				for (i = 0; i < shapes.length; i++)
				{
					shape = shapes[i];
					shape.broadPhase = _broadPhase;
					shape.proxyId = _broadPhase.createProxy(shape);
				}		
			}
		}

		public function createBody(data:RigidBodyData):RigidBody
		{
			if (_broadPhase == null)
				setBroadPhase(new ExhaustiveSearch());
			
			var b:RigidBody = new RigidBody(this, data);
			
			b.next = bodyList;
			if (bodyList) bodyList.prev = b;
			bodyList = b;
			_bodyCount++;
			
			var shapeData:ShapeData = data.shapeDataList;
			while (shapeData != null)
			{
				_shapeCount++;
				shapeData = shapeData.next;
			}
			
			return b;
		}
		
		public function createJoint(data:JointData):Joint
		{
			var c:Class = data.getJointClass();
			var j:Joint = new c(data) as Joint;

			//prepend to world list
			j.prev = null;
			j.next = jointList;
			if (jointList) jointList.prev = j;
			jointList = j;
			_jointCount++;

			//connect the bodies' doubly linked lists.
			j.node1.joint = j;
			j.node1.other = j.body2;
			j.node1.prev = null;
			j.node1.next = j.body1.jointList;

			if (j.body1.jointList) j.body1.jointList.prev = j.node1;

			j.body1.jointList = j.node1;

			j.node2.joint = j;
			j.node2.other = j.body1;
			j.node2.prev = null;
			j.node2.next = j.body2.jointList;

			if (j.body2.jointList) j.body2.jointList.prev = j.node2;
			j.body2.jointList = j.node2;

			//if the joint prevents collisions, then reset collision filtering.
			if (!data.collideConnected)
			{
				//reset the proxies on the body with the minimum number of shapes.
				var b:RigidBody = data.body1.shapeCount < data.body2.shapeCount ? data.body1 : data.body2;

				var s:ShapeSkeleton = b.shapeList;
				while (s)
				{
					s.refreshProxy();
					s = s.next;
				}
			}
			return j;
		}

		/**
		 * Applies a force to a rigid body.
		 */
		public function addForce(body:RigidBody, fg:ForceGenerator):Boolean
		{
			if (body == null) return false;

			//build triangle list
			if (fg is Buoyancy)
			{
				var s:ShapeSkeleton = body.shapeList;
				while (s)
				{
					s.triangulate();
					s = s.next;
				}
			}
			//TODO check for duplicates
			_forceRegistry.add(body, fg);
			return true;
		}

		/**
		 * Removes a force from a rigid body.
		 */
		public function removeForce(body:RigidBody, fg:ForceGenerator):Boolean
		{
			return _forceRegistry.remove(body, fg);
		}

		/**
		 * Destroys a given rigid body.
		 */
		public function destroyBody(b:RigidBody):Boolean
		{
			if (_bodyCount == 0)
				return false;

			if (b.stateBits & RigidBody.k_bitDestroy)
				return false;
			
			//delete all attached joints
			var jn1:JointNode = b.jointList;
			var jn0:JointNode;
			while (jn1)
			{
				jn0 = jn1;
				jn1 = jn1.next;
				
				_callback.onJointDestroyed(jn0.joint);

				destroyJoint(jn0.joint);
			}
			
			//delete all attached shapes. destroys broad-phase proxies and
			//pairs, leading to the destruction of contacts
			var s1:ShapeSkeleton = b.shapeList;
			var s0:ShapeSkeleton;
			while (s1)
			{
				s0 = s1;
				s1 = s1.next;
				_shapeCount--;
				
				_callback.onShapeDestroyed(s0);
			}
			
			if (b.prev) b.prev.next = b.next;
			if (b.next) b.next.prev = b.prev;
			if (b == bodyList) bodyList = b.next;

			b.stateBits |= RigidBody.k_bitDestroy;
			if (_bodyCount > 0) _bodyCount--;
			
			b.deconstruct();
			_callback.onBodyDestroyed(b);

			return true;
		}
		
		public function destroyJoint(j:Joint):void
		{
			var collideConnected:Boolean = j.collideConnected;

			//remove from the world
			if (j.prev) j.prev.next = j.next;
			if (j.next) j.next.prev = j.prev;

			if (j == jointList) jointList = j.next;

			//disconnect from island graph
			var body1:RigidBody = j.body1;
			var body2:RigidBody = j.body2;

			//wake up touching bodies
			body1.wakeUp();
			body2.wakeUp();

			//remove from body 1
			if (j.node1.prev) j.node1.prev.next = j.node1.next;
			if (j.node1.next) j.node1.next.prev = j.node1.prev;

			if (j.node1 == body1.jointList)
				body1.jointList = j.node1.next;

			j.node1.prev = null;
			j.node1.next = null;

			//remove from body 2
			if (j.node2.prev) j.node2.prev.next = j.node2.next;
			if (j.node2.next) j.node2.next.prev = j.node2.prev;

			if (j.node2 == body2.jointList)
				body2.jointList = j.node2.next;

			j.node2.prev = null;
			j.node2.next = null;

			_jointCount--;

			//if the joint prevents collisions, then reset collision filtering
			if (!collideConnected)
			{
				//reset the proxies on the body with the minimum number of shapes
				var b:RigidBody = body1.shapeCount < body2.shapeCount ? body1 : body2;
				var s:ShapeSkeleton = b.shapeList;
				while (s)
				{
					s.refreshProxy();
					s = s.next;
				}
			}
		}
		
		/**
		 * Performs a simulation step.
		 */
		public function step(dt:Number, iterations:int):void
		{
			var b:RigidBody, c:Contact, j:Joint;
			var i:int;
			
			/*/////////////////////////////////////////////////////////
			// CREATE AND/OR UPDATE CONTACTS
			/////////////////////////////////////////////////////////*/

			_contactManager.collide();

			/*/////////////////////////////////////////////////////////
			// evaluate all attached forces
			/////////////////////////////////////////////////////////*/

			_forceRegistry.evaluate();

			/*/////////////////////////////////////////////////////////
			// BUILD AND SIMULATE ALL AWAKE ISLANDS
			/////////////////////////////////////////////////////////*/

			//clear all island flags set during DFS traversal
			b = bodyList;
			while (b)
			{
				b.stateBits &= ~0x20;
				b = b.next;
			}
			c = contactList;
			while (c)
			{
				c.stateBits &= ~Contact.k_bitIsland;
				c = c.next;
			}
			j = jointList;
			while (j)
			{
				j.stateBits &= ~0x20;
				j = j.next;
			}

			var stack:Array = [];
			var stackSize:int;

			var other:RigidBody;
			var cn:ContactNode;
			var jn:JointNode;
			var seed:RigidBody;
			
			var inactiveFlags:int = RigidBody.k_bitStatic | RigidBody.k_bitSleep | RigidBody.k_bitFrozen | RigidBody.k_bitIsland;
			
			for (seed = bodyList; seed != null; seed = seed.next)
			{
				if (seed.stateBits & inactiveFlags)
					continue;

				//reset island and stack
				_island.bodyCount    = 0;
				_island.contactCount = 0;
				_island.jointCount   = 0;

				stack[0] = seed;
				stackSize = 1;

				//mark node
				seed.stateBits |= 0x20;

				//perform a depth first search (DFS) on the constraint graph.
				//http://lab.polygonal.de/2007/06/13/data-structures-example-the-graph-class/
				while (stackSize > 0)
				{
					//grab the next body off the stack and add it to the island.
					b = stack[--stackSize];
					_island.bodies[int(_island.bodyCount++)] = b;

					//make sure the body is awake.
					b.stateBits &= ~RigidBody.k_bitSleep;

					//to keep islands as small as possible, we don't propagate
					//islands across static bodies.
					if (b.stateBits & RigidBody.k_bitStatic)
						continue;

					//search all contacts connected to this body
					for (cn = b.contactList; cn; cn = cn.next)
					{
						//already marked
						if (cn.contact.stateBits & Contact.k_bitIsland)
							continue;

						//add and mark
						_island.contacts[int(_island.contactCount++)] = cn.contact;

						cn.contact.stateBits |= Contact.k_bitIsland;

						//other body marked
						other = cn.other;
						if (other.stateBits & 0x20)
							continue;

						stack[stackSize++] = other;
						other.stateBits |= 0x20;
					}

					//search all joints connected to this body
					for (jn = b.jointList; jn; jn = jn.next)
					{
						var joint:Joint = jn.joint;

						//already marked
						if (joint.stateBits & 0x20) continue;

						//add and mark
						_island.joints[int(_island.jointCount++)] = joint;

						joint.stateBits |= 0x20;

						other = jn.other;
						if (other.stateBits & 0x20)
							continue;

						stack[stackSize++] = other;
						other.stateBits |= 0x20;
					}
				}
				
				_island.solve(gravity.x, gravity.y, iterations, dt);
				if (doSleep) _island.updateSleep(dt);

				//post solve cleanup
				for (i = 0; i < _island.bodyCount; i++)
				{
					b = _island.bodies[i];

					//allow static bodies to participate in other islands
					if (b.stateBits & RigidBody.k_bitStatic)
						b.stateBits &= ~0x20;
				}
			}
			
			/*/////////////////////////////////////////////////////////
			// SYNC SHAPES, RESET FORCE ACCUMULATOR
			/////////////////////////////////////////////////////////*/

			inactiveFlags &= ~RigidBody.k_bitIsland;
			b = bodyList;
			while (b != null)
			{
				if ((b.stateBits & inactiveFlags) > 0)
				{
					b = b.next;
					continue;	
				}
				
				b.fx = b.fy = b.t = 0;
				
				if (!b.updateShapes())
					_callback.onBodyLeftWorld(b);	
				
				b = b.next;
			}
			
			//commit shape proxy movements to the broad-phase so that new contacts are created.
			//also, some contacts can be destroyed.
			_broadPhase.findPairs();
		}

	}
}

import de.polygonal.motor2.WorldCallback;
import de.polygonal.motor2.collision.shapes.ShapeSkeleton;
import de.polygonal.motor2.dynamics.RigidBody;
import de.polygonal.motor2.dynamics.joints.Joint;
internal class NullCallback implements WorldCallback
{
	public function onBodyDestroyed(body:RigidBody):void {}
	
	public function onBodyLeftWorld(body:RigidBody):void {}
	
	public function onShapeDestroyed(shape:ShapeSkeleton):void {}
	
	public function onJointDestroyed(joint:Joint):void {}
}