package com.thetinyempire.lamech
{
	import com.thetinyempire.lamech.config.WindowConfig;
	import com.thetinyempire.lamech.layer.Layer;
	
	import flash.display.IBitmapDrawable;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.filters.BlurFilter;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Window
	{
		private static var _instance:Window
		private var _viewComponent:Sprite;
		private var _width:uint;
		private var _height:uint;
		private var _bitmapData:BitmapData;
		private var _plane:Bitmap;
		
		public function Window()
		{
			super();
		}
		
		public static function getInstance() : Window 
        {
            if ( _instance == null ) _instance = new Window();
            return _instance as Window;
        }
        
        public function init(config:WindowConfig):void
        {
        	_viewComponent = config.viewComponent as Sprite;
        	
        	_width = config.width;
			_height = config.height;
			
        	_bitmapData = new BitmapData(_width, _height, true, 0x00000000);
        	
        	_plane = new Bitmap(_bitmapData, "auto", true);
        	
        	_viewComponent.addChild(_plane);
        	
        	//_viewComponent.graphics.beginFill(0xffffff, 1);
        	//_viewComponent.graphics.drawRect(10,10,50,100);
        	//_viewComponent.graphics.endFill();
        }
        
		public function clear():void
		{
			_bitmapData.fillRect(new Rectangle(0,0,_width,_height),0x00000000);
			
//			var rect:Rectangle = new Rectangle(0,0,_width,_height);
//			var blur:BlurFilter = new BlurFilter(1.1,1.1,2)
//			_bitmapData.applyFilter(_bitmapData, rect, new Point(0,0), blur);
		}
		
		public function pushHandlers(l:Layer):void
		{
			
		}
		
		public function removeHandlers(l:Layer):void
		{
			
		}
		
		public function draw(obj:Object):void
		{
			var drawable:IBitmapDrawable = obj.obj as IBitmapDrawable;
			var pos:Point = new Point(obj.x, obj.y);
			
			var matrix:Matrix = new Matrix();
			matrix.translate(pos.x, pos.y);
			_bitmapData.draw(drawable, matrix, null, BlendMode.NORMAL);
			//_viewComponent.addChild(displayObject);
		}
		
		public function render():void
		{
			
		}
		
		public function lock():void
		{
			_bitmapData.lock();
			_plane.visible = false;
		}
		
		public function unlock():void
		{
			_plane.visible = true;
			_bitmapData.unlock();
		}
		//  GETTER / SETTER  //
		public function get width():uint
		{
			return(_width);
		}
		
		public function set width(w:uint):void
		{
			_width = w
		}
		
		public function get height():uint
		{
			return(_height);
		}
		
		public function set height(h:uint):void
		{
			_height = h
		}
	}
}