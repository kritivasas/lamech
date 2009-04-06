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
	
	import flash.display.DisplayObject;
	import flash.display.Graphics;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Point;
	import flash.text.AntiAliasType;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	import de.polygonal.motor2.collision.shapes.PolyShape;
	import de.polygonal.motor2.collision.shapes.ShapeSkeleton;
	import de.polygonal.motor2.collision.shapes.ShapeTypes;
	import de.polygonal.motor2.math.Tri2;
	import de.polygonal.motor2.math.V2;		

	public class DebugShapeRenderer extends ShapeRenderer
	{
		//[Embed(source="C:/WINDOWS/Fonts/arial.ttf", fontFamily="arial")]
		public var Arial:Class;
		
		private var _labels:Array;
		private var _reqWCS:int = (RenderFlags.RENDER_WORLD_POS | RenderFlags.RENDER_WORLD_NORMALS | RenderFlags.RENDER_WORLD_EDGES | RenderFlags.RENDER_PROXY | RenderFlags.RENDER_VERTEX_IDS);

		public function DebugShapeRenderer(shape:ShapeSkeleton, style:RenderStyle = null) 
		{
			super(shape, style);
		}

		override public function deconstruct():void
		{
			if (_labels)
			{
				for (var i:int = 0; i < _labels.length; i++)
					removeChild(_labels[i]);
				_labels = null;
			}
			super.deconstruct();
		}

		override public function render(alpha:Number = 1):void
		{
			super.render(alpha);
			graphics.clear();
			graphics.lineStyle(0, 0xff00ff, 1);
			
			_modelCanvas.alpha = shape.body.isSleeping() || shape.body.isFrozen() ? .25 : 1;
			
			if (_flags & _reqWCS) shape.toWorldSpace();
			
			if (_flags & RenderFlags.RENDER_WORLD_POS)
				drawWorldVertices(graphics);
			
			if (_flags & RenderFlags.RENDER_WORLD_NORMALS)
				drawWorldNormals(graphics);
				
			if (_flags & RenderFlags.RENDER_WORLD_NORMALS)
				drawWorldEdges(graphics);
			
			if (_flags & RenderFlags.RENDER_PROXY)
				drawProxy(graphics);
			
			if (_flags & RenderFlags.RENDER_TRIANGLES)
				drawWorldTriangles(graphics);
				
			if (_flags & RenderFlags.RENDER_VERTEX_IDS)
				alignVertexIds();
		}
		
		override protected function drawModelSpace(g:Graphics):void
		{
			super.drawModelSpace(g);
			
			if (_flags & RenderFlags.RENDER_MODEL_NORMALS) drawModelNormals(g);
			if (_flags & RenderFlags.RENDER_MODEL_AXIS)    drawModelAxis(g);
			if (_flags & RenderFlags.RENDER_MODEL_EDGES)   drawModelEdges(g);
			
			if (_flags & RenderFlags.RENDER_VERTEX_IDS && shape.type != ShapeTypes.CIRCLE)
				drawVertexIds();
			else
				clearLabels();
		}
		
		protected function drawModelNormals(g:Graphics):void
		{
			if (shape.type == ShapeTypes.CIRCLE) return;
			
			g.lineStyle(0, 0x0000ff, .8);
			
			var xmid:Number, ymid:Number;
			
			var v:V2 = shape.modelVertexChain;
			var n:V2 = shape.modelNormalChain;
			
			g.moveTo(v.x, v.y);
			
			while (true)
			{
				xmid = v.x + (v.next.x - v.x) * .5;
				ymid = v.y + (v.next.y - v.y) * .5;
				
				g.moveTo(xmid, ymid);
				g.lineTo(xmid + n.x * 6, ymid + n.y * 6);
				
				if (v.isTail) break;
				
				if (shape.type == ShapeTypes.LINE)
					if (!LineShape(shape).doubleSided)
						break;
						
				v = v.next;
				n = n.next;
			}
		}
		
		protected function drawModelEdges(g:Graphics):void
		{
			if (shape.type == ShapeTypes.CIRCLE) return;
			
			g.lineStyle(0, 0x00ffff, .8);
			
			var xmid:Number, ymid:Number;
		
			var v:V2 = shape.modelVertexChain;
			var n:V2 = shape.modelNormalChain;
		
			g.moveTo(v.x, v.y);
		
			while (true)
			{
				xmid = v.x + (v.next.x - v.x) * .5;
				ymid = v.y + (v.next.y - v.y) * .5;
				
				g.moveTo(v.x, v.y);
				g.lineTo(xmid, ymid);
				
				if (v.isTail) break;
				
				v = v.next;
				n = n.next;
			}
		}
		
		protected function drawModelAxis(g:Graphics):void
		{
			var p:V2 = new V2();
			shape.getShapeOffset(p);
			g.lineStyle(0, 0xff0000, 1);
			g.moveTo(p.x, p.y);
			g.lineTo(p.x + Math.min(shape.ex - 2, 12), p.y);
			
			g.lineStyle(0, 0x00ff00, 1);
			g.moveTo(p.x, p.y);
			g.lineTo(p.x, p.y + Math.min(shape.ey - 2, 12));
		}
		
		protected function drawWorldTriangles(g:Graphics):void
		{
			g.lineStyle(0, 0, 0);
			
			if (shape.triangleList == null)
				shape.triangulate();
			
			var i:int = 0;
			
			var t:Tri2 = shape.triangleList;
			while (t)
			{
				g.beginFill(i++ & 1 ? 0xff00ff : 0xffff00, .5);
				g.moveTo(t.a.x, t.a.y);				g.lineTo(t.b.x, t.b.y);				g.lineTo(t.c.x, t.c.y);
				g.endFill();
				
				t = t.next;
			}
		}
		
		protected function drawVertexIds():void
		{
			clearLabels();
			
			var v:V2 = shape.worldVertexChain;
			
			var font:Font = new Arial as Font;
			var tfm:TextFormat = new TextFormat(font.fontName, 7, 0, true);
			
			_labels = [];
			
			while (true)
			{
				var tf:TextField = new TextField();
				tf.autoSize = TextFieldAutoSize.LEFT;
				tf.defaultTextFormat = tfm;
				tf.text = String(v.index);
				tf.embedFonts = true;
				tf.antiAliasType = AntiAliasType.ADVANCED;
				tf.selectable = false;
				
				addChild(tf);
				_labels.push(tf);
				
				if (v.isTail) break;
				v = v.next;
			}
			
			alignVertexIds();
		}
		
		protected function alignVertexIds():void
		{
			if (!_labels) return;
			
			var v:V2 = shape.worldVertexChain;
			
			var n:Point = new Point();
			while (true)
			{
				n.x = v.x - shape.x;
				n.y = v.y - shape.y;
				n.normalize(1);
				
				var tf:TextField = _labels[v.index] as TextField;
				tf.x = v.x + n.x * -10 - tf.width  / 2;
				tf.y = v.y + n.y * -10 - tf.height / 2;
								if (v.isTail) break;
				v = v.next;
			}
		}
		
		private function clearLabels():void
		{
			if (!_labels) return;
			for (var i:int = 0; i < _labels.length; i++)
				removeChild(_labels[i]);	
			
			_labels = null;
		}

		protected function drawWorldVertices(g:Graphics):void
		{
			if (shape.type == ShapeTypes.CIRCLE)
			{
				g.drawCircle(shape.x, shape.y, shape.radius);
				g.moveTo(shape.x, shape.y);
				
				var l:Number = -Math.min(shape.radius, 20);
				g.lineTo(shape.x + shape.r12 * l,  shape.y + shape.r22 * l);
				return;
			}
			
			drawVertexChain(g, shape.worldVertexChain);
		}
		
		protected function drawWorldNormals(g:Graphics):void
		{
			if (shape.type == ShapeTypes.CIRCLE) return;
			
			var xmid:Number, ymid:Number;
			
			var v:V2 = shape.worldVertexChain;
			var n:V2 = shape.worldNormalChain;
			
			g.moveTo(v.x, v.y);
			
			while (true)
			{
				xmid = v.x + (v.next.x - v.x) * .5;
				ymid = v.y + (v.next.y - v.y) * .5;
				
				g.moveTo(xmid, ymid);
				g.lineTo(xmid + n.x * 6, ymid + n.y * 6);
				
				if (v.isTail) break;
				
				if (shape.type == ShapeTypes.LINE)
					if (!LineShape(shape).doubleSided)
						break;
				
				v = v.next;
				n = n.next;
			}
		}	
		
		protected function drawWorldEdges(g:Graphics):void
		{
			if (shape.type == ShapeTypes.CIRCLE) return;
			
			g.lineStyle(0, 0xffff00, .8);
			
			var xmid:Number, ymid:Number;
		
			var v:V2 = shape.worldVertexChain;
			var n:V2 = shape.worldNormalChain;
		
			g.moveTo(v.x, v.y);
		
			while (true)
			{
				xmid = v.x + (v.next.x - v.x) * .5;
				ymid = v.y + (v.next.y - v.y) * .5;
				
				g.moveTo(v.x, v.y);
				g.lineTo(xmid, ymid);
				
				if (v.isTail) break;
				
				v = v.next;
				n = n.next;
			}
		}
		
		protected function drawProxy(g:Graphics):void
		{
			shape.synced = false;
			shape.update();
			
			if (_flags & ProxyTypes.AABB_PROXY)
			{
				g.lineStyle(0, 0x0000ff, .5);
				g.moveTo(shape.xmin, shape.ymin);
				g.lineTo(shape.xmax, shape.ymin);
				g.lineTo(shape.xmax, shape.ymax);
				g.lineTo(shape.xmin, shape.ymax);
				g.lineTo(shape.xmin, shape.ymin);
			}
			
			if (_flags & ProxyTypes.CIRCLE_PROXY)
			{
				g.lineStyle(0, 0x00ff00, 1);
				g.drawCircle(shape.x, shape.y, shape.radius);
			}
			
			if (_flags & ProxyTypes.OBB_PROXY)
			{
				if (shape.type == ShapeTypes.POLY)
				{
					var s:Shape = _modelCanvas.getChildByName("obb") as Shape;
					if (!s)
					{
						s = new Shape();
						s.name = "obb";
						_modelCanvas.addChild(s);
					}
					g = s.graphics;
					g.clear();
					g.lineStyle(0, 0xff0000, .5);
					var t:V2 = PolyShape(shape).getWorldOBB(); 
					var v:V2 = t;
					g.moveTo(v.x, v.y);
					while (v)
					{
						g.lineTo(v.x, v.y);
						v = v.next;
					}
					g.lineTo(t.x, t.y);
				}
			}
		}
	}
}