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
package de.polygonal.motor2.collision.shapes.data
{
	import de.polygonal.motor2.collision.shapes.PolyShape;
	import de.polygonal.motor2.collision.shapes.ShapeTypes;
	import de.polygonal.motor2.math.V2;

	/**
	 * Defines the shape and mass properties of a convex polygon.
	 */
	public class PolyData extends ShapeData
	{
		private var _vertexCount:int;
		private var _vertices:Vector.<V2>;
		private var _regular:Boolean;
		private var _radius:Number;
		private var _area:Number;

		/**
		 * Creates a new PolyData instance.
		 *
		 * The polygon's shape is defined by a flat vector of numbers, where
		 * each consecute pair of numbers represents a vertex position.<br/>
		 * vertex format (clockwise ordered):
		 * <pre>[x(0), y(0), x(1), y(1), ... , x(n-1), y(n-1)], i = 1..n</pre>
		 *
		 * @param density    The polygon's density.
		 * @param vertexList The polygon's vertices.
		 */
		public function PolyData(density:Number, vertexList:Vector.<Number>)
		{
			super(density);
			setVertices(vertexList);
		}

		public function isRegular():Boolean
		{
			return _regular;
		}

		public function get radius():Number
		{
			return _radius;
		}

		/** @inheritDoc */
		override public function get area():Number
		{
			return _area;
		}

		public function getVertexCount():int { return _vertexCount; }

		public function getVertices():Vector.<V2>
		{
			var i:int, copy:Vector.<V2>;

			copy = new Vector.<V2>(_vertexCount, true);
			for (i = 0; i < _vertexCount; i++)
				copy[i] = new V2(_vertices[i].x, _vertices[i].y);
			return copy;
		}

		private function setVertices(source:Vector.<Number>):void
		{
			var i:int, j:int, k:int, rSq:Number;
			var v0:V2, v1:V2, v2:V2, n:V2;
			var chain:V2;

			if (k % 2 != 0)
				throw new Error("invalid source data");

			k = source.length / 2;
			_vertices = null;

			if (k < 3) throw new Error("invalid source data");

			chain = v0 = new V2(source[0], source[1]);

			if (isNaN(v0.x) || isNaN(v0.y))
				throw new Error("invalid source data");

			for (i = 1, j = 2; i < k; i++)
			{
				v1 = new V2(source[j], source[int(j + 1)]);
				j += 2;

				if (isNaN(v1.x) || isNaN(v1.y))
					throw new Error("invalid source data");

				v0.next = v1;
				v0 = v1;
			}
			v0.next = chain;

			/* check for overlapping vertices */
			v0 = chain;
			for (i = 0; i < k - 1; i++)
			{
				v1 = v0.next;
				for (j = i + 1; j < k; j++)
				{
					if ((v1.x - v0.x) * (v1.x - v0.x) + (v1.y - v0.y) * (v1.y - v0.y) < .1)
						throw new Error("overlapping vertices detected");
					v1 = v1.next;
				}
				v0 = v0.next;
			}

			/* check if vertices are ordered clockwise */
			v0 = chain;
			var a:Number = 0;
			for (i = 0; i < k; i++)
			{
				v1 = v0.next;
				a += v0.x * v1.y - v0.y * v1.x;
				v0 = v1;
			}
			if (a < 0) throw new Error("vertices are not clockwise ordered");

			/* check convexity, O(n^2) */
			var ex:Number, ey:Number;
			v0 = chain;
			v1 = v0.next;
			for (i = 0; i < k; i++)
			{
				ex = v1.x - v0.x;
				ey = v1.y - v0.y;

				n = v1.next;
				for (j = 0; j < k - 2; j++)
				{
					if ((ex * (n.y - v0.y) - (n.x - v0.x) * ey ) < 0)
						throw new Error("shape is not convex");
					n = n.next;
				}

				v0 = v1;
				v1 = v0.next;
			}

			/* check for coplanar and degenerated edges */

			//TODO check for coplanar and degenerated edges

			/* all tests passed, write into vertex list */
			_vertexCount = k;
			_vertices = new Vector.<V2>(k, true);
			for (i = 0, v0 = chain; i < k; i++)
			{
				_vertices[i] = v0;
				v0 = v0.next;
			}

			/* check if polygon is regular (ngon) */
			var e1x:Number, e1y:Number, e2x:Number, e2y:Number, t:Number;
			_regular = true;
			v0 = chain;
			v1 = v0.next;
			v2 = v1.next;

			e1x = v2.x - v1.x;
			e1y = v2.y - v1.y;
			e2x = v1.x - v0.x;
			e2y = v1.y - v0.y;
			a = Math.atan2(e1x * e2y - e1y * e2x, e1x * e2x + e1y * e2y);
			for (i = 1; i < k; i++)
			{
				v0 = v1;
				v1 = v2;
				v2 = v2.next;

				e1x = v2.x - v1.x;
				e1y = v2.y - v1.y;
				e2x = v1.x - v0.x;
				e2y = v1.y - v0.y;

				t = Math.atan2(e1x * e2y - e1y * e2x, e1x * e2x + e1y * e2y);
				if (Math.abs(a - t) > 1e-6)
				{
					_regular = false;
					break;
				}
			}

			/* compute bounding circle radius */
			rSq = Number.MIN_VALUE;
			v0 = chain;
			for (i = 0, v0 = chain; i < k; i++)
			{
				rSq = Math.max(rSq, v0.x * v0.x + v0.y * v0.y);
				v0 = v0.next;
			}
				_radius = Math.sqrt(rSq);

				/* invalidate mass data (forces recomputation) */
				invalidate();
		}

		override public function getShapeClass():Class
		{
			return PolyShape;
		}

		override protected function computeMass():void
		{
			//centroid, area, inertia
			var cx:Number = 0;
			var cy:Number = 0;
			var A:Number  = 0;
			var I:Number  = 0;

			//triangle vertices
			var px1:Number = 0, px2:Number, py2:Number;
			var py1:Number = 0, px3:Number, py3:Number;

			//triangle edges
			var ex1:Number, ey1:Number;
			var ex2:Number, ey2:Number;

			var D:Number, triArea:Number;
			var intx2:Number, inty2:Number;
			var inv3:Number = 1 / 3;
			var v:V2;

			for (var i:int = 0; i < _vertexCount; i++)
			{
				v = _vertices[i];
				px2 = v.x;
				py2 = v.y;

				v = _vertices[int((i + 1) % _vertexCount)];
				px3 = v.x;
				py3 = v.y;

				ex1 = px2 - px1;
				ey1 = py2 - py1;

				ex2 = px3 - px1;
				ey2 = py3 - py1;

				//triangle area .5 * perpDot(e1, e2)
				D = (ex1 * ey2 - ey1 * ex2);

				triArea = .5 * D;
				A += triArea;

				//centroid
				cx += triArea * inv3 * (px1 + px2 + px3);
				cy += triArea * inv3 * (py1 + py2 + py3);

				intx2 = inv3 * (0.25 * (ex1 * ex1 + ex2 * ex1 + ex2 * ex2) + (px1 * ex1 + px1 * ex2)) + .5 * px1 * px1;
				inty2 = inv3 * (0.25 * (ey1 * ey1 + ey2 * ey1 + ey2 * ey2) + (py1 * ey1 + py1 * ey2)) + .5 * py1 * py1;

				//inertia
				I += D * (intx2 + inty2);
			}

			//inertia tensor relative to the center
			_mass = _density * A;
			cx /= A;
			cy /= A;

			/*
			for (i = 0; i < _vertexCount; i++)
			{
				v = _vertices[i];
				v.x -= cx;
				v.y -= cy;
			}*/

			_cm = new V2(cx, cy);
			_I = _density * (I - A * (cx * cx + cy * cy));

			_area = A;
		}

		override protected function setType():void
		{
			type = ShapeTypes.POLY;
		}
	}
}