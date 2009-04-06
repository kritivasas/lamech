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
package display
{
	import flash.display.Graphics;		

	public class RenderStyle
	{
		public var drawLine:Boolean;
		public var drawFill:Boolean;
		
		public var lineClr:uint;
		public var fillClr:uint;
		
		public var lineAlpha:Number;
		public var fillAlpha:Number;
		
		public var lineThickness:Number;
		
		public function RenderStyle(lineClr:uint = 0, fillClr:uint = 0xffffff,
			lineAlpha:Number = 1, fillAlpha:Number = 0, lineThickness:Number = 0)
		{
			drawLine = true;
			drawFill = true;
			
			this.lineClr = lineClr;
			this.fillClr = fillClr;
			
			this.lineAlpha = lineAlpha;
			this.fillAlpha = fillAlpha;
			
			this.lineThickness = lineThickness;
		}
		
		public function applyLineStyle(canvas:Graphics, pixelHinting:Boolean = false, scaleMode:String = "normal", caps:String = null, joints:String = null, miterLimit:Number = 3):void
		{
			if (drawLine)
				canvas.lineStyle(lineThickness, lineClr, lineAlpha, pixelHinting, scaleMode, caps, joints, miterLimit);
		}
		
		public function applyFill(canvas:Graphics, end:Boolean = false):void
		{
			if (!drawFill) return;
			
			if (end)
				canvas.endFill();
			else
				canvas.beginFill(fillClr, fillAlpha);
		}
		
		public function setLineRGBA(r:int, g:int, b:int, a:int = 1):void
		{
			lineClr = r << 16 | g << 8 | b;
			lineAlpha = a;
		}
		
		public function setFillRGBA(r:int, g:int, b:int, a:int = 1):void
		{
			fillClr = r << 16 | g << 8 | b;
			fillAlpha = a;
		}
		
		public function copy():RenderStyle
		{
			var s:RenderStyle = new RenderStyle(lineClr, fillClr, lineAlpha, fillAlpha, lineThickness);
			s.drawLine = drawLine;
			s.drawFill = drawFill;
			return s;
		}
		
		public function paste(s:RenderStyle):void
		{
			drawLine = s.drawLine;
			drawFill = s.drawFill;
			
			lineClr = s.lineClr;
			fillClr = s.fillClr;
			lineAlpha = s.lineAlpha;
			fillAlpha = s.fillAlpha;
			lineThickness = s.lineThickness;
		}
	}
}