package com.thetinyempire.lamech.config
{
	import flash.display.DisplayObject;
	
	public class WindowConfig
	{
		public var doNotScale:Boolean = true;
		public var viewComponent:DisplayObject;
		public var width:uint = 640;
		public var height:uint = 360;
		public var fps:uint = 60;
		
		public function WindowConfig()
		{
		}

	}
}