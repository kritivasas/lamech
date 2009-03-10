package com.thetinyempire.lamech
{
	//import com.thetinyempire.lamech.interfaces.ILamechNode;
	import com.thetinyempire.lamech.base.BaseLamechNode;
	
	import flash.display.BitmapData;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class Scene extends BaseLamechNode
	{
		public static const KLASS:String = "com.thetinyempire.lamech.Scene";
		
		private var _handlersEnabled:Boolean;
		
		public function Scene(children:Array)
		{
			super();
			
	        _handlersEnabled = false;
	        
	        for(var i:uint = 0; i < children.length; i++)
	        {
	        	add(children[i],i, null)
	        }
	        
	        var p:Point = Director.getInstance().windowSize;
	        transformAnchor = new Point(p.x/2, p.y/2);
	     	
	     	_width = p.x;
	     	_height = p.y;
	     	
	        _BMD = new BitmapData(p.x, p.y);
		}
		
		override public function onEnter():void
		{
			for each(var i:BaseLamechNode in _children)
			{
				i.parent = this
			}
			
			super.onEnter();
		}
		
//		override public function pushAllHandlers():void
//		{
//			super.pushAllHandlers();
//			
//			for each(var i:BaseLamechNode in _children)
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
//			super.pushAllHandlers();
//			
//			for each(var i:BaseLamechNode in _children)
//			{
//				if(i is Layer)
//				{
//					i.removeAllHandlers();
//				}
//			}
//		}
//		
		public function enableHandlers(value:Boolean = true):void
		{
//			if(value && !_handlersEnabled && _isRunning)
//			{
//				pushAllHandlers();
//			}
//			else if(!value && _handlersEnabled && _isRunning)
//			{
//				removeAllHandlers();
//			}
//			_handlersEnabled = value;
		}
		
		public function end(value:Object = null):void
		{
			Director.getInstance().returnedValue = value;
			//director.pop();
		}
		
		//  GETTER / SETTER  //
		public function get isRunning():Boolean
		{
			return _isRunning;
		}
		
		public function get handlersEnabled():Boolean
		{
			return _handlersEnabled;
		}
	}
}