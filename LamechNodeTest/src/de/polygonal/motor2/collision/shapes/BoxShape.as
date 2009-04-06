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
	import de.polygonal.motor2.collision.shapes.data.BoxData;
	import de.polygonal.motor2.collision.shapes.data.ShapeData;
	import de.polygonal.motor2.dynamics.RigidBody;
	import de.polygonal.motor2.math.ConvexBSPNode;
	import de.polygonal.motor2.math.Tri2;
	import de.polygonal.motor2.math.V2;
	
	import flash.geom.Point;	

	/**
	 * An oriented bounding box shape (OBB)
	 */
	public class BoxShape extends ShapeSkeleton
	{
		//modeling space orientation
		private var _r11:Number, _r12:Number;
		private var _r21:Number, _r22:Number;

		private var _mr:Number;

		private var _v0:V2, _v1:V2, _v2:V2, _v3:V2;
		private var _n0:V2, _n1:V2, _n2:V2, _n3:V2;

		/**
		 * Create a new BoxShape instance.
		 *
		 * @param sd An object defining the shape properties (e.g. size, mass...).
		 * @param rb The body to which the new shape is attached to.
		 */
		public function BoxShape(sd:BoxData, rb:RigidBody)
		{
			super(sd, rb);
			setup(sd, rb);
		}

		private function setup(sd:BoxData, rb:RigidBody):void
		{
			var xLocalCenter:Number, sin:Number;
			var yLocalCenter:Number, cos:Number;
			var modelVertexList:Vector.<V2>;
			var v:V2;

			//modeling space position
			xLocalCenter = rb.cx;
			yLocalCenter = rb.cy;
			mx = sd.mx - xLocalCenter;
			my = sd.my - yLocalCenter;

			//modeling space orientation
			sin = Math.sin(sd.mr);
			cos = Math.cos(sd.mr);
			_r11 = cos; _r12 = -sin;
			_r21 = sin; _r22 =  cos;
			_mr = sd.mr;

			//aabb proxy
			ex = sd.width  * .5;
			ey = sd.height * .5;
			xmin =-ex; xmax = ex;
			xmin =-ey; ymax = ey;

			radiusSq = ex * ex + ey * ey;
			radius = Math.sqrt(radiusSq);

			//setup polygon
			vertexCount = 4;
			modelVertexList = new Vector.<V2>(vertexCount, true);

			v = modelVertexList[0] = new V2();
			v.x = mx + _r11 * ex + _r12 * ey;
			v.y = my + _r21 * ex + _r22 * ey;

			v = modelVertexList[1] = new V2();
			v.x = mx + _r11 *-ex + _r12 * ey;
			v.y = my + _r21 *-ex + _r22 * ey;

			v = modelVertexList[2] = new V2();
			v.x = mx + _r11 *-ex + _r12 *-ey;
			v.y = my + _r21 *-ex + _r22 *-ey;

			v = modelVertexList[3] = new V2();
			v.x = mx + _r11 * ex + _r12 *-ey;
			v.y = my + _r21 * ex + _r22 *-ey;

			initPoly(modelVertexList, vertexCount, true, mx, my);

			v = worldVertexChain;
			_v0 = v; v = v.next;
			_v1 = v; v = v.next;
			_v2 = v; v = v.next;
			_v3 = v;

			v = worldNormalChain;
			_n0 = v; v = v.next;
			_n1 = v; v = v.next;
			_n2 = v; v = v.next;
			_n3 = v;
			
			//bsp tree for boxes used by extremal search
			//root
			var node:ConvexBSPNode = new ConvexBSPNode();
			node.N = _n0;
			node.I = 0;
			
			//root->left
			node.L = new ConvexBSPNode();
			node.L.N = _n3;
			node.L.I = 3;
				
				//root->left->left
				node.L.L = new ConvexBSPNode();
				node.L.L.V = _v3;
				node.L.L.I = 3;
				
				//root->left->right
				node.L.R = new ConvexBSPNode();
				node.L.R.V = _v0;
				node.L.R.I = 0;
			
			//root->right
			node.R = new ConvexBSPNode();
			node.R.N = _n1;
			node.R.I = 1;
				
				//root->right->left
				node.R.L = new ConvexBSPNode();
				node.R.L.V = _v1;
				node.R.L.I = 1;
				
				//root->right->right
				node.R.R = new ConvexBSPNode();
				node.R.R.V = _v2;
				node.R.R.I = 2;
			
			BSPNode = node;
			
			update();
			createProxy();
		}

		/** @inheritDoc */
		override public function update():Boolean
		{
			synced = false;

			//WCS transform
			if (_mr == 0)
			{
				r11 = body.r11; r12 = body.r12;
				r21 = body.r21; r22 = body.r22;
			}
			else
			{
				r11 = _r11 * body.r11 + _r12 * body.r21;
				r21 = _r21 * body.r11 + _r22 * body.r21;
				r12 = _r11 * body.r12 + _r12 * body.r22;
				r22 = _r21 * body.r12 + _r22 * body.r22;
			}

			x = body.x + body.r11 * mx + body.r12 * my;
			y = body.y + body.r21 * mx + body.r22 * my;

			//compute tight AABB (refit to OBB)
			xmin = xmax = x;
			ymin = ymax = y;

			if (r11 > 0)
			{
				xmin -= r11 * ex;
				xmax += r11 * ex;
			}
			else
			{
				xmin += r11 * ex;
				xmax -= r11 * ex;
			}
			if (r12 > 0)
			{
				xmin -= r12 * ey;
				xmax += r12 * ey;
			}
			else
			{
				xmin += r12 * ey;
				xmax -= r12 * ey;
			}
			if (r21 > 0)
			{
				ymin -= r21 * ex;
				ymax += r21 * ex;
			}
			else
			{
				ymin += r21 * ex;
				ymax -= r21 * ex;
			}
			if (r22 > 0)
			{
				ymin -= r22 * ey;
				ymax += r22 * ey;
			}
			else
			{
				ymin += r22 * ey;
				ymax -= r22 * ey;
			}

			return super.update();
		}

		/** @inheritDoc */
		override public function toWorldSpace():void
		{
			if (synced) return; synced = true;

			var wx:Number = r11 * ex, hx:Number = r12 * ey;
			var wy:Number = r21 * ex, hy:Number = r22 * ey;

			_v0.x = x + wx + hx; _n0.x = r12;
			_v0.y = y + wy + hy; _n0.y = r22;

			_v1.x = x - wx + hx; _n1.x =-r11;
			_v1.y = y - wy + hy; _n1.y =-r21;

			_v2.x = x - wx - hx; _n2.x =-r12;
			_v2.y = y - wy - hy; _n2.y =-r22;

			_v3.x = x + wx - hx; _n3.x = r11;
			_v3.y = y + wy - hy; _n3.y = r21;
		}

		/** @inheritDoc */
		override public function pointInside(p:Point):Boolean
		{
			var dx:Number, dy:Number, dist:Number;

			dx = p.x - x;
			dy = p.y - y;
			dist = dx * r11 + dy * r21;
			if (dist > ex)
				return false;
			else
			if (dist <-ex)
				return false;

			dist = dx * r12 + dy * r22;
			if (dist > ey)
				return false;
			else
			if (dist <-ey)
				return false;

			return true;
		}

		/** @inheritDoc */
		override public function closestPoint(p:Point, q:Point = null):void
		{
			var dx:Number, dy:Number, dist:Number;

			if (q)
			{
				dx = x - (q.x = x);
				dy = y - (q.y = y);

				dist = dx * r11 + dy * r21;
				if (dist > ex)
					dist = ex;
				else
				if (dist <-ex)
					dist =-ex;

				q.x += r11 * dist;
				q.y += r21 * dist;

				dist = dx * r12 + dy * r22;
				if (dist > ey)
					dist = ey;
				else
				if (dist <-ey)
					dist =-ey;

				q.x += r12 * dist;
				q.y += r22 * dist;
			}
			else
			{
				dx = x - (p.x = x);
				dy = y - (p.y = y);

				dist = dx * r11 + dy * r21;
				if (dist > ex)
					dist = ex;
				else
				if (dist <-ex)
					dist =-ex;

				x += r11 * dist;
				y += r21 * dist;

				dist = dx * r12 + dy * r22;
				if (dist > ey)
					dist = ey;
				else
				if (dist <-ey)
					dist =-ey;

				x += r12 * dist;
				y += r22 * dist;
			}
		}

		/** @inheritDoc */
		override public function getShapeOffset(p:Point):void
		{
			p.x = mx * _r11 + my * _r12;
			p.y = mx * _r21 + my * _r22;
		}

		/** @inheritDoc */
		override public function triangulate():void
		{
			//cut box into two triangles
			triangleList = new Tri2(_v0, _v1, _v3);
			triangleList.next = new Tri2(_v3, _v1, _v2);		}

		/** @inheritDoc */
		override protected function setType():void
		{
			type = ShapeTypes.BOX;
		}
	}
}