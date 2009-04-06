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
package de.polygonal.motor2.dynamics.contact.generator
{
	import de.polygonal.motor2.collision.pairwise.CollidePolyBSP;
	import de.polygonal.motor2.collision.pairwise.CollidePolyCHC;
	import de.polygonal.motor2.collision.pairwise.CollideTriangleHC;
	import de.polygonal.motor2.collision.pairwise.Collider;
	import de.polygonal.motor2.collision.shapes.ShapeSkeleton;
	import de.polygonal.motor2.math.V2;
	
	import flash.utils.Dictionary;	

	/** @private */
	public class PolyContact extends ConvexContact
	{
		private static const COLLIDE_POLY_BSP:CollidePolyBSP = new CollidePolyBSP();		private static const COLLIDE_POLY_CHC:CollidePolyCHC = new CollidePolyCHC();
		
		private static const COLLIDE_TRIANGLE_HC:CollideTriangleHC = new CollideTriangleHC();

		public var firstOut:Boolean, p:V2, d:V2;
		public var hc:Dictionary;

		public function PolyContact(shape1:ShapeSkeleton, shape2:ShapeSkeleton)
		{
			super(shape1, shape2);
			
			firstOut = true;
			p = shape1.worldVertexChain;
			d = shape1.worldNormalChain;
			
			if (shape1.vertexCount + shape2.vertexCount > 10)
				hc = new Dictionary(true);
		}
		
		override public function flush():void
		{
			hc = null;
		}

		override protected function getCollider():Collider
		{
			if (shape1.vertexCount + shape2.vertexCount > 10)
				return COLLIDE_POLY_CHC;
			else
			{
				if (shape1.vertexCount == 3 && shape2.vertexCount == 3)
					return COLLIDE_TRIANGLE_HC;
				
				return COLLIDE_POLY_BSP;
			}
		}
	}
}