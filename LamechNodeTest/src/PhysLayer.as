package
{
	import com.thetinyempire.lamech.KeyboardManager;
	import com.thetinyempire.lamech.KeyboardManagerEvent;
	import com.thetinyempire.lamech.LamechSprite;
	import com.thetinyempire.lamech.action.*;
	import com.thetinyempire.lamech.layer.ScrollableLayer;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	
	public class PhysLayer extends ScrollableLayer
	{
		private var _sprite:LamechSprite;
		
		public function PhysLayer()
		{
			super();
			
			var sp:Sprite = new Sprite()
			sp.graphics.beginFill(0x00ff00, .5);
			sp.graphics.drawRect(0,0,32,32);
			sp.graphics.endFill();
			
			_sprite = new LamechSprite(sp, new Point(50,50),0,0x00000000,null,1);
			
			add(_sprite,0,"");
			
			_keyboardManager.addEventListener(KeyboardManagerEvent.DOWN, checkKeysDown);
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
//					case KeyboardManager.KEY_ARROW_UP:
//						_sprite.doAction(new ApplyForce(new Point(0,0-5000)));
//					break;
//					case KeyboardManager.KEY_ARROW_DOWN:
//						_sprite.doAction(new ApplyForce(new Point(0,0+5000)));
//					break;
					case KeyboardManager.KEY_ARROW_LEFT:
						_sprite.doAction(new ApplyForce(new Point(0-5000,0)));
					break;
					case KeyboardManager.KEY_ARROW_RIGHT:
						_sprite.doAction(new ApplyForce(new Point(0+5000,0)));
					break;
				}
			}
		}
		
		private function checkKeysDown(e:Event):void
		{
			//Debug.trace('check keys')
			for each(var i:uint in _keyboardManager.keys)
			{
				switch(i)
				{
					case KeyboardManager.KEY_ARROW_UP:
						_sprite.doAction(new ApplyForce(new Point(0,0-100000)));
					break;
//					case KeyboardManager.KEY_ARROW_DOWN:
//						_sprite.doAction(new ApplyForce(new Point(0,0+5000)));
//					break;
				}
			}
		}
	}
}