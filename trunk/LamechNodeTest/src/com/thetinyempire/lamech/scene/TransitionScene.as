package com.thetinyempire.lamech.scene
{
	import com.thetinyempire.lamech.Director;
	import com.thetinyempire.lamech.Scene;
	
	import flash.geom.Point;
	
	import com.hexagonstar.util.debug.Debug;
	
	public class TransitionScene extends Scene
	{
		protected var _inScene:Scene;
		protected var _outScene:Scene;
		protected var _duration:Number;
		protected var _director:Director;
		
		public function TransitionScene(dst:Scene, duration:Number = 1.25, src:Scene = null)
		{
			super([dst, src]);
			
			_director = Director.getInstance()
			_inScene = dst;
			
			if(src == null)
			{
				src = _director.scene;
			}
			
			_outScene = src;
			_duration = duration
			
			start();
		}
		
		protected function start():void
		{
			//add(_inScene, 1, "");
			//add(_outScene, 0, "");
			
			_inScene.visible = true;
			_outScene.visible = true;
		}
		
		protected function finish():void
		{
			remove(_inScene);
			remove(_outScene);
			restoreOut();
			_director.replace(_outScene);
		}
		
		protected function hideOutShowIn():void
		{
			//_inScene.visible = true;
			//_outScene.visible = false;
		}
		
		protected function hideAll():void
		{
			//_inScene.visible = false;
			//_outScene.visible = false;
		}
		
		protected function restoreOut():void
		{
			_outScene.visible = true;
			_outScene.anchor = new Point(0, 0);
			//_outScene.scale = 1;
		}
		
//		public override function draw(...args):void
//		{
//			//transform()
//			//_element.draw();
//			
//			Debug.trace(this + ' parent : ' + this._parent);
//			
//		}
	}
}