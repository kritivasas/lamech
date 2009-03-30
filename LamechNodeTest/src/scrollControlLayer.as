package
{
	import com.thetinyempire.lamech.Director;
	import com.thetinyempire.lamech.KeyboardManager;
	import com.thetinyempire.lamech.action.*;
	import com.thetinyempire.lamech.layer.Layer;
	import com.thetinyempire.lamech.layer.ScrollManager;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	public class scrollControlLayer extends Layer
	{
		private var _director:Director;
		private var _sm:ScrollManager;
		private var _speed:uint = 5;
		
		public function scrollControlLayer(sm:ScrollManager)
		{
			super();
			_director = Director.getInstance();
			//this._keyboardManager.addEventListener(KeyboardManagerEvent.DOWN, checkKeys);
			_sm = sm;
		}
		
		override public function onEnter():void
		{
			super.onEnter();
			schedule(checkKeys);
		}
		
		private function checkKeys(e:Event):void
		{
			var k:KeyboardManager = KeyboardManager.getInstance()
			for each(var key:uint in k.keys)
			{
				var dir:Point; 
				switch(key)
				{
					case KeyboardManager.KEY_ARROW_DOWN:
						dir = new Point(_sm.fx, _sm.fy - _speed >= 0 ? _sm.fy - _speed : 0);
					break;
					case KeyboardManager.KEY_ARROW_UP:
						dir = new Point(_sm.fx, _sm.fy + _speed);
					break;
					case KeyboardManager.KEY_ARROW_LEFT:
						dir = new Point(_sm.fx - _speed >= 0 ? _sm.fx - _speed : 0, _sm.fy);
					break;
					case KeyboardManager.KEY_ARROW_RIGHT:
						dir = new Point(_sm.fx + _speed, _sm.fy);
					break;
				}
				if(dir!= null)
				{
					_sm.setFocus(dir.x, dir.y);
				}
			}
		}
	}
}