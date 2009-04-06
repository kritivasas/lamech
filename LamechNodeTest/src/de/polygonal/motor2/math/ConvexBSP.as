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
package de.polygonal.motor2.math
{
	import de.polygonal.ds.BinaryTreeNode;
	import de.polygonal.motor2.math.V2;	

	/**
	 * A bsp tree-based acceleration structure for performing extremal queries
	 * on a convex polygon, as described by Eberly, David in Game Physics,
	 * Morgan Kaufmann Publishers, 2004
	 * 
	 * The bsp tree is created for the polar dual supporting a O(log*n) search.
	 * Note: I have also tried the bisection method & the dobkin-kirkpatrick
	 * hierarchy, but eberly's method outperforms all other solutions in AS3.
	 */
	public class ConvexBSP
	{	
		public static function createBSP(vertexCount:int, normals:Vector.<V2>, edges:Vector.<V2>):ConvexBSPNode
		{
			var NIR:Vector.<int> = new Vector.<int>(), AIL:Vector.<Vector.<int>> = new Vector.<Vector.<int>>();
			var NIL:Vector.<int> = new Vector.<int>(), AIR:Vector.<Vector.<int>> = new Vector.<Vector.<int>>();
			
			var arc:Vector.<int>;
			var R:ConvexBSPNode, L:ConvexBSPNode;
			
			var d0:Number = 0;
			for (var i:int = 1; i < vertexCount; i++)
			{
				var d1:Number = edges[0].x * normals[i].x + edges[0].y * normals[i].y;
				if (d1 >= 0)
					NIR.push(i);
				else 
					NIL.push(i);
				
				arc = new Vector.<int>(2, true);
				arc[0] = i - 1;
				arc[1] = i;
				
				if (d0 >= 0 && d1 >= 0)
					AIR.push(arc);
				else
				if (d0 <= 0 && d1 <= 0)
					AIL.push(arc);
				else
				{
					AIL.push(arc);
					AIR.push(arc);
				}
				
				d0 = d1;
			}
			
			arc = new Vector.<int>();
			arc[0] = vertexCount - 1;
			arc[1] = 0;	
			AIL.push(arc);			
			
			R = createInternalNode(vertexCount, normals, edges, NIR, AIR);
			L = createInternalNode(vertexCount, normals, edges, NIL, AIL);

			return createNode(0, R, L);
		}
		
		public static function createInternalNode(vertexCount:int, normals:Vector.<V2>, edges:Vector.<V2>, NI:Vector.<int>, AI:Vector.<Vector.<int>>):ConvexBSPNode
		{
			var NIR:Vector.<int> = new Vector.<int>(), AIL:Vector.<Vector.<int>> = new Vector.<Vector.<int>>();
			var NIL:Vector.<int> = new Vector.<int>(), AIR:Vector.<Vector.<int>> = new Vector.<Vector.<int>>();
			
			var k:int = NI.length;
			var l:int = AI.length;
			var mid:int;
			
			if (k > 1)
			{
				if ((l & 1) == 0)
					//even number of arcs, floor
					mid = (NI[0] + NI[int(k - 1)]) >> 1;
				else
				if ((l & 1) == 1)
					//odd number of arcs, ceil
					mid = (NI[0] + NI[int(k - 1)]) / 2 + 0.5;
			}
			else  
				mid = NI[0];	
			
			var ex:Number = edges[mid].x;
			var ey:Number = edges[mid].y;
			
			var d:Vector.<Number> = new Vector.<Number>();
			var i:int, ni:int, t:Number;
			var N:V2;
			
			for (i = 0; i < k; i++)
			{
				ni = NI[i];
				
				if (mid == ni)
				{
					d[i] = ni;
					continue;
				}
				
				N = normals[ni];
				
				t = ex * N.x + ey * N.y;
				d[i] = t;
				
				if (t >= 0)
					NIR.push(ni);
				else
					NIL.push(ni);
			}
			
			d.unshift(-1);			
			d.push(1);
			
			for (i = 0; i < l; i++)
			{				
				if (d[i] >= 0 && d[int(i + 1)] >= 0)
					AIR.push(AI[i]);
				else 
					AIL.push(AI[i]);
			}
			
			var LChild:ConvexBSPNode;
			if (NIL.length > 0)
				LChild = createInternalNode(vertexCount, normals, edges, NIL, AIL);
			else
			if (AIL.length > 0)
				LChild = createNode(AIL[0][1]); //leaf node containing arc
			
			var RChild:ConvexBSPNode;
			if (NIR.length > 0)
				RChild = createInternalNode(vertexCount, normals, edges, NIR, AIR);
			else
			if (AIR.length > 0)
				RChild = createNode(AIR[0][1]); //leaf node containing arc

			var node:ConvexBSPNode = createNode(mid, RChild, LChild);
			return node;
		}
		
		public static function createNode(I:int, R:ConvexBSPNode = null, L:ConvexBSPNode = null):ConvexBSPNode
		{
			var n:ConvexBSPNode = new ConvexBSPNode();
			n.I = I;
			
			n.R = R;
			n.L = L;
			
			n.right = R;
			n.left  = L;
			
			return n;
		}
	}
}