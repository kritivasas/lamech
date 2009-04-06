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
	import de.polygonal.motor2.dynamics.contact.ContactID;			

	/** @private */
	public class ContactPoint
	{
		/* debug/demo only */
		public var matched:Boolean = false;
		
		public var id:ContactID;
		
		public var x:Number;
		public var y:Number;
		
		public var sep:Number;
		
		public var velBias:Number;
		
		/**
		 * normal, tangent & position impulse
		 */
		public var Pn:Number, Pt:Number, Pp:Number;
		
		/**
		 * normal & tangent contact mass
		 */
		public var nMass:Number, tMass:Number;
		
		/**
		 * local & world space anchors
		 */
		public var l_r1x:Number, l_r1y:Number;
		public var l_r2x:Number, l_r2y:Number;
		public var w_r1x:Number, w_r1y:Number;
		public var w_r2x:Number, w_r2y:Number;
		
		public function ContactPoint():void
		{
			init();
		}
		
		public function init():void
		{
			id = new ContactID();
			x = y = sep = velBias = Pn = Pt = Pp = nMass = tMass = 0;
		}
	}
}