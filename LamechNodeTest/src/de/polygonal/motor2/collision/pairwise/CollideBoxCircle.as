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
	import de.polygonal.motor2.dynamics.contact.generator.BoxCircleContact;
	import de.polygonal.motor2.math.V2;

	/** @private */
	public class CollideBoxCircle implements Collider
	{
		public function collide(manifold:Manifold, s1:ShapeSkeleton, s2:ShapeSkeleton, contact:Contact):void
		{
			var sep:Number, mag:Number;
			var dx:Number;
			var dy:Number;
			var cp:ContactPoint;
			var nf:int = ContactID.NULL_FEATURE;

			if (manifold.pointCount == 1)
			{
				//closest point features

				var incVert:int = nf;
				var incEdgeAndRefFace:int = nf;

				var qx:Number = s1.x;
				var qy:Number = s1.y;
				var vx:Number = s2.x - s1.x;
				var vy:Number = s2.y - s1.y;

				var sqDist:Number = 0;
				var excess:Number = 0;
				var d:Number = vx * s1.r11 + vy * s1.r21;
				if (d < -s1.ex)
				{
					excess = d + s1.ex;
					d =-s1.ex;
					incVert = incEdgeAndRefFace = 1 + 1;
				}
				else
				if (d > s1.ex)
				{
					excess = d - s1.ex;
					d = s1.ex;
					incVert = incEdgeAndRefFace = 3 + 1;
				}

				qx += s1.r11 * d;
				qy += s1.r21 * d;
				sqDist += excess * excess;

				excess = 0;
				d = vx * s1.r12 + vy * s1.r22;
				if (d < -s1.ey)
				{
					excess = d + s1.ey;
					d =-s1.ey;

					incEdgeAndRefFace = nf;

					if (incVert == 1 + 1)
						incVert = 2 + 1;
					else
					if (incVert == nf)
						incEdgeAndRefFace = 2 + 1;
				}
				else
				if (d > s1.ey)
				{
					excess = d - s1.ey;
					d = s1.ey;

					incEdgeAndRefFace = nf;

					if (incVert == 3 + 1)
						incVert = 0 + 1;
					else
					if (incVert == nf)
						incEdgeAndRefFace = 0 + 1;
				}
				else
					incVert = nf;

				qx += s1.r12 * d;
				qy += s1.r22 * d;

				sep = sqDist + excess * excess;
				if (sep >= s2.radiusSq)
				{
					manifold.pointCount = 0;
					return;
				}

				manifold.pointCount = 1;
				cp = manifold.c0;
				cp.id.refFace = nf;
				cp.id.flip = 0;

				if (sep == 0)
				{
					cp.id.incVert = nf;

					//point inside obb
					dx = (vx * s1.r11 + vy * s1.r21);
					dy = (vx * s1.r12 + vy * s1.r22);

					if (dx > 0)
					{
						if (dy > 0)
						{
							if (s1.ex - dx < s1.ey - dy)
							{
								manifold.nx = s1.r11;
								manifold.ny = s1.r21;
								cp.sep = s2.radius + s1.ex - dx;
								cp.id.incEdge = 3;
							}
							else
							{
								manifold.nx = s1.r12;
								manifold.ny = s1.r22;
								cp.sep = s2.radius + s1.ey - dy;
								cp.id.incEdge = 0;
							}
						}
						else
						{
							if (s1.ex - dx < s1.ey + dy)
							{
								manifold.nx = s1.r11;
								manifold.ny = s1.r21;
								cp.sep = s2.radius + s1.ex - dx;
								cp.id.incEdge = 3;
							}
							else
							{
								manifold.nx = -s1.r12;
								manifold.ny = -s1.r22;
								cp.sep = s2.radius + s1.ey + dy;
								cp.id.incEdge = 2;
							}
						}
					}
					else
					{
						if (dy > 0)
						{
							if (s1.ex + dx < s1.ey - dy)
							{
								manifold.nx =-s1.r11;
								manifold.ny =-s1.r21;
								cp.sep = s2.radius + s1.ex + dx;
								cp.id.incEdge = 1;
							}
							else
							{
								manifold.nx = s1.r12;
								manifold.ny = s1.r22;
								cp.sep = s2.radius + s1.ey - dy;
								cp.id.incEdge = 0;
							}
						}
						else
						{
							if (s1.ex + dx < s1.ey + dy)
							{
								manifold.nx =-s1.r11;
								manifold.ny =-s1.r21;
								cp.sep = s2.radius + s1.ex + dx;
								cp.id.incEdge = 1;
							}
							else
							{
								manifold.nx = -s1.r12;
								manifold.ny = -s1.r22;
								cp.sep = s2.radius + s1.ey + dy;
								cp.id.incEdge = 2;
							}
						}
					}

					cp.sep = -cp.sep;
				}
				else
				{
					dx = s2.x - qx;
					dy = s2.y - qy;
					mag = Math.sqrt(dx * dx + dy * dy);
					manifold.nx = dx / mag;
					manifold.ny = dy / mag;

					cp.id.incVert = incVert;
					cp.id.incEdge = incEdgeAndRefFace;

					cp.sep = -(s2.radius - Math.sqrt(sep));
				}

				cp.x = s2.x - s2.radius * manifold.nx;
				cp.y = s2.y - s2.radius * manifold.ny;

				cp.id.bake();
			}
			else
			{
				//separating-axis test

				var mv:V2, mn:V2, N:V2, p:V2;
				var cx:Number = s2.x;
				var cy:Number = s2.y;
				var s:Number, r:Number = s2.radius;
				sep = -2147483648;

				var c:BoxCircleContact = BoxCircleContact(contact);

				mv = c.p;
				mn = c.d;
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

				mv = mv.next;
				mn = mn.next;
				s = mn.x * (cx - mv.x) + mn.y * (cy - mv.y);
				if (s > r)
				{
					c.p = mv;
					c.d = mn;
					manifold.pointCount = 0;
					return;
				}
				if (s > sep)
				{
					sep = s;
					N = mn;
					p = mv;
				}

				mv = mv.next;
				mn = mn.next;
				s = mn.x * (cx - mv.x) + mn.y * (cy - mv.y);
				if (s > r)
				{
					c.p = mv;
					c.d = mn;
					manifold.pointCount = 0;
					return;
				}
				if (s > sep)
				{
					sep = s;
					N = mn;
					p = mv;
				}

				mv = mv.next;
				mn = mn.next;
				s = mn.x * (cx - mv.x) + mn.y * (cy - mv.y);
				if (s > r)
				{
					c.p = mv;
					c.d = mn;
					manifold.pointCount = 0;
					return;
				}
				if (s > sep)
				{
					sep = s;
					N = mn;
					p = mv;
				}

				if (sep < 1e-6)
				{
					//point inside obb
					manifold.pointCount = 1;
					manifold.nx = N.x;
					manifold.ny = N.y;

					cp = manifold.c0;
					cp.id.incEdge = N.index;
					cp.id.incVert = nf;
					cp.id.refFace = nf;
					cp.id.flip = 0;
					cp.id.bake();

					cp.x = cx - r * manifold.nx;
					cp.y = cy - r * manifold.ny;
					cp.sep = sep - r;
					return;
				}

				var ex:Number;
				var ey:Number;

				var i:int = p.index;
				if (i == 0)
				{
					mag = s1.ex * 2;
					ex = -s1.r11;
					ey = -s1.r21;
				}
				else
				if (i == 1)
				{
					ex = -s1.r12;
					ey = -s1.r22;
					mag = s1.ey * 2;
				}
				else
				if (i == 2)
				{
					ex = s1.r11;
					ey = s1.r21;
					mag = s1.ex * 2;
				}
				else
				if (i == 3)
				{
					ex = s1.r12;
					ey = s1.r22;
					mag = s1.ey * 2;
				}

				var dist:Number;

				if (mag < 1e-6)
				{
					dx = cx - p.x;
					dy = cy - p.y;

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

					cp = manifold.c0;
					cp.id.incVert = i + 1;
					cp.id.incEdge = nf;
					cp.id.refFace = nf;
					cp.id.flip = 0;
					cp.id.bake();

					cp.x = cx - s2.radius * dx;
					cp.y = cy - s2.radius * dy;
					cp.sep = dist - r;
					return;
				}

				cp = manifold.c0;
				cp.id.flip = 0;
				cp.id.refFace = nf;

				var px:Number, py:Number;
				var u:Number = (cx - p.x) * ex + (cy - p.y) * ey;
				if (u <= 0)
				{
					px = p.x;
					py = p.y;

					cp.id.incVert = p.index;
					cp.id.incEdge = nf;
				}
				else
				if (u >= mag)
				{
					px = p.next.x;
					py = p.next.y;

					cp.id.incVert = p.next.index;
					cp.id.incEdge = nf;
				}
				else
				{
					px = ex * u + p.x;
					py = ey * u + p.y;

					cp.id.incVert = nf;
					cp.id.incEdge = p.index;
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

				cp.x = cx - r * dx;
				cp.y = cy - r * dy;
				cp.sep = dist - r;

				cp.id.bake();
			}
		}
	}
}