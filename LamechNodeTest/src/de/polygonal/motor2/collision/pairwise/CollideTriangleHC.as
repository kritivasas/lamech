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
	import de.polygonal.motor2.dynamics.contact.generator.PolyContact;
	import de.polygonal.motor2.math.V2;	

	public class CollideTriangleHC implements Collider
	{
		public function collide(manifold:Manifold, s1:ShapeSkeleton, s2:ShapeSkeleton, contact:Contact):void
		{
			var c:PolyContact = PolyContact(contact);
			var p:V2, d:V2, s:V2, n:V2, smin:V2, smax:V2;
			var sep:Number = -2147483648, depth:Number, flip:int;
			
			var min0:Number, min1:Number;
			
			p = c.p;
			d = c.d;
			if (c.firstOut)
			{
				//shape1, d1
				s = s2.worldVertexChain;
				min0 = s.x * d.x + s.y * d.y; s = s.next;
				min1 = s.x * d.x + s.y * d.y;
				if (min1 < min0)
					s = (s.next.x * d.x + s.next.y * d.y < min1) ? s.next : s;
				else
					s = (s.next.x * d.x + s.next.y * d.y < min0) ? s.next : s.prev;
					
				depth = d.x * (s.x - p.x) + d.y * (s.y - p.y);
				if (depth > 0)
				{
					c.p = p;
					c.d = d;
					manifold.pointCount = 0;
					return;
				}

				if (depth * .95 + .01 > sep)
				{
					sep = depth;
					n = d;
					smax = p;
					smin = s;
				}
				
				p = p.next;
				d = d.next;
				
				//shape1, d2
				s = s2.worldVertexChain;
				min0 = s.x * d.x + s.y * d.y; s = s.next;
				min1 = s.x * d.x + s.y * d.y;
				if (min1 < min0)
					s = (s.next.x * d.x + s.next.y * d.y < min1) ? s.next : s;
				else
					s = (s.next.x * d.x + s.next.y * d.y < min0) ? s.next : s.prev;
				
				depth = d.x * (s.x - p.x) + d.y * (s.y - p.y);
				if (depth > 0)
				{
					c.p = p;
					c.d = d;
					manifold.pointCount = 0;
					return;
				}

				if (depth * .95 + .01 > sep)
				{
					sep = depth;
					n = d;
					smax = p;
					smin = s;
				}
				
				p = p.next;
				d = d.next;
				
				//shape1, d3
				s = s2.worldVertexChain;
				min0 = s.x * d.x + s.y * d.y; s = s.next;
				min1 = s.x * d.x + s.y * d.y;
				if (min1 < min0)
					s = (s.next.x * d.x + s.next.y * d.y < min1) ? s.next : s;
				else
					s = (s.next.x * d.x + s.next.y * d.y < min0) ? s.next : s.prev;
				
				depth = d.x * (s.x - p.x) + d.y * (s.y - p.y);
				if (depth > 0)
				{
					c.p = p;
					c.d = d;
					manifold.pointCount = 0;
					return;
				}

				if (depth * .95 + .01 > sep)
				{
					sep = depth;
					n = d;
					smax = p;
					smin = s;
				}
				
				p = s2.worldVertexChain;
				d = s2.worldNormalChain;
				
				//shape2, d1
				s = s1.worldVertexChain;
				min0 = s.x * d.x + s.y * d.y; s = s.next;
				min1 = s.x * d.x + s.y * d.y;
				if (min1 < min0)
					s = (s.next.x * d.x + s.next.y * d.y < min1) ? s.next : s;
				else
					s = (s.next.x * d.x + s.next.y * d.y < min0) ? s.next : s.prev;
				
				depth = d.x * (s.x - p.x) + d.y * (s.y - p.y);
				if (depth > 0)
				{
					c.p = p;
					c.d = d;
					c.firstOut = false;
					manifold.pointCount = 0;
					return;
				}

				if (depth * .95 + .01 > sep)
				{
					sep = depth;
					n = d;
					smax = p;
					smin = s;
					flip = 1;
				}
				
				p = p.next;
				d = d.next;
				
				//shape1, d2
				s = s1.worldVertexChain;
				min0 = s.x * d.x + s.y * d.y; s = s.next;
				min1 = s.x * d.x + s.y * d.y;
				if (min1 < min0)
					s = (s.next.x * d.x + s.next.y * d.y < min1) ? s.next : s;
				else
					s = (s.next.x * d.x + s.next.y * d.y < min0) ? s.next : s.prev;
				
				depth = d.x * (s.x - p.x) + d.y * (s.y - p.y);
				if (depth > 0)
				{
					c.p = p;
					c.d = d;
					c.firstOut = false;
					manifold.pointCount = 0;
					return;
				}

				if (depth * .95 + .01 > sep)
				{
					sep = depth;
					n = d;
					smax = p;
					smin = s;
					flip = 1;
				}
				
				p = p.next;
				d = d.next;
				
				//shape1, d3
				s = s1.worldVertexChain;
				min0 = s.x * d.x + s.y * d.y; s = s.next;
				min1 = s.x * d.x + s.y * d.y;
				if (min1 < min0)
					s = (s.next.x * d.x + s.next.y * d.y < min1) ? s.next : s;
				else
					s = (s.next.x * d.x + s.next.y * d.y < min0) ? s.next : s.prev;
				
				depth = d.x * (s.x - p.x) + d.y * (s.y - p.y);
				if (depth > 0)
				{
					c.p = p;
					c.d = d;
					c.firstOut = false;
					manifold.pointCount = 0;
					return;
				}

				if (depth * .95 + .01 > sep)
				{
					sep = depth;
					n = d;
					smax = p;
					smin = s;
					flip = 1;
				}
			}
			else
			{
				//shape2, d1
				s = s1.worldVertexChain;
				min0 = s.x * d.x + s.y * d.y; s = s.next;
				min1 = s.x * d.x + s.y * d.y;
				if (min1 < min0)
					s = (s.next.x * d.x + s.next.y * d.y < min1) ? s.next : s;
				else
					s = (s.next.x * d.x + s.next.y * d.y < min0) ? s.next : s.prev;
				
				depth = d.x * (s.x - p.x) + d.y * (s.y - p.y);
				if (depth > 0)
				{
					c.p = p;
					c.d = d;
					manifold.pointCount = 0;
					return;
				}

				if (depth * .95 + .01 > sep)
				{
					sep = depth;
					n = d;
					smax = p;
					smin = s;
					flip = 1;
				}
				
				p = p.next;
				d = d.next;
				
				//shape2, d2
				s = s1.worldVertexChain;
				min0 = s.x * d.x + s.y * d.y; s = s.next;
				min1 = s.x * d.x + s.y * d.y;
				if (min1 < min0)
					s = (s.next.x * d.x + s.next.y * d.y < min1) ? s.next : s;
				else
					s = (s.next.x * d.x + s.next.y * d.y < min0) ? s.next : s.prev;
				
				depth = d.x * (s.x - p.x) + d.y * (s.y - p.y);
				if (depth > 0)
				{
					c.p = p;
					c.d = d;
					manifold.pointCount = 0;
					return;
				}

				if (depth * .95 + .01 > sep)
				{
					sep = depth;
					n = d;
					smax = p;
					smin = s;
					flip = 1;
				}
				
				p = p.next;
				d = d.next;
				
				//shape2, d3
				s = s1.worldVertexChain;
				min0 = s.x * d.x + s.y * d.y; s = s.next;
				min1 = s.x * d.x + s.y * d.y;
				if (min1 < min0)
					s = (s.next.x * d.x + s.next.y * d.y < min1) ? s.next : s;
				else
					s = (s.next.x * d.x + s.next.y * d.y < min0) ? s.next : s.prev;
				
				depth = d.x * (s.x - p.x) + d.y * (s.y - p.y);
				if (depth > 0)
				{
					c.p = p;
					c.d = d;
					manifold.pointCount = 0;
					return;
				}

				if (depth * .95 + .01 > sep)
				{
					sep = depth;
					n = d;
					smax = p;
					smin = s;
					flip = 1;
				}
				
				p = s1.worldVertexChain;
				d = s1.worldNormalChain;
				
				//shape1, d1
				s = s2.worldVertexChain;
				min0 = s.x * d.x + s.y * d.y; s = s.next;
				min1 = s.x * d.x + s.y * d.y;
				if (min1 < min0)
					s = (s.next.x * d.x + s.next.y * d.y < min1) ? s.next : s;
				else
					s = (s.next.x * d.x + s.next.y * d.y < min0) ? s.next : s.prev;
				
				depth = d.x * (s.x - p.x) + d.y * (s.y - p.y);
				if (depth > 0)
				{
					c.p = p;
					c.d = d;
					c.firstOut = true;
					manifold.pointCount = 0;
					return;
				}

				if (depth * .95 + .01 > sep)
				{
					sep = depth;
					n = d;
					smax = p;
					smin = s;
					flip = 0;
				}
				
				p = p.next;
				d = d.next;
				
				//shape1, d2
				s = s2.worldVertexChain;
				min0 = s.x * d.x + s.y * d.y; s = s.next;
				min1 = s.x * d.x + s.y * d.y;
				if (min1 < min0)
					s = (s.next.x * d.x + s.next.y * d.y < min1) ? s.next : s;
				else
					s = (s.next.x * d.x + s.next.y * d.y < min0) ? s.next : s.prev;
				
				depth = d.x * (s.x - p.x) + d.y * (s.y - p.y);
				if (depth > 0)
				{
					c.p = p;
					c.d = d;
					c.firstOut = true;
					manifold.pointCount = 0;
					return;
				}

				if (depth * .95 + .01 > sep)
				{
					sep = depth;
					n = d;
					smax = p;
					smin = s;
					flip = 0;
				}
				
				p = p.next;
				d = d.next;
				
				//shape1, d3
				s = s2.worldVertexChain;
				min0 = s.x * d.x + s.y * d.y; s = s.next;
				min1 = s.x * d.x + s.y * d.y;
				if (min1 < min0)
					s = (s.next.x * d.x + s.next.y * d.y < min1) ? s.next : s;
				else
					s = (s.next.x * d.x + s.next.y * d.y < min0) ? s.next : s.prev;
				
				depth = d.x * (s.x - p.x) + d.y * (s.y - p.y);
				if (depth > 0)
				{
					c.p = p;
					c.d = d;
					c.firstOut = true;
					manifold.pointCount = 0;
					return;
				}

				if (depth * .95 + .01 > sep)
				{
					sep = depth;
					n = d;
					smax = p;
					smin = s;
					flip = 0;
				}
			}

			var refShape:ShapeSkeleton = flip ? s2 : s1;
			var nx:Number = n.x;
			var ny:Number = n.y;

			var refFace:int = smax.index;
			var incVert:int = smin.index;
			var incEdge:int;

			var incFaceNormal:V2 = smin.edge.n;

			var min:Number = incFaceNormal.x * nx + incFaceNormal.y * ny;
			if ((incFaceNormal.prev.x * nx + incFaceNormal.prev.y * ny) < min)
			{
				smin = smin.prev;
				incEdge = incFaceNormal.prev.index;
			}
			else
			if (incFaceNormal.next.x * nx + incFaceNormal.next.y * ny < min)
			{
				smin = smin.next;
				incEdge = incFaceNormal.next.index;
			}

			//clip incident edge against reference face side planes. this
			//basically clips an edge againt the face's voronoi planes.
			var front:Number = (refShape.x * nx + refShape.y * ny) + ((smax.x - refShape.x) * nx + (smax.y - refShape.y) * ny);

			var side:Number;
			if (refShape.regularShape)
				side = refShape.y * nx - refShape.x * ny;
			else
			{
				var offset:V2 = refShape.offsets[smax.index];
				side = (refShape.y + refShape.r21 * offset.x + refShape.r22 * offset.y) * nx -
				       (refShape.x + refShape.r11 * offset.x + refShape.r12 * offset.y) * ny;
			}
			var edgeExt:Number = smax.edge.mag / 2;

			var cv0x:Number, cv1x:Number;
			var cv0y:Number, cv1y:Number;

			var dist0:Number, dist1:Number, interp:Number;

			dist0 = smin.x      * ny - smin.y      * nx + side - edgeExt;
			dist1 = smin.next.x * ny - smin.next.y * nx + side - edgeExt;
			if (dist0 * dist1 < 0)
			{
				interp = dist0 / (dist0 - dist1);
				if (dist0 < 0)
				{
					cv0x = smin.x;
					cv0y = smin.y;
					cv1x = cv0x + interp * (smin.next.x - cv0x);
					cv1y = cv0y + interp * (smin.next.y - cv0y);
				}
				else
				{
					cv0x = smin.next.x;
					cv0y = smin.next.y;
					cv1x = smin.x + interp * (cv0x - smin.x);
					cv1y = smin.y + interp * (cv0y - smin.y);
				}
			}
			else
			{
				if (dist0 > 0)
				{
					manifold.pointCount = 0;
					return;
				}

				if (dist0 < dist1)
				{
					cv0x = smin.x;
					cv0y = smin.y;
					cv1x = smin.next.x;
					cv1y = smin.next.y;
				}
				else
				{
					cv1x = smin.x;
					cv1y = smin.y;
					cv0x = smin.next.x;
					cv0y = smin.next.y;
				}
			}
			dist0 = cv0y * nx - side - edgeExt - cv0x * ny;
			dist1 = cv1y * nx - side - edgeExt - cv1x * ny;
			if (dist0 * dist1 < 0)
			{
				interp = dist0 / (dist0 - dist1);
				cv0x = cv0x + interp * (cv1x - cv0x);
				cv0y = cv0y + interp * (cv1y - cv0y);
			}
			else
			{
				if (dist0 > 0)
				{
					manifold.pointCount = 0;
					return;
				}
			}

			//output contact manifold:
			//cv0 and cv1 are potential clipping points, due to roundoff, it is
			//possible that clipping removes all points.
			var cp:ContactPoint;
			sep = nx * cv0x + ny * cv0y - front;

			if (sep <= 0)
			{
				manifold.pointCount = 1;

				if (flip)
				{
					manifold.nx =-nx;
					manifold.ny =-ny;
				}
				else
				{
					manifold.nx = nx;
					manifold.ny = ny;
				}

				cp = manifold.c0;
				cp.sep = sep;
				cp.x   = cv0x;
				cp.y   = cv0y;

				cp.id.flip    = flip;
				cp.id.incEdge = incEdge;
				cp.id.incVert = incVert;
				cp.id.refFace = refFace;
				cp.id.bake();

				sep = nx * cv1x + ny * cv1y - front;
				if (sep <= 0)
				{
					manifold.pointCount = 2;

					cp = manifold.c1;
					cp.sep = sep;
					cp.x   = cv1x;
					cp.y   = cv1y;

					cp.id.flip    = flip;
					cp.id.incEdge = incEdge;
					cp.id.incVert = incVert;
					cp.id.refFace = refFace;
					cp.id.bake();
				}
			}
			else
			{
				sep = nx * cv1x + ny * cv1y - front;
				if (sep <= 0)
				{
					manifold.pointCount = 1;
					if (flip)
					{
						manifold.nx =-nx;
						manifold.ny =-ny;
					}
					else
					{
						manifold.nx = nx;
						manifold.ny = ny;
					}

					cp = manifold.c0;
					cp.sep = sep;
					cp.x   = cv1x;
					cp.y   = cv1y;

					cp.id.flip    = flip;
					cp.id.incEdge = incEdge;
					cp.id.incVert = incVert;
					cp.id.refFace = refFace;
					cp.id.bake();
				}
			}
		}
	}
}