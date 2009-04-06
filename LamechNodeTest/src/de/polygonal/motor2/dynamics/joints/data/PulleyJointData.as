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
package de.polygonal.motor2.dynamics.joints.data
{
	import flash.geom.Point;

	import de.polygonal.motor2.dynamics.RigidBody;
	import de.polygonal.motor2.dynamics.joints.PulleyJoint;
	import de.polygonal.motor2.dynamics.joints.JointTypes;	

	/**
	 * Pulley joint definition.
	 * 
	 * This requires two ground anchors, two dynamic body anchors, maximum
	 * lengths for each side and a pulley ratio. 
	 */
	public class PulleyJointData extends JointData
	{
		/**
		 * The local anchor position relative to body1's origin.
		 */
		public const anchor1:Point = new Point();
		
		/**
		 * The local anchor position relative to body2's origin.
		 */
		public const anchor2:Point = new Point();
		
		/**
		 * The first ground anchor in world coordinates. This point never moves.
		 */		
		public const groundAnchor1:Point = new Point();
		
		/**
		 * The second ground anchor in world coordinates. This point never moves.
		 */		
		public const groundAnchor2:Point = new Point();
		
		/**
		 * The a reference length for the segment attached to body1. 
		 */		
		public var length1:Number;
		
		/**
		 * The a reference length for the segment attached to body2. 
		 */		
		public var length2:Number;
		
		/**
		 * The maximum length of the segment attached to body1.
		 */				
		public var maxlength1:Number;
		
		/**
		 * The maximum length of the segment attached to body2.
		 */				
		public var maxlength2:Number;
		
		/**
		 *  The pulley ratio.
		 */			
		public var ratio:Number;
		
		/**
		 * Minimum allowed joint length.
		 */
		public var minLength:Number = 2;
		
		/**
		 * Creates a new PulleyJointData instance.
		 * 
		 * @param body1   The first body attached to the joint.
		 * @param body2   The second body attached to the joint.
		 * @param anchor1 The body1's anchor in world space.
		 * @param anchor2 The body2's anchor in world space.
		 * @param groundAnchor1 The body1's groundAnchor in world space.
		 * @param groundAnchor2 The body2's groundAnchor in world space.
		 * @param ratio   The pulley ratio.	
		 */
		public function PulleyJointData(body1:RigidBody, body2:RigidBody, anchor1:Point, anchor2:Point, groundAnchor1:Point, groundAnchor2:Point, ratio:Number = 1)
		{
			super(body1, body2);
			
			length1 = Math.sqrt((anchor1.x - groundAnchor1.x) * (anchor1.x - groundAnchor1.x) + (anchor1.y - groundAnchor1.y) * (anchor1.y - groundAnchor1.y));
			length2 = Math.sqrt((anchor2.x - groundAnchor2.x) * (anchor2.x - groundAnchor2.x) + (anchor2.y - groundAnchor2.y) * (anchor2.y - groundAnchor2.y));	
			
			body1.getModelPoint(anchor1);
			this.anchor1.x = anchor1.x;
			this.anchor1.y = anchor1.y;
			
			body2.getModelPoint(anchor2);
			this.anchor2.x = anchor2.x;
			this.anchor2.y = anchor2.y;
			
			this.groundAnchor1.x = groundAnchor1.x;
			this.groundAnchor1.y = groundAnchor1.y;
			
			this.groundAnchor2.x = groundAnchor2.x;
			this.groundAnchor2.y = groundAnchor2.y;
			
			this.ratio = ratio;
			
			maxlength1 = length1 + ratio * length2 - ratio * minLength;
			maxlength2 = (length1 + ratio * length2 - minLength) / ratio;
		}
		
		/** @private */
		override public function getJointClass():Class
		{
			return PulleyJoint;
		}
		
		/** @private */
		override protected function setType():void
		{
			type = JointTypes.PULLEY;
		}
	}
}