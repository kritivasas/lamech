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
	import de.polygonal.motor2.dynamics.joints.GearJoint;
	import de.polygonal.motor2.dynamics.joints.Joint;
	import de.polygonal.motor2.dynamics.joints.JointTypes;
	
	/**
	 * Gear joint definition.
	 * 
	 * Two existing revolute or prismatic joints are needed.
	 * 
	 * Both joints must consist of a dynamic body attached to a static body,
	 * where the static body is the first in the initialisation of the
	 * prismatic/revolute joints.	 
	 */	
	public class GearJointData extends JointData
	{
		/**
		* The first joint, should be a prismatic or revolute joint.
		*/
		public var joint1:Joint;
		
		/**
		 * The second joint, should be a prismatic or revolute joint.
		 */
		public var joint2:Joint;
		
		/**
		 * The gear ratio between the two gears.
		 */
		public var ratio:Number;

		/**
		 * Creates a new GearJointData instance.
		 * 
		 * @param joint1   	The first gear of the joint. 
		 * @param joint2   	The second gear of the joint
		 * @param ratio 	The gear joint's gear ratio.
		 */
		public function GearJointData(joint1:Joint, joint2:Joint, ratio:Number = 1)
		{
			super(joint1.body2,joint2.body2);

			this.joint1 = joint1;
			this.joint2 = joint2;
			
			this.ratio = ratio;
		}
		
		/** @private */
		override public function getJointClass():Class
		{
			return GearJoint;
		}
		
		/** @private */
		override protected function setType():void
		{
			type = JointTypes.GEAR;
		}
	}
}