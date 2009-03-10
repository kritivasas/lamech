package com.thetinyempire.lamech.action
{
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
	
	import flash.geom.Point;

	public class MoveTo extends IntervalAction
	{
		private var _startPosition:Point;
		private var _endPosition:Point;
		private var _delta:Point;
		private var  myTweenX:Tween;
		private var  myTweenY:Tween;
		private var dummy:Point;
		
		public function MoveTo(dst:Point, duration:Number = 5)
		{
			super();
			
			_endPosition = dst;
			_duration = duration;
		}
		
		override public function init():void
		{
			super.init();
			
			
		}
		
		override public function start():void
		{
			
			_startPosition = _target.anchor;
			_delta = _startPosition.subtract(_endPosition);
			
			dummy = new Point();
			
			myTweenX = new Tween(dummy, "x", Strong.easeInOut, _startPosition.x, _endPosition.x, 1, true);
			myTweenY = new Tween(dummy, "y", Strong.easeInOut, _startPosition.y, _endPosition.y, 1, true);
 			
 			myTweenX.stop();
 			myTweenX.rewind();	
 			myTweenY.stop();
 			myTweenY.rewind();
		}
		
		override public function update(t:Number):void
		{
			var t_x:Number = _delta.x;
			var t_y:Number = _delta.y;
			
			//var t_p:Point = new Point((_startPosition.x - (t_x * t)), (_startPosition.y - (t_y * t)));
			
			myTweenX.time = myTweenY.time = t
			
			var t_p:Point = new Point(dummy.x, dummy.y);
			
			_target.anchor = t_p;
		}
	}
}