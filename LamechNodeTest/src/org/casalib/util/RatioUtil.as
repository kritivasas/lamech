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
	import org.casalib.math.Percent;
	
	/**
		Provides utility functions for ratio scaling.
		
		@author Aaron Clinger
		@version 08/29/08
	*/
	public class RatioUtil {
		
		/**
			Determines the ratio of width to height.
			
			@param size: The area's width and height expressed as a {@code Rectangle}. The {@code Rectangle}'s {@code x} and {@code y} values are ignored.
		*/
		public static function widthToHeight(size:Rectangle):Number {
			return size.width / size.height;
		}
		
		/**
			Determines the ratio of height to width.
			
			@param size: The area's width and height expressed as a {@code Rectangle}. The {@code Rectangle}'s {@code x} and {@code y} values are ignored.
		*/
		public static function heightToWidth(size:Rectangle):Number {
			return size.height / size.width;
		}
		
		/**
			Scales an area's width and height while preserving aspect ratio.
			
			@param size: The area's width and height expressed as a {@code Rectangle}. The {@code Rectangle}'s {@code x} and {@code y} values are ignored.
			@param amount: The amount you wish to scale by.
		*/
		public static function scale(size:Rectangle, amount:Percent):Rectangle {
			var scaled:Rectangle = size.clone();
			
			scaled.width  *= amount.decimalPercentage;
			scaled.height *= amount.decimalPercentage;
			
			return scaled;
		}
		
		/**
			Scales the width of an area while preserving aspect ratio.
			
			@param size: The area's width and height expressed as a {@code Rectangle}. The {@code Rectangle}'s {@code x} and {@code y} values are ignored.
			@param height: The new height of the area.
		*/
		public static function scaleWidth(size:Rectangle, height:Number):Rectangle {
			var scaled:Rectangle = size.clone();
			var ratio:Number     = RatioUtil.widthToHeight(size);
			
			scaled.width  = height * ratio;
			scaled.height = height;
			
			return scaled;
		}
		
		/**
			Scales the height of an area while preserving aspect ratio.
			
			@param size: The area's width and height expressed as a {@code Rectangle}. The {@code Rectangle}'s {@code x} and {@code y} values are ignored.
			@param width: The new width of the area.
		*/
		public static function scaleHeight(size:Rectangle, width:Number):Rectangle {
			var scaled:Rectangle = size.clone();
			var ratio:Number     = RatioUtil.heightToWidth(size);
			
			scaled.width  = width;
			scaled.height = width * ratio;
			
			return scaled;
		}
		
		/**
			Resizes an area to fill the bounding area while preserving aspect ratio.
			
			@param size: The area's width and height expressed as a {@code Rectangle}. The {@code Rectangle}'s {@code x} and {@code y} values are ignored.
			@param bounds: The area to fill. The {@code Rectangle}'s {@code x} and {@code y} values are ignored.
		*/
		public static function scaleToFill(size:Rectangle, bounds:Rectangle):Rectangle {
			var scaled:Rectangle = RatioUtil.scaleHeight(size, bounds.width);
			
			if (scaled.height < bounds.height)
				scaled = RatioUtil.scaleWidth(size, bounds.height);
			
			return scaled;
		}
		
		/**
			Resizes an area to the maximum size of a bounding area without exceeding while preserving aspect ratio.
			
			@param size: The area's width and height expressed as a {@code Rectangle}. The {@code Rectangle}'s {@code x} and {@code y} values are ignored.
			@param bounds: The area the rectangle needs to fit within. The {@code Rectangle}'s {@code x} and {@code y} values are ignored.
		*/
		public static function scaleToFit(size:Rectangle, bounds:Rectangle):Rectangle {
			var scaled:Rectangle = RatioUtil.scaleHeight(size, bounds.width);
			
			if (scaled.height > bounds.height)
				scaled = RatioUtil.scaleWidth(size, bounds.height);
			
			return scaled;
		}
	}
}