package com.thetinyempire.lamech.layer
{
	import com.thetinyempire.lamech.Director;
	
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.geom.Matrix;
	import flash.geom.Point;
	
	public class ColorLayer extends Layer
	{
		private var _RGBA:uint;
		private var _alpha:Number;
		
		private var _TBMD:BitmapData;
		
		public function ColorLayer(rgba:uint, width:uint=0, height:uint=0)
		{
			super();
			
			// batch = pyglet.graphics.batch() ?/
			
			var p:Point = Director.getInstance().windowSize;
			
			_width = width == 0 ? p.x : width;
			_height = height == 0 ? p.y : height;
			
			transformAnchor = new Point(p.x/2, p.y/2);
			
			_RGBA = rgba;
			//_scheduledLayer = false;
			
			_TBMD = new BitmapData(_width, _height, true, _RGBA);
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
				_parent._BMD.draw(_TBMD, matrix, null);
			}
		}
	}
}