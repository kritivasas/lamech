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
	import de.polygonal.motor2.collision.nbody.BroadPhase;
	import de.polygonal.motor2.collision.nbody.BufferedPair;
	import de.polygonal.motor2.collision.nbody.PairCallback;
	
	import flash.utils.Dictionary;	

	public class BufferedPairManager
	{
		public static const NULL_PAIR:int = 0x0000ffff;
		
		public var _broadPhase:BroadPhase;
		public var _callback:PairCallback;
		
		private var _pairs:Vector.<BufferedPair>;
		private var _pairCount:int;
		
		private var _pairBuffer:Vector.<BufferedPair>;
		private var _pairBufferCount:int;
		private var _pairTable:Dictionary;

		private var _freePair:int;
		
		public function BufferedPairManager(maxPairs:int, pairCallback:PairCallback, broadPhase:BroadPhase)
		{
			_callback = pairCallback;
			_broadPhase = broadPhase;
			_pairTable = new Dictionary(true);
			
			_pairs = new Vector.<BufferedPair>(maxPairs + 1, true);
			var pair:BufferedPair;
			for (var i:int = 1; i < maxPairs + 1; i++)
			{
				pair = new BufferedPair();
				pair.proxyId1 = Proxy.NULL_PROXY;
				pair.proxyId2 = Proxy.NULL_PROXY;
				pair.contact = null;
				pair.bits = 0;
				pair.next = i + 1;
				_pairs[i] = pair;
			}
			
			_pairs[maxPairs].next = NULL_PAIR;
			
			_freePair = 1;
			_pairCount = 0;
			_pairBufferCount = 0;
			
			_pairBuffer = new Vector.<BufferedPair>(maxPairs, true);
			for (i = 0; i < maxPairs; i++)
				_pairBuffer[i] = new BufferedPair();
		}
		
		public function addPair(proxyId1:int, proxyId2:int):void
		{
			var key:int = getKey(proxyId1, proxyId2);
			var pair:BufferedPair;
			
			//pairIndex does not exist (undefined is converted to int)
			var pairIndex:int = _pairTable[key];
			if (pairIndex == 0)
			{
				pairIndex = _freePair;
				_pairTable[key] = pairIndex;
				
				//initialize pair data
				pair = _pairs[pairIndex];
				pair.proxyId1 = proxyId1;
				pair.proxyId2 = proxyId2;
				pair.bits = 0;
				pair.contact = null;
				
				_freePair = pair.next;
				_pairCount++;
			}
			else
				pair = _pairs[pairIndex];
			
			var bufferedPair:BufferedPair;
			if (!pair.getBuffered())
			{
				//this must be a newly added pair, so add it to the pair buffer
				pair.setBuffered();
				bufferedPair = _pairBuffer[_pairBufferCount];
				bufferedPair.proxyId1 = pair.proxyId1;
				bufferedPair.proxyId2 = pair.proxyId2;
				_pairBufferCount++;
			}
		
			//confirm this pair for the subsequent call to commit
			pair.clrRemoved();
		}
		
		public function removePair(proxyId1:int, proxyId2:int):void
		{
			//find pair
			var key:int = getKey(proxyId1, proxyId2);
			var pairIndex:int = _pairTable[key];
			
			//the pair never existed, this is legal due to collision filtering
			if (pairIndex == 0)
				return;
			
			//if this pair is not in the pair buffer
			var pair:BufferedPair = _pairs[pairIndex];
			if (!pair.getBuffered())
			{
				//this must be an old pair
				pair.setBuffered();
				var bufferedPair:BufferedPair = _pairBuffer[_pairBufferCount];
				bufferedPair.proxyId1 = pair.proxyId1;
				bufferedPair.proxyId2 = pair.proxyId2;
				_pairBufferCount++;
			}
			
			pair.setRemoved();
		}
		
		public function commit():void
		{
			var bufferedPair:BufferedPair;
			var removeCount:int = 0;
			
			var key:int;
			var pairIndex:int;
			var pair:BufferedPair;
			
			for (var i:int = 0; i < _pairBufferCount; i++)
			{
				bufferedPair = _pairBuffer[i];
				key = getKey(bufferedPair.proxyId1, bufferedPair.proxyId2);
				pairIndex = _pairTable[key];
				pair = _pairs[pairIndex];
				
				pair.clrBuffered();
		
				var proxy1:Proxy = _broadPhase.getProxy(pair.proxyId1);				var proxy2:Proxy = _broadPhase.getProxy(pair.proxyId2);
				
				if (pair.getRemoved())
				{
					//it is possible a pair was added then removed before a commit. therefore,
					//we should be careful not to tell the user the pair was removed when the
					//the user didn't receive a matching add
					if (pair.getFinal())
						_callback.pairRemoved(pair.contact);
		
					//store the ids so we can actually remove the pair below
					bufferedPair = _pairBuffer[removeCount];
					bufferedPair.proxyId1 = pair.proxyId1;
					bufferedPair.proxyId2 = pair.proxyId2;
					removeCount++;
				}
				else
				{
					if (!pair.getFinal())
					{
						pair.contact = _callback.pairAdded(proxy1.shape, proxy2.shape);						pair.setFinal();
					}
				}
			}
			
			for (i = 0; i < removeCount; i++)
			{
				bufferedPair = _pairBuffer[i];
				
				//remove pair
				key = getKey(bufferedPair.proxyId1, bufferedPair.proxyId2);
				pairIndex = _pairTable[key];
				delete _pairTable[key];
				
				//reset pair
				pair = _pairs[pairIndex];
				pair.proxyId1 = Proxy.NULL_PROXY;
				pair.proxyId2 = Proxy.NULL_PROXY;
				pair.bits = 0;
				pair.contact = null;
				pair.next = _freePair;
				
				_freePair = pairIndex;
				_pairCount--;
			}
		
			_pairBufferCount = 0;
		}
		
		private function getKey(proxyId1:int, proxyId2:int):int
		{
			if (proxyId1 < proxyId2)
				return (proxyId1 << 16) | proxyId2;
			return (proxyId2 << 16) | proxyId1;
		}
	}
}