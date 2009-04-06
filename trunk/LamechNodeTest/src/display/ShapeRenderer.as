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
	import de.polygonal.motor2.collision.shapes.LineShape;	
	
	import flash.display.Graphics;
	import flash.display.Sprite;
	import flash.events.Event;
	
	import de.polygonal.motor2.collision.shapes.ShapeSkeleton;
	import de.polygonal.motor2.collision.shapes.ShapeTypes;
	import de.polygonal.motor2.math.V2;
	import de.polygonal.motor2.dynamics.RigidBody;
	import de.polygonal.motor2.math.E2;	

	public class ShapeRenderer extends Sprite
	{
		public static const DEFAULT_STYLE:RenderStyle = new RenderStyle(0x666666, 0xffffff, .8, 0, 0);
		
		public var shape:ShapeSkeleton;
		
		protected var _x0:Number, _x1:Number;
		protected var _y0:Number, _y1:Number;
		protected var _r0:Number, _r1:Number;
		protected var _flags:int;
		protected var _style:RenderStyle;
		protected var _modelCanvas:Sprite;
		
		private var _redraw:Boolean = false;

		public function ShapeRenderer(shape:ShapeSkeleton, style:RenderStyle = null) 
		{
			this.shape = shape;
			_style = style != null ? style : DEFAULT_STYLE;
			init();
		}
		
		public function deconstruct():void
		{
			shape = null;
			removeChild(_modelCanvas);
			parent.removeChild(this);
		}

		public function get style():RenderStyle
		{
			return _style;	
		}
		
		public function set style(style:RenderStyle):void
		{
			_style = style.copy();
			invalidate();	
		}
		
		public function get modelCanvas():Sprite
		{
			return _modelCanvas;
		}

		public function update():void
		{
			_x0 = _x1; _x1 = shape.body.x;
			_y0 = _y1; _y1 = shape.body.y;
			_r0 = _r1; _r1 = shape.body.r;
		}

		public function render(alpha:Number = 1):void
		{
			//lerp between previous and current state
			//state = s1 * alpha + s0 * (1 - alpha)
			var t:Number = 1 - alpha;
			var xInterp:Number = _x1 * alpha + _x0 * t;
			var yInterp:Number = _y1 * alpha + _y0 * t;
			var rInterp:Number = _r1 * alpha + _r0 * t;
			
			//WCS transform
			_modelCanvas.x = xInterp;
			_modelCanvas.y = yInterp;
			_modelCanvas.rotation = rInterp * 57.295780;
		}
		
		public function toggleRender(flag:int):void
		{
			if (_flags & flag)
				_flags &= ~flag;
			else
				_flags |= flag;
			
			invalidate();
		}
		
		protected function drawModelSpace(g:Graphics):void
		{
			var s:RenderStyle = _style.copy();
			s.drawFill = true;
			s.fillClr = 0x666666;
			s.fillAlpha = 1;
			
			if (_flags & RenderFlags.RENDER_CENTER)
			{
				s.applyFill(g);
				g.drawRect(-2, -2, 4, 4);
				s.applyFill(g, true);
			}
			
			_style.applyLineStyle(g, false, "normal", "none", "miter");
			if (_flags & RenderFlags.RENDER_MODEL_POS)
				drawModelVertices(_modelCanvas.graphics);
		}

		protected function drawModelVertices(g:Graphics):void
		{
			if (shape.type == ShapeTypes.CIRCLE)
			{
				g.moveTo(0, 0);
				style.applyFill(g);
				
				g.drawCircle(shape.mx, shape.my, shape.radius);
				g.moveTo(shape.mx, shape.my);
				g.lineTo(shape.mx, shape.my - Math.min(shape.radius, 20));
				style.applyFill(g, true);
			}
			else
			if (shape.type == ShapeTypes.LINE)
			{
				if (LineShape(shape).infinite)
				{
					var d:V2 = shape.modelVertexChain.edge.d;
					var v:V2 = shape.modelVertexChain;
					g.moveTo(v.x - d.x * 1000, v.y - d.y * 1000);
					v = v.next;
					g.lineTo(v.x + d.x * 1000, v.y + d.y * 1000);
				}
				else
					drawVertexChain(g, shape.modelVertexChain);
			}						else
				drawVertexChain(g, shape.modelVertexChain);
		}
		
		protected function drawVertexChain(g:Graphics, chain:V2):void
		{
			var v:V2 = chain;
			g.moveTo(0, 0);
			style.applyFill(g);
			
			g.moveTo(v.x, v.y);
			while (true)
			{
				g.lineTo(v.x, v.y);
				if (v.isTail)
				{
					g.lineTo(v.next.x, v.next.y);
					break;
				}
				v = v.next;
			}
			
			style.applyFill(g, true);
		}

		protected function invalidate():void
		{
			if (stage) stage.invalidate();
			_redraw = true;
		}
		
		protected function init():void
		{
			_x0 = _x1 = _y0 = _y1 = _r0 = _r1 = 0;
			_flags = 0;
			
			_modelCanvas = new Sprite();
			
			this.addChild(_modelCanvas);
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
		}
		
		private function onRender(e:Event):void
		{	
			if (_redraw)
			{
				_redraw = false;			
				_modelCanvas.graphics.clear();
				drawModelSpace(_modelCanvas.graphics);
			}
		}
		
		private function onAddedToStage(e:Event):void
		{
			removeEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.RENDER, onRender);
			invalidate();
		}
	}
}
