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
	import de.polygonal.motor2.World;
	import de.polygonal.motor2.collision.shapes.ShapeSkeleton;
	import de.polygonal.motor2.collision.shapes.ShapeTypes;
	import de.polygonal.motor2.dynamics.RigidBody;
	import de.polygonal.motor2.math.Tri2;
	import de.polygonal.motor2.math.V2;	

	public class Buoyancy extends ForceGenerator
	{
		public var density:Number;
		public var linDrag:Number;
		public var angDrag:Number;
		
		public var velocity:V2;
		public var planeNormal:V2;
		public var planeOffset:Number;
		
		private var _clipTri0:ClipTriangle = new ClipTriangle();
		private var _clipTri1:ClipTriangle = new ClipTriangle();
		private var _cp0:V2 = new V2();
		private var _cp1:V2 = new V2();
		
		public function Buoyancy(planeOffset:Number, planeNormal:V2,
			density:Number, linDrag:Number = 5, angDrag:Number = .5, velocity:V2 = null)
		{
			this.planeOffset = planeOffset;
			this.planeNormal = planeNormal;
			
			this.density = density;
			this.linDrag = linDrag;
			this.angDrag = angDrag;
			
			this.velocity = velocity ? velocity : new V2();
		}
		
		override public function evaluate(body:RigidBody):void
		{
			var totalArea:Number = 0;
			var submergedArea:Number = 0;
			
			var xmin:Number = 2147483648;
			var xmax:Number =-2147483648;
			
			var cx:Number = 0;
			var cy:Number = 0;
			var nOut:int;
			var a:V2, b:V2, c:V2;
			var area:Number;
			
			//compute submerged area and center of buoyancy
			var s:ShapeSkeleton;
			var t:Tri2;
			
			for (s = body.shapeList; s; s = s.next)
			{
				totalArea += s.area;
				
				//above plane
				if (s.ymax < planeOffset) continue;
				
				//below plane
				if (s.ymin >= planeOffset)
				{
					area = s.area;
					cx += area * s.x;
					cy += area * s.y;
					submergedArea += area;
					if (s.xmin < xmin) xmin = s.xmin;
					if (s.xmax > xmax) xmax = s.xmax;
					continue;
				}
				
				if (s.type == ShapeTypes.CIRCLE)
				{
					var r:Number = s.radius;
					var h:Number = s.ymax - planeOffset; 
					
					area = r * r * Math.acos((r - h) / r) - (r - h) * Math.sqrt(2 * r * h - h * h);
					var q:Number = (2 * r - h);
					var z:Number = 3 * (q * q) / (4 * (3 * r - h));
					
					cx += s.x * area;
					cy += (s.y + z) * area;
					submergedArea += area;
					if (s.xmin < xmin) xmin = s.xmin;
					if (s.xmax > xmax) xmax = s.xmax;
				}
				else
				{
					if (!s.synced) s.toWorldSpace();

					//clip triangle against plane
					for (t = s.triangleList; t; t = t.next)
					{
						nOut = clipTriangle(t, planeOffset, _clipTri0, _clipTri1);
						
						//accumulate submerged area and center of buoyancy
						if (nOut > 0)
						{
							a = _clipTri0.a;
							b = _clipTri0.b;
							c = _clipTri0.c;
							
							area = ((b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)) / 2;
							
							if (area < 0) area = -area;
							if (area > 1e-5)
							{
								cx += (area * (a.x + b.x + c.x) / 3);
								cy += (area * (a.y + b.y + c.y) / 3);
								submergedArea += area;
							}
							
						}
						
						if (nOut > 1)
						{
							a = _clipTri1.a;
							b = _clipTri1.b;
							c = _clipTri1.c;
							
							area = ((b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x)) / 2;
							
							if (area < 0) area = -area;
							if (area > 1e-5)
							{
								cx += (area * (a.x + b.x + c.x) / 3);
								cy += (area * (a.y + b.y + c.y) / 3);
								submergedArea += area;
							}
							
						}
						
						if (s.xmin < xmin) xmin = s.xmin;
						if (s.xmax > xmax) xmax = s.xmax;
					}
				}
			}
			
			//normalize the centroid by the total volume
			cx /= submergedArea;
			cy /= submergedArea;
			
			//compute buoyancy force
			if (submergedArea <= 1e-5) return;
			
			var force:Number = density * submergedArea * body.world.gravity.y;
			var partialMass:Number = body.mass * submergedArea / totalArea;
			var rc_x:Number = cx - body.x;
			var rc_y:Number = cy - body.y;
			
			var fx:Number = (planeNormal.x * force) + ((partialMass * linDrag) * (velocity.x - (body.vx - body.w * rc_y)));
			var fy:Number = (planeNormal.y * force) + ((partialMass * linDrag) * (velocity.y - (body.vy + body.w * rc_x)));
			
			body.fx += fx;
			body.fy += fy;
			body.t  += ((rc_x * fy - rc_y * fx) + ((-partialMass * angDrag * ((xmax - xmin) * (xmax - xmin))) * body.w));
		}
		
		private function clipTriangle(tri:Tri2, offset:Number, ct0:ClipTriangle, ct1:ClipTriangle):int
		{
			//count points below / above plane
			var aboveCount:int = 0;
			var belowCount:int = 0;
			
			var aboveVec0:V2 = null; var belowVec0:V2 = null;
			var aboveVec1:V2 = null; var belowVec1:V2 = null;
			
			if (tri.a.y > offset)
			{
				++belowCount;
				belowVec0 = tri.a;
			}
			else
			{
				++aboveCount;
				aboveVec0 = tri.a;
			}
			
			if (tri.b.y > offset)
			{
				++belowCount;
				if (belowVec0)
					belowVec1 = tri.b;
				else
					belowVec0 = tri.b;
			}
			else
			{
				++aboveCount;
				if (aboveVec0)
					aboveVec1 = tri.b;
				else
					aboveVec0 = tri.b;
			}
			
			if (tri.c.y > offset)
			{
				++belowCount;
				if (belowVec0)
					belowVec1 = tri.c;
				else
					belowVec0 = tri.c;
			}
			else
			{
				++aboveCount;
				if (aboveVec0)
					aboveVec1 = tri.c;
				else
					aboveVec0 = tri.c;
			}
			
			//early out
			if (aboveCount == 0)
			{
				ct0.a = tri.a;
				ct0.b = tri.b;
				ct0.c = tri.c;
				return 1;
			}
			else
			if (belowCount == 0)
				return -1;
			
			//clip triangle against plane
			var p1:V2, p2:V2, t:V2, distance0:Number, distance1:Number, interp:Number;
			
			//two submerged vertices -> two clipped triangles
			if (aboveCount == 1)
			{
				p1 = aboveVec0;
				p2 = belowVec0;
				
				//offset = -waterLevel;
				distance0 = p1.y - offset;
				distance1 = p2.y - offset;
				interp = distance0 / (distance0 - distance1);
				_cp0.x = p1.x + interp * (p2.x - p1.x);
				_cp0.y = p1.y + interp * (p2.y - p1.y);
				
				p2 = belowVec1;
				
				distance1 = p2.y - offset;
				interp = distance0 / (distance0 - distance1);
				_cp1.x = p1.x + interp * (p2.x - p1.x);
				_cp1.y = p1.y + interp * (p2.y - p1.y);
				
				if (_cp0.x > _cp1.x)
				{
					t = _cp0;
					_cp0 = _cp1;
					_cp1 = t;
				}
				
				//(belowVec0 - p1) x (belowVec1, p1)
				var side:Number = (belowVec0.x - p1.x) * (belowVec1.y - p1.y) - (belowVec0.y - p1.y) * (belowVec1.x - p1.x);
				
				//cp0, cp1 --> b0, b1
				if (belowVec0.x > _cp1.x)
				{
					ct0.a = belowVec1;
					ct0.b = _cp1;
					ct0.c = belowVec0;
				
					if (side > 0)
					{
						ct1.a = belowVec1;
						ct1.b = _cp1;
						ct1.c = _cp0;
					}
					else
					{
						ct1.a = belowVec0;
						ct1.b = _cp1;
						ct1.c = _cp0;
					}
					return 2;
				}
				else
				//b0, b1 <-- cp0, cp1
				if (belowVec1.x < _cp0.x)
				{
					ct0.a = belowVec1;
					ct0.b = _cp0;
					ct0.c = belowVec0;
					
					if (side > 0)
					{
						ct1.a = belowVec0;
						ct1.b = _cp1;
						ct1.c = _cp0;
					}
					else
					{
						ct1.a = belowVec1;
						ct1.b = _cp1;
						ct1.c = _cp0;
					}
					return 2;
				}
				//cp0 --> b0 --> cp1 --> b1
				else
				{
					ct0.a = belowVec0;
					ct0.b = belowVec1;
					ct0.c = _cp0;
					
					ct1.a = _cp0;
					ct1.b = belowVec1;
					ct1.c = _cp1;
					return 2;
				}
			}
			else
			//one submerged vertice -> one clipped triangle
			if (aboveCount == 2)
			{
				p1 = belowVec0;
				p2 = aboveVec0;
				
				distance0 = p1.y - offset;
				distance1 = p2.y - offset;
				interp = distance0 / (distance0 - distance1);
				_cp0.x = p1.x + interp * (p2.x - p1.x);
				_cp0.y = p1.y + interp * (p2.y - p1.y);
				
				p2 = aboveVec1;
				
				distance1 = p2.y - offset;
				interp = distance0 / (distance0 - distance1);
				_cp1.x = p1.x + interp * (p2.x - p1.x);
				_cp1.y = p1.y + interp * (p2.y - p1.y);

				if (_cp0.x > _cp1.x)
				{
					t = _cp0;
					_cp0 = _cp1;
					_cp1 = t;
				}
				
				ct0.a = _cp1;
				ct0.b = _cp0;
				ct0.c = belowVec0;
				
				return 1;
			}
			return -1;
		}
	}
}

import de.polygonal.motor2.math.V2;

internal class ClipTriangle
{
	public var a:V2 = new V2();
	public var b:V2 = new V2();
	public var c:V2 = new V2();
}

internal class Plane2
{
	public var n:V2 = new V2();
	public var d:Number = 0;	
}