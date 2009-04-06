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
	import de.polygonal.motor2.Constants;
	import de.polygonal.motor2.collision.nbody.BroadPhase;
	import de.polygonal.motor2.collision.nbody.LinkedProxy;
	import de.polygonal.motor2.collision.nbody.PairCallback;
	import de.polygonal.motor2.collision.shapes.ShapeSkeleton;
	import de.polygonal.motor2.math.AABB2;
	import de.polygonal.motor2.math.Circle2;
	
	import flash.system.System;	

	/**
	 * Checks every possible pair against each other.
	 * Time complexity: <code>n(n-1)/2 ~ O(n^2)</code>
	 */
	public class ExhaustiveSearch implements BroadPhase
	{
		private var _proxyList:LinkedProxy;
		private var _proxyPool:Vector.<LinkedProxy>;
		private var _freeProxy:int;
		private var _proxyCount:int;
		
		private var _pairManager:UnbufferedPairManager;
		
		private var _xmin:Number, _xmax:Number;
		private var _ymin:Number, _ymax:Number;

		public function ExhaustiveSearch()
		{
			var memory:uint = System.totalMemory;
			
			var maxProxies:int = Constants.k_maxProxies;
			var proxy:LinkedProxy;
			
			_proxyPool = new Vector.<LinkedProxy>(maxProxies, true);
			for (var i:int = 0; i < maxProxies - 1; i++)
			{
				proxy = new LinkedProxy();
				proxy.setNext(i + 1);
				proxy.id = i;
				_proxyPool[i] = proxy;
			}
			
			proxy = new LinkedProxy();
			proxy.setNext(Proxy.NULL_PROXY);			proxy.id = maxProxies - 1;
			_proxyPool[maxProxies - 1] = proxy;
			
			trace("/*////////////////////////////////////////////////////////*");
			trace(" * EXHAUSTIVE SEARCH STATISTICS");
			trace(" * max proxies = " + maxProxies);
			trace(" * memory = " + ((System.totalMemory - memory) >> 10) + " KiB");
			trace(" ////////////////////////////////////////////////////////*/");
			trace("");
		}
		
		/** @inheritDoc */
		public function deconstruct():void
		{
			var p0:LinkedProxy;
			var p1:LinkedProxy = _proxyList;
			while (p1 != null)
			{
				p0 = p1;
				p1 = p1.next;
				p0.next = null;
				p0.prev = null;
				p0.shape = null;
			}
			
			_proxyPool = null;
			_pairManager = null;
		}
		
		public function setWorldBounds(aabb:AABB2):void
		{
			_xmin = aabb.xmin; _ymin = aabb.ymin;
			_xmax = aabb.xmax; _ymax = aabb.ymax;
		}
		
		public function setPairHandler(pairHandler:PairCallback):void
		{
			_pairManager = new UnbufferedPairManager(pairHandler, this);		}
		
		public function insideBounds(xmin:Number, ymin:Number, xmax:Number, ymax:Number):Boolean
		{
			if (xmin < _xmin) return false;
			if (xmax > _xmax) return false;
			if (ymin < _ymin) return false;
			if (ymax > _ymax) return false;
			return true;
		}
		
		public function queryCircle(circle:Circle2, out:Vector.<ShapeSkeleton>, maxCount:int = int.MAX_VALUE):int
		{
			if (out.fixed) maxCount = out.length;
			
			var cx:Number = circle.c.x;
			var cy:Number = circle.c.y;
			var r:Number  = circle.radius;
			
			var p:LinkedProxy = _proxyList;
			var s:ShapeSkeleton;
			
			var i:int = 0;
			while (p != null)
			{
				s = p.shape;
				
				if ((s.x - cx) * (s.x - cx) +
					(s.y - cy) * (s.y - cy) <= (s.radius + r) * (s.radius + r))
				{
					out[i++] = s;
					if (i == maxCount)
						break;				
				}
				
				p = p.next;
			}
			
			return i;
		}
		
		public function queryAABB(aabb:AABB2, out:Vector.<ShapeSkeleton>, maxCount:int = int.MAX_VALUE):int
		{
			if (out.fixed) maxCount = out.length;
			
			var xmin:Number = aabb.xmin;			var xmax:Number = aabb.xmax;			var ymin:Number = aabb.ymin;			var ymax:Number = aabb.ymax;
			
			var p:LinkedProxy = _proxyList;
			var s:ShapeSkeleton;
			
			var i:int = 0;
			while (p != null)
			{
				s = p.shape;
				if (s.xmin > xmax || s.xmax < xmin || s.ymin > ymax || s.ymax < ymin)
				{
					p = p.next;
					continue;
				}
				
				out[i++] = s;
				
				if (i == maxCount)
					break;
				
				p = p.next;
			}
			
			return i;
		}
		
		public function createProxy(shape:ShapeSkeleton):int
		{
			var proxyId:int = _freeProxy;
			var proxy:LinkedProxy = _proxyPool[proxyId];
			_freeProxy = proxy.getNext();
			
			proxy.next = _proxyList;
			if (_proxyList) _proxyList.prev = proxy;
			_proxyList = proxy;
			
			proxy.shape = shape;
			_proxyCount++;
			
			return proxyId;
		}
		
		public function destroyProxy(proxyId:int):void
		{
			if (proxyId == Proxy.NULL_PROXY) return;
			
			var p1:LinkedProxy = _proxyPool[proxyId];
			var p2:LinkedProxy = _proxyList;
			
			var s1:ShapeSkeleton = p1.shape;
			var s2:ShapeSkeleton;
			
			var xmin:Number = s1.xmin, xmax:Number = s1.xmax;
			var ymin:Number = s1.ymin, ymax:Number = s1.ymax;
			
			while (p2 != null)
			{
				if (p1 == p2)
				{
					p2 = p2.next;
					continue;
				}
				
				s2 = p2.shape;
				
				if (xmin > s2.xmax || xmax < s2.xmin || ymin > s2.ymax || ymax < s2.ymin)
				{
					p2 = p2.next;
					continue;
				}
				
				if (_pairManager.removePair(proxyId, p2.id))
					--p2.overlapCount;
				
				p2 = p2.next;
			}
			
			//unlink from list
			if (p1.prev) p1.prev.next = p1.next;
			if (p1.next) p1.next.prev = p1.prev;
			if (p1 == _proxyList) _proxyList = p1.next;
			
			//recycle & reset
			p1.setNext(_freeProxy);
			_freeProxy = proxyId;
			p1.reset();
			
			_proxyCount--;
		}
		
		public function moveProxy(proxyId:int):void
		{
		}

		public function findPairs():void
		{
			var p1:LinkedProxy, s1:ShapeSkeleton;
			var p2:LinkedProxy, s2:ShapeSkeleton;
			
			p1 = _proxyList;
			while (p1 != null)
			{
				s1 = p1.shape;
				p2 = p1.next;
				
				while (p2 != null)
				{
					s2 = p2.shape;
					
					//separated?
					if (s1.xmin > s2.xmax || s1.xmax < s2.xmin || s1.ymin > s2.ymax || s1.ymax < s2.ymin)
					{
						//remove pairs if the AABB's cease to overlap
						if (p1.overlapCount * p2.overlapCount > 0)
						{
							if (_pairManager.removePair(p1.id, p2.id))
							{
								p1.overlapCount++;
								p2.overlapCount++;
							}
						}
					}
					else
					{
						//create pairs if the AABB's start to overlap
						if (_pairManager.addPair(p1.id, p2.id))
						{
							p1.overlapCount++;
							p2.overlapCount++;
						}
					}
					p2 = p2.next;
				}
				p1 = p1.next;
			}
		}
		
		public function getProxy(proxyId:int):Proxy
		{
			return _proxyPool[proxyId];
		}
		
		public function getProxyList():Vector.<Proxy>
		{
			var list:Vector.<Proxy> = new Vector.<Proxy>(_proxyCount, true);
			var i:int;
			var p:LinkedProxy = _proxyList;
			while (p != null)
			{
				list[i++] = p;
				p = p.next;
			}
			
			return list;
		}
	}
}