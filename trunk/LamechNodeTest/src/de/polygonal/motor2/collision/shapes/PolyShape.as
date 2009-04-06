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
package de.polygonal.motor2.collision.shapes
{
	import flash.geom.Point;

	import de.polygonal.ds.BinaryTreeNode;
	import de.polygonal.motor2.collision.shapes.ShapeTypes;
	import de.polygonal.motor2.collision.shapes.data.PolyData;
	import de.polygonal.motor2.dynamics.RigidBody;
	import de.polygonal.motor2.math.ConvexBSP;
	import de.polygonal.motor2.math.ConvexBSPNode;
	import de.polygonal.motor2.math.Tri2;
	import de.polygonal.motor2.math.V2;

	public class PolyShape extends ShapeSkeleton
	{
		//obb position and orientation offset in model space
		private var _x:Number, _r11:Number, _r12:Number;
		private var _y:Number, _r21:Number, _r22:Number;

		private var _triCenter:V2;

		/**
		 * Create a new PolyShape instance.
		 *
		 * @param sd An object defining the shape properties (e.g. size, mass...).
		 * @param rb The body to which the new shape is attached to.
		 */
		public function PolyShape(sd:PolyData, rb:RigidBody)
		{
			super(sd, rb);
			setup(sd, rb);
		}

		private function setup(sd:PolyData, rb:RigidBody):void
		{
			var xLocalCenter:Number, xt:Number, s:Number;
			var yLocalCenter:Number, yt:Number, c:Number;
			var verts:Vector.<V2>, modelVertexList:Vector.<V2>;
			var i:int, r:Number, v:V2, pos:V2, ext:V2;

			//modeling space position
			xLocalCenter = rb.cx;
			yLocalCenter = rb.cy;

			mx = sd.mx - xLocalCenter;
			my = sd.my - yLocalCenter;

			//modeling space orientation
			s = Math.sin(sd.mr);
			c = Math.cos(sd.mr);
			r11 = c; r12 = -s;
			r21 = s; r22 =  c;

			radius = sd.radius;
			radiusSq = radius * radius;

			//setup polygon
			vertexCount = sd.getVertexCount();

			modelVertexList = new Vector.<V2>(vertexCount, true);
			verts = sd.getVertices();

			for (i = 0; i < vertexCount; i++)
			{
				v = verts[i];
				xt = mx + r11 * v.x + r12 * v.y;
				yt = my + r21 * v.x + r22 * v.y;
				modelVertexList[i] = new V2(xt, yt);
			}

			initPoly(modelVertexList, vertexCount, sd.isRegular(), mx, my);

			//setup minimum area rectangle
			pos = new V2();
			ext = new V2();
			r = computeMinAreaRect(pos, ext);

			_x = pos.x - mx; ex = ext.x;
			_y = pos.y - my; ey = ext.y;
			s = Math.sin(r);
			c = Math.cos(r);
			_r11 = c; _r12 = -s;
			_r21 = s; _r22 =  c;
			
			if (vertexCount == 3)
			{
				//bsp tree for triangles used by extremal search
				//take the easy way out
				var node:ConvexBSPNode = new ConvexBSPNode();
				node.I = 0;
				node.N = worldNormalChain;
				
				//root-L
				node.L = new ConvexBSPNode();
				node.L.I = 2;
				node.L.N = worldNormalChain.prev;
					
					//root-L-L
					node.L.L = new ConvexBSPNode();
					node.L.L.I = 2;
					node.L.L.V = worldVertexChain.prev;
					
					//root-L-R
					node.L.R = new ConvexBSPNode();
					node.L.R.I = 0;
					node.L.R.V = worldVertexChain;
				
				//root-R
				node.R = new ConvexBSPNode();
				node.R.I = 1;
				node.R.N = worldNormalChain.next;
					
					//root-R-L
					node.R.L = new ConvexBSPNode();
					node.R.L.I = 1;
					node.R.L.V = worldVertexChain.next;
					
					//root-R-R
					node.R.R = new ConvexBSPNode();
					node.R.R.I = 2;
					node.R.R.V = worldVertexChain.prev;
				
				BSPNode = node;
			}
			else
			{
				//precompute bsp the hard way
				BSPNode = ConvexBSP.createBSP(vertexCount, modelNormalChain.toArray(), extractEdgeList(modelVertexChain));
				BinaryTreeNode.inorder(BSPNode, function(node:ConvexBSPNode):void
					{
						node.N = worldNormalChain.getAt(node.I);
						node.V = worldVertexChain.getAt(node.I);
					});
			}
			
			update();
			createProxy();
		}

		/** @inheritDoc */
		override public function update():Boolean
		{
			synced = false;

			//WCS transform
			x = body.x + (r11 = body.r11) * mx + (r12 = body.r12) * my;
			y = body.y + (r21 = body.r21) * mx + (r22 = body.r22) * my;

			//TODO fast tight AABB refit using HC

			//refit mbr to obb
			xmin = xmax = x + r11 * _x + r12 * _y;
			ymin = ymax = y + r21 * _x + r22 * _y;

			var t:Number = _r11 * r11 + _r12 * r21;
			if (t > 0)
			{
				xmin += t *-ex;
				xmax += t * ex;
			}
			else
			{
				xmin += t * ex;
				xmax += t *-ex;
			}

			t = _r11 * r12 + _r12 * r22;
			if (t > 0)
			{
				xmin += t *-ey;
				xmax += t * ey;
			}
			else
			{
				xmin += t * ey;
				xmax += t *-ey;
			}

			t = _r21 * r11 + _r22 * r21;
			if (t > 0)
			{
				ymin += t *-ex;
				ymax += t * ex;
			}
			else
			{
				ymin += t * ex;
				ymax += t *-ex;
			}

			t = _r21 * r12 + _r22 * r22;
			if (t > 0)
			{
				ymin += t *-ey;
				ymax += t * ey;
			}
			else
			{
				ymin += t * ey;
				ymax += t *-ey;
			}

			if (_triCenter)
			{
				_triCenter.x = x;
				_triCenter.y = y;
			}

			return super.update();
		}

		/** @inheritDoc */
		override public function toWorldSpace():void
		{
			var wv:V2 = worldVertexChain;
			var mv:V2 = modelVertexChain;

			var wn:V2 = worldNormalChain;
			var mn:V2 = modelNormalChain;

			var x:Number = body.x;
			var y:Number = body.y;

			while (true)
			{
				wv.x = r11 * mv.x + r12 * mv.y + x;
				wv.y = r21 * mv.x + r22 * mv.y + y;
				wn.x = r11 * mn.x + r12 * mn.y;
				wn.y = r21 * mn.x + r22 * mn.y;

				if (wv.isTail) break;

				wv = wv.next;
				mv = mv.next;

				wn = wn.next;
				mn = mn.next;
			}
		}

		/** @inheritDoc */
		override public function closestPoint(p:Point, q:Point = null):void
		{
			var ex:Number, dx:Number, tx:Number, px:Number, rx:Number;
			var ey:Number, dy:Number, ty:Number, py:Number, ry:Number;

			var minSq:Number = -1, dSq:Number, interp:Number;
			var v0:V2, v1:V2;

			//search is done in modeling space
			px = r11 * (x - this.x) + r21 * (y - this.y);
			py = r12 * (x - this.x) + r22 * (y - this.y);

			v0 = modelVertexChain;
			v1 = v0.next;
			while (true)
			{
				ex = v1.x - v0.x;
				ey = v1.y - v0.y;

				dx = px - v0.x;
				dy = py - v0.y;

				if (dx * ex + dy * ey > 0)
				{
					interp = (dx * ex + dy * ey) / (ex * ex + ey * ey);
					interp = (interp < 0) ? 0 : (interp > 1) ? 1 : interp;

					tx = v0.x + ex * interp;
					ty = v0.y + ey * interp;

					dSq = (px - tx) * (px - tx) + (py - ty) * (py - ty);
					if (dSq < minSq || minSq < 0)
					{
						minSq = dSq;

						rx = this.x + r11 * tx + r12 * ty;
						ry = this.y + r21 * tx + r22 * ty;
					}
				}

				if (v0.isTail) break;
				v0 = v1;
				v1 = v1.next;
			}

			if (q)
			{
				q.x = rx;
				q.y = ry;
			}
			else
			{
				p.x = rx;
				p.y = ry;
			}
		}

		/** @inheritDoc */
		override public function pointInside(p:Point):Boolean
		{
			//search is done in modeling space
			var x:Number = p.x;
			var y:Number = p.y;
			var px:Number = r11 * (x - this.x) + r21 * (y - this.y);
			var py:Number = r12 * (x - this.x) + r22 * (y - this.y);
			var v:V2 = modelVertexChain;
			var n:V2 = modelNormalChain;
			while (v)
			{
				if ((px - v.x) * n.x + (py - v.y) * n.y > 0)
					return false;

				if (v.isTail) break;
				n = n.next;
				v = v.next;
			}
			return true;
		}

		/** @inheritDoc */
		override public function triangulate():void
		{
			//triangulate by center-point
			_triCenter = new V2(x, y);
			var v:V2 = worldVertexChain;
			while (true)
			{
				var t:Tri2 = new Tri2(v, v.next, _triCenter);
				t.next = triangleList;
				triangleList = t;

				if (v.isTail) break;
				v = v.next;
			}
		}

		/** @inheritDoc */
		override protected function setType():void
		{
			type = ShapeTypes.POLY;
		}

		//used only DebugShapeRenderer.drawProxy()
		/** @private */
		public function getWorldOBB():V2
		{
			var wx:Number = _r11 * ex;
			var wy:Number = _r21 * ex;
			var hx:Number = _r12 * ey;
			var hy:Number = _r22 * ey;
			var v0:V2 = new V2(_x + mx + wx - hx, _y + my + wy - hy);
			var v1:V2 = new V2(_x + mx - wx - hx, _y + my - wy - hy);
			var v2:V2 = new V2(_x + mx - wx + hx, _y + my - wy + hy);
			var v3:V2 = new V2(_x + mx + wx + hx, _y + my + wy + hy);
			v0.next = v1;
			v1.next = v2;
			v2.next = v3;
			return v0;
		}
	}
}