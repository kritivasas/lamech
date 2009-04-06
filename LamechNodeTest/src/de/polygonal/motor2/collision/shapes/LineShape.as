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
	import de.polygonal.motor2.Constants;	
	import de.polygonal.motor2.World;
	import de.polygonal.motor2.collision.shapes.ShapeTypes;
	import de.polygonal.motor2.collision.shapes.data.LineData;
	import de.polygonal.motor2.dynamics.RigidBody;
	import de.polygonal.motor2.math.AABB2;
	import de.polygonal.motor2.math.V2;
	
	import flash.geom.Point;
	
	import de.polygonal.motor2.math.E2;	

	public class LineShape extends ShapeSkeleton
	{
		public var infinite:Boolean;
		public var doubleSided:Boolean;

		public function LineShape(sd:LineData, rb:RigidBody)
		{
			super(sd, rb);
			setup(sd, rb);
		}

		private function setup(sd:LineData, rb:RigidBody):void
		{
			infinite = sd.infinite;
			doubleSided = sd.doubleSided;

			var xLocalCenter:Number, dx:Number;
			var yLocalCenter:Number, dy:Number;
			var modelVertexList:Vector.<V2>;
			var v:V2;

			//modeling space position
			xLocalCenter = rb.cx;
			yLocalCenter = rb.cy;
			mx = sd.mx - xLocalCenter;
			my = sd.my - yLocalCenter;

			//modeling space orientation
			x = body.x + ((r11 = body.r11) * mx + (r12 = body.r12) * my);
			y = body.y + ((r21 = body.r21) * mx + (r22 = body.r22) * my);
			dx = sd.b.x - sd.a.x;
			dy = sd.b.y - sd.a.y;
			var mag:Number = Math.sqrt(dx * dx + dy * dy);

			//vertices
			vertexCount = 2;

			//bake down model transform
			modelVertexList = new Vector.<V2>(vertexCount);
			v = modelVertexList[0] = new V2();
			v.x = mx + r11 * sd.a.x + r12 * sd.a.y;
			v.y = my + r21 * sd.a.x + r22 * sd.a.y;

			v = modelVertexList[1] = new V2();
			v.x = mx + r11 * sd.b.x + r12 * sd.b.y;
			v.y = my + r21 * sd.b.x + r22 * sd.b.y;

			initPoly(modelVertexList, vertexCount, true);

			radius = mag / 2;
			radiusSq = radius * radius;

			toWorldSpace();

			if (!infinite)
			{
				v = worldVertexChain;
				xmin = Math.min(v.x, v.next.x);
				xmax = Math.max(v.x, v.next.x);
				ymin = Math.min(v.y, v.next.y);
				ymax = Math.max(v.y, v.next.y);
				
				xmin = int(xmin + 0.5);
				ymin = int(ymin + 0.5);
				xmax = int(xmax);
				ymax = int(ymax);
				
				ex = (xmax - xmin) / 2;
				ey = (ymax - ymin) / 2;
				
				//avoid degenerated case
				if (ex * 2 < Constants.k_minLineAABBThickness)
					ex += Constants.k_minLineAABBThickness * .5 - ex;
				if (ey < Constants.k_minLineAABBThickness)
					ey += Constants.k_minLineAABBThickness * .5 - ey;
			}
			else
			{
				ex = NaN;
				ey = NaN;	
			}

			dx = worldVertexChain.next.x - worldVertexChain.x;
			dy = worldVertexChain.next.y - worldVertexChain.y;
			mag = Math.sqrt(dx * dx + dy * dy);
			dx /= mag;
			dy /= mag;
			d = worldNormalChain.x * worldVertexChain.x + worldNormalChain.y * worldVertexChain.y;

			update();
			createProxy();
		}

		/** @inheritDoc */
		override public function update():Boolean
		{
			synced = false;

			//WCS transform
			x = body.x + ((r11 = body.r11) * mx + (r12 = body.r12) * my);
			y = body.y + ((r21 = body.r21) * mx + (r22 = body.r22) * my);
			
			if (infinite)
			{
				//clip plane against AABB
				var a:V2 = new V2();
				var b:V2 = new V2();
				if (clip(a, b))
				{
					if (a.x < b.x)
					{
						xmin = a.x;
						xmax = b.x;
					}
					else
					{
						xmin = b.x;
						xmax = a.x;
					}
					
					if (a.y < b.y)
					{
						ymin = a.y;
						ymax = b.y;
					}
					else
					{
						ymin = b.y;
						ymax = a.y;
					}
					
					//avoid degenerated case
					if (xmax - xmin < Constants.k_minLineAABBThickness)
					{
						var w:Number = xmax - xmin;
						xmin -= Constants.k_minLineAABBThickness * .5 - w;
						xmax += Constants.k_minLineAABBThickness * .5 - w;
					}
					if (ymax - ymin < Constants.k_minLineAABBThickness)
					{
						var h:Number = ymax - ymin;
						ymin -= Constants.k_minLineAABBThickness * .5 - h;
						ymax += Constants.k_minLineAABBThickness * .5 - h;
					}
					
					xmin = int(xmin + 0.5);
					ymin = int(ymin + 0.5);
					xmax = int(xmax);
					ymax = int(ymax);
				}
				else
				{
					//plane does not intersect world bounds, freeze shape
					xmin = body.world.getWorldBounds().xmin - 1;
				}
			}
			else
			{
				xmin = x - ex;
				ymin = y - ey;
				xmax = x + ex;
				ymax = y + ey;
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

			wv.x = r11 * mv.x + r12 * mv.y + x;
			wv.y = r21 * mv.x + r22 * mv.y + y;
			wn.x = r11 * mn.x + r12 * mn.y;
			wn.y = r21 * mn.x + r22 * mn.y;

			wv = wv.next; wn = wn.next;
			mv = mv.next; mn = mn.next;

			wv.x = r11 * mv.x + r12 * mv.y + x;
			wv.y = r21 * mv.x + r22 * mv.y + y;
			wn.x = r11 * mn.x + r12 * mn.y;
			wn.y = r21 * mn.x + r22 * mn.y;
		}

		/** @inheritDoc */
		override protected function setType():void
		{
			type = ShapeTypes.LINE;
		}
		
		/** clip plane against world bounds */
		private function clip(cp0:V2, cp1:V2):Boolean
		{
			var d:V2 = worldVertexChain.edge.d;
			var bounds:AABB2 = body.world.getWorldBounds();
			
			var tmin:Number =-2147483647;
			var tmax:Number = 2147483647;
			
			if ((d.x < 0 ? -d.x : d.x) < 1e-6)
			{
				if (x < bounds.xmin) return false;
				if (x > bounds.xmax) return false;
			}
			else
			{
				var t1:Number = (bounds.xmin - x) / d.x;
				var t2:Number = (bounds.xmax - x) / d.x;
				
				if (t1 > t2)
				{
					var t:Number = t1;
					t1 = t2;
					t2 = t;
				}
				
				if (t1 > tmin) tmin = t1;
				if (t2 < tmax) tmax = t2;
				if (tmin > tmax) return false;
			}
			
			if ((d.y < 0 ? -d.y : d.y) < 1e-6)
			{
				if (y < bounds.ymin) return false;
				if (y > bounds.ymax) return false;
			}
			else
			{
				t1 = (bounds.ymin - y) / d.y;
				t2 = (bounds.ymax - y) / d.y;
				
				if (t1 > t2)
				{
					t  = t1;
					t1 = t2;
					t2 = t;
				}
				
				if (t1 > tmin) tmin = t1;
				if (t2 < tmax) tmax = t2;
				if (tmin > tmax) return false;
			}
		
			cp0.x = x + d.x * tmin;
			cp0.y = y + d.y * tmin;
			cp1.x = x + d.x * tmax;
			cp1.y = y + d.y * tmax;
			return true;
		}
	}
}