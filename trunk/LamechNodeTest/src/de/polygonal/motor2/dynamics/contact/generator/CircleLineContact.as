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
package de.polygonal.motor2.dynamics.contact.generator
{
	import de.polygonal.motor2.World;
	import de.polygonal.motor2.collision.pairwise.CollideCircleLineDoubleSided;
	import de.polygonal.motor2.collision.pairwise.CollideCircleLineSingleSided;
	import de.polygonal.motor2.collision.pairwise.CollideCirclePlaneDoubleSided;
	import de.polygonal.motor2.collision.pairwise.CollideCirclePlaneSingleSided;
	import de.polygonal.motor2.collision.pairwise.Collider;
	import de.polygonal.motor2.collision.shapes.LineShape;
	import de.polygonal.motor2.collision.shapes.ShapeSkeleton;
	import de.polygonal.motor2.dynamics.contact.Contact;
	import de.polygonal.motor2.dynamics.contact.ContactPoint;
	import de.polygonal.motor2.dynamics.contact.Manifold;	

	public class CircleLineContact extends Contact
	{	
		private static const COLLIDE_CIRCLE_PLANE_SS:CollideCirclePlaneSingleSided = new CollideCirclePlaneSingleSided();		private static const COLLIDE_CIRCLE_PLANE_DS:CollideCirclePlaneDoubleSided = new CollideCirclePlaneDoubleSided(); 
		
		private static const COLLIDE_CIRCLE_LINE_SS:CollideCircleLineSingleSided = new CollideCircleLineSingleSided();
		private static const COLLIDE_CIRCLE_LINE_DS:CollideCircleLineDoubleSided = new CollideCircleLineDoubleSided();

		public var manifold:Manifold;
		
		private var _m1Cp1:ContactPoint;
		private var _id0:uint;
		private var _Pn0:Number;
		private var _Pt0:Number;
		
		public function CircleLineContact(shape1:ShapeSkeleton, shape2:ShapeSkeleton)
		{
			super(shape1, shape2);
			
			manifold = manifolds[0] = new Manifold();
			_m1Cp1 = manifold.c0; 
			manifold.c0.Pn = 0;
			manifold.c0.Pt = 0;
		}

		override public function evaluate():void
		{
			//line segment is static
			//if (!shape1.synced) shape1.toWorldSpace();
			
			if (World.doWarmStarting)
			{
				//store impulses from previous time step
				_m1Cp1.matched = false;
				var k0:int = manifold.pointCount;
				if (k0 > 0)
				{
					_id0 = _m1Cp1.id.key;
					_Pn0 = _m1Cp1.Pn;
					_Pt0 = _m1Cp1.Pt;
				}
				
				//create contact manifold 
				_collider.collide(manifold, shape1, shape2, this);
				
				var k1:int = manifold.pointCount;
				if (k1 > 0)
					manifoldCount = 1;
				else
				{
					manifoldCount = 0;
					return;
				}
				
				//reapply impulse if contact id matches
				_m1Cp1.Pn = .0;
				_m1Cp1.Pt = .0;
				if (k0 == 1 && k1 == 1)
				{
					//match one new contact against one old contact
					if (_m1Cp1.id.key == _id0)
					{
						_m1Cp1.Pn = _Pn0;
						_m1Cp1.Pt = _Pt0;
						_m1Cp1.matched = true;
					}
				}
			}
			else
			{
				//create contact manifold 
				_collider.collide(manifold, shape1, shape2, this);
				manifoldCount = manifold.pointCount > 0 ? 1 : 0;
			}
		}

		override protected function getCollider():Collider
		{
			var ls:LineShape = LineShape(shape2);
			if (ls.infinite)
			{
				if (ls.doubleSided)
					return COLLIDE_CIRCLE_PLANE_DS;
				return COLLIDE_CIRCLE_PLANE_SS;
			}
			
			if (ls.doubleSided)
				return COLLIDE_CIRCLE_LINE_DS;
			return COLLIDE_CIRCLE_LINE_SS;	
		}
	}
}