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
	import de.polygonal.motor2.dynamics.joints.PrismaticJoint;
	import de.polygonal.motor2.dynamics.joints.JointTypes;	

	/**
	 * Prismatic joint definition.
	 * 
	 * A line of motion is defined through an anchor point and an axis. The
	 * joint translation is zero when the  local anchor points are the same
	 * in world space. 
	 */	 
	public class PrismaticJointData extends JointData
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
		 * The local translation axis relative to body1.
		 */			
		public const axis:Point = new Point();		
		
		/**
		 * The constrained angle between the bodies: body2_angle - body1_angle.
		 */	
		public var angle:Number;
		
		/**
		 * The lower joint limit.
		 */		
		public var lowerTrans:Number;
		
		/**
		 * The upper joint limit.
		 */
		public var upperTrans:Number;		
		
		/**
		 * The desired motor speed.
		 */
		public var motorSpeed:Number;
		
		/**
		 * The maximum motor torque.
		 */
		public var maxMotorForce:Number;
		
		/**
		 * Enable/disable the joint limit.
		 */
		public var enableLimit:Boolean;
		
		/**
		 * A flag to enable the joint motor.
		 */
		public var enableMotor:Boolean;
				
		/**
		 * Creates a new PrismaticJointData instance.
		 * 
		 * @param body1   The first body attached to the joint.
		 * @param body2   The second body attached to the joint.
		 * @param anchor  The body1's anchor in world space.
		 * @param axis 	  The axis in world space.
		 */
		public function PrismaticJointData(body1:RigidBody, body2:RigidBody, anchor:Point, axis:Point)
		{
			super(body1, body2);		
			
			body1.getModelPoint(anchor,this.anchor1);		

			body2.getModelPoint(anchor,this.anchor2);		

			body1.getModelDirection(axis);
			
			this.axis.x = axis.x;
			this.axis.y = axis.y;
			
			angle = body2.r - body1.r;

			enableLimit = enableMotor = false;
			upperTrans = lowerTrans = motorSpeed = maxMotorForce = 0;
		}
		
		/** @private */
		override public function getJointClass():Class
		{
			return PrismaticJoint;
		}

		/** @private */
		override protected function setType():void
		{
			type = JointTypes.PRISMATIC;
		}
	}
}