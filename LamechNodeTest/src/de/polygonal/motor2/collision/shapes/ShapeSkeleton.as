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
	import de.polygonal.motor2.collision.nbody.BroadPhase;
	import de.polygonal.motor2.collision.nbody.Proxy;
	import de.polygonal.motor2.collision.shapes.data.ShapeData;
	import de.polygonal.motor2.dynamics.RigidBody;
	import de.polygonal.motor2.math.ConvexBSPNode;
	import de.polygonal.motor2.math.E2;
	import de.polygonal.motor2.math.Tri2;
	import de.polygonal.motor2.math.V2;
	
	import flash.geom.Point;	

	/**
	 * A generic raw shape from which all concrete shapes are derived.
	 */
	public class ShapeSkeleton
	{
		/**
		 * The parent body. This is where this shape is attached to.
		 * Don't modify.
		 */
		public var body:RigidBody;

		/** @private */ public var next:ShapeSkeleton;

		/** @private */ public var proxyId:int;

		/**
		 * The shape type (read-only).
		 */
		public var type:int;
		
		public var userData:*;

		/**
		 * The coefficient of friction.
		 *
		 * @copy ShapeData#friction
		 */
		public var friction:Number;

		/**
		 * The coefficient of restitution.
		 *
		 * @copy ShapeData#restitution
		 */
		public var restitution:Number;

		/** 
		 * Flag for requesting WCS tranform.
		 */
		public var synced:Boolean = false;

		/** The shape's world-space position, x-axis. */
		public var x:Number;

		/** The shape's world-space position, y-axis. */
		public var y:Number;

		/**
		 * Shape radius (read-only).
		 */
		public var radius:Number, radiusSq:Number;
		
		/** @private */ public var broadPhase:BroadPhase;
		
		public var groupIndex:int;
		public var categoryBits:int;
		public var maskBits:int;

		//shape offset in model-space
		/** @private */ public var mx:Number;
		/** @private */ public var my:Number;

		//2x2 rotation matrix
		/** @private */ public var r11:Number, r12:Number;
		/** @private */ public var r21:Number, r22:Number;

		//AABB, e=extends (halfwidths)
		/** @private */ public var xmin:Number, xmax:Number, ex:Number;
		/** @private */ public var ymin:Number, ymax:Number, ey:Number;
		
		//used by the buoyancy solver
		/** @private */ public var area:Number;

		//shape vertex/normal data
		/** @private */ public var modelVertexChain:V2, modelNormalChain:V2;
		/** @private */ public var worldVertexChain:V2, worldNormalChain:V2;

		/** @private */ public var BSPNode:ConvexBSPNode;
		/** @private */ public var regularShape:Boolean;
		/** @private */ public var vertexCount:int;
		/** @private */ public var offsets:Vector.<V2>;

		//normalized plane, (n X) = d, used when line is infinite
		/** @private */ public var d:Number;

		/** @private */ public var triangleList:Tri2;

		/** @private */
		public function ShapeSkeleton(sd:ShapeData, rb:RigidBody)
		{
			friction     = sd.friction;
			restitution  = sd.restitution;
			area         = sd.area;
			body         = rb;
			groupIndex   = sd.groupIndex;
			categoryBits = sd.categoryBits; 
			maskBits     = sd.maskBits;

			setType();

			broadPhase = body.world.getBroadPhase();
			proxyId = Proxy.NULL_PROXY;
		}

		/**
		 * Unlock all ressources for the garbage collector.
		 */
		public function deconstruct():void
		{
			BSPNode = null;
			modelVertexChain = modelNormalChain = worldVertexChain = worldNormalChain = null;
			offsets = null;
			triangleList = null;

			//destroy proxy
			if (proxyId != Proxy.NULL_PROXY)
			{
				broadPhase.destroyProxy(proxyId);
				proxyId = Proxy.NULL_PROXY;
			}

			broadPhase = null;
		}
		
		/**
		 * Remove and then add proxy from the broad-phase,
		 * this is used to refresh the collision filters.
		 */
		public function refreshProxy():void
		{
			if (proxyId != Proxy.NULL_PROXY)
			{			
				broadPhase.destroyProxy(proxyId);
				createProxy();
			}
		}
		
		/**
		 * Syncronize shape with parent body.
		 * Invoked when the body's position/orientation has changed.
		 */
		public function update():Boolean
		{
			if (proxyId == Proxy.NULL_PROXY)
				return false;
			
			if (broadPhase.insideBounds(xmin, ymin, xmax, ymax))
			{
				broadPhase.moveProxy(proxyId);
				return true;
			}
			return false;
		}

		/**
		 * Perform a WCS transform on all model-space vertices.
		 */
		public function toWorldSpace():void {}

		/**
		 * Compute the closest point to the shape given some input coordinates.
		 * This directly modifies the input point p if no parameter q is given.
		 * Otherwise the result is stored in the second parameter.
		 *
		 * @param p The input coordinates.
		 * @param q The output coordinates.
		 */
		public function closestPoint(p:Point, q:Point = null):void {}

		/**
		 * Determine if a given point p is contained by the shape.
		 *
		 * @param p The input coordinates.
		 * @return True if the point is inside the shape, otherwise false.
		 */
		public function pointInside(p:Point):Boolean
		{
			return false;
		};

		/**
		 * Triangulate the shape.
		 * Currently this is only used by the buoyancy solver.
		 * @private
		 */
		public function triangulate():void {};

		/**
		 * Get the offset vector from the body's center to the shape's
		 * center. The result is stored in the parameter p.
		 *
		 * @param p The offset vector.
		 */
		public function getShapeOffset(p:Point):void
		{
			p.x = mx;
			p.y = my;
		};
		
		public function extractEdgeList(vertexChain:V2):Vector.<V2>
		{
			var w:V2 = vertexChain;
			var v:Vector.<V2> = new Vector.<V2>(vertexCount, true);
			for (var i:int = 0; i < vertexCount; i++)
			{
				v[i] = w.edge.d;
				w = w.next;
			}
			return v;
		}
		
		/** @private */
		protected function createProxy():void
		{
			if (broadPhase.insideBounds(xmin, ymin, xmax, ymax))
				proxyId = broadPhase.createProxy(this);
			else
			{
				proxyId = Proxy.NULL_PROXY;			
				body.freeze();
			}
		}
		
		/** @private */
		protected function initPoly(vertexList:Vector.<V2>, vertexCount:int, regular:Boolean, mx:Number = 0, my:Number = 0):void
		{
			var i:int;
			var ex:Number, ey:Number, nx:Number, ny:Number, mag:Number;
			var v:V2, v0:V2, v1:V2, mv:V2, wv:V2, mn:V2, wn:V2;
			var e:E2;

			regularShape = regular;

			//setup chains
			modelVertexChain = mv = vertexList[0];
			worldVertexChain = wv = new V2();
			mv.index = 0;
			wv.index = 0;
			mv.isHead = true;
			wv.isHead = true;

			modelNormalChain = mn = new V2();
			worldNormalChain = wn = new V2();
			mn.index = 0;
			wn.index = 0;
			mn.isHead = true;
			wn.isHead = true;

			//set up previous and next links to effectively
			//form a doubly-linked *circular* vertex list.
			for (i = 1; i < vertexCount; i++)
			{
				v = vertexList[i];

				//vertex in model space
				v0 = mv;
				v1 = v;
				v1.index = i;
				v0.next = v1;
				v1.prev = v0;
				mv = mv.next;

				//vertex in world space
				v0 = wv;
				v1 = new V2();
				v1.index = i;
				v0.next = v1;
				v1.prev = v0;
				wv = wv.next;

				//normal in model space
				v0 = mn;
				v1 = new V2();
				v1.index = i;
				v0.next = v1;
				v1.prev = v0;
				mn = mn.next;

				//normal in world space
				v0 = wn;
				v1 = new V2();
				v1.index = i;
				v0.next = v1;
				v1.prev = v0;
				wn = wn.next;
			}

			//make circular
			mv.isTail = true;
			mv.next = modelVertexChain;
			modelVertexChain.prev = mv;

			wv.isTail = true;
			wv.next = worldVertexChain;
			worldVertexChain.prev = wv;

			mn.isTail = true;
			mn.next = modelNormalChain;
			modelNormalChain.prev = mn;

			wn.isTail = true;
			wn.next = worldNormalChain;
			worldNormalChain.prev = wn;

			//precompute shape properties
			var edges:Vector.<V2> = new Vector.<V2>(vertexCount, true);
			offsets = new Vector.<V2>(vertexCount, true);

			wn = worldNormalChain;
			wv = worldVertexChain;

			mn = modelNormalChain;
			v0 = modelVertexChain;
			v1 = v0.next;

			for (i = 0; i < vertexCount; i++)
			{
				//normalized edge
				ex = v1.x - v0.x;
				ey = v1.y - v0.y;
				mag = Math.sqrt(ex * ex + ey * ey);
				ex /= mag;
				ey /= mag;
				edges[i] = new V2(ex, ey);

				nx = ey;
				ny =-ex;

				//edge normal
				mn.x = nx;
				mn.y = ny;
				mn = mn.next;

				//minimum distance center to face
				var midx:Number = body.cx + v0.x + (v1.x - v0.x) * .5;
				var midy:Number = body.cy + v0.y + (v1.y - v0.y) * .5;
				var ext:Number = (midx - mx) * nx + (midy - my) * ny;

				//offset for non-regular polygons (otherwise 0)
				//mid(v0, v1) + -N(N * mid(v0, v1))
				if (!regular) offsets[i] = new V2(midx + (-nx * ext), midy + (-ny * ext));

				//model space
				e = new E2();
				e.v = v0;
				e.w = v0.next;
				e.n = mn;
				e.d = edges[i];
				e.mag = mag;

				v0.edge = e;
				v0 = v1;
				v1 = v0.next;

				//world space
				e = new E2();
				e.v = wv;
				e.w = wv.next;
				e.n = wn;
				e.d = edges[i];
				e.mag = mag;
				
				wv.edge = e;
				wv = wv.next;
				wn = wn.next;
			}
			
			//set up a doubly-linked circular edge list
			v = modelVertexChain;
			for (i = 0; i < vertexCount; i++)
			{
				v.edge.next = v.next.edge;
				v.edge.prev = v.prev.edge;
				v = v.next;
			}
			
			v = worldVertexChain;
			for (i = 0; i < vertexCount; i++)
			{
				v.edge.next = v.next.edge;
				v.edge.prev = v.prev.edge;
				v = v.next;
			}
		}

		/**
		 * Compute a minimum bounding rectangle using a brute-force approach
		 * from the shape's modeling space vertex chain.
		 * @private
		 */
		protected function computeMinAreaRect(pos:V2, ext:V2):Number
		{
			var minArea:Number = Number.MAX_VALUE, area:Number;
			var x0_x:Number, y0_x:Number, x1_x:Number, y1_x:Number;
			var x0_y:Number, y0_y:Number, x1_y:Number, y1_y:Number;

			var s0:Number, t0:Number, s1:Number, t1:Number;

			var ux:Number, nx:Number, dx:Number;
			var uy:Number, ny:Number, dy:Number;

			var x_theta:Number, y_theta:Number;
			var w:Number, h:Number, d:Number, l:Number;

			var v0:V2, v1:V2, r0:V2, rj:V2;

			var i:int;

			v0 = modelVertexChain;
			v1 = modelVertexChain.next;
			r0 = modelVertexChain;

			for (i = 0; i < vertexCount; i++)
			{
				ux = v1.x - v0.x;
				uy = v1.y - v0.y;
				l = Math.sqrt(ux * ux + uy * uy);
				ux /= l;
				uy /= l;

				nx =-uy;
				ny = ux;

				s0 = s1 = r0.x * ux + r0.y * uy;
				t0 = t1 = r0.x * nx + r0.y * ny;

				rj = modelVertexChain.next;
				while (true)
				{
					d = rj.x * ux + rj.y * uy;
					if (d < s0)
						s0 = d;
					else
					if (d > s1)
						s1 = d;

					d = rj.x * nx + rj.y * ny;
					if (d < t0)
						t0 = d;
					else
					if (d > t1)
						t1 = d;

					if (rj.isTail) break;
					rj = rj.next;
				}

				area = (s1 - s0) * (t1 - t0);
				if (area < minArea)
				{
					minArea = area;

					x0_x = ux * s0;
					y0_x = uy * s0;

					x1_x = ux * s1;
					y1_x = uy * s1;

					x0_y = nx * t0;
					y0_y = ny * t0;

					x1_y = nx * t1;
					y1_y = ny * t1;
				}

				v0 = v1;
				v1 = v1.next;
			}

			dx = x1_x - x0_x;
			dy = y1_x - y0_x;
			w = Math.sqrt(dx * dx + dy * dy);
			x_theta = Math.atan2(dy, dx);

			dx = x1_y - x0_y;
			dy = y1_y - y0_y;
			h = Math.sqrt(dx * dx + dy * dy);
			y_theta = Math.atan2(dy, dx);

			var rotation:Number;

			if ((y_theta < 0 ? -y_theta : y_theta) < (x_theta < 0 ? -x_theta : x_theta))
			{
				rotation = y_theta;
				ext.x = h / 2;
				ext.y = w / 2;
			}
			else
			{
				rotation = x_theta;
				ext.x = w / 2;
				ext.y = h / 2;
			}

			//min + (max - min) / 2
			pos.x = (x0_x + x0_y) + ((x1_x + x1_y) - (x0_x + x0_y)) / 2;
			pos.y = (y0_x + y0_y) + ((y1_x + y1_y) - (y0_x + y0_y)) / 2;

			return rotation;
		}
		
		/**
		 * Hook for setting the shape's type, implement in subclass.
		 * @private
		 */
		protected function setType():void
		{
			type = ShapeTypes.UNKNOWN;
		}
	}
}