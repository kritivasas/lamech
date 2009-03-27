package com.thetinyempire.lamech.layer
{
	import com.thetinyempire.lamech.LamechSprite;
	import com.thetinyempire.lamech.cell.Cell;
	import com.thetinyempire.lamech.config.TextConfig;
	import com.thetinyempire.lamech.resource.TileMapResource;
	import com.thetinyempire.lamech.text.Label;
	
	import de.polygonal.ds.Array2;
	
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	import com.hexagonstar.util.debug.Debug;
	
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
//			_cells = cells;
//			_pxWidth = cells.length * _tw;
//			_pxHeight = cells[0].length * _th;
		}
		
		private function init():void
		{
			setView(0,0,this._width, this._height);
			_cells = _tmRes.cells
			
			// this should be elsewhere
			_pxWidth = _cells.width * 32;
			_pxHeight = _cells.height * 32;
			//
			
			//_cellsBMD = new BitmapData(_pxHeight, _pxHeight);
			
//			var zcount:uint = 0;
//			
//			for(var i:uint = 0; i < _cells.width; i++)
//			{
//				for(var j:uint = 0; j < _cells.height; j++)
//				{
//					var cell:Cell = _cells.get(i, j);
//					var config:TextConfig = new TextConfig();
//					
//					config.text = cell.tile.id;
//					config.color = 0xffffff
//					config.position = new Point(cell.i *32, cell.j *32);
//					
//					if(cell.tile.id != "blank")
//					{
//						var sp:LamechSprite = new LamechSprite(cell.tile.image, new Point(cell.i *32, cell.j *32))
//						this.add(sp, zcount, 'label'+zcount);
//						zcount++;
//					}
//				}
//			}
			_ready = true;
		}
		
		override protected function getInRegion(x1:uint, y1:uint, x2:uint, y2:uint):Array2
		{
			var ox:uint = _origin.x;
			var oy:uint = _origin.y;
			
			var x1:uint = Math.max(0, Math.floor((x1 - ox) / (_tw - 1)));
			var y1:uint = Math.max(0, Math.floor((y1 - oy) / (_th - 1)));
			
//			var x2:uint = Math.min(_cells.length, Math.floor((x2 - 0x) / (_tw +1)));
//			var y2:uint = Math.min(_cells[0].length, Math.floor((y2 - 0y) / (_th +1)));
			
			var ret:Array2 = new Array2(1,1);
			for(var i:uint = x1; i < x2; i++)
			{
				var adj_i:uint = i - x1;
				//ret.push(new Array());
				
				for(var j:uint = y1; j < y2; j++)
				{
					var adj_j:uint = j - y1;
					ret.set(adj_i, adj_j, _cells.get(i, j));
				}
				
			}
			
			return ret;
			
		}
		
		public function getAtPixel(x:uint, y:uint):Cell
		{
//			 ''' Return Cell at pixel px=(x,y) on the map.
//
//	        The pixel coordinate passed in is in the map's coordinate space,
//	        unmodified by screen, layer or view transformations.
//	
//	        Return None if out of bounds.
//	        '''
			return getCell(Math.floor((x - _origin.x) / _tw), Math.floor((y - _origin.y) / _th));
		}
		
		public function getNeighboor(cell:Cell, direction:Object):Cell
		{
//			'''Get the neighbor Cell in the given direction (dx, dy) which
//	        is one of self.UP, self.DOWN, self.LEFT or self.RIGHT.
//	
//	        Returns None if out of bounds.
//	        '''
			var dx:int = direction.x;
			var dy:int = direction.y;
			
			return getCell(cell.i + dx, cell.j + dy);
		}
		
		public function asXML():XML
		{
			return new XML();
		}
		
		//
		
		public function tmResReadyHandler(e:Event):void
		{
			init()
		}
		
		
//			if(_tmRes.ready)
//			{
//				var bmd1:BitmapData = new BitmapData(_view.width, _view.height, true, 0x00000000);
//				var bmd2:BitmapData = new BitmapData(_pxWidth, _pxHeight, true, 0x00000000);
//				
//				//bmd2.draw(_imgRes.img,null,null,null,_view,true);
//				return bmd2;
//			}
//			else
//			{
//				return new BitmapData(50, 50, true, 0x55000000);
//			}
//		}
		
		override public function get myBitmapDrawable():IBitmapDrawable
		{
			if(_tmRes.ready)
			{
//				var bmd1:BitmapData = new BitmapData(_view.width, _view.height, true, 0x00000000);
//				var bmd2:BitmapData = new BitmapData(_pxWidth, _pxHeight, true, 0x00000000);
				
//				Debug.trace(_BMD.width);
//				//bmd2.draw(_imgRes.img,null,null,null,null,true);
//				bmd1.copyPixels(_BMD, _view, new Point(0,0));
//				return bmd1;

				var zcount:uint = 0;
				var tbmd:BitmapData = new BitmapData(1000,1000, true, 0x00000000);
				var tbmd2:BitmapData = new BitmapData(1000,1000, true, 0x00000000);
				
				for(var i:uint = 0; i < _cells.width; i++)
				{
					for(var j:uint = 0; j < _cells.height; j++)
					{
						var cell:Cell = _cells.get(i, j);
//						var config:TextConfig = new TextConfig();						
//						config.text = cell.tile.id;
//						config.color = 0xffffff
//						config.position = new Point(cell.i *32, cell.j *32);
				
						if(cell.tile.id != "blank")
						{
							if(cell.physRep == null)
							{
								cell.physRep = _physWorld.createBox(new Point(cell.i*32, cell.j*32), 0);
							}
							//var sp:LamechSprite = new LamechSprite(cell.tile.image, new Point(cell.i *32, cell.j *32))
							//this.add(sp, zcount, 'label'+zcount);
							var matrix:Matrix = new Matrix();
							matrix.translate(cell.i *32, cell.j *32);
							tbmd.draw(cell.tile.image, matrix);
							zcount++;
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