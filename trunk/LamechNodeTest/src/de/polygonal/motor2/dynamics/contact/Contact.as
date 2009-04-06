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
	import de.polygonal.motor2.collision.pairwise.Collider;
	import de.polygonal.motor2.collision.shapes.ShapeSkeleton;
	import de.polygonal.motor2.dynamics.RigidBody;	

	/** @private */
	public class Contact
	{
		public static const k_bitIsland:int = 0x20;
		
		public var next:Contact;
		public var prev:Contact;
		
		public var node1:ContactNode;
		public var node2:ContactNode;
		
		public var shape1:ShapeSkeleton, body1:RigidBody;
		public var shape2:ShapeSkeleton, body2:RigidBody;
		
		//used by single-sided collisions only
		public var disabled:Boolean;
		
		public var manifolds:Vector.<Manifold>;
		public var manifoldCount:int;
		public var friction:Number;
		public var restitution:Number;
		public var stateBits:int;
		public var secondary:Boolean;
		
		protected var _collider:Collider;
		
		public function Contact(s1:ShapeSkeleton, s2:ShapeSkeleton)
		{
			init(s1, s2);
		}
		
		public function evaluate():void {}
		
		public function flush():void {}
		
		protected function init(s1:ShapeSkeleton, s2:ShapeSkeleton):void
		{
			shape1 = s1;
			shape2 = s2;
			
			manifoldCount = 0;
			manifolds = new Vector.<Manifold>(2, true);
			
			friction = Math.sqrt(s1.friction * s2.friction);
			restitution = s1.restitution > s2.restitution ? s1.restitution : s2.restitution;
			
			_collider = getCollider();

			node1 = new ContactNode();
			node2 = new ContactNode();
		}
		
		protected function getCollider():Collider
		{
			return null;
		}
	}
}