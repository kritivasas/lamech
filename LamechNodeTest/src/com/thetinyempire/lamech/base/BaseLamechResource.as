package com.thetinyempire.lamech.base
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;

	public class BaseLamechResource extends EventDispatcher
	{
		protected var _ready:Boolean;
		protected var _id:String;
		
		public function BaseLamechResource(id:String, target:IEventDispatcher=null)
		{
			super(target);
			
			_id = id;
			_ready = false;
		}
		
		public function get ready():Boolean
		{
			return _ready;
		}
		
		public function get id():String
		{
			return _id;
		}
	}
}