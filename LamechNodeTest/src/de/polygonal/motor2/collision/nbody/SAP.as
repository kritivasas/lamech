/*
 * Copyright (c) 2007-2008, Michael Baczynski
 * Based on Box2D by Erin Catto, http://www.box2d.org
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
	import de.polygonal.motor2.collision.shapes.ShapeSkeleton;
	import de.polygonal.motor2.math.AABB2;
	import de.polygonal.motor2.math.Circle2;
	
	import flash.geom.Point;
	import flash.system.System;	

	/**
	 * This is a proper AS3 port of the Sweep and Prune broad phase algorithm
	 * found in Box2D and described in: Collision Detection in Interactive 3D
	 * Environments by Gino van den Bergen. Also, some ideas, such as using
	 * integral values for fast compares comes from Bullet
	 * (http:/www.bulletphysics.com).
	 */
	public class SAP implements BroadPhase
	{
		private var _pairManager:BufferedPairManager;
		
		private var _proxyCount:int;
		private var _maxProxies:int;
		private var _proxyPool:Vector.<SAPProxy>;
		private var _freeProxy:int;
		
		private var _timeStamp:int;
		
		private var _xbounds:Vector.<Bound>;
		private var _ybounds:Vector.<Bound>;
		
		private var _queryResultCount:int;
		private var _queryResults:Vector.<int>;
		
		//world bounds
		private var _xmin:Number, _xmax:Number;
		private var _ymin:Number, _ymax:Number;
		
		//fast integral compares
		private var _xQuantizationFactor:Number;		private var _yQuantizationFactor:Number;
		
		private var _tempInterval:QueryInterval;
		private var _xmin0:Number, _xmax0:Number;		private var _ymin0:Number, _ymax0:Number;
		private var _xmin1:Number, _xmax1:Number;
		private var _ymin1:Number, _ymax1:Number;

		public function SAP()
		{
			var memory:uint = System.totalMemory;
			
			_maxProxies = Constants.k_maxProxies;
			
			_queryResults = new Vector.<int>(_maxProxies, true);
			_tempInterval = new QueryInterval();
			
			var proxy:SAPProxy;
			_proxyPool = new Vector.<SAPProxy>(Constants.k_maxPairs, true);
			for (var i:int = 0; i < _maxProxies - 1; i++)
			{
				proxy  = new SAPProxy();
				_proxyPool[i] = proxy;
				proxy.setNext(i + 1);
				proxy.reset();
			}
			
			proxy = _proxyPool[_maxProxies - 1] = new SAPProxy();
			proxy.setNext(Proxy.NULL_PROXY);
			proxy.reset();
			
			_proxyCount = _freeProxy = _queryResultCount = 0;
			_timeStamp = 1;
			
			_xbounds = new Vector.<Bound>(2 * _maxProxies);
			_ybounds = new Vector.<Bound>(2 * _maxProxies);
			
			for (i = 0; i < _maxProxies << 1; i++)
			{
				_xbounds[i] = new Bound();
				_ybounds[i] = new Bound(); 
			}
			
			trace("/*////////////////////////////////////////////////////////*");
			trace(" * SAP STATISTICS");
			trace(" * max proxies = " + _maxProxies);
			trace(" * memory = " + ((System.totalMemory - memory) >> 10) + " KiB");
			trace(" ////////////////////////////////////////////////////////*/");
			trace("");
		}
		
		/** @inheritDoc */
		public function deconstruct():void
		{
			for (var i:int = 0;i < _maxProxies; i++)
				_proxyPool[i].shape = null;
			_proxyPool = null;	
		}
		
		public function setWorldBounds(aabb:AABB2):void
		{
			_xmin = aabb.xmin;
			_xmax = aabb.xmax;
			
			_ymin = aabb.ymin;
			_ymax = aabb.ymax;
			
			var dx:Number = aabb.xmax - aabb.xmin;
			var dy:Number = aabb.ymax - aabb.ymin;
			
			_xQuantizationFactor = 0xffff / dx;
			_yQuantizationFactor = 0xffff / dy;
		}
		
		public function setPairHandler(pairHandler:PairCallback):void
		{
			_pairManager = new BufferedPairManager(Constants.k_maxPairs, pairHandler, this);
		}
		
		public function insideBounds(xmin:Number, ymin:Number, xmax:Number, ymax:Number):Boolean
		{
			var dx0:Number = xmin - _xmax, dx1:Number = _xmin - xmax;
			var dy0:Number = ymin - _ymax, dy1:Number = _ymin - ymax;
			dx0 = dx0 > dx1 ? dx0 : dx1;
			dy0 = dy0 > dy1 ? dy0 : dy1;
			return (dx0 > dy0 ? dx0 : dy0) < 0;
		}
		
		public function queryAABB(aabb:AABB2, out:Vector.<ShapeSkeleton>, maxCount:int = int.MAX_VALUE):int
		{
			if (out.fixed) maxCount = out.length;
			
			_xmin0 = (_xQuantizationFactor * (clamp(aabb.xmin, _xmin, _xmax) - _xmin)) & (0xffff - 1);
			_xmax0 = (_xQuantizationFactor * (clamp(aabb.xmax, _xmin, _xmax) - _xmin)) | 1;
			_ymin0 = (_yQuantizationFactor * (clamp(aabb.ymin, _ymin, _ymax) - _ymin)) & (0xffff - 1);
			_ymax0 = (_yQuantizationFactor * (clamp(aabb.ymax, _ymin, _ymax) - _ymin)) | 1;
			
			rangeQuery(_tempInterval, _xmin0, _xmax0, _xbounds, _proxyCount << 1, 0);			rangeQuery(_tempInterval, _ymin0, _ymax0, _ybounds, _proxyCount << 1, 1);
			
			for (var i:int = 0; i < _queryResultCount; i++)
			{
				var proxy:SAPProxy = _proxyPool[int(_queryResults[i])];
				out[i] = proxy.shape;
				
				if (i == maxCount)
					break;
			}
			
			//prepare for next query
			_queryResultCount = 0;
			incrementTimeStamp();
			return i;
		}
		
		public function queryCircle(circle:Circle2, out:Vector.<ShapeSkeleton>, maxCount:int = int.MAX_VALUE):int
		{
			if (out.fixed) maxCount = out.length;
			
			var cx:Number = circle.c.x;
			var cy:Number = circle.c.y;
			var r:Number  = circle.radius;
			
			var s:ShapeSkeleton;
			var c:int = 0;
			for (var i:int = 0; i < _maxProxies; i++)
			{
				s = _proxyPool[i].shape;
				
				if (s == null) continue;
				
				if ((s.x - cx) * (s.x - cx) +
					(s.y - cy) * (s.y - cy) <= (s.radius + r) * (s.radius + r))
					out[c++] = s;
			}
			
			return c;
		}
		
		public function querySegment(a:Point, b:Point, shapeList:Vector.<ShapeSkeleton>, maxCount:int = -1):int
		{
			return 0;
		}
		
		public function createProxy(shape:ShapeSkeleton):int
		{
			var proxyId:int = _freeProxy;
			var proxy:SAPProxy = _proxyPool[proxyId];
			_freeProxy = proxy.getNext();
			proxy.overlapCount = 0;
			proxy.shape = shape;
			
			_xmin0 = (_xQuantizationFactor * (clamp(shape.xmin, _xmin, _xmax) - _xmin)) & (0xffff - 1);
			_xmax0 = (_xQuantizationFactor * (clamp(shape.xmax, _xmin, _xmax) - _xmin)) | 1;
			_ymin0 = (_yQuantizationFactor * (clamp(shape.ymin, _ymin, _ymax) - _ymin)) & (0xffff - 1);
			_ymax0 = (_yQuantizationFactor * (clamp(shape.ymax, _ymin, _ymax) - _ymin)) | 1;
			
			var boundCount:int = _proxyCount << 1;
			var index:int;
			
			var bound:Bound;
			var lowerBound:Bound, lowerIndex:int;			var upperBound:Bound, upperIndex:int;
			
			//x-axis
			rangeQuery(_tempInterval, _xmin0, _xmax0, _xbounds, boundCount, 0);
			lowerIndex = _tempInterval.lower;
			upperIndex = _tempInterval.upper;
			
			_xbounds.splice(lowerIndex, 0, new Bound());
			upperIndex++; //the upper index has increased because of the lower bound insertion
			_xbounds.splice(upperIndex, 0, new Bound());
			
			//copy in the new bounds
			lowerBound = _xbounds[lowerIndex];
			lowerBound.value = _xmin0;
			lowerBound.proxyId = proxyId;
			
			upperBound = _xbounds[upperIndex];
			upperBound.value = _xmax0;
			upperBound.proxyId = proxyId;
	
			lowerBound.stabbingCount = (lowerIndex == 0) ? 0 : _xbounds[int(lowerIndex - 1)].stabbingCount;
			upperBound.stabbingCount = _xbounds[int(upperIndex - 1)].stabbingCount;
			
			//adjust the stabbing count between the new bounds
			for (index = lowerIndex; index < upperIndex; index++)
				_xbounds[index].stabbingCount++;
	
			//adjust all the affected bound indices
			for (index = lowerIndex; index < boundCount + 2; index++)
			{
				bound = _xbounds[index];
				proxy = _proxyPool[bound.proxyId];
				if (bound.isLower())
					proxy.xmin = index;
				else
					proxy.xmax = index;
			}
			
			//y-axis
			rangeQuery(_tempInterval, _ymin0, _ymax0, _ybounds, boundCount, 1);
			lowerIndex = _tempInterval.lower;
			upperIndex = _tempInterval.upper;
			
			_ybounds.splice(lowerIndex, 0, new Bound());
			upperIndex++;
			_ybounds.splice(upperIndex, 0, new Bound());
			
			lowerBound = _ybounds[lowerIndex];
			lowerBound.value = _ymin0;
			lowerBound.proxyId = proxyId;
			
			upperBound = _ybounds[upperIndex];
			upperBound.value = _ymax0;
			upperBound.proxyId = proxyId;
	
			lowerBound.stabbingCount = (lowerIndex == 0) ? 0 : _ybounds[int(lowerIndex - 1)].stabbingCount;
			upperBound.stabbingCount = _ybounds[int(upperIndex - 1)].stabbingCount;
			
			for (index = lowerIndex; index < upperIndex; index++)
				_ybounds[index].stabbingCount++;
	
			for (index = lowerIndex; index < boundCount + 2; index++)
			{
				bound = _ybounds[index];
				proxy = _proxyPool[bound.proxyId];
				if (bound.isLower())
					proxy.ymin = index;
				else
					proxy.ymax = index;
			}
			
			_proxyCount++;
		
			//create pairs if the AABB is in range
			for (var i:int = 0; i < _queryResultCount; i++)
				_pairManager.addPair(proxyId, _queryResults[i]);
		
			_pairManager.commit();
		
			//prepare for next query
			_queryResultCount = 0;
			incrementTimeStamp();
		
			return proxyId;
		}
		
		public function destroyProxy(proxyId:int):void
		{
			if (proxyId == Proxy.NULL_PROXY) return;
			
			var tBound1:Bound;
			var tBound2:Bound;
			
			var proxy:SAPProxy = _proxyPool[proxyId];
			var proxy2:SAPProxy;
			
			var boundCount:int = _proxyCount << 1;
			
			var lowerIndex:int, lowerValue:int;			var upperIndex:int, upperValue:int;
			
			var boundEnd:int;
			var index:int;
			
			//x-axis
			lowerIndex = proxy.xmin;
			upperIndex = proxy.xmax;
			tBound1 = _xbounds[lowerIndex];
			lowerValue = tBound1.value;
			tBound2 = _xbounds[upperIndex];
			upperValue = tBound2.value;
			
			_xbounds.splice(lowerIndex, 1);
			_xbounds.splice(upperIndex - 1, 1);
			
			//fix bound indices
			boundEnd = boundCount - 2;
			for (index = lowerIndex; index < boundEnd; index++)
			{
				tBound1 = _xbounds[index];
				proxy2 = _proxyPool[tBound1.proxyId];
				if (tBound1.isLower())
					proxy2.xmin = index;
				else
					proxy2.xmax = index;
			}
			
			//fix stabbing count
			boundEnd = upperIndex - 1;
			for (index = lowerIndex; index < boundEnd; index++)
			{
				tBound1 = _xbounds[index];
				tBound1.stabbingCount--;
			}
			
			//query for pairs to be removed. lowerIndex and upperIndex are not needed
			rangeQuery(_tempInterval, lowerValue, upperValue, _xbounds, boundCount - 2, 0);
			
			//y-axis
			lowerIndex = proxy.ymin;
			upperIndex = proxy.ymax;
			tBound1 = _ybounds[lowerIndex];
			lowerValue = tBound1.value;
			tBound2 = _ybounds[upperIndex];
			upperValue = tBound2.value;
			
			_ybounds.splice(lowerIndex, 1);
			_ybounds.splice(upperIndex - 1, 1);
			
			boundEnd = boundCount - 2;
			for (index = lowerIndex; index < boundEnd; index++)
			{
				tBound1 = _ybounds[index];
				proxy2 = _proxyPool[tBound1.proxyId];
				if (tBound1.isLower())
					proxy2.ymin = index;
				else
					proxy2.ymax = index;
			}
			
			boundEnd = upperIndex - 1;
			for (index = lowerIndex; index < boundEnd; index++)
			{
				tBound1 = _ybounds[index];
				tBound1.stabbingCount--;
			}
			
			rangeQuery(_tempInterval, lowerValue, upperValue, _ybounds, boundCount - 2, 1);
			
			for (var i:int = 0; i < _queryResultCount; ++i)
				_pairManager.removePair(proxyId, _queryResults[i]);
			
			_pairManager.commit();
			
			//prepare for next query
			_queryResultCount = 0;
			incrementTimeStamp();
			
			//return the proxy to the pool
			proxy.shape = null;
			proxy.overlapCount   = Constants.k_invalid;
			proxy.xmin = Constants.k_invalid;
			proxy.ymin = Constants.k_invalid;
			proxy.xmax = Constants.k_invalid;
			proxy.ymax = Constants.k_invalid;
			
			proxy.setNext(_freeProxy);
			_freeProxy = proxyId;
			_proxyCount--;
		}
		
		public function moveProxy(proxyId:int):void
		{
			var proxy:SAPProxy = _proxyPool[proxyId];
			var boundCount:int = _proxyCount << 1;
			
			//get new bound values
			//bump lower bounds downs and upper bounds up. this ensures correct
			//sorting of lower/upper bounds that would have equal values
			_xmin1 = (_xQuantizationFactor * (clamp(proxy.shape.xmin, _xmin, _xmax) - _xmin)) & (0xffff - 1);
			_xmax1 = (_xQuantizationFactor * (clamp(proxy.shape.xmax, _xmin, _xmax) - _xmin)) | 1;
			_ymin1 = (_yQuantizationFactor * (clamp(proxy.shape.ymin, _ymin, _ymax) - _ymin)) & (0xffff - 1);
			_ymax1 = (_yQuantizationFactor * (clamp(proxy.shape.ymax, _ymin, _ymax) - _ymin)) | 1;
			
			//get old bound values
			_xmin0 = _xbounds[proxy.xmin].value;
			_xmax0 = _xbounds[proxy.xmax].value;
			_ymin0 = _ybounds[proxy.ymin].value;
			_ymax0 = _ybounds[proxy.ymax].value;
			
			var index:int;
			var bound:Bound;
			
			var prevProxy:SAPProxy;
			var nextProxy:SAPProxy;
			
			var prevProxyId:int;
			var nextProxyId:int;
			
			var prevBound:Bound;
			var nextBound:Bound;
			
			var lowerIndex:int, lowerValue:int, deltaLower:int;
			var upperIndex:int, upperValue:int, deltaUpper:int;
			
			//x-axis
			lowerIndex = proxy.xmin;
			upperIndex = proxy.xmax;
	
			lowerValue = _xmin1;
			upperValue = _xmax1;
	
			deltaLower = lowerValue - _xbounds[lowerIndex].value;
			deltaUpper = upperValue - _xbounds[upperIndex].value;
	
			_xbounds[lowerIndex].value = lowerValue;
			_xbounds[upperIndex].value = upperValue;
	
			//expanding adds overlaps
	
			//should we move the lower bound down?
			if (deltaLower < 0)
			{
				index = lowerIndex;
				while (index > 0 && lowerValue < _xbounds[int(index - 1)].value)
				{
					bound = _xbounds[index];
					prevBound = _xbounds[int(index - 1)];
	
					prevProxyId = prevBound.proxyId;
					prevProxy = _proxyPool[prevBound.proxyId];
	
					prevBound.stabbingCount++;
	
					if (prevBound.isUpper())
					{
						if (testOverlap(_xmin1, _ymin1, _xmax1, _ymax1, prevProxy))
							_pairManager.addPair(proxyId, prevProxyId);
						
						prevProxy.xmax++;
						bound.stabbingCount++;
					}
					else
					{
						prevProxy.xmin++;
						bound.stabbingCount--;
					}
	
					proxy.xmin--;
					swapBounds(bound, prevBound);
					index--;
				}
			}
	
			//should we move the upper bound up?
			if (deltaUpper > 0)
			{
				index = upperIndex;
				while (index < boundCount - 1 && _xbounds[int(index + 1)].value <= upperValue)
				{
					bound = _xbounds[index];
					nextBound = _xbounds[int(index + 1)];
					nextProxyId = nextBound.proxyId;
					nextProxy = _proxyPool[nextProxyId];
					
					nextBound.stabbingCount++;
	
					if (nextBound.isLower())
					{
						if (testOverlap(_xmin1, _ymin1, _xmax1, _ymax1, nextProxy))
							_pairManager.addPair(proxyId, nextProxyId);
	
						nextProxy.xmin--;
						bound.stabbingCount++;
					}
					else
					{
						nextProxy.xmax--;
						bound.stabbingCount--;
					}
	
					proxy.xmax++;
					swapBounds(bound, nextBound);
					index++;
				}
			}
	
			//shrinking removes overlaps
	
			//should we move the lower bound up?
			if (deltaLower > 0)
			{
				index = lowerIndex;
				while (index < boundCount - 1 && _xbounds[int(index + 1)].value <= lowerValue)
				{
					bound = _xbounds[index];
					nextBound = _xbounds[int(index + 1)];
					nextProxyId = nextBound.proxyId;
					nextProxy = _proxyPool[nextProxyId];
	
					nextBound.stabbingCount--;
	
					if (nextBound.isUpper())
					{
						if (testOverlap(_xmin0, _ymin0, _xmax0, _ymax0, nextProxy))
							_pairManager.removePair(proxyId, nextProxyId);
	
						nextProxy.xmax--;
						bound.stabbingCount--;
					}
					else
					{
						nextProxy.xmin--;
						bound.stabbingCount++;
					}
	
					proxy.xmin++;
					swapBounds(bound, nextBound);
					index++;
				}
			}
	
			//should we move the upper bound down?
			if (deltaUpper < 0)
			{
				index = upperIndex;
				while (index > 0 && upperValue < _xbounds[int(index - 1)].value)
				{
					bound = _xbounds[index];
					prevBound = _xbounds[index - 1];
					
					prevProxyId = prevBound.proxyId;
					prevProxy = _proxyPool[prevProxyId];
					
					prevBound.stabbingCount--;
	
					if (prevBound.isLower())
					{
						if (testOverlap(_xmin0, _ymin0, _xmax0, _ymax0, prevProxy))
						{
							_pairManager.removePair(proxyId, prevProxyId);
						}
						
						prevProxy.xmin++;
						bound.stabbingCount--;
					}
					else
					{
						prevProxy.xmax++;
						bound.stabbingCount++;
					}
	
					proxy.xmax--;
					swapBounds(bound, prevBound);
					index--;
				}
			}
			
			//y-axis
			lowerIndex = proxy.ymin;
			upperIndex = proxy.ymax;
	
			lowerValue = _ymin1;
			upperValue = _ymax1;
	
			deltaLower = lowerValue - _ybounds[lowerIndex].value;
			deltaUpper = upperValue - _ybounds[upperIndex].value;
	
			_ybounds[lowerIndex].value = lowerValue;
			_ybounds[upperIndex].value = upperValue;
	
			if (deltaLower < 0)
			{
				index = lowerIndex;
				while (index > 0 && lowerValue < _ybounds[int(index - 1)].value)
				{
					bound = _ybounds[index];
					prevBound = _ybounds[int(index - 1)];
	
					prevProxyId = prevBound.proxyId;
					prevProxy = _proxyPool[prevBound.proxyId];
	
					prevBound.stabbingCount++;
	
					if (prevBound.isUpper())
					{
						if (testOverlap(_xmin1, _ymin1, _xmax1, _ymax1, prevProxy))
							_pairManager.addPair(proxyId, prevProxyId);
						
						prevProxy.ymax++;
						bound.stabbingCount++;
					}
					else
					{
						prevProxy.ymin++;
						bound.stabbingCount--;
					}
	
					proxy.ymin--;
					swapBounds(bound, prevBound);
					index--;
				}
			}
	
			if (deltaUpper > 0)
			{
				index = upperIndex;
				while (index < boundCount - 1 && _ybounds[int(index + 1)].value <= upperValue)
				{
					bound = _ybounds[index];
					nextBound = _ybounds[int(index + 1)];
					nextProxyId = nextBound.proxyId;
					nextProxy = _proxyPool[nextProxyId];
					
					nextBound.stabbingCount++;
	
					if (nextBound.isLower())
					{
						if (testOverlap(_xmin1, _ymin1, _xmax1, _ymax1, nextProxy))
							_pairManager.addPair(proxyId, nextProxyId);
	
						nextProxy.ymin--;
						bound.stabbingCount++;
					}
					else
					{
						nextProxy.ymax--;
						bound.stabbingCount--;
					}
	
					proxy.ymax++;
					swapBounds(bound, nextBound);
					index++;
				}
			}
	
			if (deltaLower > 0)
			{
				index = lowerIndex;
				while (index < boundCount - 1 && _ybounds[int(index + 1)].value <= lowerValue)
				{
					bound = _ybounds[index];
					nextBound = _ybounds[int(index + 1)];
					nextProxyId = nextBound.proxyId;
					nextProxy = _proxyPool[nextProxyId];
	
					nextBound.stabbingCount--;
	
					if (nextBound.isUpper())
					{
						if (testOverlap(_xmin0, _ymin0, _xmax0, _ymax0, nextProxy))
							_pairManager.removePair(proxyId, nextProxyId);
	
						nextProxy.ymax--;
						bound.stabbingCount--;
					}
					else
					{
						nextProxy.ymin--;
						bound.stabbingCount++;
					}
	
					proxy.ymin++;
					swapBounds(bound, nextBound);
					index++;
				}
			}
	
			if (deltaUpper < 0)
			{
				index = upperIndex;
				while (index > 0 && upperValue < _ybounds[int(index - 1)].value)
				{
					bound = _ybounds[index];
					prevBound = _ybounds[index - 1];
					
					prevProxyId = prevBound.proxyId;
					prevProxy = _proxyPool[prevProxyId];
					
					prevBound.stabbingCount--;
	
					if (prevBound.isLower())
					{
						if (testOverlap(_xmin0, _ymin0, _xmax0, _ymax0, prevProxy))
						{
							_pairManager.removePair(proxyId, prevProxyId);
						}
						
						prevProxy.ymin++;
						bound.stabbingCount--;
					}
					else
					{
						prevProxy.ymax++;
						bound.stabbingCount++;
					}
	
					proxy.ymax--;
					swapBounds(bound, prevBound);
					index--;
				}
			}
		}
		
		public function findPairs():void
		{
			_pairManager.commit();
		}
		
		public function getProxy(proxyId:int):Proxy
		{
			var proxy:SAPProxy = _proxyPool[proxyId];
			if (proxyId == Proxy.NULL_PROXY)
				return null;
			
			return proxy;
		}
		
		public function getProxyList():Vector.<Proxy>
		{
			return null;
		}
		
		private function incrementOverlapCount(proxyId:int):void
		{
			var proxy:SAPProxy = _proxyPool[proxyId];
			if (proxy.timeStamp < _timeStamp)
			{
				proxy.timeStamp = _timeStamp;
				proxy.overlapCount = 1;
			}
			else
			{
				proxy.overlapCount = 2;
				_queryResults[_queryResultCount] = proxyId;
				_queryResultCount++;
			}
		}
		
		private function incrementTimeStamp():void
		{
			if (_timeStamp == 0xffff)
			{
				for (var i:int = 0; i < _maxProxies; i++)
					_proxyPool[i].timeStamp = 0;
				_timeStamp = 1;
			}
			else
				_timeStamp++;
		}
		
		private function binarySearch(bounds:Vector.<Bound>, count:int, value:int):int
		{
			var low:int = 0, high:int = count - 1;
			while (low <= high)
			{
				var mid:int = (low + high) >> 1;
				var bound:Bound = bounds[mid];
				if (bound.value > value)
					high = mid - 1;
				else
				if (bound.value < value)
					low = mid + 1;
				else
				{
					low = mid;
					break;
				}
			}
			
			return low;
		}
		
		private function rangeQuery(out:QueryInterval, lowerValue:int, upperValue:int, bounds:Vector.<Bound>, boundCount:int, axis:int):void
		{
			var lowerQuery:int = out.lower = binarySearch(bounds, boundCount, lowerValue);
			var upperQuery:int = out.upper = binarySearch(bounds, boundCount, upperValue);
			
			//easy case: lowerQuery <= lowerIndex(i) < upperQuery
			//solution: search query range for min bounds
			var i:int;
			
			for (i = lowerQuery; i < upperQuery; i++)
			{
				if (bounds[i].isLower())
					incrementOverlapCount(bounds[i].proxyId);
			}
			
			//hard case: lowerIndex(i) < lowerQuery < upperIndex(i)
			//solution: use the stabbing count to search down the bound vector
			if (lowerQuery > 0)
			{
				//find the s overlaps
				i = lowerQuery - 1;
				var s:int = bounds[i].stabbingCount;
				var proxy:SAPProxy;
				if (axis == 0)
				{
					while (s > 0)
					{
						if (bounds[i].isLower())
						{
							proxy = _proxyPool[bounds[i].proxyId];
							if (lowerQuery <= proxy.xmax)
							{
								incrementOverlapCount(bounds[i].proxyId);
								s--;
							}
						}
						i--;
					}
				}
				else
				{
					while (s > 0)
					{
						if (bounds[i].isLower())
						{
							proxy = _proxyPool[bounds[i].proxyId];
							if (lowerQuery <= proxy.ymax)
							{
								incrementOverlapCount(bounds[i].proxyId);
								s--;
							}
						}
						i--;
					}
				}
			}
		}
		
		private function testOverlap(xmin:int, ymin:int, xmax:int, ymax:int, p:SAPProxy):Boolean
		{
			//test x-axis
			if (xmin > _xbounds[p.xmax].value)
				return false;
	
			if (xmax < _xbounds[p.xmin].value)
				return false;
			
			//test y-axis
			if (ymin > _ybounds[p.ymax].value)
				return false;
	
			if (ymax < _ybounds[p.ymin].value)
				return false;
			
			return true;
		}
		
		private function clamp(val:Number, min:Number, max:Number):Number
		{
			return (val < min) ? min : (val > max) ? max : val;
		}
		
		private function swapBounds(a:Bound, b:Bound):void
		{
			var tmp:int = b.value;
			b.value = a.value;
			a.value = tmp;
			
			tmp = b.proxyId;
			b.proxyId = a.proxyId;
			a.proxyId = tmp;
			
			tmp = b.stabbingCount;
			b.stabbingCount = a.stabbingCount;
			a.stabbingCount = tmp;
		}
	}
}

internal class Bound
{
	public var value:int;
	public var proxyId:int;
	public var stabbingCount:int;
	
	public function isLower():Boolean
	{
		return (value & 1) == 0;
	}
	
	public function isUpper():Boolean
	{
		return (value & 1) == 1;
	}
	
	public function swap(b:Bound):void
	{
		var tmp:int;
		
		tmp = value;
		value = b.value;
		b.value = tmp;
		
		tmp = proxyId;
		proxyId = b.proxyId;
		b.proxyId = tmp;
		
		tmp = stabbingCount;
		stabbingCount = b.stabbingCount;
		b.stabbingCount = tmp;
	}
}

internal class BoundValues
{
	public var xmin:int, xmax:int;
	public var ymin:int, ymax:int;
}

internal class QueryInterval
{
	public var lower:int;
	public var upper:int;
}