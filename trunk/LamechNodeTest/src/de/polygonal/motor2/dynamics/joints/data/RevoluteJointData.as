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
	import de.polygonal.motor2.dynamics.joints.JointTypes;
	import de.polygonal.motor2.dynamics.joints.RevoluteJoint;	

	/**
	 * Revolute joint definition. This requires defining an anchor point where
	 * the bodies are joined. The definition uses local anchor points so that
	 * the initial configuration can violate the constraint slightly. You also
	 * need to specify the initial relative angle for joint limits. This helps
	 * when saving and loading a game. The local anchor points are measured from
	 * the body's origin rather than the center of mass because:
	 * 1. you might not know where the center of mass will be.
	 * 2. if you add/remove shapes from a body and recompute the mass, the
	 *    joints will be broken.
	 */
	public class RevoluteJointData extends JointData
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
		 * The body2 angle minus body1 angle in the reference state.
		 */
		public var referenceAngle:Number;
		
		/**
		 * The maximum motor torque used to achieve the desired motor speed.
		 */
		public var maxMotorTorque:Number; 
		
		/**
		 * A flag to enable the joint motor.
		 */
		public var enableMotor:Boolean;
		
		/**
		 * The desired motor speed. Usually in radians per second.
		 */
		public var motorSpeed:Number;		
		
		/**
		 * A flag to enable joint limits.
		 */
		public var enableLimit:Boolean;
		
		/**
		 * The lower angle for the joint limit (radians).
		 */
		public var lowerAngle:Number;
		
		/**
		 * The upper angle for the joint limit (radians).
		 */
		public var upperAngle:Number;
		
		/**
		 * Creates a new RevoluteJointData instance.
		 * 
		 * @param body1   The first body attached to the joint.
		 * @param body2   The second body attached to the joint.
		 * @param anchor  The anchor in world space.
		 */
		public function RevoluteJointData(body1:RigidBody, body2:RigidBody, anchor:Point)
		{
			super(body1, body2);
			
			referenceAngle = body2.r - body1.r;
			
			lowerAngle = upperAngle = 0;
			enableLimit = false;
			
			motorSpeed = maxMotorTorque = 0;
			enableMotor = false;
			
			var t:Point = new Point();

			body1.getModelPoint(anchor, t);
			anchor1.x = t.x;
			anchor1.y = t.y;

			body2.getModelPoint(anchor, t);
			anchor2.x = t.x;
			anchor2.y = t.y;
		}

		/** @private */
		override public function getJointClass():Class
		{
			return RevoluteJoint;
		}
		
		/** @private */
		override protected function setType():void
		{
			type = JointTypes.REVOLUTE;
		}
	}
}