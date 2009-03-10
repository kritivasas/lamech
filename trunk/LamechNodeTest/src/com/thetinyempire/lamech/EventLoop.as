package com.thetinyempire.lamech
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class EventLoop extends EventDispatcher
	{
		public static const TICK:String = "TICK";
		
		private var _timer:Timer;
		private var _fps:Number;
		private var _spf:Number;
		private var _dt:Number;
		private var _now:Date;
		private var _then:Date;
		
		private static var _instance:EventLoop;
		
		public function EventLoop()
		{
			super();
		}
		
		public static function getInstance():EventLoop
		{
			if(_instance == null)
			{
				_instance = new EventLoop();
			}
			return(_instance);
		}
		
		public function init(t_fps:Number):void
		{
			_fps = t_fps;
			_spf = 1/_fps;
			_timer = new Timer(_spf);
			_timer.addEventListener(TimerEvent.TIMER, timerHandler);
		}
		
		public function run():void
		{
			_now = new Date();
			_then = new Date();
			_dt = 0;
			_timer.start();
		}
		
		private function timerHandler(e:TimerEvent):void
		{
			_then = _now
			_now = new Date();
			dispatchEvent(new Event(TICK));
		}
		
		public function get dt():Number
		{
			return((_now.time - _then.time)/1000);
		}
	}
}