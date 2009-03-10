package
{
	import com.thetinyempire.lamech.KeyboardManager;
	import com.thetinyempire.lamech.KeyboardManagerEvent;
	import com.thetinyempire.lamech.Layer;
	import com.thetinyempire.lamech.action.*;
	import com.thetinyempire.lamech.config.TextConfig;
	import com.thetinyempire.lamech.text.Label;
	
	import flash.events.Event;
	import flash.geom.Point;
	
	import com.hexagonstar.util.debug.Debug;
	
	public class LayerAA extends Layer
	{
		private var _label:Label;
		
		public function LayerAA()
		{
			super();
			
			var config:TextConfig = new TextConfig();
			
			config.text = "this is scene A";
			config.position = new Point(_width/2, _height/2);
			config.color = 0xff0000;
			//
			
			_label = new Label(config);
			
			add(_label,0,"");
			
			//
		}
		
		override public function onEnter():void
		{
			super.onEnter();
			schedule(checkKeys);
		}
		
		private function checkKeys(e:Event):void
		{
			//Debug.trace('check keys')
			for each(var i:uint in _keyboardManager.keys)
			{
				switch(i)
				{
					case KeyboardManager.KEY_ARROW_UP:
						_label.doAction(new Place(new Point(_label.anchorX,_label.anchorY-2.5)));
					break;
					case KeyboardManager.KEY_ARROW_DOWN:
						_label.doAction(new Place(new Point(_label.anchorX,_label.anchorY+2.5)));
					break;
					case KeyboardManager.KEY_ARROW_LEFT:
						_label.doAction(new Place(new Point(_label.anchorX-2.5,_label.anchorY)));
					break;
					case KeyboardManager.KEY_ARROW_RIGHT:
						_label.doAction(new Place(new Point(_label.anchorX+2.5,_label.anchorY)));
					break;
				}
			}
		}
	}
}