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
	import flash.geom.Point;

	import de.polygonal.motor2.collision.shapes.LineShape;
	import de.polygonal.motor2.collision.shapes.ShapeTypes;
	import de.polygonal.motor2.math.V2;

	/**
	 * Line shape definition.
	 */
	public class LineData extends ShapeData
	{
		/**
		 * The start position of the line segment in model space.
		 */
		public const a:Point = new Point();

		/**
		 * The end position of the line segment in model space.
		 */
		public const b:Point = new Point();

		/**
		 * Settings this flag to true will turn the line segment into an
		 * infinite line extending which extends in both directions (aka plane)
		 */
		public var infinite:Boolean;

		/**
		 * True = collisions will be detected in the positive & negative
		 * halfspace of the line (the positive halfspace is defined by the
		 * clockwise normal of the vector AB).
		 */
		public var doubleSided:Boolean;

		/**
		 * Creates a new LineData instance.
		 *
		 * @param a        The line start position.
		 * @param b        The line end position.
		 * @param infinite Turns the line into a plane.
		 */
		public function LineData(a:Point, b:Point, infinite:Boolean = false, doubleSided:Boolean = true)
		{
			super(0);

			var dx:Number = b.x - a.x;
			var dy:Number = b.y - a.y;
			if (Math.sqrt(dx * dx + dy + dy) <= 1e-6)
				throw new Error("overlapping vertices detected");

			//transform line so center of a,b is at 0,0
			var offsetx:Number = a.x + (b.x - a.x) * .5;
			var offsety:Number = a.y + (b.y - a.y) * .5;

			this.a.x = a.x - offsetx; this.b.x = b.x - offsetx;
			this.a.y = a.y - offsety; this.b.y = b.y - offsety;

			this.infinite = infinite;
			this.doubleSided = doubleSided;
		}

		/**
		 * The shape's density.
		 */
		override public function get density():Number
		{
			return 0;
		}

		/** @private */
		override public function set density(n:Number):void
		{
			super.density = 0;
		}

		/** @private */
		override public function get area():Number
		{
			return 0;
		}

		/** @private */
		override public function getShapeClass():Class
		{
			return LineShape;
		}

		/** @private */
		override protected function computeMass():void
		{
			_mass = 0;
			_I    = 0;
			_cm   = new V2(a.x + 0.5 * (b.x - a.x),
						   a.y + 0.5 * (b.y - a.y));
		}

		/** @private */
		override protected function setType():void
		{
			type = ShapeTypes.LINE;
		}
	}
}