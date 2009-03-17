package com.thetinyempire.lamech.tiles
{
	import flash.display.BitmapData;
	
	public class Tile
	{
		protected var _id:String;
		protected var _properties:Object;
		protected var _image:BitmapData;
		protected var _offset:Number
		
		public function Tile(id:String, properties:Object, image:Object, offset:Number = 0)
		{
			_id = id;
			_properties = properties;
			_image = image as BitmapData
			_offset = offset;
		}
		
		public function get width():uint
		{
			return _image.width
		}
		
		public function get height():uint
		{
			return _image.height	
		}
		
		public function get image():BitmapData
		{
			return(_image);
		}
	}
}