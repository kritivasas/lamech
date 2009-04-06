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
package de.polygonal.motor2.collision.nbody
{
	import de.polygonal.motor2.collision.nbody.PairCallback;
	import de.polygonal.motor2.collision.shapes.ShapeSkeleton;
	import de.polygonal.motor2.math.AABB2;
	import de.polygonal.motor2.math.Circle2;	

	public interface BroadPhase
	{
		function setWorldBounds(aabb:AABB2):void
		function setPairHandler(pairHandler:PairCallback):void
		
		function insideBounds(xmin:Number, ymin:Number, xmax:Number, ymax:Number):Boolean
		
		function queryAABB(aabb:AABB2, out:Vector.<ShapeSkeleton>, maxCount:int = int.MAX_VALUE):int
		function queryCircle(circle:Circle2, out:Vector.<ShapeSkeleton>, maxCount:int = int.MAX_VALUE):int

		function createProxy(shape:ShapeSkeleton):int
		function destroyProxy(proxyId:int):void
		function moveProxy(proxyId:int):void
		
		function findPairs():void
		
		function getProxy(proxyid:int):Proxy;
		function getProxyList():Vector.<Proxy>
		
		/**
		 * Make sure everything is garbage collected.
		 */
		function deconstruct():void
	}
}