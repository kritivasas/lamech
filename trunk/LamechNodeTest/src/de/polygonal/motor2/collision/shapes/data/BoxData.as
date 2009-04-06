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
	import de.polygonal.motor2.collision.shapes.BoxShape;
	import de.polygonal.motor2.collision.shapes.ShapeTypes;
	import de.polygonal.motor2.math.V2;

	/**
	 * Defines the shape and mass properties of a box.
	 */
	public class BoxData extends ShapeData
	{
		private var _w:Number, _h:Number;

		/**
		 * Creates a new BoxData instance.
		 *
		 * @param density The box's density.
		 * @param width   The box's width.
		 * @param height  The box's height.
		 */
		public function BoxData(density:Number, width:Number, height:Number)
		{
			super(density);

			this.width  = width;
			this.height = height;
		}

		/**
		 * The box's width.
		 */
		public function get width():Number
		{
			return _w;
		}

		/**
		 * @private
		 */
		public function set width(val:Number):void
		{
			_w = val;
			invalidate();
		}

		/**
		 * The box's height.
		 */
		public function get height():Number
		{
			return _h;
		}

		/**
		 * @private
		 */
		public function set height(val:Number):void
		{
			_h = val;
			invalidate();
		}

		/**
		 * @inheritDoc
		 */
		override public function get area():Number
		{
			return _w * _h;
		}

		/**
		 * @private
		 */
		override public function getShapeClass():Class
		{
			return BoxShape;
		}

		/**
		 * @private
		 */
		override protected function computeMass():void
		{
			_mass = _density * _w * _h;
			_I    = _mass / 12 * (_w * _w + _h * _h);
			_cm   = new V2();
		}

		/**
		 * @private
		 */
		override protected function setType():void
		{
			type = ShapeTypes.BOX;
		}
	}
}