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
	import flash.geom.Point;	

	public class V2 extends Point
	{
		public var next:V2;
		public var prev:V2;
		
		public var index:int;
		public var isHead:Boolean;
		public var isTail:Boolean;
		
		public var edge:E2;
		
		public function V2(x:Number = 0, y:Number = 0)
		{
			super(x, y);
			index = -1;
		}
		
		public function deconstruct():void
		{
			var w:V2 = this, t:V2;
			while (w)
			{
				t = w.next;
				w = null;
				w = t;	
			}
		}
		
		public function getAt(index:int):V2
		{
			var w:V2 = this;
			while (w)
			{
				if (w.index == index) return w;
				if (w.isTail) break;
				w = w.next;
			}
			return null;
		}
		
		public function toArray():Vector.<V2>
		{
			var c:int = index + 1;
			var w:V2 = next;
			while (!w.isHead)
			{
				c++;
				w = w.next;
			}
			
			var v:Vector.<V2> = new Vector.<V2>(c, true);
			w = this;
			for (var i:int = 0; i < c; i++)
			{
				v[i] = w;
				w = w.next;	
			}
			
			return v;
		}
		
		public function copy():V2
		{
			return new V2(x, y);
		}
		
		override public function toString():String
		{
			return "{V2, index=" + index + ", head=" + int(isHead) + ", tail=" + int(isTail) + ", x=" + x.toFixed(2) + ", y=" + y.toFixed(2) + "}";
		}
	}
}