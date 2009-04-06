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
	import de.polygonal.motor2.dynamics.contact.generator.ConvexCircleContact;
	import de.polygonal.motor2.math.E2;
	import de.polygonal.motor2.math.V2;

	/** @private */
	public class CollidePolyCircle implements Collider
	{
		public function collide(manifold:Manifold, s1:ShapeSkeleton, s2:ShapeSkeleton, contact:Contact):void
		{
			var mv:V2, mn:V2, N:V2, p:V2;
			var cx:Number = s2.x;
			var cy:Number = s2.y;
			var s:Number, r:Number = s2.radius;
			var sep:Number = -2147483648;

			var c:ConvexCircleContact = ConvexCircleContact(contact);

			mv = c.p;
			mn = c.d;

			var last:int = mv.prev.index;
			while (true)
			{
				s = mn.x * (cx - mv.x) + mn.y * (cy - mv.y);
				if (s > r)
				{
					manifold.pointCount = 0;
					c.p = mv;
					c.d = mn;
					return;
				}

				if (s > sep)
				{
					sep = s;
					N = mn;
					p = mv;
				}

				if (mv.index == last) break;
				mv = mv.next;
				mn = mn.next;
			}

			if (sep < 1e-6)
			{
				//point inside polygon
				manifold.pointCount = 1;
				manifold.nx = N.x;
				manifold.ny = N.y;

				cp = manifold.c0;

				cp.id.incEdge = N.index + 1;
				cp.id.incVert = 0xfe;
				cp.id.refFace = 0xfe;
				cp.id.flip = 0;
				cp.id.bake();

				cp.x = cx - r * manifold.nx;
				cp.y = cy - r * manifold.ny;
				cp.sep = sep - r;
				return;
			}

			var edge:E2 = p.edge;
			var dx:Number, ex:Number = s1.r11 * edge.d.x + s1.r12 * edge.d.y;
			var dy:Number, ey:Number = s1.r21 * edge.d.x + s1.r22 * edge.d.y;

			var dist:Number;
			var cp:ContactPoint;

			if (edge.mag < 1e-6)
			{
				dx = cx - p.x;
				dy = cy - p.y;
				dist = dx * dx + dy * dy;
				if (dist > s2.radiusSq);
				{
					manifold.pointCount = 0;
					return;
				}

				dist = Math.sqrt(dist);
				dx /= dist;
				dy /= dist;

				manifold.pointCount = 1;
				manifold.nx = dx;
				manifold.ny = dy;

				cp = manifold.c0;

				cp.id.incEdge = 0xfe;
				cp.id.incVert = p.index + 1;
				cp.id.refFace = 0xfe;
				cp.id.flip    = 0;
				cp.id.bake();

				cp.x = cx - r * dx;
				cp.y = cy - r * dy;
				cp.sep = dist - r;
				return;
			}

			var u:Number = (cx - p.x) * ex + (cy - p.y) * ey;

			cp = manifold.c0;

			cp.id.refFace = 0xfe;
			cp.id.flip = 0;

			var px:Number, py:Number;
			if (u <= 0)
			{
				px = p.x;
				py = p.y;

				cp.id.incVert = p.index + 1;
				cp.id.incEdge = 0xfe;
			}
			else
			if (u >= edge.mag)
			{
				px = p.next.x;
				py = p.next.y;

				cp.id.incVert = p.next.index + 1;
				cp.id.incEdge = 0xfe;
			}
			else
			{
				px = ex * u + p.x;
				py = ey * u + p.y;

				cp.id.incVert = 0xfe;
				cp.id.incEdge = p.index + 1;
			}

			dx = cx - px;
			dy = cy - py;

			dist = dx * dx + dy * dy;
			if (dist > s2.radiusSq)
			{
				manifold.pointCount = 0;
				return;
			}
			dist = Math.sqrt(dist);
			dx /= dist;
			dy /= dist;

			manifold.pointCount = 1;
			manifold.nx = dx;
			manifold.ny = dy;

			cp.x = cx - s2.radius * dx;
			cp.y = cy - s2.radius * dy;
			cp.sep = dist - r;

			cp.id.bake();
		}
	}
}