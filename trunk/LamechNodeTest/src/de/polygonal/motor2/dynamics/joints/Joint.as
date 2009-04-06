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
package de.polygonal.motor2.dynamics.joints 
{
	import flash.geom.Point;
	
	import de.polygonal.motor2.dynamics.RigidBody;
	import de.polygonal.motor2.dynamics.joints.data.JointData;	

	public class Joint
	{
		public static const k_bitIsland:int = 0x20;
		
		public var body1:RigidBody, node1:JointNode;		public var body2:RigidBody, node2:JointNode;
		
		public var prev:Joint;
		public var next:Joint;
		
		public var userData:*;
		public var type:int;
		
		public var stateBits:int;
		
		public var collideConnected:Boolean;
		
		/* anchors in body's modeling space */
		public var la1x:Number, la2x:Number;
		public var la1y:Number, la2y:Number;
	
		/** @private */ protected const _reactionForce:Point = new Point();
		/** @private */ protected const _anchor1:Point = new Point();
		/** @private */ protected const _anchor2:Point = new Point();
		
		/** @private */ protected var _dt:Number;		/** @private */ protected var _invdt:Number;

		public function Joint(data:JointData) 
		{
			type = data.type;
			
			body1 = data.body1;
			body2 = data.body2;
			
			collideConnected = data.collideConnected;
			userData = data.userData;
			
			node1 = new JointNode();
			node2 = new JointNode();
		}

		/**
		 * The body1's anchor position in world coordinates.
		 */
		public function getAnchor1():Point
		{
			_anchor1.x = body1.x + body1.r11 * la1x + body1.r12 * la1y;
			_anchor1.y = body1.y + body1.r21 * la1x + body1.r22 * la1y;
			return _anchor1;
		}
		
		/**
		 * The body2's anchor position in world coordinates.
		 */
		public function getAnchor2():Point
		{
			_anchor2.x = body2.x + body2.r11 * la2x + body2.r12 * la2y;
			_anchor2.y = body2.y + body2.r21 * la2x + body2.r22 * la2y;
			return _anchor2;
		}
		
		public function getReactionForce():Point
		{
			return null;
		}

		public function getReactionTorque():Number
		{
			return 0;
		}
		
		/** @private */
		public function preStep(dt:Number):void
		{
			_dt = dt;
			_invdt = 1 / dt;
		};
		
		/** @private */
		public function preparePosSolver():void
		{
		};
		
		/** @private */
		public function solveVelConstraints(dt:Number, iterations:int):void 
		{
		};
		
		/** @private */
		public function solvePosConstraints():Boolean
		{
			return true;
		};
		
		/** @private */
		protected function setType(type:int):void
		{
			this.type = type;
		}
	}
}