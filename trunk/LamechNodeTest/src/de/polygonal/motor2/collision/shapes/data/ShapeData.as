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
	import de.polygonal.motor2.collision.shapes.ShapeTypes;
	import de.polygonal.motor2.math.V2;

	/**
	 * A ShapeData object defines an abstract shape definition and acts as a
	 * template for constructing a shape. A ShapeData object can be safely
	 * reused to create multiple shapes out of it. 
	 */
	public class ShapeData
	{
		private var _restitution:Number;
		private var _friction:Number;

		/**
		 * The shape's position in modeling space along the x-axis.
		 */
		public var mx:Number;

		/**
		 * The shape's position in modeling space along the y-axis.
		 */
		public var my:Number;

		/**
		 * The shape's rotation in modeling space.
		 */
		public var mr:Number;
		
		/**
		 * A sensor shape collects contact information but never generates a
		 * collision.
		 */
		public var isSensor:Boolean;
		
		/**
		 * Use this to store application specify shape data.
		 */
		public var userData:*;
		
		/**
		 * The coefficient of friction (0..1). Default value is 0.2.
		 */
		public function get friction():Number
		{
			return _friction;
		}

		/** @private */
		public function set friction(val:Number):void
		{
			_friction = (val < 0) ? 0 : (val > 1) ? 1 : val;
		}

		/**
		 * The coefficient of restitution (0..1). The default value is 0.0.
		 * A value 0 zero indicates a completely inelastic collision, a value
		 * of one perfect elastic collision (object will bounce forever).
		 */
		public function get restitution():Number
		{
			return _restitution;
		}

		/** @private */
		public function set restitution(val:Number):void
		{
			_restitution = (val < 0) ? 0 : (val > 1) ? 1 : val;
		}

		/**
		 * The shape's density, usually in kg/m^2.
		 */
		public function get density():Number
		{
			return _density;
		};

		/** @private */
		public function set density(n:Number):void
		{
			_density = n;
			invalidate();
		}

		/**
		 * The shape's area.
		 */
		public function get area():Number
		{
			return NaN;
		}

		/**
		 * The collision category bits.
		 */
		public var categoryBits:int;

		/**
		 * The collision mask bits, the categories that this shape would accept
		 * for collision.
		 */
		public var maskBits:int;

		/**
		 * The collision groups allow a certain group of objects to never
		 * collide (negative) or always collide (positive). Non-zero group
		 * filtering always wins against the mask bits.
		 */
		public var groupIndex:int;
		
		/**
		 * Set a specific bit within the <code>categoryBits</code> bit field.
		 * 
		 * @param bit The bit to set; valid value are: 0 <= bit <= 31
		 * 
		 * @see #clrCategoryBit()
		 */
		public function setCategoryBit(bit:int):void
		{
			categoryBits |= (1 << bit);
		}
		
		/**
		 * Clear a specific bit within the <code>categoryBits</code> bit field.
		 * 
		 * @param bit The bit to clear; valid value are: 0 <= bit <= 31
		 * 
		 * @see #setCategoryBit()
		 */
		public function clrCategoryBit(bit:int):void
		{
			categoryBits &= ~(1 << bit);
		}
		
		/**
		 * Set a specific bit within the <code>maskBits</code> bit field.
		 * 
		 * @param bit The bit to set; valid value are: 0 <= bit <= 31
		 * 
		 * @see #clrCategoryBit()
		 */
		public function setMaskBit(bit:int):void
		{
			maskBits |= (1 << bit);
		}
		
		/**
		 * Clear a specific bit within the <code>categoryBits</code> bit field.
		 * 
		 * @param bit The bit to clear; valid value are: 0 <= bit <= 31
		 * 
		 * @see #setMaskBit()
		 */
		public function clrMaskBit(bit:int):void
		{
			maskBits &= ~(1 << bit);
		}
		
		/** @private */
		public var type:int;

		/** @private */
		public var next:ShapeData;

		/** @private */
		protected var _density:Number, _mass:Number, _I:Number;

		/** @private */
		protected var _cm:V2;

		/** @private */
		public function ShapeData(density:Number)
		{
			this.density = density;
			init();
		}

		/** @private */
		public function invalidate():void
		{
			_mass = Number.NaN;
			_I    = Number.NaN;
			_cm   = null;
		}

		/**
		 * The mass of the shape, usually in kilograms.
		 */
		public function getMass():Number
		{
			if (_density == 0)
				return 0;

			if (isNaN(_mass))
				computeMass();

			return _mass;
		}

		/**
		 * The rotational inertia of the shape.
		 */
		public function getInertia():Number
		{
			if (_density == 0)
				return 0;

			if (isNaN(_I))
				computeMass();

			return _I;
		}

		/**
		 * The shape's center of mass.
		 * This is the position of the shape's centroid relative to the shape's
		 * origin.
		 */
		public function getCM():V2
		{
			if (_cm == null)
				computeMass();

			return _cm;
		}

		/** @private */
		public function getShapeClass():Class
		{
			return null;
		}

		/** @private */
		protected function computeMass():void
		{
		}

		/** @private */
		protected function setType():void
		{
			type = ShapeTypes.UNKNOWN;
		}

		private function init():void
		{
			setType();

			mx = my = mr = .0;
			friction     = .2;
			restitution  = .0;

			categoryBits = 0x0001;
			maskBits     = 0xFFFF;
			groupIndex   = 0;
		}
	}
}