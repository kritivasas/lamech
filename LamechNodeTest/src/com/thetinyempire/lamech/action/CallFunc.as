package com.thetinyempire.lamech.action
{
	public class CallFunc extends InstantAction
	{
		private var _func:Function;
		private var _args:Array;
		
		public function CallFunc(func:Function, ...args)
		{
			super();
			_func = func;
			_args = args;
		}
		
		override public function start():void
		{
			_func();
		}
	}
}