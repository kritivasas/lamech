package com.thetinyempire.lamech.tiles
{
	import flash.utils.Dictionary;
	
	public class TileSet
	{
		static protected var _tileID:uint = 0;
		
		protected var _id:String;
		protected var _properties:Object;
		public var _lib:Object
		
		public function TileSet(id:String, properties:Object)
		{
			super();
			_id = id;
			properties = _properties;
			_lib = new Object;
		}
		
		static protected function generateTileID():String
		{
			_tileID ++;
			return(_tileID.toString());
		}
		
		public function add(properties:Object, image:Object, id:String = ""):Tile
		{
			if(id == "")
			{
				id = generateTileID();
			}
			
			_lib[id] = new Tile(id, properties, image)
			return _lib[id]
		}
		
		public function getTile(id:String):Tile
		{
			var r:Tile = _lib[id] != null ? _lib[id] : null;
			
			return r;
		}

	}
}