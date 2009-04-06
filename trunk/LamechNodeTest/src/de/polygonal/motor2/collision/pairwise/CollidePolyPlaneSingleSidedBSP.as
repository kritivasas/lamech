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
package de.polygonal.motor2.collision.pairwise
{
	import flash.geom.Point;

	import de.polygonal.motor2.collision.shapes.ShapeSkeleton;
	import de.polygonal.motor2.dynamics.contact.Contact;
	import de.polygonal.motor2.dynamics.contact.ContactPoint;
	import de.polygonal.motor2.dynamics.contact.Manifold;
	import de.polygonal.motor2.math.ConvexBSPNode;
	import de.polygonal.motor2.math.V2;

	/** @private */
	public class CollidePolyPlaneSingleSidedBSP implements Collider
	{
		public function collide(manifold:Manifold, s1:ShapeSkeleton, s2:ShapeSkeleton, contact:Contact):void
		{
			var node:ConvexBSPNode;

			var nx:Number = s2.worldNormalChain.x;
			var ny:Number = s2.worldNormalChain.y;
			var d:Number = s2.d;

			node = s1.BSPNode;
			while (node.R) node = (node.N.x * ny - node.N.y * nx <= 0) ? node.R : node.L;
			var s:V2 = node.V;

			var sep:Number = s.x * nx + s.y * ny - d;
			if (sep > 0)
			{
				manifold.pointCount = 0;
				return;
			}

			manifold.nx =-nx;
			manifold.ny =-ny;
			manifold.pointCount = 1;
			var cp:ContactPoint = manifold.c0;
			cp.sep = sep;
			cp.x   = s.x;
			cp.y   = s.y;
			cp.id.key = 0;

			sep = s.prev.x * nx + s.prev.y * ny - d;
			if (sep < 0)
			{
				cp.id.key = 1;
				cp = manifold.c1;
				cp.sep = sep;
				cp.x   = s.prev.x;
				cp.y   = s.prev.y;
				cp.id.key = 1;
				manifold.pointCount++;
			}
			else
			{
				sep = s.next.x * nx + s.next.y * ny - d;
				if (sep < 0)
				{
					cp.id.key = 1;
					cp = manifold.c1;
					cp.sep = sep;
					cp.x   = s.next.x;
					cp.y   = s.next.y;
					cp.id.key = 1;
					manifold.pointCount++;
				}
			}
		}
	}
}