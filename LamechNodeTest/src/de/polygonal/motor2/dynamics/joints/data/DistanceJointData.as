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
	import de.polygonal.motor2.dynamics.joints.DistanceJoint;
	import de.polygonal.motor2.dynamics.joints.JointTypes;	

	/**
	 * Distance joint definition.
	 * 
	 * This requires defining an anchor point on both bodies and the non-zero
	 * length of the distance joint. The definition uses local anchor points so
	 * that the initial configuration can violate the constraint slightly.
	 * This helps when saving and loading a game. Do not use a zero or short
	 * length.
	 */
	public class DistanceJointData extends JointData
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
		 * The equilibrium length between the anchor points.
		 */
		public var length:Number;
		
		/**
		 * The response speed.
		 */
		public var frequencyHz:Number;
		
		/**
		 * The damping ratio. 0 = no damping, 1 = critical damping.
		 */
		public var dampingRatio:Number;
		
		/**
		 * Create a new DistanceJointData instance.
		 * 
		 * @param body1   The first body attached to the joint.		 * @param body2   The second body attached to the joint.
		 * @param anchor1 The body1's anchor in world space.		 * @param anchor2 The body2's anchor in world space.
		 */
		public function DistanceJointData(body1:RigidBody, body2:RigidBody, anchor1:Point, anchor2:Point)
		{
			super(body1, body2);
			
			length = Math.sqrt((anchor2.x - anchor1.x) * (anchor2.x - anchor1.x) + (anchor2.y - anchor1.y) * (anchor2.y - anchor1.y));
			
			body1.getModelPoint(anchor1);
			this.anchor1.x = anchor1.x;			this.anchor1.y = anchor1.y;
			
			body2.getModelPoint(anchor2);
			this.anchor2.x = anchor2.x;
			this.anchor2.y = anchor2.y;
			
			frequencyHz = dampingRatio = 0;
		}
		
		/** @private */
		override public function getJointClass():Class
		{
			return DistanceJoint;
		}

		/** @private */
		override protected function setType():void
		{
			type = JointTypes.DISTANCE;
		}
	}
}