package com.thetinyempire.lamech.layer
{
	import com.thetinyempire.lamech.cell.Cell;
	import com.thetinyempire.lamech.resource.TileMapResource;
	
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
//	Rectangular map.
//
//    Cells are stored in column-major order with y increasing up,
//    allowing [i][j] addressing:
//    +---+---+---+
//    | d | e | f |
//    +---+---+---+
//    | a | b | c |
//    +---+---+---+
//    Thus cells = [['a', 'd'], ['b', 'e'], ['c', 'f']]
//    and cells[0][1] = 'd'
//    '''

	public class RectMapLayer extends RegularTesselationMapLayer
	{
		static public var UP:Object = {x:0,y:1};
		static public var DOWN:Object = {x:0,y:-1};
		static public var LEFT:Object = {x:-1,y:0};
		static public var RIGHT:Object = {x:1,y:0};
		
		private var _id:String;
		private var _tw:uint;
		private var _th:uint;
		public var _tmRes:TileMapResource;
		
		private var _cellsBMD:BitmapData;
		
		public function RectMapLayer(id:String, tw:uint, th:uint, tmRes:TileMapResource, origin:Point = null)
		{
			super();
			
			_id = id;
			_tw = tw
			_th = th;
			if(origin == null)
			{
				origin = new Point(0,0);
			}
			_origin = origin;
			
			_tmRes = tmRes;
			if(_tmRes.ready)
			{
				init()
			}
			else
			{
				_tmRes.addEventListener(Event.COMPLETE, tmResReadyHandler);
			}
		}
		
		private function init():void
		{
			setView(0,0,this._width, this._height);
			_cells = _tmRes.cells
			
			// this should be elsewhere
			_pxWidth = _cells.width * 32;
			_pxHeight = _cells.height * 32;
			
			//
			
			_ready = true;
		}
		
		override public function draw(...args):void
		{
			var matrix:Matrix = new Matrix();
			
//			matrix.translate(-this._width/2 -16, -this._height/2 -16);
//			matrix.rotate(_rotation);
			
//			var tfp:Sprite = new Sprite();
//			tfp.graphics.beginFill(0xff0000);
//			tfp.graphics.drawCircle(0,0,5);
//			tfp.graphics.endFill();
			
			//_parent._BMD.draw(tfp, matrix, null, BlendMode.NORMAL);
			
//			matrix.translate(this._width/2 +16, this._height/2 +16);
			matrix.translate(_x, _y);
			
			if(_grid && _grid.active)
			{
				var ibmd:IBitmapDrawable =  _grid.blit() as IBitmapDrawable;
				_parent._BMD.draw(ibmd, matrix, null);
			}
			else
			{
				_parent._BMD.draw(myBitmapDrawable, matrix, null);
			}
		}
		
//		override protected function getInRegion(x1:uint, y1:uint, x2:uint, y2:uint):Array2
//		{
//			var ox:uint = _origin.x;
//			var oy:uint = _origin.y;
//			
//			var x1:uint = Math.max(0, Math.floor((x1 - ox) / (_tw - 1)));
//			var y1:uint = Math.max(0, Math.floor((y1 - oy) / (_th - 1)));
//			
////			var x2:uint = Math.min(_cells.length, Math.floor((x2 - 0x) / (_tw +1)));
////			var y2:uint = Math.min(_cells[0].length, Math.floor((y2 - 0y) / (_th +1)));
//			
//			var ret:Array2 = new Array2(1,1);
//			for(var i:uint = x1; i < x2; i++)
//			{
//				var adj_i:uint = i - x1;
//				//ret.push(new Array());
//				
//				for(var j:uint = y1; j < y2; j++)
//				{
//					var adj_j:uint = j - y1;
//					ret.set(adj_i, adj_j, _cells.get(i, j));
//				}
//				
//			}
//			
//			return ret;
//			
//		}
		
//		public function getAtPixel(x:uint, y:uint):Cell
//		{
////			 ''' Return Cell at pixel px=(x,y) on the map.
////
////	        The pixel coordinate passed in is in the map's coordinate space,
////	        unmodified by screen, layer or view transformations.
////	
////	        Return None if out of bounds.
////	        '''
//			return getCell(Math.floor((x - _origin.x) / _tw), Math.floor((y - _origin.y) / _th));
//		}
//		
//		public function getNeighboor(cell:Cell, direction:Object):Cell
//		{
////			'''Get the neighbor Cell in the given direction (dx, dy) which
////	        is one of self.UP, self.DOWN, self.LEFT or self.RIGHT.
////	
////	        Returns None if out of bounds.
////	        '''
//			var dx:int = direction.x;
//			var dy:int = direction.y;
//			
//			return getCell(cell.i + dx, cell.j + dy);
//		}
//		
//		public function asXML():XML
//		{
//			return new XML();
//		}
		
		//
		
		public function tmResReadyHandler(e:Event):void
		{
			init()
		}
		
		public function get myBitmapDrawable():IBitmapDrawable
		{
			if(_tmRes.ready)
			{
				var tbmd:BitmapData = new BitmapData(1000,1000, true, 0x00000000);
				var tbmd2:BitmapData = new BitmapData(1000,1000, true, 0x00000000);
				
				for(var i:uint = 0; i < _cells.width; i++)
				{
					for(var j:uint = 0; j < _cells.height; j++)
					{
						var cell:Cell = _cells.get(i, j);
						
						if(cell.tile.id != "blank")
						{
							if(cell.physRep == null)
							{
								cell.physRep = _physWorld.createBox(new Point(cell.i*32, cell.j*32), 0);
							}
							
							if(_view.contains((cell.i * _tw) + 32, (cell.j * _th)) + 32)
							{
								var matrix:Matrix = new Matrix();
								matrix.translate(cell.i * 32, cell.j * 32);
								
								tbmd.draw(cell.tile.image, matrix);
							}
						}
					}
				}
				tbmd2.copyPixels(tbmd, _view, new Point(0,0));
				return(tbmd2);
			}
			else
			{
				return new BitmapData(50, 50, true, 0x55000000);
			}
		}
	}
}