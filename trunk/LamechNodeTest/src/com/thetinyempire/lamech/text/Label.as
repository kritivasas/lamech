package com.thetinyempire.lamech.text
{
	import com.thetinyempire.lamech.text.TextElement;
	import com.thetinyempire.lamech.config.TextConfig;

	public class Label extends TextElement
	{
		public var KLASS:String = "com.thetinyempire.lamech.text.Label";
		
		public function Label(config:TextConfig)
		{
			super(config);
		}
	}
}