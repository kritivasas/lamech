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
package de.polygonal.motor2.utils
{
	import flash.geom.Point;	

	public class ShapeLib
	{
		public static function shiftToCM(vertices:Vector.<Number>):void
		{
			var a:Number = 0, t:Number;
			var cx:Number = 0, x0:Number, x1:Number;
			var cy:Number = 0, y0:Number, y1:Number;
			
			var k:int = vertices.length;
			for (var i:int = 0; i < k; i +=2)
			{
				x0 = vertices[     i          ];
				y0 = vertices[int (i + 1)     ];
				x1 = vertices[int((i + 2) % k)];
				y1 = vertices[int((i + 3) % k)];
				
				t = x0 * y1 - y0 * x1;
				cx += (x0 + x1) * t;
				cy += (y0 + y1) * t;
				
				a += t;
			}
			
			a = 1 / (a * 3);
			cx *= a;
			cy *= a;
			
			for (i = 0; i < k; i+= 2)
			{
				vertices[i] -= cx;
				vertices[int(i + 1)] -= cy;
			}
		}
		
		public static function box(w:uint, h:uint):Vector.<Number>
		{
			if (w == 0 || h == 0) return null;
			
			var w2:Number = w * .5;
			var h2:Number = h * .5;
			
			var v:Vector.<Number> = new Vector.<Number>(2 * 4, true);
			v[0] =-w2;
			v[1] =-h2;
			v[2] = w2;
			v[3] =-h2;
			v[4] = w2;
			v[5] = h2;
			v[6] =-w2;
			v[7] = h2;
			return v;
		}
		
		public static function ngon(sides:uint, xRadius:Number, yRadius:Number = 0):Vector.<Number>
		{
			var span:Number, i:int, j:int, verts:Vector.<Number> = new Vector.<Number>(sides << 1, true);
			
			if (xRadius == 0 || sides < 3) return null;
			xRadius = Math.abs(xRadius);
			yRadius = yRadius == 0 ? xRadius : Math.abs(yRadius);
			
			span = Math.PI * 2 / sides;
			for (i = 0; i < sides; i++)
			{
				verts[j++] = Math.cos(i * span) * xRadius;
				verts[j++] = Math.sin(i * span) * yRadius;
			}
			return verts;
		}
		
		public static function randomConvex(sides:uint, xRadius:Number, yRadius:Number = 0):Vector.<Number>
		{
			var tmp:Vector.<Point> = new Vector.<Point>(sides, true);
			var p0:Point, p1:Point;
			
			var inv3:Number = 1 / 3;
			var triArea:Number = 0, A:Number = 0;
			var cx:Number = 0;
			var cy:Number = 0;
			var verts:Vector.<Number> = new Vector.<Number>(sides << 1, true);
			var i:int, j:int;
			
			if (xRadius == 0 || sides < 3) return null;
			xRadius = Math.abs(xRadius);
			yRadius = yRadius == 0 ? xRadius : Math.abs(xRadius);
			
			for (i = 0; i < sides; i++)
			{
				p0 = new Point();
				p0.x = Math.random() * 2 - 1;
				p0.y = Math.random() * 2 - 1;
				p0.normalize(1);
				p0.x *= xRadius; 
				p0.y *= yRadius;
				tmp[i] = p0;
			}
			
			tmp.sort(function (a:Point, b:Point):int
			{
				var t0:Number = Math.atan2(a.y, a.x);
				var t1:Number = Math.atan2(b.y, b.x);
				return (t0 > t1) ? 1 : (t0 < t1) ? -1 : 0;
			});
			
			for (i = 0; i < sides; i++)
			{
				p0 = tmp[i];
				p1 = tmp[int((i + 1) % sides)];
				triArea = .5 * (p0.x * p1.y - p0.y * p1.x);
				A += triArea;
				cx += triArea * inv3 * (p0.x + p1.x);
				cy += triArea * inv3 * (p0.y + p1.y);
			}
			cx /= A;
			cy /= A;
			
			for (i = 0; i < sides; i++)
			{
				p0 = tmp[i];
				verts[j++] = p0.x - cx;				verts[j++] = p0.y - cy;
			}
			return verts;
		}
		
		public static function capsule(length:Number, capSize1:Number, capSize2:Number, capCount1:uint = 3, capCount2:uint = 3):Vector.<Number>
		{
			var t1:Number = capSize1 / 2;
			var t2:Number = capSize2 / 2;
			var h2:Number = (length - t1 - t2) * .5;
			
			var span0:Number = Math.PI / (capCount1 + 1);
			var span1:Number = Math.PI / (capCount2 + 1);
			
			var verts:Vector.<Number> = new Vector.<Number>((capCount1 + capCount2 + 4) << 1, true), k:int = 0, i:int = 0, j:int = 0;			
			k = capCount1 + 1;
			for (i = 0; i <= k; i++)
			{
				verts[j++] = Math.cos(i * span0) * t1;				verts[j++] = Math.sin(i * span0) * t1 + h2;
			}
			
			k = capCount2 + 1;
			for (i = 0; i <= k; i++)
			{
				verts[j++] =-Math.cos(i * span1) * t2;				verts[j++] =-Math.sin(i * span1) * t2 - h2;
			}
			
			return verts;
		}
	}
}