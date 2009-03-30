package com.thetinyempire.lamech
{
	//import com.thetinyempire.lamech.interfaces.ILamechNode;
	import com.thetinyempire.lamech.base.BaseLamechNode;
	
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
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
		
		override public function draw(...args):void
		{
			var matrix:Matrix = new Matrix();
			
//			matrix.translate(-this._width/2 -16, -this._height/2 -16);
//			matrix.rotate(_rotation);
			
//			var tfp:Sprite = new Sprite();
//			tfp.graphics.beginFill(0xff0000);
//			tfp.graphics.drawCircle(0,0,5);
//			tfp.graphics.endFill();
			
			//_parent._BMD.draw(tfp, matrix, null, BlendMode.NORMAL);
			
//			matrix.translate(this._width/2 +16, this._height/2 +16);
			matrix.translate(_x, _y);
			var win:Window = Window.getInstance();
			if(_grid && _grid.active)
			{
				var ibmd:IBitmapDrawable =  _grid.blit() as IBitmapDrawable;
				win.draw({obj:ibmd, x:_x, y:_y});
			}
			else
			{
				win.draw({obj:_BMD, x:_x, y:_y});
			}
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