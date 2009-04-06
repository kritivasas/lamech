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
package de.polygonal.motor2.dynamics.contact
{
	import de.polygonal.ds.Array2;
	import de.polygonal.motor2.collision.shapes.ShapeSkeleton;
	import de.polygonal.motor2.collision.shapes.ShapeTypes;
	import de.polygonal.motor2.dynamics.RigidBody;
	import de.polygonal.motor2.dynamics.contact.generator.*;

	/** @private */
	public class ContactFactory
	{
		private static var _contactMatrix:Array2;

		public function ContactFactory()
		{
			initializeContactMatrix();
		}

		public function create(shape1:ShapeSkeleton, shape2:ShapeSkeleton):Contact
		{
			var r:ContactRegister = _contactMatrix.get(shape1.type, shape2.type);
			var C:Class = r.constructor;
			if (C)
			{
				if (r.primary)
					return new C(shape1, shape2);
				else
				{
					var c:Contact = new C(shape2, shape1);
					c.secondary = true;

					//TODO needed ?
					for (var i:int = 0; i < c.manifoldCount; i++)
					{
						var m:Manifold = c.manifolds[i];
						m.nx = -m.nx;
						m.ny = -m.ny;

						/*
						if (createFcn)
						{
								b2Contact* c = createFcn(shape2, shape1, allocator);
								for (int32 i = 0; i < c->GetManifoldCount(); ++i)
								{
									b2Manifold* m = c->GetManifolds() + i;
									m->normal = -m->normal;
								}
								return c;
						}
						*/
					}
					return c;
				}
			}
			return null;
		}

		public function destroy(c:Contact):void
		{
			if (c.manifoldCount > 0)
			{
				c.shape1.body.wakeUp();
				c.shape2.body.wakeUp();
			}
			_contactMatrix.get(c.shape1.type, c.shape2.type).deconstruct(c);
		}

		private function initializeContactMatrix():void
		{
			_contactMatrix = new Array2(ShapeTypes.SHAPE_COUNT, ShapeTypes.SHAPE_COUNT);
			_contactMatrix.fill(ContactRegister);

			registerContactHandler(BoxContact       , ShapeTypes.BOX    , ShapeTypes.BOX);
			registerContactHandler(PolyContact      , ShapeTypes.BOX    , ShapeTypes.POLY);
			registerContactHandler(BoxCircleContact , ShapeTypes.BOX    , ShapeTypes.CIRCLE);
			registerContactHandler(BoxLineContact   , ShapeTypes.BOX    , ShapeTypes.LINE);
			registerContactHandler(PolyContact      , ShapeTypes.POLY   , ShapeTypes.POLY);
			registerContactHandler(PolyCircleContact, ShapeTypes.POLY   , ShapeTypes.CIRCLE);
			registerContactHandler(PolyLineContact  , ShapeTypes.POLY   , ShapeTypes.LINE);
			registerContactHandler(CircleContact    , ShapeTypes.CIRCLE , ShapeTypes.CIRCLE);			registerContactHandler(CircleLineContact, ShapeTypes.CIRCLE , ShapeTypes.LINE);
		}

		private function registerContactHandler(constructor:Class, type1:int, type2:int):void
		{
			ContactRegister(_contactMatrix.get(type1, type2)).constructor = constructor;
			ContactRegister(_contactMatrix.get(type1, type2)).primary = true;

			if (type1 != type2)
			{
				ContactRegister(_contactMatrix.get(type2, type1)).constructor = constructor;
				ContactRegister(_contactMatrix.get(type2, type1)).primary = false;
			}
		}
	}
}

internal class ContactRegister
{
	public var constructor:Class;
	public var deconstruct:Function;
	public var primary:Boolean;
}