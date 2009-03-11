package com.thetinyempire.lamech
{
	import com.thetinyempire.lamech.base.BaseLamechGrid;
	import com.thetinyempire.lamech.util.DistortImage;
	
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	
	public class Grid2D extends BaseLamechGrid
	{
		private var idxPts:Array;
		private var verPtsIdx:Array
		private var texPtsIdx:Array;
		
		private var _vertexList:Object;
		private var _vertexPoints:Array;
		
		
		public function Grid2D(gridSize:Point, width:uint=0, height:uint=0)
		{
			super(gridSize, width, height);
			
			_vertexPoints = new Array();
			_vertexList = new Object();
			_vertexList.vertices = new Array()
			
			//_vertexList.texCoords = texPtsIdx
			//vertexList.colors = 
			_calculateVertexPoints();
			
		}
		
		public function blit():IBitmapDrawable
		{
			var bmd:BitmapData = new BitmapData(this._width, this._height, true, 0x00000000);
			var rect:BitmapData = new BitmapData(5,5,true,0x66ff0000);
			
			var sprite:Sprite = new Sprite();
			
			//bmd.draw(_texture);
			
			for(var i:uint = 0; i < _gridSize.x; i++)
			{
				for(var j:uint = 1; j <= _gridSize.y; j++)
				{

//					#  b <-- c
//		            #        ^
//		            #        |
//		            #  a --> d 


					var a:Point = _vertexList.vertices[i][j];
					var b:Point = _vertexList.vertices[i][j-1];
					var c:Point = _vertexList.vertices[i+1][j-1];
					var d:Point = _vertexList.vertices[i+1][j];
					
					var oa:Point = _vertexPoints[i][j];
					var ob:Point = _vertexPoints[i][j-1];
					var oc:Point = _vertexPoints[i+1][j-1];
					var od:Point = _vertexPoints[i+1][j+1];
					
					//
					
					//var matrix:Matrix = new Matrix();
					
					//matrix.translate(b.x, b.y);
					//bmd.draw(rect,matrix);
					
					
					var mc:MovieClip = new MovieClip();
					var t_bmp:BitmapData = new BitmapData(_width / _gridSize.x,_height/_gridSize.y, true, 0x000000);
					
					//var t_matrix:Matrix = new Matrix();
					//t_matrix.translate(-a.x, -a.y);
					t_bmp.copyPixels(_texture, new Rectangle(ob.x, ob.y, _width / _gridSize.x,_height/_gridSize.y), new Point(0,0))//, _texture, new Point(0,0));
					
					var dist:DistortImage = new DistortImage(mc, t_bmp, 1, 1);
					
//					#  b <-- c
//		            #        ^
//		            #        |
//		            #  a --> d 

					dist.setTransform(b.x,b.y,c.x,c.y,d.x,d.y,a.x,a.y);
					
					bmd.draw(mc, new Matrix());
				}
			}
			
			return(bmd);
		}
		
		
		private function _calculateVertexPoints():void
		{
			var w:uint = _texture.width;
			var h:uint = _texture.height;
			
			var indexPoints:Array = new Array();
			var texturePointsIndex:Array = new Array();
			
			for(var i:uint = 0; i < _gridSize.x + 1; i++)
			{
				_vertexPoints.push(new Array);
				_vertexList.vertices.push(new Array);
				
				for(var j:uint = 0; j < _gridSize.y + 1; j++)
				{
					_vertexPoints[i].push([-1, -1]);
					_vertexList.vertices[i].push([-1, -1]);
					
					texturePointsIndex.push([-1, -1]);
				}
			}
			
			for(var i:uint = 0; i < _gridSize.x + 1; i++)
			{
			//	_vertexPoints.push(new Array());
				for(var j:uint = 0; j < _gridSize.y + 1; j++)
				{
					var x1:Number = i * _xStep;
					var x2:Number = x1 + _xStep;
					
					var y1:Number = j * _yStep;
					var y2:Number = y1 + _yStep;
					
//					#  d <-- c
//		            #        ^
//		            #        |
//		            #  a --> b 
					
					var a:Number = i * (_gridSize.y+1) + j
	                var b:Number = (i + 1) * (_gridSize.y + 1) + j
	                var c:Number = (i + 1) * (_gridSize.y + 1) + (j + 1)
	                var d:Number = i * (_gridSize.y + 1) + (j + 1)
					
					// 2 triangles: a-b-d, b-c-d
               		indexPoints.push([ a, b, d, b, c, d]);    // triangles 
               		
               		var l1:Array = [a*3, b*3, c*3, d*3]
               		var l2:Array = [new Point(x1,y1), new Point(x2,y1), new Point(x2,y2), new Point(x1,y2)]
               		
               		//building the vertex
               		_vertexPoints[i][j] = new Point(x1,y1);
               		_vertexList.vertices[i][j] = new Point(x1, y1);
//               		for(var k:uint = 0; k < l1.length; k++)
//               		{
//               			_vertexPoints[l1[k]] = l2[k].x
//               			_vertexPoints[l1[k] + 1] = l2[k].y
//               		}
               		
               		//bulding the texels
               		var tex1:Array = [a*2, b*2, c*2, d*2]
               		var tex2:Array = [new Point(x1,y1), new Point(x2,y1), new Point(x2,y2), new Point(x1,y2)]
               		
               		for(var k:uint = 0; k < tex1.length; k++)
               		{
               			texturePointsIndex[ tex1[k] ] = tex2[k].x / w
                  	  	texturePointsIndex[ tex1[k] + 1 ] = tex2[k].y / h
               		}
				}
			}
			
			idxPts = indexPoints;
			
			
			texPtsIdx = texturePointsIndex;
		}
		
		public function getVertex(x:Number, y:Number):Point
		{
			var idx:Number = (x * (_gridSize.y+1) + y) * 3;
        	var t_x:Number = _vertexList.vertices[idx];
        	var t_y:Number = _vertexList.vertices[idx+1];
        	
        	//z = self.vertex_list.vertices[idx+2]
        	//return (x,y,z)
        	
        	return(new Point(t_x, t_y));
		}
		
		public function getOriginalVertex(x:Number, y:Number):Point
		{
			return(_vertexPoints[x][y]);
		}
		
		public function setVertex(x:Number, y:Number, v:Point):void
		{
		    _vertexList.vertices[x][y] = v;
		}
		
		//
		
		public function get gridSize():Point
		{
			return _gridSize;
		}
		
		public function get reuseGrid():Number
		{
			return _reuseGrid;
		}
		
		public function set reuseGrid(rg:Number):void
		{
			_reuseGrid = rg;
		}
		
		public function get vertexList():Object
		{
			return _vertexList;
		}
		
		//
		
		public function get vertexPoints():Array
		{
			return _vertexPoints;
		}
		
		public function set vertexPoints(vp:Array):void
		{
			_vertexPoints = vp;
		}
	}
}