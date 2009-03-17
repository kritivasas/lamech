package com.thetinyempire.lamech.resource
{
	import com.hexagonstar.util.debug.Debug;
	import com.thetinyempire.lamech.base.BaseLamechResource;
	import com.thetinyempire.lamech.tiles.Tile;
	import com.thetinyempire.lamech.tiles.TileSet;
	
	import flash.display.BitmapData;
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class TileSetResource extends BaseLamechResource
	{
		
		private var _url:String;
		private var _loader:URLLoader;
		private var _urlReq:URLRequest;
		private var _imgResCount:uint
		private var _imgResLoadCount:uint;
		private var _imgResList:Object;
		private var _tileSetList:Object;
		private var _xml:XML;
		
		public function TileSetResource(id:String, target:IEventDispatcher=null)
		{
			super(id, target);
			
			_imgResCount = 0;
			_imgResLoadCount = 0;
			_imgResList = new Object();
			_tileSetList = new Object();
		}
		
		public function load(url:String):void
		{
			_url = url;
			_loader = new URLLoader();
			_loader.addEventListener(Event.INIT, initHandler);
			_loader.addEventListener(Event.COMPLETE, completeHandler);
			_loader.addEventListener(ProgressEvent.PROGRESS, progressHandler);
			_loader.addEventListener(flash.events.HTTPStatusEvent.HTTP_STATUS , statusEventHandler);
            _loader.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_urlReq = new URLRequest(_url);
			_loader.load(_urlReq);	
		}
		
		//
		
		private function parseXML(xml:XML):void
		{
			_xml = xml;
			
			var  fileList:XMLList  = xml.imageatlas.attribute("file");
 
			for each (var file:XML in fileList)
			{
				Debug.trace(file);
				var imgRes:ImageResource = new ImageResource(file);
				imgRes.addEventListener(Event.COMPLETE, imgResLoadComplete);
				_imgResCount++;
				imgRes.load(file);			
			}
		}
		
		private function buildTiles():void
		{
			var tileSetList:XMLList = _xml.tileset
			
			for each(var tileSet:XML in tileSetList)
			{
				var tileList:XMLList = tileSet.tile
				var tileSetObj:TileSet = new TileSet(tileSet.attribute('id'), null);
				
				_tileSetList[tileSet.attribute('id')] = tileSetObj
				
				for each(var tile:XML in tileList)
				{
					//  find the image reference
					var imgRefList:XMLList = tile.image;
					var imgRef:String = imgRefList[0].attribute('ref');
					
					//  find the image data
					var imageList:XMLList = _xml.imageatlas.image.(@id == imgRef);
					var imageXML:XML = imageList[0];
					var atlas:XML = imageXML.parent();
					
					//  find the image resource
					var imgRes:ImageResource = _imgResList[atlas.attribute('file')];
					
					var w:uint = parseInt(atlas.attribute('tile_w'))
					var h:uint = parseInt(atlas.attribute('tile_h'))
					var x:uint = parseInt(imageXML.attribute('offset_x')) * w;
					var y:uint = parseInt(imageXML.attribute('offset_y')) * h;
					
					var bmd1:BitmapData = new BitmapData(imgRes.width, imgRes.height, true, 0x00000000);
					var bmd2:BitmapData = new BitmapData(w, h, true, 0x00000000);
					bmd1.draw(imgRes.img);
					bmd2.copyPixels(bmd1, new Rectangle(x, y, w, h), new Point(0, 0));
					//bmd.draw(imgRes.img, null, null, null, new Rectangle(x, y, w, h), false);
					
					//var tileObj:Tile = new Tile('id',null,null);
					
					tileSetObj.add(null, bmd2, tile.attribute('id'));
				}
			}
			
        	_ready = true;
            dispatchEvent(new Event(Event.COMPLETE));
		}
		//
		
		private function initHandler(event:Event):void
		{
            var loader:URLLoader = URLLoader(event.target);
            Debug.trace("initHandler: " + loader);
        }
        
        private function progressHandler(event:ProgressEvent):void
		{
            var loader:URLLoader = URLLoader(event.target);
            Debug.trace("progressHandler: " + loader);
        }
        
        private function completeHandler(event:Event):void
		{
            var loader:URLLoader = URLLoader(event.target);
            Debug.trace("completeHandler: " + loader);
            
            parseXML(new XML(_loader.data));
        }
		
		private function statusEventHandler(event:HTTPStatusEvent):void
		{
            Debug.trace("statusEventHandler: " + event);
        }
        
        private function ioErrorHandler(event:IOErrorEvent):void
		{
            Debug.trace("ioErrorHandler: " + event);
        }
        
        //
		
		private function imgResLoadComplete(e:Event):void
		{
			_imgResList[e.target.id] = e.target;
			
			_imgResLoadCount++;
			
        	if(_imgResLoadCount == _imgResCount)
        	{
        		buildTiles();
        	}
        	
        	e.target.removeEventListener(Event.COMPLETE, imgResLoadComplete);
		}
		
		//
		
		public function getTile(id:String):Tile
		{
			var r:Tile = null
			for each(var ts:TileSet in _tileSetList)
			{
				var t:Tile = ts.getTile(id);
				t!=null ? r = t : [];
					
			}
			return r;
		}
	}
}