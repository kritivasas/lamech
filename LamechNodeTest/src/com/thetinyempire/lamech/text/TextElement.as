package com.thetinyempire.lamech.text
{
	import com.thetinyempire.lamech.base.BaseLamechNode;
	import com.thetinyempire.lamech.config.TextConfig;
	
	import flash.display.IBitmapDrawable;
	import flash.display.Sprite;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class TextElement extends BaseLamechNode
	{
		//public static const(
		private var _opacity:Number;
		private var _text:String;
		private var _textfield:TextField;
		private var _textformat:TextFormat;
		
		public function TextElement(config:TextConfig)
		{
			super();
			
			anchor = config.position;
			_text = config.text;
			_x = config.position.x;
			_y = config.position.y;
			
			_textfield = new TextField();
			_textfield.autoSize = TextFieldAutoSize.LEFT;
			
			_textformat = new TextFormat();
			_textformat.font = "_sans";
            _textformat.color = config.color;
            _textformat.size = 12;
            //_textformat.underline = true;
            
            _textfield.defaultTextFormat = _textformat;
            
            _textfield.text = config.text;
            
//			_group = null
//			_batch = null
//			
//			_opacity = 0;
//			
//			createElement();
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
			
			if(_grid && _grid.active)
			{
				var ibmd:IBitmapDrawable =  _grid.blit() as IBitmapDrawable;
				_parent._BMD.draw(ibmd, matrix, null);
			}
			else
			{
				_parent._BMD.draw(_textfield, matrix, null);
			}
		}
		
//		public function createElement()
//		{
//			_element = 
//		}
		
		//
		
		public function get opacity():Number
		{
			return _opacity;
		}
		
		public function set opacity(o:Number):void
		{
			_opacity = o;
		}
	}
}