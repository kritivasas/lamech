package com.thetinyempire.lamech.layer
{
	import com.thetinyempire.lamech.base.BaseLamechNode;
	import com.thetinyempire.lamech.Scene;
	import com.thetinyempire.lamech.Director;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;

	public class Layer extends BaseLamechNode
	{
		
		private var _isEventHandler:Boolean;
		private var _scheduledLayer:Boolean;
		
		public function Layer()
		{
			super();
			
			_isEventHandler = false;
			_scheduledLayer = false;
			
			var p:Point = Director.getInstance().windowSize;
			transformAnchor = new Point(p.x/2, p.y/2);
			_width = p.x;
			_height = p.y;
			
			_BMD = new BitmapData(p.x, p.y, true, 0x00000000);
		}
		
//		override public function pushAllHandlers():void
//		{
//			super.pushAllHandlers();
//			
//			if(_isEventHandler)
//			{
//				Director.getInstance().window.pushHandlers(this);
//			}
//			for each(var i:ILamechNode in _children)
//			{
//				if(i is Layer)
//				{
//					i.pushAllHandlers();
//				}
//			}
//		}
//		
//		override public function removeAllHandlers():void
//		{
//			super.removeAllHandlers();
//			
//			if(_isEventHandler)
//			{
//				Director.getInstance().window.removeHandlers(this);
//			}
//			for each(var i:ILamechNode in _children)
//			{
//				if(i is Layer)
//				{
//					i.removeAllHandlers();
//				}
//			}
//		}
		
		override public function onEnter():void
		{
			super.onEnter();
			var scn:Scene = getAncestor(Scene.KLASS) as Scene;
			if(scn == null)
			{
				return;
			}
			
//			if(scn.handlersEnabled)
//			{
//				if(_isEventHandler)
//				{
//					Director.getInstance().window.pushHandlers(this)
//				}
//			}
		}
		
		override public function onExit():void
		{
			super.onExit();
			var scn:Scene = getAncestor(Scene.KLASS) as Scene;
			if(scn == null)
			{
				return;
			}
			
//			if(scn.handlersEnabled)
//			{
//				if(_isEventHandler)
//				{
//					Director.getInstance().window.removeHandlers(this)
//				}
//			}
		}
	}
}