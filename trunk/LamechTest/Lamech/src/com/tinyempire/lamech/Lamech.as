package com.tinyempire.lamech
{
    

	import flash.display.BitmapData;
	import flash.display.Stage;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.utils.Dictionary;
	import flash.display.StageScaleMode;
	import flash.display.StageAlign;
	
	import com.hexagonstar.util.debug.*;
	
	import com.tinyempire.lamech.objects.*;
	import com.tinyempire.lamech.game.*;
	import com.tinyempire.lamech.display.*
	
	public class Lamech
	{
		private var _w:uint;
		private var _h:uint;
		
		private var _world:GameWorld;
		private var _render:Renderer;
		private var _tileMap:TileMap;
		private var _time:Timer;
		
		private var level = new Array();
		
		/////////////////////////////////////////////////////////////////////////////////////////////////
		//                                                                                CONSTRUCTOR  //
		/////////////////////////////////////////////////////////////////////////////////////////////////
		
		public function Lamech(t_stage:Stage)
		{
			Debug.trace('NEW LAMECK');
			
			t_stage.scaleMode = StageScaleMode.NO_SCALE;
			t_stage.align = StageAlign.TOP_LEFT;
			
			_world = new GameWorld();
			
			_render = new Renderer(_world, t_stage);
			
			_time = new Timer(1000/60, 0);
			_time.addEventListener(TimerEvent.TIMER, timerHandle);
			
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////
		//                                                                              PUBLIC METHOD  //
		/////////////////////////////////////////////////////////////////////////////////////////////////
		
		public function startTime():void
		{
			_time.start();
		}
		
		public function stopTime():void
		{
			_time.stop();
		}
		
		public function buildLevel(t_arr:Array, t_key:Dictionary, t_map:BitmapData):void
		{
			_world.buildLevel(t_arr, t_key, t_map);
		}
		
		public function addGameObject(t_obj:GameObject):void
		{
			_world.addGameObject(t_obj);
		}
		/////////////////////////////////////////////////////////////////////////////////////////////////
		//                                                                            GETTER / SETTER  //
		/////////////////////////////////////////////////////////////////////////////////////////////////
		public function set gridSize(t_size:uint):void
		{
			_world.gridSize = t_size;
		}
		
		public function setCamera(t_obj:GameObject, t_w:uint, t_h:uint):void
		{
			_render.setCamera(t_obj, t_w, t_h);
		}
		
		public function get world():GameWorld
		{
			return _world;
		}
		/////////////////////////////////////////////////////////////////////////////////////////////////
		//                                                                               EVENT HANDLE  //
		/////////////////////////////////////////////////////////////////////////////////////////////////
		
		public function timerHandle(e:TimerEvent):void
		{
			//_world.updateInput(_input.keyList)
			_world.update();
			_render.update();
		}
	}
}