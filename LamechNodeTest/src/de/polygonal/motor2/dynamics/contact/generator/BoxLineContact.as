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
	import de.polygonal.motor2.collision.pairwise.CollideBoxLineDoubleSided;
	import de.polygonal.motor2.collision.pairwise.CollideBoxLineSingleSided;
	import de.polygonal.motor2.collision.pairwise.CollideBoxPlaneDoubleSided;
	import de.polygonal.motor2.collision.pairwise.CollideBoxPlaneSingleSided;
	import de.polygonal.motor2.collision.pairwise.Collider;
	import de.polygonal.motor2.collision.shapes.LineShape;
	import de.polygonal.motor2.collision.shapes.ShapeSkeleton;	

	/** @private */
	public class BoxLineContact extends ConvexContact
	{
		private static const COLLIDE_BOX_PLANE_SS:CollideBoxPlaneSingleSided = new CollideBoxPlaneSingleSided();		private static const COLLIDE_BOX_PLANE_DS:CollideBoxPlaneDoubleSided = new CollideBoxPlaneDoubleSided();
		
		private static const COLLIDE_BOX_LINE_SS:CollideBoxLineSingleSided = new CollideBoxLineSingleSided();
		private static const COLLIDE_BOX_LINE_DS:CollideBoxLineDoubleSided = new CollideBoxLineDoubleSided();
		
		//support point id hint
		public var sid:int = -1;
		
		public function BoxLineContact(shape1:ShapeSkeleton, shape2:ShapeSkeleton)
		{
			super(shape1, shape2);
		}
		
		override protected function getCollider():Collider
		{
			var ls:LineShape = LineShape(shape2);
			if (ls.infinite)
			{
				if (ls.doubleSided)
					return COLLIDE_BOX_PLANE_DS;
				return COLLIDE_BOX_PLANE_SS;
			}
			
			if (ls.doubleSided)
				return COLLIDE_BOX_LINE_DS;
			return COLLIDE_BOX_LINE_SS;
		}
	}
}