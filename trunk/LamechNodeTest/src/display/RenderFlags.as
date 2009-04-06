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
	public class RenderFlags 
	{
		public static const RENDER_MODEL_POS:int       = 1 << 0;
		public static const RENDER_WORLD_POS:int       = 1 << 1;
		public static const RENDER_MODEL_NORMALS:int   = 1 << 2;
		public static const RENDER_WORLD_NORMALS:int   = 1 << 3;
		public static const RENDER_MODEL_EDGES:int     = 1 << 4; 		public static const RENDER_WORLD_EDGES:int     = 1 << 5; 
		public static const RENDER_MODEL_AXIS:int      = 1 << 6;
		public static const RENDER_VERTEX_IDS:int      = 1 << 7;
		public static const RENDER_PROXY:int           = 1 << 8;
		public static const RENDER_CONTACT_POINTS:int  = 1 << 9;		public static const RENDER_CONTACT_NORMALS:int = 1 << 10;
		public static const RENDER_CONTACT_GRAPH:int   = 1 << 11;
		public static const RENDER_WARM_START:int      = 1 << 12;
		public static const RENDER_TRIANGLES:int       = 1 << 13;		public static const RENDER_IMPULSES:int        = 1 << 14;		public static const RENDER_CONTACT_PAIRS:int   = 1 << 15;
		public static const RENDER_CENTER:int          = 1 << 16;
		
		public static const ALL:int = RENDER_MODEL_POS |
									  RENDER_WORLD_POS |
									  RENDER_MODEL_NORMALS |
									  RENDER_WORLD_NORMALS |
									  RENDER_MODEL_EDGES |
									  RENDER_WORLD_EDGES |
									  RENDER_MODEL_AXIS |
									  RENDER_VERTEX_IDS |
									  RENDER_PROXY | RENDER_CONTACT_POINTS |
									  RENDER_CONTACT_NORMALS |
									  RENDER_CONTACT_GRAPH |
									  RENDER_WARM_START |
									  RENDER_TRIANGLES |
									  RENDER_IMPULSES |
									  RENDER_CONTACT_PAIRS |
									  RENDER_CENTER |
									  ProxyTypes.ALL;
	}
}