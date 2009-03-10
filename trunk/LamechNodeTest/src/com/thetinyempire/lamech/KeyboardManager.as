package com.thetinyempire.lamech
{
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	
	import org.casalib.events.KeyComboEvent;
	import org.casalib.ui.Key;
	import org.casalib.ui.KeyCombo;
	import org.casalib.util.ArrayUtil;
    
	public class KeyboardManager extends EventDispatcher
	{	
		public static const KEY_ARROW_UP:uint = 38;
		public static const KEY_ARROW_DOWN:uint = 40;
		public static const KEY_ARROW_LEFT:uint = 37;
		public static const KEY_ARROW_RIGHT:uint = 39;
		public static const KEY_SPACE_BAR:uint = 32;
		
		private var _key:Key;
		private var _asdfCombo:KeyCombo;
		private var _downs:Array;
		public static var _instance:KeyboardManager;
		
		public function KeyboardManager(target:IEventDispatcher=null)
		{
			super(target);
			
			_key = Key.getInstance();
			_downs = new Array();
			
			 this._asdfCombo = new KeyCombo(new Array(65, 83, 68, 70));
            this._key.addKeyCombo(this._asdfCombo);

			_key.addEventListener(KeyComboEvent.DOWN, this._onComboDown);
            _key.addEventListener(KeyComboEvent.RELEASE, this._onComboRelease);
            _key.addEventListener(KeyComboEvent.SEQUENCE, this._onComboTyped);
            _key.addEventListener(KeyboardEvent.KEY_DOWN, this._onKeyPressed);
            _key.addEventListener(KeyboardEvent.KEY_UP, this._onKeyReleased);
		}
		
		public static function getInstance():KeyboardManager
		{
			if(_instance == null)
			{
				_instance = new KeyboardManager();
			}
			return(_instance);
		}
		//
		
		protected function _onComboDown(e:KeyComboEvent):void {
//            if (this._asdfCombo.equals(e.keyCombo)) {
//                trace("User is holding down keys a-s-d-f.");
//            }
        }

        protected function _onComboRelease(e:KeyComboEvent):void {
//            if (this._asdfCombo.equals(e.keyCombo)) {
//                trace("User no longer holding down keys a-s-d-f.");
//            }
        }

        protected function _onComboTyped(e:KeyComboEvent):void {
//            if (this._asdfCombo.equals(e.keyCombo)) {
//                Debug.trace("User typed casa.");
//            }
        }

        protected function _onKeyPressed(e:KeyboardEvent):void {
//           Debug.trace("User pressed key with code: " + e.keyCode + ".");
			if(ArrayUtil.containsAny(_downs,[e.keyCode]))
			{
				for each(var i:uint in _downs)
				{
					var exit:KeyboardManagerEvent = new KeyboardManagerEvent(KeyboardManagerEvent.PERSIST, false, false)
					exit.keyCode = i
					dispatchEvent(exit);
				}
			}
			else
			{
				_downs.push(e.keyCode);
				var exit:KeyboardManagerEvent = new KeyboardManagerEvent(KeyboardManagerEvent.DOWN, false, false)
				exit.keyCode = e.keyCode
				dispatchEvent(exit);
			}
			
        }

        protected function _onKeyReleased(e:KeyboardEvent):void {
//            Debug.trace("User released key with code: " + e.keyCode + ".");
			if(ArrayUtil.containsAny(_downs,[e.keyCode]))
			{
				ArrayUtil.removeItem(_downs,e.keyCode);
				var exit:KeyboardManagerEvent = new KeyboardManagerEvent(KeyboardManagerEvent.UP, false, false)
				exit.keyCode = e.keyCode
				dispatchEvent(exit);
			}
			else
			{
				_downs.push(e.keyCode);
				
			}
        }
        
        //
        
        public function get keys():Array
        {
        	return _downs;	
        }
	}
}