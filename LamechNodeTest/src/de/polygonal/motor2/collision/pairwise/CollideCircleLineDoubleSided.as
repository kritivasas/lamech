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
	import de.polygonal.motor2.collision.shapes.ShapeSkeleton;
	import de.polygonal.motor2.dynamics.contact.Contact;
	import de.polygonal.motor2.dynamics.contact.ContactID;
	import de.polygonal.motor2.dynamics.contact.ContactPoint;
	import de.polygonal.motor2.dynamics.contact.Manifold;
	import de.polygonal.motor2.math.V2;

	/** @private */
	public class CollideCircleLineDoubleSided implements Collider
	{
		public function collide(manifold:Manifold, s1:ShapeSkeleton, s2:ShapeSkeleton, contact:Contact):void
		{
			var cp:ContactPoint;

			var a:V2 = s2.worldVertexChain;
			var b:V2 = a.next;

			var rSq:Number = s1.radiusSq;

			var ax:Number = a.x, bx:Number = b.x, px:Number = s1.x;
			var ay:Number = a.y, by:Number = b.y, py:Number = s1.y;

			var bax:Number = bx - ax;
			var bay:Number = by - ay;

			var pax:Number = px - ax;
			var pay:Number = py - ay;

			var distSq:Number, dist:Number, nx:Number, ny:Number;

			var t:Number = pax * bax + pay * bay;

			//Q beyond A, d2 = |AP|
			if (t < 0)
			{
				distSq = pax * pax + pay * pay;

				if (distSq > rSq)
				{
					manifold.pointCount = 0;
					return;
				}

				dist = Math.sqrt(distSq);
				nx = pax / dist;
				ny = pay / dist;

				cp = manifold.c0;
				cp.id.incEdge = a.index;
				cp.id.incVert = a.index;
			}
			else
			{
				var bpx:Number = bx - px;
				var bpy:Number = by - py;
				t = bpx * bax + bpy * bay;

				//Q beyond B, d2 = |BP|
				if (t < 0)
				{
					distSq = bpx * bpx + bpy * bpy;
					if (distSq > rSq)
					{
						manifold.pointCount = 0;
						return;
					}

					dist = Math.sqrt(distSq);
					nx = -bpx / dist;
					ny = -bpy / dist;

					cp = manifold.c0;
					cp.id.incEdge = b.index;
					cp.id.incVert = b.index;
				}
				else
				{
					//Q on AB, d2 = d1
					var a2:Number = pay * bax - pax * bay;

					distSq = (a2 * a2) / (bax * bax + bay * bay);
					if (distSq > rSq)
					{
						manifold.pointCount = 0;
						return;
					}

					dist = Math.sqrt(distSq);
					nx =-by + ay;
					ny = bx - ax;

					var mag:Number = Math.sqrt(nx * nx + ny * ny) * ((nx * pax + ny * pay) < 0 ? -1 : 1);
					nx /= mag;
					ny /= mag;

					cp = manifold.c0;
					cp.id.incEdge = a.index;
					cp.id.incVert = b.index;
				}
			}

			manifold.pointCount = 1;
			manifold.nx = -nx;
			manifold.ny = -ny;

			cp.id.refFace = ContactID.NULL_FEATURE;
			cp.id.flip = 0;
			cp.id.bake();

			var r:Number = s1.radius;
			cp.x = px - r * nx;
			cp.y = py - r * ny;
			cp.sep = dist - r;
		}
	}
}