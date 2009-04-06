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
	import de.polygonal.motor2.dynamics.forces.ForceGenerator;
	import de.polygonal.motor2.math.V2;	

	public class Spring2 extends ForceGenerator
	{
		public var offset:V2;
		public var offsetOther:V2;
		public var otherBody:RigidBody;
		
		public var restLength:Number;
		public var stiffness:Number;
		public var damping:Number;
		
		public function Spring2(otherBody:RigidBody, stiffness:Number, restLenght:Number = 0, damping:Number = 0, offset:V2 = null, offsetOther:V2 = null)
		{
			this.otherBody = otherBody;
			this.stiffness  = stiffness;
			this.restLength = restLenght < 0 ? -restLenght : restLenght;
			this.damping    = damping    < 0 ? -damping    : damping;
			
			this.offset = offset ? offset.copy() : null;
			this.offsetOther = offsetOther ? offsetOther.copy() : null;
		}
		
		/**
		 * -k(|x| - d)(x / |x|) - bv
		 */
		override public function evaluate(body:RigidBody):void
		{
			var vx:Number, fx:Number, dx:Number, rx0:Number, rx1:Number, ax0:Number, ax1:Number;
			var vy:Number, fy:Number, dy:Number, ry0:Number, ry1:Number, ay0:Number, ay1:Number;
			
			var k:Number, bv:Number;
			
			var flag:int = 0;
			
			if (offset)
			{
				rx0 = body.r11 * offset.x + body.r12 * offset.y;
				ry0 = body.r21 * offset.x + body.r22 * offset.y;
				
				ax0 = body.x + rx0;
				ay0 = body.y + ry0;
				
				flag ^= 1;
			}
			else
			{
				ax0 = body.x;
				ay0 = body.y;
				
				rx0 = 0;
				ry0 = 0;
			}

			if (offsetOther)
			{
				rx1 = otherBody.r11 * offsetOther.x + otherBody.r12 * offsetOther.y;
				ry1 = otherBody.r21 * offsetOther.x + otherBody.r22 * offsetOther.y;
				
				ax1 = otherBody.x + rx1;
				ay1 = otherBody.y + ry1;
				
				flag ^= 1;
			}
			else
			{
				ax1 = otherBody.x;
				ay1 = otherBody.y;
				
				rx1 = 0;
				ry1 = 0;
			}
			
			dx = ax0 - ax1;
			dy = ay0 - ay1;
						
			if (restLength > 0)
			{
				//-k(|x| - d)(x / |x|)
				var l:Number = Math.sqrt(dx * dx + dy * dy) + 1e-6;
				k = -stiffness * (l - restLength);
				fx = k * (dx / l);
				fy = k * (dy / l); 
			}
			else
			{
				//-kx
				k = -stiffness;
				fx = k * dx;
				fy = k * dy;
			}
			
			if (flag != 0)
			{
				if (offset)
				{
					if (damping > 0)
					{
						//-bv
						vx = (body.vx - body.w * ry0) - otherBody.vx;
						vy = (body.vy + body.w * rx0) - otherBody.vy;
						bv = -damping * (vx * fx + vy * fy) /  (fx * fx + fy * fy);
						
						fx += fx * bv;
						fy += fy * bv;
					}
					
					body.fx += fx;
					body.fy += fy;
					body.t  += rx0 * fy - ry0 * fx;
					
					otherBody.fx -= fx;
					otherBody.fy -= fy;
				}
				else
				{
					if (damping > 0)
					{
						//-bv
						vx = body.vx - (otherBody.vx - otherBody.w * ry1);
						vy = body.vy - (otherBody.vy + otherBody.w * rx1);
						bv = -damping * (vx * fx + vy * fy) /  (fx * fx + fy * fy);
						
						fx += fx * bv;
						fy += fy * bv;
					}
					
					body.fx += fx;
					body.fy += fy;
					
					otherBody.fx -= fx;
					otherBody.fy -= fy;
					otherBody.t  -= rx1 * fy - ry1 * fx;
				}
			}
			else
			{
				if (offset)
				{
					if (damping > 0)
					{
						//-bv
						vx = (body.vx - body.w * ry0) - (otherBody.vx - otherBody.w * ry1);
						vy = (body.vy + body.w * rx0) - (otherBody.vy + otherBody.w * rx1);
						bv = -damping * (vx * fx + vy * fy) /  (fx * fx + fy * fy);
						
						fx += fx * bv;
						fy += fy * bv;
					}
					
					body.fx += fx;
					body.fy += fy;
					body.t  += rx0 * fy - ry0 * fx;
					
					otherBody.fx -= fx;
					otherBody.fy -= fy;
					otherBody.t  -= rx1 * fy - ry1 * fx;
				}
				else
				{
					if (damping > 0)
					{
						//-bv
						vx = body.vx - otherBody.vx;
						vy = body.vy - otherBody.vy;
						bv = -damping * (vx * fx + vy * fy) /  (fx * fx + fy * fy);
						
						fx += fx * bv;
						fy += fy * bv;
					}
					
					body.fx += fx;
					body.fy += fy;
					
					otherBody.fx -= fx;
					otherBody.fy -= fy;
				}
			}
		}
	}
}