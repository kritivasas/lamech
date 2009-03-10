package com.thetinyempire.lamech.action
{
	import com.thetinyempire.lamech.base.BaseLamechAction;

	public class Sequence extends IntervalAction
	{
		private var _one:BaseLamechAction;
		private var _two:BaseLamechAction;
		private var _actions:Array;
		private var _split:Number;
		
		private var _last:Number;
		
		public function Sequence(one:BaseLamechAction, two:BaseLamechAction, ...args)
		{
			super();
			
			_one = one
			_two = two
			
			_actions = [_one, _two];
			
			// check for durations
			// raise exception if either of the two durations is not an acceptable value
			
			_duration = _one.duration + _two.duration;
			_split = _one.duration / _duration;
			
			_last = -1;
		}
		
		override public function start():void
		{
			_duration = _one.duration + _two.duration;
			_split = _one.duration / _duration;
			
			_one.target = _target
			_two.target = _target
		}
		
		override public function update(t:Number):void
		{
			var found:Number = -1;
			var newTime:Number = -1;
			
			if(t >= _split)
			{
				found = 1;
				if(_split == 1)
				{
					newTime = 1
				}
				else
				{
					newTime = (t - _split) / (1 - _split);
				}
			}
			else if (t < _split)
			{
				found = 0;
				if(_split != 0)
				{
					newTime = t / _split
				}
				else
				{
					newTime = 1;
				}
			}
			
			//execute the action...save the state
			
			if(_last == -1 && found == 1)
			{
				_one.start();
				_one.update(1);
				_one.stop();
			}
			
			if(_last != found)
			{
				if(_last != -1)
				{
					_actions[_last].update(1);
					_actions[_last].stop();
				}
				_actions[found].start();
			}
			
			_actions[found].update(newTime);
			_last = found
		}
		
		override public function stop():void
		{
			_two.stop();
		}
	}
}