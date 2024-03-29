/*
	CASA Lib for ActionScript 3.0
	Copyright (c) 2009, Aaron Clinger & Contributors of CASA Lib
	All rights reserved.
	
	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:
	
	- Redistributions of source code must retain the above copyright notice,
	  this list of conditions and the following disclaimer.
	
	- Redistributions in binary form must reproduce the above copyright notice,
	  this list of conditions and the following disclaimer in the documentation
	  and/or other materials provided with the distribution.
	
	- Neither the name of the CASA Lib nor the names of its contributors
	  may be used to endorse or promote products derived from this software
	  without specific prior written permission.
	
	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
	ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
	LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
	CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
	SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
	INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
	CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
	ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
	POSSIBILITY OF SUCH DAMAGE.
*/
package org.casalib.transitions {
	
	/**
		A simple property tween class that extends {@link Tween}.
		
		@author Aaron Clinger
		@author Mike Creighton
		@version 07/08/08
		@example
			<code>
				package {
					import fl.motion.easing.Bounce;
					import flash.display.MovieClip;
					import flash.display.Sprite;
					import org.casalib.transitions.PropertyTween;
					
					
					public class MyExample extends MovieClip {
						protected var _box:Sprite;
						protected var _tween:PropertyTween;
						
						
						public function MyExample() {
							super();
							
							this._box = new Sprite();
							this._box.graphics.beginFill(0xFF00FF);
							this._box.graphics.drawRect(0, 0, 25, 25);
							this._box.graphics.endFill();
							
							this.addChild(this._box);
							
							this._tween = new PropertyTween(this._box, "x", Bounce.easeOut, 200, 5);
							this._tween.start();
						}
					}
				}
			</code>
		@usageNote If you want to tween a value other than a property use {@link Tween}.
	*/
	public class PropertyTween extends Tween {
		protected var _scope:Object;
		protected var _property:String;
		
		
		/**
			Creates and defines a new PropertyTween.
			
			@param scope: An object that contains the property specified by {@code property}.
			@param property: Name of the property you want to tween.
			@param equation: The tween equation.
			@param endPos: The ending value of the transition.
			@param duration: Length of time of the transition.
			@param useFrames: Indicates to use frames {@code true}, or seconds {@code false} in relation to the value specified in the {@code duration} parameter.
			@usageNote The function specified in the {@code equation} parameter must follow the (currentTime, startPosition, endPosition, totalTime) parameter standard.
		*/
		public function PropertyTween(scope:Object, property:String, equation:Function, endPos:Number, duration:Number, useFrames:Boolean = false) {
			this._scope    = scope;
			this._property = property;
			
			super(equation, this.position, endPos, duration, useFrames);
		}
		
		/**
			@exclude
		*/
		override public function start():void {
			this._initPropertyTween();
			
			super.start();
		}
		
		/**
			@exclude
		*/
		override public function continueTo(endPos:Number, duration:Number):void {
			this._initPropertyTween();
			
			super.continueTo(endPos, duration);
		}
		
		/**
			@exclude
		*/
		override public function get position():Number {
			return this.scope[this.property];
		}
		
		/**
			@exclude
		*/
		override public function set position(pos:Number):void {
			this.scope[this.property] = pos;
		}
		
		/**
			Retrieves the object defined as scope in the class' constructor.
		*/
		public function get scope():Object {
			return this._scope;
		}
		
		/**
			Retrieves the property as a String defined in the class' constructor.
		*/
		public function get property():String {
			return this._property;
		}
		
		protected function _initPropertyTween():void {
			this._begin   = this.position;
			this._diff    = this._end - this._begin;
		}
	}
}