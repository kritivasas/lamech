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
	import de.polygonal.motor2.dynamics.contact.ContactPoint;
	import de.polygonal.motor2.dynamics.contact.Manifold;
	import de.polygonal.motor2.dynamics.contact.generator.BoxContact;

	/**
	 * Homogenous SAT obb collision detection.
	 *
	 * <ul><li>the separation distance is computed by applying weightings to
	 * prefer one axis over another. the factor 1.05 requires a 5% increase and
	 * 0.01 guards against very small separation magnitudes.
	 * (ERIN - improved coherence).</li>
	 * <li>collision normal: reference shape ---> incident shape</li>
	 * </ul>
	 *
	 * <pre>
	 *        ^ FACE_Y (s1: 1, s2: 3)
	 *        |
	 *        e3
	 *   v2 ------ v3
	 *    |        |
	 * e2 |   CW   | e4  --> FACE_X (s1: 0, s2: 2)
	 *    |        |
	 *   v1 ------ v0
	 *        e1
	 * </pre>
	 *
	 * @private
	 */
	public class CollideBox implements Collider
	{
		/**
		 * Check if two oriented bounding boxes intersect and generate a contact
		 * manifold.
		 *
		 * @see de.polygonal.motor2.collision.shapes.BoxShape
		 *
		 * @param manifold The resulting contact manifold.
		 * @param s1       Shape one (a BoxShape instance).
		 * @param s2       Shape two (a BoxShape instance).
		 * @param contact  A contact object used for reading/writing hints.
		 */
		public function collide(manifold:Manifold, s1:ShapeSkeleton, s2:ShapeSkeleton, contact:Contact):void
		{
			var c:BoxContact = BoxContact(contact);

			var ncollx:Number, ncolly:Number;
			var d:Number, sep:Number, minSep:Number, sepAxisId:int;
			var dx:Number = s2.x - s1.x;
			var dy:Number = s2.y - s1.y;

			var c11:Number, c21:Number;
			var c12:Number, c22:Number;

			var refFace:int;
			var incVert:int;
			var incEdge:int;

			//separating-axis test
			//take the sep-axis hint from the last time step
			//as the potential separation axis. if it's overlapping
			//process with all remaining axis.
			sepAxisId = c.sepAxisId;

			/* check axis 0, 1, 2, 3 */
			if (sepAxisId == 0)
			{
				c11 = s1.r11 * s2.r11 + s1.r21 * s2.r21; if (c11 < 0) c11 = -c11;
				c12 = s1.r11 * s2.r12 + s1.r21 * s2.r22; if (c12 < 0) c12 = -c12;

				/* shape1, x-axis (0) */

				d = s1.r11 * dx + s1.r21 * dy;
				if (d > 0)
				{
					sep = d - s1.ex - (c11 * s2.ex + c12 * s2.ey);
					if (sep > 0)
					{
						manifold.pointCount = 0;
						return;
					}
					ncollx = s1.r11;
					ncolly = s1.r21;
					refFace = 3;
				}
				else
				{
					sep =-d - s1.ex - (c11 * s2.ex + c12 * s2.ey);
					if (sep > 0)
					{
						manifold.pointCount = 0;
						return;
					}
					ncollx =-s1.r11;
					ncolly =-s1.r21;
					refFace = 1;
				}

				minSep = sep;

				c22 = s1.r12 * s2.r12 + s1.r22 * s2.r22; if (c22 < 0) c22 = -c22;
				c21 = s1.r12 * s2.r11 + s1.r22 * s2.r21; if (c21 < 0) c21 = -c21;

				/* shape1, y-axis (1) */

				d = s1.r12 * dx + s1.r22 * dy;
				if (d > 0)
				{
					sep = d - s1.ey - (c21 * s2.ex + c22 * s2.ey);
					if (sep > 0)
					{
						c.sepAxisId   = 1;
						manifold.pointCount = 0;
						return;
					}
					if (sep > .95 * minSep + .01 * s1.ey)
					{
						sepAxisId = 1;
						minSep = sep;
						ncollx = s1.r12;
						ncolly = s1.r22;
						refFace = 0;
					}
				}
				else
				{
					sep =-d - s1.ey - (c21 * s2.ex + c22 * s2.ey);
					if (sep > 0)
					{
						c.sepAxisId   = 1;
						manifold.pointCount = 0;
						return;
					}
					if (sep > .95 * minSep + .01 * s1.ey)
					{
						sepAxisId = 1;
						minSep = sep;
						ncollx =-s1.r12;
						ncolly =-s1.r22;
						refFace = 2;
					}
				}

				/* shape2, x-axis (2) */

				d = s2.r11 * dx + s2.r21 * dy;
				if (d > 0)
				{
					sep = d - (c11 * s1.ex + c21 * s1.ey) - s2.ex;
					if (sep > 0)
					{
						c.sepAxisId   = 2;
						manifold.pointCount = 0;
						return;
					}
					if (sep > .95 * minSep + .01 * s2.ex)
					{
						sepAxisId = 2;
						minSep = sep;
						ncollx = s2.r11;
						ncolly = s2.r21;
						refFace = 1;
					}
				}
				else
				{
					sep =-d - (c11 * s1.ex + c21 * s1.ey) - s2.ex;
					if (sep > 0)
					{
						c.sepAxisId   = 2;
						manifold.pointCount = 0;
						return;
					}
					if (sep > .95 * minSep + .01 * s2.ex)
					{
						sepAxisId = 2;
						minSep = sep;
						ncollx =-s2.r11;
						ncolly =-s2.r21;
						refFace = 3;
					}
				}

				/* shape2, y-axis (3) */

				d = s2.r12 * dx + s2.r22 * dy;
				if (d > 0)
				{
					sep = d - (c12 * s1.ex + c22 * s1.ey) - s2.ey;
					if (sep > 0)
					{
						c.sepAxisId   = 3;
						manifold.pointCount = 0;
						return;
					}
					if (sep > .95 * minSep + .01 * s2.ey)
					{
						sepAxisId = 3;
						minSep = sep;
						ncollx = s2.r12;
						ncolly = s2.r22;
						refFace = 2;
					}
				}
				else
				{
					sep =-d - (c12 * s1.ex + c22 * s1.ey) - s2.ey;
					if (sep > 0)
					{
						c.sepAxisId   = 3;
						manifold.pointCount = 0;
						return;
					}
					if (sep > .95 * minSep + .01 * s2.ey)
					{
						sepAxisId = 3;
						minSep = sep;
						ncollx =-s2.r12;
						ncolly =-s2.r22;
						refFace = 0;
					}
				}
			}
			else
			/* check axis 1, 0, 2, 3 */
			if (sepAxisId == 1)
			{
				c22 = s1.r12 * s2.r12 + s1.r22 * s2.r22; if (c22 < 0) c22 = -c22;
				c21 = s1.r12 * s2.r11 + s1.r22 * s2.r21; if (c21 < 0) c21 = -c21;

				/* shape1, y-axis (1) */

				d = s1.r12 * dx + s1.r22 * dy;
				if (d > 0)
				{
					sep = d - s1.ey - (c21 * s2.ex + c22 * s2.ey);
					if (sep > 0)
					{
						manifold.pointCount = 0;
						return;
					}
					ncollx = s1.r12;
					ncolly = s1.r22;
					refFace = 0;
				}
				else
				{
					sep =-d - s1.ey - (c21 * s2.ex + c22 * s2.ey);
					if (sep > 0)
					{
						manifold.pointCount = 0;
						return;
					}
					ncollx =-s1.r12;
					ncolly =-s1.r22;
					refFace = 2;
				}

				minSep = sep;

				c11 = s1.r11 * s2.r11 + s1.r21 * s2.r21; if (c11 < 0) c11 = -c11;
				c12 = s1.r11 * s2.r12 + s1.r21 * s2.r22; if (c12 < 0) c12 = -c12;

				/* shape1, x-axis (0) */

				d = s1.r11 * dx + s1.r21 * dy;
				if (d > 0)
				{
					sep = d - s1.ex - (c11 * s2.ex + c12 * s2.ey);
					if (sep > 0)
					{
						c.sepAxisId   = 0;
						manifold.pointCount = 0;
						return;
					}
					if (sep > .95 * minSep + .01 * s1.ex)
					{
						sepAxisId = 0;
						minSep = sep;
						ncollx = s1.r11;
						ncolly = s1.r21;
						refFace = 3;
					}
				}
				else
				{
					sep =-d - s1.ex - (c11 * s2.ex + c12 * s2.ey);
					if (sep > 0)
					{
						c.sepAxisId   = 0;
						manifold.pointCount = 0;
						return;
					}
					if (sep > .95 * minSep + .01 * s1.ex)
					{
						sepAxisId = 0;
						minSep = sep;
						ncollx =-s1.r11;
						ncolly =-s1.r21;
						refFace = 1;
					}
				}

				/* shape2, x-axis (2) */

				d = s2.r11 * dx + s2.r21 * dy;
				if (d > 0)
				{
					sep = d - (c11 * s1.ex + c21 * s1.ey) - s2.ex;
					if (sep > 0)
					{
						c.sepAxisId   = 2;
						manifold.pointCount = 0;
						return;
					}
					if (sep > .95 * minSep + .01 * s2.ex)
					{
						sepAxisId = 2;
						minSep = sep;
						ncollx = s2.r11;
						ncolly = s2.r21;
						refFace = 1;
					}
				}
				else
				{
					sep =-d - (c11 * s1.ex + c21 * s1.ey) - s2.ex;
					if (sep > 0)
					{
						c.sepAxisId   = 2;
						manifold.pointCount = 0;
						return;
					}
					if (sep > .95 * minSep + .01 * s2.ex)
					{
						sepAxisId = 2;
						minSep = sep;
						ncollx =-s2.r11;
						ncolly =-s2.r21;
						refFace = 3;
					}
				}

				/* shape2, y-axis (3) */

				d = s2.r12 * dx + s2.r22 * dy;
				if (d > 0)
				{
					sep = d - (c12 * s1.ex + c22 * s1.ey) - s2.ey;
					if (sep > 0)
					{
						c.sepAxisId   = 3;
						manifold.pointCount = 0;
						return;
					}
					if (sep > .95 * minSep + .01 * s2.ey)
					{
						sepAxisId = 3;
						minSep = sep;
						ncollx = s2.r12;
						ncolly = s2.r22;
						refFace = 2;
					}
				}
				else
				{
					sep =-d - (c12 * s1.ex + c22 * s1.ey) - s2.ey;
					if (sep > 0)
					{
						c.sepAxisId   = 3;
						manifold.pointCount = 0;
						return;
					}
					if (sep > .95 * minSep + .01 * s2.ey)
					{
						sepAxisId = 3;
						minSep = sep;
						ncollx =-s2.r12;
						ncolly =-s2.r22;
						refFace = 0;
					}
				}
			}
			else
			/* check axis 2, 0, 1, 3 */
			if (sepAxisId == 2)
			{
				/* shape2, x-axis (2) */

				c11 = s1.r11 * s2.r11 + s1.r21 * s2.r21; if (c11 < 0) c11 = -c11;
				c21 = s1.r12 * s2.r11 + s1.r22 * s2.r21; if (c21 < 0) c21 = -c21;

				d = s2.r11 * dx + s2.r21 * dy;
				if (d > 0)
				{
					sep = d - (c11 * s1.ex + c21 * s1.ey) - s2.ex;
					if (sep > 0)
					{
						manifold.pointCount = 0;
						return;
					}
					ncollx = s2.r11;
					ncolly = s2.r21;
					refFace = 1;
				}
				else
				{
					sep =-d - (c11 * s1.ex + c21 * s1.ey) - s2.ex;
					if (sep > 0)
					{
						manifold.pointCount = 0;
						return;
					}
					ncollx =-s2.r11;
					ncolly =-s2.r21;
					refFace = 3;
				}

				minSep = sep;

				c12 = s1.r11 * s2.r12 + s1.r21 * s2.r22; if (c12 < 0) c12 = -c12;
				c22 = s1.r12 * s2.r12 + s1.r22 * s2.r22; if (c22 < 0) c22 = -c22;

				/* shape1, x-axis (0) */

				d = s1.r11 * dx + s1.r21 * dy;
				if (d > 0)
				{
					sep = d - s1.ex - (c11 * s2.ex + c12 * s2.ey);
					if (sep > 0)
					{
						c.sepAxisId   = 0;
						manifold.pointCount = 0;
						return;
					}
					if (sep > .95 * minSep + .01 * s1.ex)
					{
						sepAxisId = 0;
						minSep = sep;
						ncollx = s1.r11;
						ncolly = s1.r21;
						refFace = 3;
					}
				}
				else
				{
					sep =-d - s1.ex - (c11 * s2.ex + c12 * s2.ey);
					if (sep > 0)
					{
						c.sepAxisId   = 0;
						manifold.pointCount = 0;
						return;
					}
					if (sep > .95 * minSep + .01 * s1.ex)
					{
						sepAxisId = 0;
						minSep = sep;
						ncollx =-s1.r11;
						ncolly =-s1.r21;
						refFace = 1;
					}
				}

				/* shape1, y-axis (1) */

				d = s1.r12 * dx + s1.r22 * dy;
				if (d > 0)
				{
					sep = d - s1.ey - (c21 * s2.ex + c22 * s2.ey);
					if (sep > 0)
					{
						c.sepAxisId   = 1;
						manifold.pointCount = 0;
						return;
					}
					if (sep > .95 * minSep + .01 * s1.ey)
					{
						sepAxisId = 1;
						minSep = sep;
						ncollx = s1.r12;
						ncolly = s1.r22;
						refFace = 0;
					}
				}
				else
				{
					sep =-d - s1.ey - (c21 * s2.ex + c22 * s2.ey);
					if (sep > 0)
					{
						c.sepAxisId   = 1;
						manifold.pointCount = 0;
						return;
					}
					if (sep > .95 * minSep + .01 * s1.ey)
					{
						sepAxisId = 1;
						minSep = sep;
						ncollx =-s1.r12;
						ncolly =-s1.r22;
						refFace = 2;
					}
				}

				/* shape2, y-axis (3) */

				d = s2.r12 * dx + s2.r22 * dy;
				if (d > 0)
				{
					sep = d - (c12 * s1.ex + c22 * s1.ey) - s2.ey;
					if (sep > 0)
					{
						c.sepAxisId   = 3;
						manifold.pointCount = 0;
						return;
					}
					if (sep > .95 * minSep + .01 * s2.ey)
					{
						sepAxisId = 3;
						minSep = sep;
						ncollx = s2.r12;
						ncolly = s2.r22;
						refFace = 2;
					}
				}
				else
				{
					sep =-d - (c12 * s1.ex + c22 * s1.ey) - s2.ey;
					if (sep > 0)
					{
						c.sepAxisId   = 3;
						manifold.pointCount = 0;
						return;
					}
					if (sep > .95 * minSep + .01 * s2.ey)
					{
						sepAxisId = 3;
						minSep = sep;
						ncollx =-s2.r12;
						ncolly =-s2.r22;
						refFace = 0;
					}
				}
			}
			else
			/* check axis 3, 0, 1, 2 */
			if (sepAxisId == 3)
			{
				c12 = s1.r11 * s2.r12 + s1.r21 * s2.r22; if (c12 < 0) c12 = -c12;
				c22 = s1.r12 * s2.r12 + s1.r22 * s2.r22; if (c22 < 0) c22 = -c22;

				/* shape2, y-axis (3) */

				d = s2.r12 * dx + s2.r22 * dy;
				if (d > 0)
				{
					sep = d - (c12 * s1.ex + c22 * s1.ey) - s2.ey;
					if (sep > 0)
					{
						manifold.pointCount = 0;
						return;
					}
					ncollx = s2.r12;
					ncolly = s2.r22;
					refFace = 2;
				}
				else
				{
					sep =-d - (c12 * s1.ex + c22 * s1.ey) - s2.ey;
					if (sep > 0)
					{
						manifold.pointCount = 0;
						return;
					}
					ncollx =-s2.r12;
					ncolly =-s2.r22;
					refFace = 0;
				}

				minSep = sep;

				c11 = s1.r11 * s2.r11 + s1.r21 * s2.r21; if (c11 < 0) c11 = -c11;
				c21 = s1.r12 * s2.r11 + s1.r22 * s2.r21; if (c21 < 0) c21 = -c21;

				/* shape1, x-axis (0) */

				d = s1.r11 * dx + s1.r21 * dy;
				if (d > 0)
				{
					sep = d - s1.ex - (c11 * s2.ex + c12 * s2.ey);
					if (sep > 0)
					{
						c.sepAxisId   = 0;
						manifold.pointCount = 0;
						return;
					}
					if (sep > .95 * minSep + .01 * s1.ex)
					{
						sepAxisId = 0;
						minSep = sep;
						ncollx = s1.r11;
						ncolly = s1.r21;
						refFace = 3;
					}
				}
				else
				{
					sep =-d - s1.ex - (c11 * s2.ex + c12 * s2.ey);
					if (sep > 0)
					{
						c.sepAxisId   = 0;
						manifold.pointCount = 0;
						return;
					}
					if (sep > .95 * minSep + .01 * s1.ex)
					{
						sepAxisId = 0;
						minSep = sep;
						ncollx =-s1.r11;
						ncolly =-s1.r21;
						refFace = 1;
					}
				}

				/* shape1, y-axis (1) */

				d = s1.r12 * dx + s1.r22 * dy;
				if (d > 0)
				{
					sep = d - s1.ey - (c21 * s2.ex + c22 * s2.ey);
					if (sep > 0)
					{
						c.sepAxisId   = 1;
						manifold.pointCount = 0;
						return;
					}
					if (sep > .95 * minSep + .01 * s1.ey)
					{
						sepAxisId = 1;
						minSep = sep;
						ncollx = s1.r12;
						ncolly = s1.r22;
						refFace = 0;
					}
				}
				else
				{
					sep =-d - s1.ey - (c21 * s2.ex + c22 * s2.ey);
					if (sep > 0)
					{
						c.sepAxisId   = 1;
						manifold.pointCount = 0;
						return;
					}
					if (sep > .95 * minSep + .01 * s1.ey)
					{
						sepAxisId = 1;
						minSep = sep;
						ncollx =-s1.r12;
						ncolly =-s1.r22;
						refFace = 2;
					}
				}

				/* shape2, x-axis (2) */

				d = s2.r11 * dx + s2.r21 * dy;
				if (d > 0)
				{
					sep = d - (c11 * s1.ex + c21 * s1.ey) - s2.ex;
					if (sep > 0)
					{
						c.sepAxisId   = 2;
						manifold.pointCount = 0;
						return;
					}
					if (sep > .95 * minSep + .01 * s2.ex)
					{
						sepAxisId = 2;
						minSep = sep;
						ncollx = s2.r11;
						ncolly = s2.r21;
						refFace = 1;
					}
				}
				else
				{
					sep =-d - (c11 * s1.ex + c21 * s1.ey) - s2.ex;
					if (sep > 0)
					{
						c.sepAxisId   = 2;
						manifold.pointCount = 0;
						return;
					}
					if (sep > .95 * minSep + .01 * s2.ex)
					{
						sepAxisId = 2;
						minSep = sep;
						ncollx =-s2.r11;
						ncolly =-s2.r21;
						refFace = 3;
					}
				}
			}

			//compute clipping planes (reference face side planes)
			var incShape:ShapeSkeleton;
			var front:Number, side:Number, negSide:Number, posSide:Number;
			var sideNormalx:Number, sideNormaly:Number;
			var negEdge:int, posEdge:int, flip:int;

			if (sepAxisId == 0)
			{
				incShape = s2;

				front = s1.x * ncollx + s1.y * ncolly + s1.ex;
				side  = s1.x * (sideNormalx = s1.r12) + s1.y * (sideNormaly = s1.r22);

				negSide = -side + s1.ey; negEdge = 1;
				posSide =  side + s1.ey; posEdge = 3;
			}
			else
			if (sepAxisId == 1)
			{
				incShape = s2;

				front = s1.x * ncollx + s1.y * ncolly + s1.ey;
				side  = s1.x * (sideNormalx = s1.r11) + s1.y * (sideNormaly = s1.r21);

				negSide = -side + s1.ex; negEdge = 2;
				posSide =  side + s1.ex; posEdge = 4;
			}
			else
			if (sepAxisId == 2)
			{
				incShape = s1;
				flip = 1;

				ncollx =-ncollx;
				ncolly =-ncolly;

				front = s2.x * ncollx + s2.y * ncolly + s2.ex;
				side  = s2.x * (sideNormalx = s2.r12) + s2.y * (sideNormaly = s2.r22);

				negSide = -side + s2.ey; negEdge = 1;
				posSide =  side + s2.ey; posEdge = 3;
			}
			else
			if (sepAxisId == 3)
			{
				incShape = s1;
				flip = 1;

				ncollx =-ncollx;
				ncolly =-ncolly;

				front = s2.x * ncollx + s2.y * ncolly + s2.ey;
				side  = s2.x * (sideNormalx = s2.r11) + s2.y * (sideNormaly = s2.r21);

				negSide = -side + s2.ex; negEdge = 2;
				posSide =  side + s2.ex; posEdge = 4;
			}

			//find incident edge
			var e0x:Number, e1x:Number;
			var e0y:Number, e1y:Number;

			//convert front normal to incident shape's local space
			//and flip sign rotT * (-N)
			var nx:Number = -incShape.r11 * ncollx - incShape.r21 * ncolly;
			var ny:Number = -incShape.r12 * ncollx - incShape.r22 * ncolly;

			if ((nx < 0 ? -nx : nx) > (ny < 0 ? -ny : ny))
			{
				if (nx > 0)
				{
					e0x = incShape.ex;
					e0y =-incShape.ey;
					e1x = incShape.ex;
					e1y = incShape.ey;
					if (ny > 0)
					{
						incVert = 0;
						incEdge = 3;
					}
					else
					{
						incVert = 3;
						incEdge = 0;
					}
				}
				else
				{
					e0x =-incShape.ex;
					e0y = incShape.ey;
					e1x =-incShape.ex;
					e1y =-incShape.ey;
					if (ny > 0)
					{
						incVert = 1;
						incEdge = 2;
					}
					else
					{
						incVert = 2;
						incEdge = 1;
					}
				}
			}
			else
			{
				if (ny > 0)
				{
					e0x = incShape.ex;
					e0y = incShape.ey;
					e1x =-incShape.ex;
					e1y = incShape.ey;
					if (nx > 0)
					{
						incVert = 0;
						incEdge = 1;
					}
					else
					{
						incVert = 1;
						incEdge = 0;
					}
				}
				else
				{
					e0x =-incShape.ex;
					e0y =-incShape.ey;
					e1x = incShape.ex;
					e1y =-incShape.ey;
					if (nx > 0)
					{
						incVert = 3;
						incEdge = 2;
					}
					else
					{
						incVert = 2;
						incEdge = 3;
					}
				}
			}

			//transform clipping vertices back to world space
			var xt:Number = e0x;
			var yt:Number = e0y;
			e0x = incShape.x + incShape.r11 * xt + incShape.r12 * yt;
			e0y = incShape.y + incShape.r21 * xt + incShape.r22 * yt;

			xt = e1x;
			yt = e1y;
			e1x = incShape.x + incShape.r11 * xt + incShape.r12 * yt;
			e1y = incShape.y + incShape.r21 * xt + incShape.r22 * yt;

			var cv0x:Number, cv1x:Number;
			var cv0y:Number, cv1y:Number;

			var dist0:Number, dist1:Number, interp:Number;

			dist0 = e0x * -sideNormalx + e0y * -sideNormaly - negSide;
			dist1 = e1x * -sideNormalx + e1y * -sideNormaly - negSide;
			if (dist0 * dist1 < 0)
			{
				interp = dist0 / (dist0 - dist1);
				if (dist0 < 0)
				{
					cv0x = e0x;
					cv0y = e0y;
					cv1x = cv0x + interp * (e1x - cv0x);
					cv1y = cv0y + interp * (e1y - cv0y);
				}
				else
				{
					cv0x = e1x;
					cv0y = e1y;
					cv1x = e0x + interp * (cv0x - e0x);
					cv1y = e0y + interp * (cv0y - e0y);
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
					cv0x = e0x;
					cv0y = e0y;
					cv1x = e1x;
					cv1y = e1y;
				}
				else
				{
					cv1x = e0x;
					cv1y = e0y;
					cv0x = e1x;
					cv0y = e1y;
				}
			}
			dist0 = cv0x * sideNormalx + cv0y * sideNormaly - posSide;
			dist1 = cv1x * sideNormalx + cv1y * sideNormaly - posSide;
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
			sep = ncollx * cv0x + ncolly * cv0y - front;
			if (sep <= 0)
			{
				manifold.pointCount = 1;

				if (flip)
				{
					manifold.nx =-ncollx;
					manifold.ny =-ncolly;
				}
				else
				{
					manifold.nx = ncollx;
					manifold.ny = ncolly;
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

				sep = ncollx * cv1x + ncolly * cv1y - front;
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
				sep = ncollx * cv1x + ncolly * cv1y - front;
				if (sep <= 0)
				{
					manifold.pointCount = 1;

					if (flip)
					{
						manifold.nx =-ncollx;
						manifold.ny =-ncolly;
					}
					else
					{
						manifold.nx = ncollx;
						manifold.ny = ncolly;
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