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
package de.polygonal.motor2.collision.pairwise 
{
	import de.polygonal.motor2.collision.shapes.ShapeSkeleton;
	import de.polygonal.motor2.dynamics.contact.Contact;
	import de.polygonal.motor2.dynamics.contact.ContactPoint;
	import de.polygonal.motor2.dynamics.contact.Manifold;
	import de.polygonal.motor2.math.V2;	

	/** @private */
	public class CollideBoxPlaneDoubleSided implements Collider
	{
		public function collide(manifold:Manifold, s1:ShapeSkeleton, s2:ShapeSkeleton, contact:Contact):void
		{
			var nx:Number = s2.worldNormalChain.x;
			var ny:Number = s2.worldNormalChain.y;
			
			var t0:Number = nx * s1.r11 + ny * s1.r21;
			var t1:Number = nx * s1.r12 + ny * s1.r22;
			var r:Number = s1.ex * (t0 < 0 ? -t0 : t0) + s1.ey * (t1 < 0 ? -t1 : t1);
			
			var d:Number = s2.d;
			var sep:Number = (nx * s1.x + ny * s1.y) - d;  
			if (sep > 0)
			{
				if (sep > r)
				{
					manifold.pointCount = 0;
					return;
				}
			}
			else
			{
				if (sep < -r)
				{
					manifold.pointCount = 0;
					return;
				}
				nx = -nx;
				ny = -ny;
				d  = -d;
			}
			
			var s:V2 = s1.worldVertexChain;
			var t:V2 = s;
			var min0:Number  = s.x * nx + s.y * ny, min1:Number;
			s = s.next; min1 = s.x * nx + s.y * ny; if (min1 < min0) { min0 = min1; t = s; }
			s = s.next; min1 = s.x * nx + s.y * ny; if (min1 < min0) { min0 = min1; t = s; }
			s = s.next; min1 = s.x * nx + s.y * ny; if (min1 < min0) { min0 = min1; t = s; }
			s = t;
			
			manifold.nx =-nx;
			manifold.ny =-ny;
			manifold.pointCount = 1;
			
			var cp:ContactPoint = manifold.c0;
			cp.sep = s.x * nx + s.y * ny - d;
			cp.x   = s.x;
			cp.y   = s.y;
			
			var incFaceNormal:V2 = s.edge.n;
			var incEdge:int;
			var incVert:int;
			var min:Number = incFaceNormal.x * nx + incFaceNormal.y * ny;
			if ((incFaceNormal.prev.x * nx + incFaceNormal.prev.y * ny) < min)
			{
				incEdge = incFaceNormal.prev.index;
				
				cp.id.flip    = 0;
				cp.id.incEdge = incEdge;
				cp.id.incVert = incVert;
				cp.id.refFace = 0;
				cp.id.bake();
			
				s = s.prev;
				sep = s.x * nx + s.y * ny - d;
				if (sep < 0)
				{
					cp = manifold.c1;
					cp.sep = sep;
					cp.x   = s.x;
					cp.y   = s.y;
					cp.id.flip    = 0;
					cp.id.incEdge = incEdge;
					cp.id.incVert = incVert;
					cp.id.refFace = 0;
					cp.id.bake();
					manifold.pointCount++;
				}
			}
			else
			{	
				incEdge = incFaceNormal.next.index;
				
				cp.id.flip    = 0;
				cp.id.incEdge = incEdge;
				cp.id.incVert = incVert;
				cp.id.refFace = 0;
				cp.id.bake();
				
				s = s.next;
				sep = s.x * nx + s.y * ny - d;
				if (sep < 0)
				{
					cp = manifold.c1;
					cp.sep = sep;
					cp.x   = s.x;
					cp.y   = s.y;
					cp.id.flip    = 0;
					cp.id.incEdge = incEdge;
					cp.id.incVert = incVert;
					cp.id.refFace = 0;
					cp.id.bake();
					manifold.pointCount++;
				}
			}
		}
	}
}