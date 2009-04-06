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
package de.polygonal.motor2.dynamics.contact
{
	import de.polygonal.motor2.World;
	import de.polygonal.motor2.collision.nbody.PairCallback;
	import de.polygonal.motor2.collision.shapes.ShapeSkeleton;
	import de.polygonal.motor2.dynamics.RigidBody;
	import de.polygonal.motor2.dynamics.contact.Contact;
	import de.polygonal.motor2.dynamics.contact.ContactNode;
	import de.polygonal.motor2.dynamics.contact.NullContact;

	/** @private */
	public class ContactManager implements PairCallback
	{
		private static const NULL_CONTACT:NullContact = new NullContact();

		public var statsContactCount:int;

		private var _contactFactory:ContactFactory;
		private var _contactFilter:ContactFilter;
		
		private var _world:World;

		public function ContactManager(world:World)
		{
			_world = world;
			_contactFactory = new ContactFactory();
		}
		
		public function setFilter(filter:ContactFilter):void
		{
			_contactFilter = filter;
		}

		/**
		 * Invoked by the broad-phase when two proxies start to overlap. This
		 * creates a contact object to manage the narrow phase.
		 */		public function pairAdded(proxyShape1:ShapeSkeleton, proxyShape2:ShapeSkeleton):Contact
		{
			statsContactCount++;

			var b1:RigidBody = proxyShape1.body;
			var b2:RigidBody = proxyShape2.body;

			if ((b1.stateBits & b2.stateBits) & RigidBody.k_bitStatic)
				return NULL_CONTACT;
			
			if (b1 == b2) return NULL_CONTACT;
			
			if (b2.isConnected(b1))
				return NULL_CONTACT;
			
			if (!_contactFilter.shouldCollide(proxyShape1, proxyShape2))
				return NULL_CONTACT;

			//create contact, TODO store body1, body2
			var c:Contact = _contactFactory.create(proxyShape1, proxyShape2);

			if (c == null)
				return NULL_CONTACT;
			else
			{
				//prepend to world's contact list
				c.prev = null;
				c.next = _world.contactList;
				if (_world.contactList) _world.contactList.prev = c;
				_world.contactList = c;
				
				_world.contactCount++;
			}
			return c;
		}

		/**
		 * Invoked by the broad-phase when two proxies cease to overlap.
		 * This destroys the contact object.
		 */
		public function pairRemoved(c:Contact):void
		{
			statsContactCount++;

			if (c == null || c == NULL_CONTACT)
				return;
			
			destroyContact(c);
		}

		/**
		 * The top level collision call for the time step. Here all narrow-phase
		 * collisions are processed for the world contact list.
		 */
		public function collide():void
		{
			var c:Contact = _world.contactList;
			while (c)
			{
				//TODO use body directy
				var b1:RigidBody = c.shape1.body;
				var b2:RigidBody = c.shape2.body;

				//don't disturb two sleeping bodies
				if ((b1.stateBits & b2.stateBits) & RigidBody.k_bitSleep)
				{
					c = c.next;
					continue;
				}

				//create contact manifold
				var oldCount:int = c.manifoldCount;
				c.evaluate();
				var newCount:int = c.manifoldCount;

				//refresh contact graph
				var n:ContactNode;
				if (oldCount == 0 && newCount > 0)
				{
					//connect to island graph
					//connect to body 1
					n = c.node1;
					n.contact = c;
					n.other = b2;

					//prepend to contact node list
					n.prev = null;
					n.next = b1.contactList;
					if (n.next) n.next.prev = n;
					b1.contactList = n;

					//connect to body 2
					n = c.node2;
					n.contact = c;
					n.other   = b1;

					//prepend to contact node list
					n.prev = null;
					n.next = b2.contactList;
					if (n.next) n.next.prev = n;
					b2.contactList = n;
				}
				else
				if (oldCount > 0 && newCount == 0)
				{
					//disconnect from island graph
					//unlink from body 1
					n = c.node1;
					if (n.next) n.next.prev = n.prev;
					if (n.prev) n.prev.next = n.next;
					if (n == b1.contactList) b1.contactList = n.next;
					n.next = n.prev = null;

					//unlink from body 2
					n = c.node2;
					if (n.next) n.next.prev = n.prev;
					if (n.prev) n.prev.next = n.next;
					if (n == b2.contactList) b2.contactList = n.next;
					n.next = n.prev = null;
				}

				c = c.next;
			}
		}
		
		private function destroyContact(c:Contact):void
		{
			if (_world.contactCount == 0) return;

			//unlink from world's contact list
			if (c.prev) c.prev.next = c.next;
			if (c.next) c.next.prev = c.prev;
			if (c == _world.contactList) _world.contactList = c.next;
			
			c.flush();
			
			//unlink existing contact points from island graph
			if (c.manifoldCount > 0)
			{
				var b1:RigidBody = c.shape1.body;
				b1.stateBits &= ~RigidBody.k_bitSleep;
				b1.sleepTime = 0;

				var b2:RigidBody = c.shape2.body;
				b2.stateBits &= ~RigidBody.k_bitSleep;
				b2.sleepTime = 0;

				var n:ContactNode;

				n = c.node1;
				if (n.next) n.next.prev = n.prev;
				if (n.prev) n.prev.next = n.next;
				if (n == b1.contactList) b1.contactList = n.next;
				n.next = n.prev = null;

				n = c.node2;
				if (n.next) n.next.prev = n.prev;
				if (n.prev) n.prev.next = n.next;
				if (n == b2.contactList) b2.contactList = n.next;
				n.next = n.prev = null;
			}
			_world.contactCount--;
		}
	}
}