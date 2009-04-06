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
	import de.polygonal.motor2.collision.shapes.ShapeSkeleton;
	import de.polygonal.motor2.dynamics.contact.Contact;
	import de.polygonal.motor2.dynamics.contact.ContactPoint;
	import de.polygonal.motor2.dynamics.contact.Manifold;	

	public class ConvexContact extends Contact
	{	
		public var manifold:Manifold;
		
		private var _m1Cp1:ContactPoint;
		private var _m1Cp2:ContactPoint;
		
		private var _id0_1:uint  , _id0_2:uint;
		private var _Pn0_1:Number, _Pn0_2:Number;
		private var _Pt0_1:Number, _Pt0_2:Number;
		
		public function ConvexContact(shape1:ShapeSkeleton, shape2:ShapeSkeleton)
		{
			super(shape1, shape2);
			
			//TODO optimize: create manifold buffer queue
			manifold = manifolds[0] = new Manifold(); 
			
			_m1Cp1 = manifold.c0;
			_m1Cp2 = manifold.c1;
		}
		
		override public function evaluate():void
		{
			if (!shape1.synced) shape1.toWorldSpace();
			if (!shape2.synced) shape2.toWorldSpace();
			
			if (World.doWarmStarting)
			{
				var k0:int, k1:int;
				
				//store impulses from previous time step
				_m1Cp1.matched = false;
				_m1Cp2.matched = false;
				
				k0 = manifold.pointCount;
				if (k0 > 0)
				{
					_id0_1 = _m1Cp1.id.key;
					_Pn0_1 = _m1Cp1.Pn;
					_Pt0_1 = _m1Cp1.Pt;
					
					if (k0 > 1)
					{
						_id0_2 = _m1Cp2.id.key;
						_Pn0_2 = _m1Cp2.Pn;
						_Pt0_2 = _m1Cp2.Pt;
					}
				}
				
				//create contact manifold
				_collider.collide(manifold, shape1, shape2, this);
								
				k1 = manifold.pointCount;
				if (k1 > 0)
					manifoldCount = 1;
				else
				{
					manifoldCount = 0;
					return;
				}
				
				//reapply impulses for matching new contact id's
				_m1Cp1.Pn = .0;
				_m1Cp1.Pt = .0;
				_m1Cp2.Pn = .0;
				_m1Cp2.Pt = .0;
				
				if (k1 == 1)
				{
					if (k0 == 1)
					{
						//match one new contact against one old contact
						
						//compare new1 -> old1
						if (_m1Cp1.id.key == _id0_1)
						{
							_m1Cp1.Pn = _Pn0_1;
							_m1Cp1.Pt = _Pt0_1;
							_m1Cp1.matched = true;
						}
					}
					else
					if (k0 == 2)
					{
						//match one new contact against two old contacts
						
						var newKey:int = _m1Cp1.id.key;
						
						//compare new1 -> old1
						if (newKey == _id0_1)
						{
							_m1Cp1.Pn = _Pn0_1;
							_m1Cp1.Pt = _Pt0_1;
							_m1Cp1.matched = true;
						}
						else
						//compare new1 -> old2
						if (newKey == _id0_2);
						{
							_m1Cp1.Pn = _Pn0_2;
							_m1Cp1.Pt = _Pn0_2;
							_m1Cp1.matched = true;
						}
					}
				}
				else
				if (k1 == 2)
				{
					if (k0 == 1)
					{
						//match two new contacts against one old contact
						
						//compare new1 -> old1
						if (_m1Cp1.id.key == _id0_1)
						{
							_m1Cp1.Pn = _Pn0_1;
							_m1Cp1.Pt = _Pt0_1;
							_m1Cp1.matched = true;
						}
						else
						//compare new2 -> old1
						if (_m1Cp2.id.key == _id0_1)
						{
							_m1Cp2.Pn = _Pn0_1;
							_m1Cp2.Pt = _Pt0_1;
							_m1Cp2.matched = true;
						}
					}
					else
					if (k0 == 2)
					{
						//match two new contacts against two old contacts
						
						//new1 -> old1 & old2
						
						//compare new1 -> old1
						if (_m1Cp1.id.key == _id0_1)
						{
							_m1Cp1.Pn = _Pn0_1;
							_m1Cp1.Pt = _Pt0_1;
							_m1Cp1.matched = true;
							
							//compare new2 -> old2
							if (_m1Cp2.id.key == _id0_2)
							{
								_m1Cp2.Pn = _Pn0_2;
								_m1Cp2.Pt = _Pt0_2;
								_m1Cp2.matched = true;
								return;
							}
						}
						else
						{
							//compare new1 -> old2
							if (_m1Cp1.id.key == _id0_2)
							{
								_m1Cp1.Pn = _Pn0_2;
								_m1Cp1.Pt = _Pt0_2;
								_m1Cp1.matched = true;
								
								//compare new2 -> old1
								if (_m1Cp2.id.key == _id0_1)
								{
									_m1Cp2.Pn = _Pn0_1;
									_m1Cp2.Pt = _Pt0_1;
									_m1Cp2.matched = true;
									return;
								}
							}
						}
						
						//new2 -> old1 & old2
						
						//compare new2 -> old1
						if (_m1Cp2.id.key == _id0_1)
						{
							_m1Cp2.Pn = _Pn0_1;
							_m1Cp2.Pt = _Pt0_1;
							_m1Cp2.matched = true;
						}
						else
						{
							//compare new2 -> old2
							if (_m1Cp2.id.key == _id0_2)
							{
								_m1Cp2.Pn = _Pn0_2;
								_m1Cp2.Pt = _Pt0_2;
								_m1Cp2.matched = true;
							}
						}
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
	}
}