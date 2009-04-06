package com.thetinyempire.lamech.resource
{
//	import com.hexagonstar.util.debug.Debug;
	import com.thetinyempire.lamech.base.BaseLamechResource;
	import com.thetinyempire.lamech.cell.Cell;
	import com.thetinyempire.lamech.tiles.Tile;
	
	import de.polygonal.ds.Array2;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class TileMapResource extends BaseLamechResource
	{
		private var _tileSetResList:Object;
		private var _url:String;
		private var _loader:URLLoader;
		private var _urlReq:URLRequest;
		private var _tileSetResCount:uint
		private var _tileSetResLoadCount:uint;
		private var _xml:XML;
		private var _cellList:Object;
		
		public function TileMapResource(id:String, target:IEventDispatcher=null)
		{
			super(id, target);
			
			_tileSetResCount = 0;
			_tileSetResLoadCount = 0;
			_tileSetResList = new Object();
			_cellList = new Object();
		}
		
		public function load(url:String):void
		{
			_url = url;
			_loader = new URLLoader();
			_loader.addEventListener(Event.INIT, initHandler);
			_loader.addEventListener(Event.COMPLETE, completeHandler);
			_loader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            _loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_urlReq = new URLRequest(_url);
			_loader.load(_urlReq);	
		}
		
		//
		
		private function parseXML(xml:XML):void
		{
			_xml = xml;
			
			var  fileList:XMLList  = xml.requires.attribute("file");
 
			for each (var file:XML in fileList)
			{
//				Debug.trace(file);
				var tileSetRes:TileSetResource = new TileSetResource(file);
				tileSetRes.addEventListener(Event.COMPLETE, tileSetResLoadComplete);
				_tileSetResCount++;
				tileSetRes.load(file);			
			}
		}
		
		//
		
		private function buildMaps():void
		{
			var rectmapList:XMLList = _xml.rectmap
			for each(var rectmap:XML in rectmapList)
			{
				var id:String = rectmap.attribute('id')
				
				
				var colList:XMLList = rectmap.column
				
				var c:XML = colList[0];
				var d = c.children();
				_cellList[id] = new Array2(colList.length(), d.length());
				
				var i:uint = 0;
				for each(var col:XML in colList)
				{
					var j:uint = 0;
					var row:Array = new Array();
					var celList:XMLList = col.cell
					for each(var cell:XML in  celList)
					{
						var tile:Tile = getTile(cell.attribute('tile'));
						
						var celObj:Cell = new Cell(i, j, tile.width, tile.height, new Object(), tile);
						
						_cellList[id].set(i, j, celObj);
						//row.push(celObj);
						j++;
					}
					//_cellList[id].appendRow(row);
					i++;
				}
			}
			 _ready = true;
            dispatchEvent(new Event(Event.COMPLETE));
		}
		private function initHandler(event:Event):void
		{
            var loader:URLLoader = URLLoader(event.target);
//            Debug.trace("initHandler: " + loader);
        }
        
        private function progressHandler(event:ProgressEvent):void
		{
            var loader:URLLoader = URLLoader(event.target);
//            Debug.trace("progressHandler: " + loader);
        }
        
        private function completeHandler(event:Event):void
		{
            var loader:URLLoader = URLLoader(event.target);
//            Debug.trace("completeHandler: " + loader);
            
            parseXML(new XML(_loader.data));
        }

        private function ioErrorHandler(event:IOErrorEvent):void
		{
//            Debug.trace("ioErrorHandler: " + event);
        }
        
        //
        
        private function tileSetResLoadComplete(e:Event):void
        {
        	_tileSetResList[e.target.id] = e.target;
        	
        	_tileSetResLoadCount++
        	if(_tileSetResLoadCount == _tileSetResCount)
        	{
        		buildMaps();
        	}
        	e.target.removeEventListener(Event.COMPLETE, tileSetResLoadComplete);
        }
        
        //
        
        public function getTile(id:String):Tile
        {
        	var r:Tile;
        	
        	for each(var tsr:TileSetResource in this._tileSetResList)
        	{
        		var tile:Tile = tsr.getTile(id);
        		tile != null ? r = tile : [];
        	}
        	
        	return r;
        }
        
        //
        
        public function get cells():Array2
        {
        	var rectmapList:XMLList = _xml.rectmap
        	var arr:Array2;
			for each(var rectmap:XML in rectmapList)
			{
				arr = _cellList[rectmap.attribute('id')]
			}
			
			return(arr);
        }
	}
}