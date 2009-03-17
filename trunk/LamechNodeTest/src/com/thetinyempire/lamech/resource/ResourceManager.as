package com.thetinyempire.lamech.resource
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public class ResourceManager extends EventDispatcher
	{
		private var _resources:Array;
		private var _instance;
		
		public function ResourceManager(target:IEventDispatcher=null)
		{
			super(target);
			
			_resources = new Array();
		}
		
		public static function getInstance():ResourceManager
		{
			if(!_instance)
			{
				_instance = new ResourceManager();
			}
			return _instance;
		}
	}
}