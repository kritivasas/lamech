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
	import de.polygonal.motor2.collision.nbody.PairCallback;
	import de.polygonal.motor2.collision.nbody.UnbufferedPair;
	import de.polygonal.motor2.collision.shapes.ShapeSkeleton;
	import de.polygonal.motor2.dynamics.contact.Contact;
	
	import flash.utils.Dictionary;	

	public class UnbufferedPairManager
	{
		private var _callback:PairCallback;
		private var _broadPhase:BroadPhase;

		private var _pairTable:Dictionary;
		private var _pairCount:int;
			
		private var _pairPool:Vector.<UnbufferedPair>;
		private var _poolMask:int, _readIndex:int, _writeIndex:int;
		
		public function UnbufferedPairManager(callback:PairCallback, broadphase:BroadPhase)
		{
			_callback = callback;
			_broadPhase = broadphase;
			
			_pairTable = new Dictionary();
						
			var maxPairs:int = Constants.k_maxPairs;
			
			_pairPool = new Vector.<UnbufferedPair>(maxPairs, true);
			for (var i:int = 0; i < maxPairs; i++) _pairPool[i] = new UnbufferedPair();
			_poolMask = maxPairs - 1;
		}
		
		public function addPair(proxyId1:int, proxyId2:int):Boolean		{
			var key:int = getKey(proxyId1, proxyId2);
			
			if (_pairTable[key]) return false;
			
			var pair:UnbufferedPair = _pairPool[_readIndex];
			_readIndex = (_readIndex + 1) & _poolMask;
			
			var shape1:ShapeSkeleton = _broadPhase.getProxy(proxyId1).shape;
			var shape2:ShapeSkeleton = _broadPhase.getProxy(proxyId2).shape;
			
			var contact:Contact = _callback.pairAdded(shape1, shape2);
			pair.proxyId1 = proxyId1;
			pair.proxyId2 = proxyId2;
			pair.contact = contact;
						
			_pairCount++;
			_pairTable[key] = pair;
			
			return true;
		}
		
		public function removePair(proxyId1:int, proxyId2:int):Boolean
		{
			var key:int = getKey(proxyId1, proxyId2);
			
			var pair:UnbufferedPair = _pairTable[key];
			if (pair == null) return false;
			
			_callback.pairRemoved(pair.contact);
			pair.contact = null;
			
			_pairPool[_writeIndex] = pair;
			_writeIndex = (_writeIndex + 1) & _poolMask;
			
			_pairCount--;
			delete _pairTable[key];
			
			return true;
		}
		
		private function getKey(proxyId1:int, proxyId2:int):int 
		{
			if (proxyId1 > proxyId2)
				return (proxyId2 << 16) | proxyId1;
			return (proxyId1 << 16) | proxyId2;
		}
	}
}