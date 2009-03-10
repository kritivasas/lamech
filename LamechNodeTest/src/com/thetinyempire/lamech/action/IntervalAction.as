package com.thetinyempire.lamech.action
{
	import com.thetinyempire.lamech.base.BaseLamechAction;

	public class IntervalAction extends BaseLamechAction
	{
		public function IntervalAction()
		{
			super();
			
			
		}
		
		override public function update(t:Number):void
		{
			super.update(t);
		}
		
		override public function get done():Boolean
		{
			return(_elapsed >= _duration);
		}
		
	}
}