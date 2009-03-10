package
{
	import com.thetinyempire.lamech.Director;
	import com.thetinyempire.lamech.KeyboardManager;
	import com.thetinyempire.lamech.KeyboardManagerEvent;
	import com.thetinyempire.lamech.Layer;
	import com.thetinyempire.lamech.action.*;
	
	import com.hexagonstar.util.debug.Debug;
	
	public class ControlLayer extends Layer
	{
		private var _director:Director;
		
		public function ControlLayer()
		{
			super();
			_director = Director.getInstance();
			this._keyboardManager.addEventListener(KeyboardManagerEvent.DOWN, checkKeys);
			
		}
		
		override public function onEnter():void
		{
			super.onEnter();
			//schedule(checkKeys);
		}
		
		private function checkKeys(e:KeyboardManagerEvent):void
		{
			
				switch(e.keyCode)
				{
					case KeyboardManager.KEY_ARROW_UP:
						//_label.doAction(new Place(new Point(_label.anchorX,_label.anchorY-2.5)));
					break;
					case KeyboardManager.KEY_ARROW_DOWN:
						//_label.doAction(new Place(new Point(_label.anchorX,_label.anchorY+2.5)));
					break;
					case KeyboardManager.KEY_ARROW_LEFT:
						//_label.doAction(new Place(new Point(_label.anchorX-2.5,_label.anchorY)));
					break;
					case KeyboardManager.KEY_ARROW_RIGHT:
						//_label.doAction(new Place(new Point(_label.anchorX+2.5,_label.anchorY)));
					break;
					case KeyboardManager.KEY_SPACE_BAR:
						_director.pop();
						Debug.trace("DIRECTOR POP");
						//_label.doAction(new Place(new Point(_label.anchorX+2.5,_label.anchorY)));
					break;
				}
			
		}
	}
}