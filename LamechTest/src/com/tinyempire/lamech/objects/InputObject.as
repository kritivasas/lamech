package com.tinyempire.lamech.objects
{
	import flash.display.Stage
    import flash.events.KeyboardEvent;
	
	import org.casalib.ui.Key;
    import org.casalib.ui.KeyCombo;
    import org.casalib.events.KeyComboEvent;
    import org.casalib.util.StageReference;
	
	import com.hexagonstar.util.debug.*;
	
	public class InputObject
	{
		public static const KEY_ARROW_UP: uint				= 38;
		public static const KEY_ARROW_DOWN: uint			= 40;
		public static const KEY_ARROW_LEFT: uint			= 37;
		public static const KEY_ARROW_RIGHT: uint			= 39;
		public static const KEY_SPACE: uint					= 32;
		
		
		private var _key:Key;
		private var _keyList:Array;
		
		public function InputObject()
		{
			Debug.trace('NEW INPUT OBJECT');
		}
		
		/////////////////////////////////////////////////////////////////////////////////////////////////
		//                                                                              PUBLIC METHOD  //
		/////////////////////////////////////////////////////////////////////////////////////////////////
		public function doStageCapture(t_stage:Stage):void
		{
			_keyList = new Array();
			
			StageReference.setStage(t_stage);

			_key = Key.getInstance();
			
			this._key.addEventListener(KeyboardEvent.KEY_DOWN, this._onKeyPressed);
            this._key.addEventListener(KeyboardEvent.KEY_UP, this._onKeyReleased);
		}
		
		public function pushKey(t_keyCode:uint):void
		{
			_keyList.indexOf(t_keyCode) == -1 ? _keyList.push(t_keyCode) : {};
		}
		
		public function popKey(t_keyCode:uint):void
		{
			_keyList.indexOf(t_keyCode) != -1 ? _keyList.splice(_keyList.indexOf(t_keyCode),1) : {};
		}
		/////////////////////////////////////////////////////////////////////////////////////////////////
		//                                                                            GETTER / SETTER  //
		/////////////////////////////////////////////////////////////////////////////////////////////////
		public function get keyList():Array
		{
			return(_keyList);
		}
		/////////////////////////////////////////////////////////////////////////////////////////////////
		//                                                                               EVENT HANDLE  //
		/////////////////////////////////////////////////////////////////////////////////////////////////
		protected function _onKeyPressed(e:KeyboardEvent):void
		{
			pushKey(e.keyCode);
			//Debug.trace("User pressed key with code: " + e.keyCode + ".");
        }

        protected function _onKeyReleased(e:KeyboardEvent):void
		{
			popKey(e.keyCode);
           // Debug.trace("User released key with code: " + e.keyCode + ".");
        }
	}
}