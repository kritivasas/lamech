package com.tinyempire.lamech.objects
{
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.geom.Rectangle;
	import flash.geom.Matrix;
	
	import flash.events.EventDispatcher;
	
	import com.hexagonstar.util.debug.*;
	
	public class TileMap extends EventDispatcher
	{
		public static const DATA_PARSE_COMPLETE:String = "dataParseComplete";
		
		private var _size:uint;
		private var _map:Array;
		private var _master:BitmapData;
		
		public function TileMap(t_target:String, t_size:uint)
		{
			Debug.trace('NEW TILE MAP');
			
			_size = t_size;
			
			var pictLdr:Loader = new Loader();
			var pictURL:String = t_target;
			var pictURLReq:URLRequest = new URLRequest(pictURL);
			pictLdr.load(pictURLReq);
			
			pictLdr.contentLoaderInfo.addEventListener(Event.COMPLETE, imgLoaded); 
		}
		
		private function imgLoaded(event:Event):void
		{
			Debug.trace('IMAGE LOADED');
			
			//var t_info:LoaderInfo = event.target.contentLoaderInfo;
			var t_do:DisplayObject = event.target.content;
			_master = new BitmapData(t_do.width, t_do.height);
			_master.draw(t_do);
			
			_map = new Array();
			var t_w:uint = t_do.width / _size;
			var t_h:uint = t_do.height / _size;
			
			for(var i:uint = 0; i < t_w; i++)
			{
				var t_arr:Array = new Array();
				for(var j:uint = 0; j < t_h; j++)
				{
				
					var t_bmp:BitmapData = new BitmapData(_size, _size, false, 0x33889900);
					var t_rect:Rectangle = new Rectangle(i * _size, j * _size, _size, _size);
					var t_trix:Matrix = new Matrix();
					t_trix.translate(-i * _size, -j * _size)
					t_bmp.draw(_master, t_trix, null, null );//, t_rect);
					t_arr.push(t_bmp);
				}
				_map.push(t_arr);
			}
			
			dispatchEvent(new Event(DATA_PARSE_COMPLETE));
		}
		
		public function get map():Array
		{
			return(_map);
		}
	}
}