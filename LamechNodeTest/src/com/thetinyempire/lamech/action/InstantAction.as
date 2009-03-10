package com.thetinyempire.lamech.action
{
	import com.thetinyempire.lamech.base.BaseLamechAction;

	public class InstantAction extends BaseLamechAction
	{
		public function InstantAction()
		{
			super();
			_duration = 0;
		}
		
		override public function get done():Boolean
		{
			return true;
		}
		
	}
}