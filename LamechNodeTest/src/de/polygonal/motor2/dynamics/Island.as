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
	import de.polygonal.motor2.Constants;
	import de.polygonal.motor2.World;
	import de.polygonal.motor2.dynamics.RigidBody;
	import de.polygonal.motor2.dynamics.contact.Contact;
	import de.polygonal.motor2.dynamics.contact.solver.*;
	import de.polygonal.motor2.dynamics.joints.Joint;	

	public class Island
	{
		public var bodies:Vector.<RigidBody>;
		public var contacts:Vector.<Contact>;
		public var joints:Vector.<Joint>;
		
		public var bodyList:RigidBody;
		
		public var bodyCount:int;
		public var contactCount:int;
		public var jointCount:int;
		
		public var positionIterations:int;
		public var positionError:Number;
		
		public var contactSolver:SIContactSolver;
		
		public function Island()
		{
			bodyCount    = 0;
			contactCount = 0;
			jointCount   = 0;
			
			bodyList = null;
			
			bodies   = new Vector.<RigidBody>(); 
			contacts = new Vector.<Contact>();
			joints   = new Vector.<Joint>();
			
			contactSolver = new SIContactSolver();
		}
		
		public function solve(gx:Number, gy:Number, iterations:int, dt:Number):void
		{
			var i:int, j:int;
			var b:RigidBody;
			
			/*/////////////////////////////////////////////////////////
			// INTEGRATE FORCE  
			/////////////////////////////////////////////////////////*/
			
			for (i = 0; i < bodyCount; i++)
			{
				b = bodies[i];
				if (b.invMass == 0) continue;
				
				b.vx = (b.vx + dt * (gx + b.invMass * b.fx)) * b.linDamping;
				b.vy = (b.vy + dt * (gy + b.invMass * b.fy)) * b.linDamping;
				b.w  = (b.w  + dt * (     b.invI    * b.t )) * b.angDamping;
			}
			
			/*/////////////////////////////////////////////////////////
			// PRESOLVE CONTACTS AND JOINTS
			/////////////////////////////////////////////////////////*/

			contactSolver.setContacts(contacts, contactCount);
			
			contactSolver.preStep();
			
			for (j = 0; j < jointCount; j++)
				joints[j].preStep(dt);
			
			/*/////////////////////////////////////////////////////////
			// SOLVE VELOCITY CONSTRAINTS
			/////////////////////////////////////////////////////////*/
			
			for (i = 0; i < iterations; i++)
			{
				contactSolver.solveVelConstraints();
				
				for (j = 0; j < jointCount; j++)
					joints[j].solveVelConstraints(dt, iterations);
			}
			
			/*/////////////////////////////////////////////////////////
			// INTEGRATE POSITIONS
			/////////////////////////////////////////////////////////*/
			
			var s:Number, c:Number;
			for (i = 0; i < bodyCount; i++)
			{
				b = bodies[i];
				if (b.invMass == 0) continue;
				
				b.x += dt * b.vx;
				b.y += dt * b.vy;
				b.r += dt * b.w;
				
				c = Math.cos(b.r);
				s = Math.sin(b.r);
				b.r11 = c; b.r12 = -s;
				b.r21 = s; b.r22 =  c;
			}
			
			/*/////////////////////////////////////////////////////////
			// SOLVE POSITION CONSTRAINTS
			/////////////////////////////////////////////////////////*/
			
			if (World.doPositionCorrection)
			{
				var contactsOkay:Boolean;
				var jointsOkay:Boolean;
				
				for (i = 0; i < iterations; i++)
				{
					contactsOkay = contactSolver.solvePosConstraints(Constants.k_contactBaumgarte);
					jointsOkay = true;
					for (j = 0; j < jointCount; j++)
					{
						jointsOkay = joints[j].solvePosConstraints();
						jointsOkay = jointsOkay && jointsOkay;
					}
					
					if (contactsOkay && jointsOkay)
						break;
				}
			}
		}
		
		public function updateSleep(dt:Number):void
		{
			var minSleepTime:Number = 2147483648;
			
			var linTolSqr:Number = Constants.k_linSleepToleranceSq;
			var angTolSqr:Number = Constants.k_angSleepToleranceSq;

			var b:RigidBody, i:int;

			for (i = 0; i < bodyCount; ++i)
			{
				b = bodies[i];
				if (b.invMass == 0)
					continue;
				
				if ((b.stateBits & RigidBody.k_bitAllowSleep) == 0)
				{
					b.sleepTime = 0;
					minSleepTime = 0;
				}
				
				if ((b.stateBits & RigidBody.k_bitAllowSleep) == 0 ||
				     b.w * b.w > angTolSqr || b.vx * b.vx + b.vy * b.vy > linTolSqr)
				{
					b.sleepTime = 0;
					minSleepTime = 0;
				}
				else
				{
					b.sleepTime += dt;
					minSleepTime = minSleepTime < b.sleepTime ? minSleepTime : b.sleepTime;
				}
			}
			
			if (minSleepTime >= Constants.k_timeToSleep)
			{
				for (i = 0; i < bodyCount; ++i)
				{
					b = bodies[i];
					b.stateBits |= RigidBody.k_bitSleep;
				}
			}
		}
	}
}