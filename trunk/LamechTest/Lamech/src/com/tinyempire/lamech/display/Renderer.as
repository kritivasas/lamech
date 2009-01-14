package com.tinyempire.lamech.display
{
	import flash.display.Stage;
	import flash.display.Sprite;
	import flash.display.BitmapData;
	import flash.display.Bitmap;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	import flash.display.PixelSnapping;
	
	import com.hexagonstar.util.debug.*;
	
	import com.tinyempire.lamech.game.*;
	import com.tinyempire.lamech.objects.*;
	
	public class Renderer
	{
		private var _gameWorld:GameWorld;
		private var _stage:Stage;
		//private var _screen:Sprite;
		private var _bmapData:BitmapData;
		private var _bmap:Bitmap;
		
		private var _TVbmapData:BitmapData;
		private var _TVbmap:Bitmap;
		
		private var _camera:Rectangle;
		private var _cameraTarget:GameObject;
		
		/////////////////////////////////////////////////////////////////////////////////////////////////
		//                                                                                CONSTRUCTOR  //
		/////////////////////////////////////////////////////////////////////////////////////////////////
		
		public function Renderer(t_gameObj:GameWorld, t_stage:Stage)
		{
			Debug.trace('NEW RENDERER');
			_gameWorld = t_gameObj;
			_stage = t_stage;
			
			_bmapData = new BitmapData(_gameWorld.w, _gameWorld.h);
			_bmap = new Bitmap(_bmapData);
			_stage.addChild(_bmap);
			_bmap.x = 25
			_bmap.y = 25
			_bmap.pixelSnapping=PixelSnapping.ALWAYS;
			
			_TVbmapData = new BitmapData(_gameWorld.w, _gameWorld.h);
			_TVbmap = new Bitmap(_TVbmapData);
			_stage.addChild(_TVbmap);
			_TVbmap.x = 25
			_TVbmap.y = _gameWorld.h + 50;
			_TVbmap.pixelSnapping = PixelSnapping.ALWAYS;
		}
		/////////////////////////////////////////////////////////////////////////////////////////////////
		//                                                                             PRIVATE METHOD  //
		/////////////////////////////////////////////////////////////////////////////////////////////////
		
		/////////////////////////////////////////////////////////////////////////////////////////////////
		//                                                                             GETTER / SETTER //
		/////////////////////////////////////////////////////////////////////////////////////////////////
		
		/////////////////////////////////////////////////////////////////////////////////////////////////
		//                                                                              PUBLIC METHOD  //
		/////////////////////////////////////////////////////////////////////////////////////////////////
		
		public function setCamera(t_target:GameObject, t_w:uint, t_h:uint):void
		{
			_cameraTarget = t_target
			_camera = new Rectangle(0,0,t_w,t_h);
		}
		
		public function update():void
		{
			updateCamera();
			
			_bmapData.fillRect(_bmapData.rect, 0xff000000);
			
			for each (var i in _gameWorld.gameObjects)
			{
				var t_rect:Rectangle = new Rectangle(i.x-(i.w/2), i.y-(i.h/2),i.w,i.h);
				if(_camera.intersects(t_rect))
				{
					var t_trix:Matrix = new Matrix();
					t_trix.translate(i.x-(i.w/2), i.y-(i.h/2));
					_bmapData.draw(i.blit.nextBlit, t_trix);
				}
			}
			
			_TVbmapData.fillRect(_bmapData.rect, 0xff000000);
			
			var t_TVtrix:Matrix = new Matrix();
			t_TVtrix.translate(-_camera.x, -_camera.y);
			t_TVtrix.scale(2,2);
					
			_TVbmapData.draw(_bmapData,t_TVtrix);
			
			var t_sprite:Sprite = new Sprite
			t_sprite.graphics.lineStyle(.25,0xff0000);
			t_sprite.graphics.drawRect(_camera.x,_camera.y,_camera.width,_camera.height);
			
			_bmapData.draw(t_sprite);
			
		}
		
		private function updateCamera():void
		{
			_camera.x = _cameraTarget.x - (_camera.width/2);
			_camera.y = _cameraTarget.y - ((3*_camera.height)/4);
		}
	}
}