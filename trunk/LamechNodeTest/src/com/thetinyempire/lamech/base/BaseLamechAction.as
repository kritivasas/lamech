package com.thetinyempire.lamech.base
{	
	public class BaseLamechAction
	{
		protected var _target:BaseLamechNode;
		protected var _elapsed:Number;
		protected var _duration:Number;
		
		public function BaseLamechAction()
		{
			_target = null
			_elapsed = -1;
			_duration = -1;
		}
		
		public function init():void
		{
			
		}
		
		public function start():void
		{
			
		}
		
		public function stop():void
		{
			
		}
		
		public function step(dt:Number):void
		{
			if(_elapsed == -1)
			{
				_elapsed = 0;
			}
			
			_elapsed += dt;
			
			if(_duration != -1)
			{
				update(Math.min(1, _elapsed/_duration));
			}
			else
			{
				update(1);
				stop();
			}
		}
		
		//
		
		/* private function  _add(action:BaseLamechAction):Sequence
		{
        	//"""Is the Sequence Action"""
        	return new Sequence(action)
  		}

    	private function _mul(self, other):void
    	{
			if not isinstance(other, int):
				raise TypeError("Can only multiply actions by ints")
			if other <= 1:
				return self
			return  Loop(self, other)
    	}

    def __or__(self, action):
        """Is the Spawn Action"""
        return Spawn(self, action)

    def __reversed__(self):
        raise Exception("Action %s cannot be reversed"%(self.__class__.__name__)) */


		//
		
		public function update(t:Number):void
		{
			
		}
		
		//  GETTER / SETTER  //
		
		public function get target():BaseLamechNode
		{
			return _target;	
		}
		
		public function set target(t:BaseLamechNode):void
		{
			_target = t;
		}
		
		//
		
		public function get done():Boolean
		{
			return true;
		}
		
		public function get duration():Number
		{
			return _duration;
		}
	}
}