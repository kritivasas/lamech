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
package de.polygonal.motor2.collision.shapes.data
{
	import de.polygonal.motor2.collision.shapes.CircleShape;
	import de.polygonal.motor2.collision.shapes.ShapeTypes;
	import de.polygonal.motor2.math.V2;

	/**
	 * Defines the shape and mass properties of a circle.
	 */
	public class CircleData extends ShapeData
	{
		private var _radius:Number;

		/**
		 * Creates a new CircleData instance.
		 *
		 * @param density The circle's density.
		 * @param radius  The circle's radius.
		 */
		public function CircleData(density:Number, radius:Number)
		{
			super(density);

			this.radius = Math.abs(radius);
		}

		/**
		 * The circle's radius.
		 */
		public function get radius():Number
		{
			return _radius;
		}

		/**
		 * @private
		 */
		public function set radius(r:Number):void
		{
			_radius = r;
			invalidate();
		}

		/**
		 * @inheritDoc
		 */
		override public function get area():Number
		{
			return Math.PI * _radius * _radius;
		}

		/**
		 * @private
		 */
		override public function getShapeClass():Class
		{
			return CircleShape;
		}

		/**
		 * @private
		 */
		override protected function computeMass():void
		{
			_mass = _density * Math.PI * radius * radius;
			_I    = .5 * _mass * radius * radius;
			_cm   = new V2();
		}

		/**
		 * @private
		 */
		override protected function setType():void
		{
			type = ShapeTypes.CIRCLE;
		}
	}
}