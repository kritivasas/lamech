/*
 * Copyright (c) 2007-2008, Michael Baczynski
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
package de.polygonal.motor2.dynamics.forces
{
	import de.polygonal.ds.ArrayedQueue;
	import de.polygonal.motor2.Constants;
	import de.polygonal.motor2.dynamics.RigidBody;
	import de.polygonal.motor2.dynamics.forces.ForceGenerator;	

	public class ForceRegistry
	{
		private var _registration:ForceNode;
		private var _idQue:ArrayedQueue;
		
		public function ForceRegistry()
		{
			init();
		}
		
		public function init():void
		{
			_registration = null;
			var k:int = Constants.k_maxForceGenerators;
			_idQue = new ArrayedQueue(k);
			for (var i:int = 0; i < k; i++) _idQue.enqueue(i);
		}
		
		public function add(body:RigidBody, force:ForceGenerator):int
		{
			var id:int = _idQue.dequeue();
			
			var n:ForceNode = new ForceNode(body, force);
			n.next = _registration;
			if (_registration) _registration.prev = n;
			_registration = n;
			
			return id;
		}
		
		public function remove(body:RigidBody, force:ForceGenerator):Boolean
		{
			var n:ForceNode = _registration;
			while (n)
			{
				if (n.force == force && n.body == body)
				{
					if (n.prev) n.prev.next = n.next;
					if (n.next) n.next.prev = n.prev;
					if (n == _registration) _registration = n.next;
					return true;
				}
				n = n.next;
			}
			
			return false;
		}
		
		public function clear():void
		{
			var n:ForceNode = _registration;
			_registration = null;
			
			var next:ForceNode;
			while (n)
			{
				next = n.next;
				n.next = n.prev = null;
				n = next;
			}
		}
		
		public function evaluate():void
		{
			var n:ForceNode = _registration;
			var f:ForceGenerator;
			while (n)
			{
				f = n.force;
				if (f.isActive) f.evaluate(n.body);
				n = n.next;
			}
		}
	}
}

import de.polygonal.motor2.dynamics.RigidBody;
import de.polygonal.motor2.dynamics.forces.ForceGenerator;

internal class ForceNode
{
	public var body:RigidBody;
	public var force:ForceGenerator;
	
	public var prev:ForceNode;
	public var next:ForceNode;
	
	public function ForceNode(body:RigidBody, force:ForceGenerator)
	{
		this.body = body;
		this.force = force;
		init();
	}
	
	public function init():void
	{
		prev = next = null;
	}
}