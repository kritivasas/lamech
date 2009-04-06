﻿/*
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
package de.polygonal.motor2.utils 
{
	import de.polygonal.ds.Iterator;
	import de.polygonal.motor2.World;
	import de.polygonal.motor2.collision.shapes.ShapeSkeleton;
	import de.polygonal.motor2.dynamics.RigidBody;	

	public class ShapeIterator implements Iterator
	{
		private var _world:World;
		private var _body:RigidBody;
		private var _shape:ShapeSkeleton;

		public function ShapeIterator(world:World)
		{
			_world = world;
			start();
		}

		public function hasNext():Boolean
		{
			return (_shape != null) || (_body != null && _body.next != null);
		}
		
		public function next():*
		{
			var s:ShapeSkeleton = null;
			
			if (_shape)
			{
				s = _shape;
				_shape = _shape.next;
			}
			else
			{
				_body = _body.next;
				if (_body)
				{
					_shape = _body.shapeList;
					s = _shape;
					_shape = _shape.next;
				}
			}
			
			return s;
		}
		
		public function start():void
		{
			_body = _world.bodyList;
			_shape = _body.shapeList;
		}

		public function get data():*
		{
			throw new Error("unsupported");
		}
		
		public function set data(obj:*):void
		{	
			throw new Error("unsupported");
		}
		
		public function remove():void
		{
			throw new Error("unsupported");
		}
	}
}