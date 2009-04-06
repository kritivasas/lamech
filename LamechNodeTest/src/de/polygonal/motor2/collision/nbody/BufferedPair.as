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
	public class BufferedPair extends UnbufferedPair
	{
		public static const PAIR_BUFFERED:int  = 0x01;
		public static const PAIR_REMOVED:int   = 0x02;
		public static const PAIR_FINAL:int     = 0x04;		public static const PAIR_ACTIVE:int    = 0x08;

		public var next:int;
		public var bits:int;
		
		public function getBuffered():Boolean { return (bits & PAIR_BUFFERED) == PAIR_BUFFERED; }
		public function setBuffered():void    { bits |= PAIR_BUFFERED;  }
		public function clrBuffered():void    { bits &=~PAIR_BUFFERED; }

		public function getRemoved():Boolean  { return (bits & PAIR_REMOVED) == PAIR_REMOVED; }
		public function setRemoved():void     { bits |= PAIR_REMOVED; }
		public function clrRemoved():void     { bits &=~PAIR_REMOVED; }

		public function getFinal():Boolean    { return (bits & PAIR_FINAL) == PAIR_FINAL; }
		public function setFinal():void       { bits |= PAIR_FINAL; }
	}
}