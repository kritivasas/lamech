package com.thetinyempire.lamech.scene
{
	import com.thetinyempire.lamech.Scene;
	import com.thetinyempire.lamech.action.CallFunc;
	import com.thetinyempire.lamech.action.MoveTo;
	import com.thetinyempire.lamech.action.Sequence;
	
	import flash.geom.Point;
	
	public class MoveInRTransition extends TransitionScene
	{
		public function MoveInRTransition(dst:Scene, duration:Number=1.25, src:Scene=null)
		{
			super(dst, duration, src);
			var dim:Point = _director.windowSize
			_width = dim.x
			_height = dim.y
			_outScene.anchor = new Point(dim.x, 0);
			
			var seq:Sequence = new Sequence(new MoveTo(new Point(0,0), 1),new CallFunc(finish));
			_outScene.doAction(seq);
		}
		
//		public function getAction():MoveTo
//		{
//			return(new MoveTo(new Point(0, 0), _duration));
//		}

//		public override function draw(...args):void
//		{
//			//transform()
//			//_element.draw();
//			Debug.trace(this + ' parent : ' + this._parent);
//		}
		
	}
}