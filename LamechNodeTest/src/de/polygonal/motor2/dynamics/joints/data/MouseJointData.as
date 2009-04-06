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
	import de.polygonal.motor2.dynamics.RigidBodyData;
	
	import flash.geom.Point;
	
	import de.polygonal.motor2.dynamics.RigidBody;
	import de.polygonal.motor2.dynamics.joints.JointTypes;
	import de.polygonal.motor2.dynamics.joints.MouseJoint;

	/**
	 * Mouse joint definition.
	 * 
	 * This requires a world target point, tuning parameters, and the time step.
	 */
	public class MouseJointData extends JointData
	{
		/**
		 * The initial world target point. This is assumed to coincide with the
		 * body anchor initially.
		 */
		public var target:Point;
		
		/**
		 * The maximum constraint force that can be exerted to move the
		 * candidate body. Usually you will express as some multiple of the
		 * weight (multiplier * mass * gravity).
		 */
		public var maxForce:Number;
		
		/**
		 * The response speed.
		 */
		public var frequencyHz:Number;
		
		/**
		 * The damping ratio. 0 = no damping, 1 = critical damping.
		 */
		public var dampingRatio:Number;
		
		/**
		 * The time step used in the simulation.
		 */
		public var timeStep:Number;
		
		/**
		 * Create a new MouseJointData instance.
		 * 
		 * @param body   The body attached to the joint.
		 * @param target The world body target point.
		 */
		public function MouseJointData(body:RigidBody, target:Point)
		{
			super(new RigidBody(null, new RigidBodyData()), body);
			
			maxForce     = 0;
			frequencyHz  = 5;
			dampingRatio = .7;
			timeStep     = 1 / 60;
			
			this.target = target.clone();
		}
		
		/** @private */
		override public function getJointClass():Class
		{
			return MouseJoint;
		}
		
		/** @private */
		override protected function setType():void
		{
			type = JointTypes.MOUSE;
		}
	}
}