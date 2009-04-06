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
package de.polygonal.motor2.dynamics
{
	import de.polygonal.motor2.collision.shapes.data.ShapeData;		

	public class RigidBodyData
	{
		/* position, velocity, orientation */
		public var x:Number, vx:Number;
		public var y:Number, vy:Number;
		public var r:Number,  w:Number;
		
		public var allowSleep:Boolean;
		public var isSleeping:Boolean;
		public var linDamping:Number;
		public var angDamping:Number;
		public var preventRotation:Boolean;
		
		public var shapeDataList:ShapeData;
		
		public function RigidBodyData(x:Number = 0, y:Number = 0, r:Number = 0)
		{
			init();
			
			this.x = x;
			this.y = y;
			this.r = r;
		}
		
		public function init():void
		{
			x = y = r = vx = vy = w = .0;
			
			allowSleep      = true;
			isSleeping      = false;
			linDamping      = .0;
			angDamping      = .0;
			preventRotation = false;
			shapeDataList   = null;
		}
		
		public function move(x:Number, y:Number):void
		{
			this.x = x;
			this.y = y;
		}
		
		public function rotate(deg:Number):void
		{
			//wrap input angle to 0..2PI
			if (deg < 0)
				deg += 360;
			else
			if (deg > 360)
				deg -= 360;
			
			r = deg * (Math.PI / 180);
		}
		
		public function addShapeData(sd:ShapeData):void
		{
			if (sd == null) return;
			sd.next = shapeDataList;
			shapeDataList = sd;
		}
	}
}