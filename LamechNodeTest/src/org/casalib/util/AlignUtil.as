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
package org.casalib.util {
	import flash.geom.Rectangle;
	import flash.display.DisplayObject;
	
	/**
		Provides utility functions aligning DisplayObjects.
		
		@author Aaron Clinger
		@version 01/05/09
	*/
	public class AlignUtil {
		
		/**
			Aligns a DisplayObject to the left side of the bounding Rectangle.
			
			@param displayObject: The DisplayObject to align.
			@param bounds: The area in which to align the DisplayObject.
			@param snapToPixel: Force the position to whole pixels {@code true}, or to let the DisplayObject be positioned on sub-pixels {@code false}.
		*/
		public static function alignLeft(displayObject:DisplayObject, bounds:Rectangle, snapToPixel:Boolean = true):void {
			displayObject.x = snapToPixel ? Math.round(bounds.x) : bounds.x;
		}
		
		/**
			Aligns a DisplayObject to the right side of the bounding Rectangle.
			
			@param displayObject: The DisplayObject to align.
			@param bounds: The area in which to align the DisplayObject.
			@param snapToPixel: Force the position to whole pixels {@code true}, or to let the DisplayObject be positioned on sub-pixels {@code false}.
		*/
		public static function alignRight(displayObject:DisplayObject, bounds:Rectangle, snapToPixel:Boolean = true):void {
			var rightX:Number = bounds.width - displayObject.width + bounds.x;
			
			displayObject.x = snapToPixel ? Math.round(rightX) : rightX;
		}
		
		/**
			Aligns a DisplayObject to the top of the bounding Rectangle.
			
			@param displayObject: The DisplayObject to align.
			@param bounds: The area in which to align the DisplayObject.
			@param snapToPixel: Force the position to whole pixels {@code true}, or to let the DisplayObject be positioned on sub-pixels {@code false}.
		*/
		public static function alignTop(displayObject:DisplayObject, bounds:Rectangle, snapToPixel:Boolean = true):void {
			displayObject.y = snapToPixel ? Math.round(bounds.y) : bounds.y;
		}
		
		/**
			Aligns a DisplayObject to the bottom of the bounding Rectangle.
			
			@param displayObject: The DisplayObject to align.
			@param bounds: The area in which to align the DisplayObject.
			@param snapToPixel: Force the position to whole pixels {@code true}, or to let the DisplayObject be positioned on sub-pixels {@code false}.
		*/
		public static function alignBottom(displayObject:DisplayObject, bounds:Rectangle, snapToPixel:Boolean = true):void {
			var bottomY:Number = bounds.height - displayObject.height + bounds.y;
			
			displayObject.y = snapToPixel ? Math.round(bottomY) : bottomY;
		}
		
		/**
			Aligns a DisplayObject to the horizontal center of the bounding Rectangle.
			
			@param displayObject: The DisplayObject to align.
			@param bounds: The area in which to align the DisplayObject.
			@param snapToPixel: Force the position to whole pixels {@code true}, or to let the DisplayObject be positioned on sub-pixels {@code false}.
		*/
		public static function alignCenter(displayObject:DisplayObject, bounds:Rectangle, snapToPixel:Boolean = true):void {
			var centerX:Number = bounds.width * 0.5 - displayObject.width * 0.5 + bounds.x;
			
			displayObject.x = snapToPixel ? Math.round(centerX) : centerX;
		}
		
		/**
			Aligns a DisplayObject to the vertical middle of the bounding Rectangle.
			
			@param displayObject: The DisplayObject to align.
			@param bounds: The area in which to align the DisplayObject.
			@param snapToPixel: Force the position to whole pixels {@code true}, or to let the DisplayObject be positioned on sub-pixels {@code false}.
		*/
		public static function alignMiddle(displayObject:DisplayObject, bounds:Rectangle, snapToPixel:Boolean = true):void {
			var centerY:Number = bounds.height * 0.5 - displayObject.height * 0.5 + bounds.y;
			
			displayObject.y = snapToPixel ? Math.round(centerY) : centerY;
		}
		
		/**
			Aligns a DisplayObject to the horizontal center and vertical middle of the bounding Rectangle.
			
			@param displayObject: The DisplayObject to align.
			@param bounds: The area in which to align the DisplayObject.
			@param snapToPixel: Force the position to whole pixels {@code true}, or to let the DisplayObject be positioned on sub-pixels {@code false}.
		*/
		public static function alignCenterMiddle(displayObject:DisplayObject, bounds:Rectangle, snapToPixel:Boolean = true):void {
			AlignUtil.alignCenter(displayObject, bounds, snapToPixel);
			AlignUtil.alignMiddle(displayObject, bounds, snapToPixel);
		}
	}
}