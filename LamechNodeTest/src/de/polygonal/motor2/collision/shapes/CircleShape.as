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

	import de.polygonal.motor2.collision.shapes.ShapeTypes;
	import de.polygonal.motor2.collision.shapes.data.CircleData;
	import de.polygonal.motor2.dynamics.RigidBody;

	public class CircleShape extends ShapeSkeleton
	{
		/**
		 * Create a new CircleShape instance.
		 *
		 * @param sd An object defining the shape properties (e.g. size, mass...).
		 * @param rb The body to which the new shape is attached to.
		 */
		public function CircleShape(sd:CircleData, rb:RigidBody)
		{
			super(sd, rb);
			setup(sd, rb);
		}

		private function setup(sd:CircleData, rb:RigidBody):void
		{
			//modeling space position
			var xLocalCenter:Number = rb.cx;
			var yLocalCenter:Number = rb.cy;
			mx = sd.mx - xLocalCenter;
			my = sd.my - yLocalCenter;

			//modeling space orientation
			x = body.x + ((r11 = body.r11) * mx + (r12 = body.r12) * my);
			y = body.y + ((r21 = body.r21) * mx + (r22 = body.r22) * my);

			//radius
			radius = sd.radius;
			radiusSq = radius * radius;

			//AABB proxy
			ex = radius;
			ey = radius;
			xmin =-ex; xmax = ex;
			xmin =-ey; ymax = ey;

			vertexCount = 0;
			
			update();
			createProxy();
		}

		/** @private */
		override public function update():Boolean
		{
			synced = false;

			//WCS transform
			x = body.x + ((r11 = body.r11) * mx + (r12 = body.r12) * my);
			y = body.y + ((r21 = body.r21) * mx + (r22 = body.r22) * my);

			//update AABB
			xmin = x - radius;
			ymin = y - radius;
			xmax = x + radius;
			ymax = y + radius;

			return super.update();
		}

		/** @inheritDoc */
		override public function pointInside(p:Point):Boolean
		{
			return (p.x - x) * (p.x - x) + (p.y - y) * (p.y - y) <= radiusSq;
		}

		/** @inheritDoc */
		override public function closestPoint(p:Point, q:Point = null):void
		{
			var dx:Number = p.x - x;
			var dy:Number = p.y - y;
			var mag:Number = Math.sqrt(dx * dx + dy * dy);
			if (mag > 1e-6)
			{
				if (q)
				{
					q.x = x + dx / mag * radius;
					q.y = y + dy / mag * radius;
				}
				else
				{
					p.x = x + dx / mag * radius;
					p.y = y + dy / mag * radius;
				}
			}
			else
			{
				if (q)
				{
					q.x = x;
					q.y = y;
				}
				else
				{
					p.x = x;
					p.y = y;
				}
			}
		}

		/** @private */
		override protected function setType():void
		{
			type = ShapeTypes.CIRCLE;
		}
	}
}