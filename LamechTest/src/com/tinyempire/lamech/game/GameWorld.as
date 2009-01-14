package com.tinyempire.lamech.game
{
	import com.hexagonstar.util.debug.*;
	
	import com.tinyempire.lamech.objects.InputObject;
	
	import flash.utils.Dictionary;
	import flash.display.BitmapData;
	
	public class GameWorld
	{
		private var _w:uint 				= 500;
		private var _h:uint 				= 300;
		private var _gridSize:uint 			= 16;
		private var _gridWidth:uint;
		private var _gridHeight:uint;
		private var _gameObjects:Array;
		private var _pc:GameObject;
		private var _physWorld:PhysWorld;
		
		/////////////////////////////////////////////////////////////////////////////////////////////////
		//                                                                                CONSTRUCTOR  //
		/////////////////////////////////////////////////////////////////////////////////////////////////
		
		public function GameWorld()
		{
			Debug.trace("NEW GAME WORLD");
			
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////
		//                                                                              PUBLIC METHOD  //
		/////////////////////////////////////////////////////////////////////////////////////////////////
		public function setBounds(t_w:uint, t_h:uint):void
		{
			_w = t_w;
			_h = t_h;
		}
		
		public function buildLevel(t_arr:Array, t_key:Dictionary, t_map:BitmapData)
		{
			_gameObjects = new Array();
			_physWorld = new PhysWorld(this);
			_physWorld.doDebug();
			
			for (var i:uint = 0; i < t_arr.length; i++)
			{
				for(var j:uint = 0; j < t_arr[i].length; j++)
				{
					
						var t_obj:GameObject = new t_key[t_arr[i][j]].tile(t_key[t_arr[i][j]].map) as GameObject;
						
						t_obj.x = j * _gridSize
						t_obj.y = i * _gridSize
						t_obj.id = t_arr[i][j];
						t_obj.blitSource = t_map;
						if(t_arr[i][j]!=0)
						{
						_physWorld.createStaticTile(t_obj);
						}
						_gameObjects.push(t_obj);
					
				}
			}
		}
		
		public function addGameObject(t_obj:GameObject):void
		{
			_physWorld.createDynamicTile(t_obj);
			
			_gameObjects.push(t_obj);
		}
		
		public function update():void
		{
			
			for each(var i:GameObject in _gameObjects)
			{
				i.update();
			}
			
			_physWorld.update();
		}
		/////////////////////////////////////////////////////////////////////////////////////////////////
		//                                                                            GETTER / SETTER  //
		/////////////////////////////////////////////////////////////////////////////////////////////////
		public function set gridSize(t_gs:uint):void
		{
			_gridSize = t_gs;
		}

		public function get gameObjects():Array
		{
			return(_gameObjects);
		}
		
		public function get w():uint
		{
			return(_w);
		}
		
		public function get h():uint
		{
			return(_h);
		}
		
		public function get gridWidth():uint
		{
			return(_gridWidth);
		}
		
		public function set gridWidth(t_w:uint):void
		{
			_gridWidth = t_w
			_w = t_w * _gridSize;
		}
		
		public function get gridHeight():uint
		{
			return(_gridHeight);
		}
		
		public function set gridHeight(t_h:uint):void
		{
			_gridHeight = t_h
			_h = t_h * _gridSize;
		}
	}
}