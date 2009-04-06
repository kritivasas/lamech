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
package de.polygonal.motor2.dynamics.forces
{
	import de.polygonal.motor2.dynamics.RigidBody;
	import de.polygonal.motor2.math.V2;	

	public class Bungee1 extends Spring1
	{
		public function Bungee1(anchor:V2, stiffness:Number, restLenght:Number, damping:Number = 0, offset:V2 = null)
		{
			super(anchor, stiffness, restLenght, damping, offset);
		}
		
		/**
		 * -k(|x| - d)(x / |x|) - bv
		 */
		override public function evaluate(body:RigidBody):void
		{
			var fx:Number, dx:Number, rx:Number;
			var fy:Number, dy:Number, ry:Number;
			
			var k:Number, bv:Number, l:Number;
			
			if (offset)
			{
				rx = (body.r11 * offset.x + body.r12 * offset.y);
				ry = (body.r21 * offset.x + body.r22 * offset.y);
				dx = (body.x + rx) - anchor.x;
				dy = (body.y + ry) - anchor.y;
			}
			else
			{
				dx = body.x - anchor.x;
				dy = body.y - anchor.y;	
			}
			
			//-k(|x| - d)(x / |x|)
			l = Math.sqrt(dx * dx + dy * dy) + 1e-6;
			if (l < restLength) return;
			
			k = -stiffness * (l - restLength);
			fx = k * (dx / l);
			fy = k * (dy / l);
			
			if (offset)
			{
				var vx:Number;
				var vy:Number;
				
				if (damping > 0)
				{
					//-bv
					vx = body.vx - body.w * ry;
					vy = body.vy + body.w * rx;
					bv = -damping * (vx * fx + vy * fy) /  (fx * fx + fy * fy);
					fx += fx * bv;
					fy += fy * bv;
				}
				
				body.t += rx * fy - ry * fx;
			}
			else
			{
				if (damping > 0)
				{
					//-bv
					bv = -damping * (body.vx * fx + body.vy * fy) /  (fx * fx + fy * fy);
					fx += fx * bv;
					fy += fy * bv;
				}
			}
			
			body.fx += fx;
			body.fy += fy;
		}
	}
}