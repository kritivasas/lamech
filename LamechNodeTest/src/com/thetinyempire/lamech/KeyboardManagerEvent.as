package com.thetinyempire.lamech
{
	import flash.events.Event;
	import org.casalib.ui.KeyCombo;
	
	public class KeyboardManagerEvent extends Event
	{
		public static const DOWN:String     = 'down';
		public static const UP:String  = 'u';
		public static const PERSIST:String  = 'persist';
		public static const SEQUENCE:String = 'sequence';
		protected var _keyCombo:KeyCombo;
		protected var _keyCode:uint;
		
		/**
			Creates a new KeyboardManagerEvent.
			
			@param type: The type of event.
			@param bubbles: Determines whether the Event object participates in the bubbling stage of the event flow.
			@param cancelable: Determines whether the Event object can be canceled.
		*/
		public function KeyboardManagerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
		
		/**
			The {@link KeyCombo} that contains the key codes that triggered the event.
		*/
		public function get keyCombo():KeyCombo {
			return this._keyCombo;
		}
		
		public function set keyCombo(keyCombo:KeyCombo):void {
			this._keyCombo = keyCombo;
		}
		
		/**
			The {@link KeyCode} that contains the key codes that triggered the event.
		*/
		public function get keyCode():uint {
			return this._keyCode;
		}
		
		public function set keyCode(keyCode:uint):void {
			this._keyCode = keyCode;
		}
		
		/**
			@return A string containing all the properties of the event.
		*/
		override public function toString():String {
			return formatToString('VideoInfoEvent', 'type', 'bubbles', 'cancelable', 'keyCombo');
		}
		
		/**
			@return Duplicates an instance of the event.
		*/
		override public function clone():Event {
			var e:KeyboardManagerEvent = new KeyboardManagerEvent(this.type, this.bubbles, this.cancelable);
			e.keyCombo          = this.keyCombo;
			e.keyCode          = this.keyCode;
			
			return e;
		}
	}
}