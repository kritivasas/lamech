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
	import de.polygonal.motor2.collision.pairwise.CollidePolyLineDoubleSidedCHC;
	import de.polygonal.motor2.collision.pairwise.CollidePolyLineDoubleSidedBSP;
	import de.polygonal.motor2.collision.pairwise.CollidePolyLineSingleSidedBSP;
	import de.polygonal.motor2.collision.pairwise.CollidePolyLineSingleSidedCHC;
	import de.polygonal.motor2.collision.pairwise.CollidePolyPlaneDoubleSidedBSP;
	import de.polygonal.motor2.collision.pairwise.CollidePolyPlaneDoubleSidedCHC;
	import de.polygonal.motor2.collision.pairwise.CollidePolyPlaneSingleSidedBSP;
	import de.polygonal.motor2.collision.pairwise.CollidePolyPlaneSingleSidedCHC;
	import de.polygonal.motor2.collision.pairwise.Collider;
	import de.polygonal.motor2.collision.shapes.LineShape;
	import de.polygonal.motor2.collision.shapes.ShapeSkeleton;
	import de.polygonal.motor2.math.V2;	

	/** @private */
	public class PolyLineContact extends ConvexContact
	{
		private static const COLLIDE_POLY_PLANE_SS_CHC:CollidePolyPlaneSingleSidedCHC = new CollidePolyPlaneSingleSidedCHC();		private static const COLLIDE_POLY_PLANE_SS_BSP:CollidePolyPlaneSingleSidedBSP = new CollidePolyPlaneSingleSidedBSP();
		private static const COLLIDE_POLY_PLANE_DS_CHC:CollidePolyPlaneDoubleSidedCHC = new CollidePolyPlaneDoubleSidedCHC();
		private static const COLLIDE_POLY_PLANE_DS_BSP:CollidePolyPlaneDoubleSidedBSP = new CollidePolyPlaneDoubleSidedBSP();
		
		private static const COLLIDE_POLY_LINE_SS_CHC:CollidePolyLineSingleSidedCHC = new CollidePolyLineSingleSidedCHC();
		private static const COLLIDE_POLY_LINE_SS_BSP:CollidePolyLineSingleSidedBSP = new CollidePolyLineSingleSidedBSP();
		private static const COLLIDE_POLY_LINE_DS_CHC:CollidePolyLineDoubleSidedCHC = new CollidePolyLineDoubleSidedCHC();
		private static const COLLIDE_POLY_LINE_DS_BSP:CollidePolyLineDoubleSidedBSP = new CollidePolyLineDoubleSidedBSP();
		
		public var hint1:V2;
		public var hint2:V2;
		
		public function PolyLineContact(shape1:ShapeSkeleton, shape2:ShapeSkeleton)
		{
			super(shape1, shape2);
			
			var useHillClimbing:Boolean = shape1.vertexCount > 10;
			if (useHillClimbing)
			{
				hint1 = shape1.worldVertexChain;
				hint2 = hint1;
			}
		}

		override protected function getCollider():Collider
		{
			var useHillClimbing:Boolean = shape1.vertexCount > 10;
			
			var ls:LineShape = LineShape(shape2);
			if (ls.infinite)
			{
				if (ls.doubleSided)
				{
					if (useHillClimbing)
						return COLLIDE_POLY_PLANE_DS_CHC;
					return COLLIDE_POLY_PLANE_DS_BSP;
				}
				
				if (useHillClimbing)
					return COLLIDE_POLY_PLANE_SS_CHC;
				return COLLIDE_POLY_PLANE_SS_BSP;
			}
			
			if (ls.doubleSided)
			{
				if (useHillClimbing)
					return COLLIDE_POLY_LINE_DS_CHC;
				return COLLIDE_POLY_LINE_DS_BSP;
			}
			
			if (useHillClimbing)
				return COLLIDE_POLY_LINE_SS_CHC;
			return COLLIDE_POLY_LINE_SS_BSP;
		}
	}
}