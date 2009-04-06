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
	import flash.display.Sprite;
	
	import de.polygonal.motor2.World;
	import de.polygonal.motor2.dynamics.contact.Contact;
	import de.polygonal.motor2.dynamics.contact.ContactPoint;
	import de.polygonal.motor2.dynamics.contact.Manifold;	

	public class ManifoldRenderer extends Sprite
	{
		private var _world:World;
		private var _flags:int;
		
		public function ManifoldRenderer(world:World) 
		{
			_world = world;
		}
		
		public function render():void
		{
			graphics.clear();
			
			if (_flags & RenderFlags.RENDER_CONTACT_NORMALS)
				drawContactNormals(graphics);
				
			if (_flags & RenderFlags.RENDER_CONTACT_POINTS)
				drawContactPoints(graphics);
			
			if (_flags & RenderFlags.RENDER_CONTACT_GRAPH)
				drawContactGraph(graphics);
			
			if (_flags & RenderFlags.RENDER_IMPULSES)
				drawImpulses(graphics);
				
			if (_flags & RenderFlags.RENDER_CONTACT_PAIRS)	
				drawContacts(graphics);
		}
		
		public function toggleRender(flag:int):void
		{
			if (_flags & flag)
				_flags &= ~flag;
			else
				_flags |= flag;
		}
		
		private function drawContactGraph(g:Graphics):void
		{
			var i:int, j:int, c:Contact, cp:ContactPoint, m:Manifold;
			
			var xdir:Number, ydir:Number, len:Number, offset:Number = 0;
			
			g.lineStyle(0, 0x00ff00, .5);
			
			c = _world.contactList;
			
			draw:
			{
				while (c)
				{
					for (i = 0; i < c.manifoldCount; i++)
					{
						if (c.body1 && c.body2)
						{
							if (c.body1.isSleeping() && c.body2.isSleeping())
							{
								c = c.next;
								if (c == null)
									break draw;
								else
									break;
							}
						}
						
						m = c.manifolds[i];
						
						for (j = 0; j < m.pointCount; j++)
						{
							cp = m.points[j];
							
							xdir = c.shape1.x - cp.x;
							ydir = c.shape1.y - cp.y;
							len = Math.sqrt(xdir * xdir + ydir * ydir);
							xdir /= len;
							ydir /= len;
							
							g.moveTo(c.shape1.x - xdir * offset, c.shape1.y - ydir * offset);
							g.lineTo(cp.x + xdir * offset      , cp.y + ydir * offset);
							xdir = c.shape2.x - cp.x;
							ydir = c.shape2.y - cp.y;
							len = Math.sqrt(xdir * xdir + ydir * ydir);
							xdir /= len;
							ydir /= len;
							
							g.moveTo(c.shape2.x - xdir * offset, c.shape2.y - ydir * offset);
							g.lineTo(cp.x + xdir * offset      , cp.y + ydir * offset);
						}
					}
					c = c.next;
				}
			}
		}
		
		private function drawContacts(g:Graphics):void
		{
			g.lineStyle(0);
			var c:Contact;
			
			g.moveTo(0, 0);
			g.lineStyle(0, 0xff00ff, 1);
			
			c = _world.contactList;
			while (c)
			{
				g.moveTo(c.shape1.x, c.shape1.y);
				g.lineTo(c.shape2.x, c.shape2.y);
				c = c.next;
			}
		}
		
		private function drawContactNormals(g:Graphics):void
		{
			var i:int, j:int, c:Contact, m:Manifold, cp:ContactPoint;
			
			g.moveTo(0, 0);
			g.lineStyle(0, 0x4FA7FF, 1);
			
			c = _world.contactList;
			while (c)
			{
				if (c.body1 && c.body2)
				{
					if (c.body1.isSleeping() && c.body2.isSleeping())
					{
						c = c.next;
						continue;
					}
				}
				
				for (i = 0; i < c.manifoldCount; i++)
				{
					m = c.manifolds[i];
					for (j = 0; j < m.pointCount; j++)
					{
						cp = m.points[j];
						
						g.moveTo(cp.x, cp.y);
						g.lineTo(cp.x + m.nx * 15, cp.y + m.ny * 15);
					}
				}
				c = c.next;
			}
		}
		
		private function drawContactPoints(g:Graphics):void
		{
			var i:int, j:int, c:Contact, m:Manifold, cp:ContactPoint;
			
			g.moveTo(0, 0);
			g.lineStyle(0, 0, 0);
			
			var warmStart:Boolean = (_flags & RenderFlags.RENDER_WARM_START) == RenderFlags.RENDER_WARM_START;
			
			c = _world.contactList;
			while (c)
			{
				if (c.body1 && c.body2)
				{
					if (c.body1.isSleeping() && c.body2.isSleeping())
					{
						c = c.next;
						continue;
					}
				}
				
				for (i = 0; i < c.manifoldCount; i++)
				{
					m = c.manifolds[i];
					for (j = 0; j < m.pointCount; j++)
					{
						cp = m.points[j];
						
						g.beginFill(cp.matched && warmStart ? 0xFF8000 : 0x4FA7FF, 1);
						g.drawRect(cp.x - 2, cp.y - 2, 4, 4);
						g.endFill();
					}
				}
				c = c.next;
			}
		}
		
		private function drawImpulses(g:Graphics):void
		{
			var i:int, j:int, c:Contact, m:Manifold, cp:ContactPoint;
			
			g.moveTo(0, 0);
			g.lineStyle(0xff0000, 0, 1);
			
			var x:Number, y:Number;
			
			c = _world.contactList;
			while (c)
			{
				if (c.body1 && c.body2)
				{
					if (c.body1.isSleeping() && c.body2.isSleeping())
					{
						c = c.next;
						continue;
					}
				}
				
				for (i = 0; i < c.manifoldCount; i++)
				{
					m = c.manifolds[i];
					for (j = 0; j < m.pointCount; j++)
					{
						cp = m.points[j];
						
						x = cp.x;
						y = cp.y;
						g.moveTo(x, y);
						
						x += cp.Pn * m.nx;						y += cp.Pn * m.ny;
						g.lineTo(x, y);
					}
				}
				c = c.next;
			}
		}
	}
}