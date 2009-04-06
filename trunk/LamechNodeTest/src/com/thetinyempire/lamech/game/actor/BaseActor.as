package com.thetinyempire.lamech.game.actor
{
	import com.thetinyempire.lamech.LamechSprite;
	
	import de.polygonal.motor2.collision.shapes.data.CircleData;
	import de.polygonal.motor2.dynamics.RigidBodyData;
	
	import flash.display.Sprite;
	import flash.geom.Point;

	public class BaseActor extends LamechSprite
	{
		public function BaseActor(image:Object = null, position:Point=null, rotation:Number=0, ARGB:uint=0x00000000, anchor:Object=null)
		{
			super(image, position, rotation, ARGB, anchor);
		}
		
		override protected function createPhysRep():void
		{
			//_physRep = _physWorld.createBox(this.anchor, 1, true);
			
        	//every shape is defined by a 'template', implemented as a subclass of the ShapeData class.
			//this makes it easy to reuse the same definition for creating multiple shapes.
			//here we create a box definition with density=1 and size=40
			var circle:CircleData = new CircleData(.5, 32/2);
			circle.friction = 0.5
			
			var circle2:CircleData = new CircleData(.5, 32/2);
			circle2.friction = 0.5
			circle2.my = 32
			
			//like every shape is defined by a ShapeData, every RigidBody is
			//defined by a RigidBodyData object.
			//here we create a rigid body definition and add the box to it.
			//the rigid body's initial position is set to the stage center.  
			var rigidBodyData:RigidBodyData = new RigidBodyData(this.anchorX, this.anchorY);
			rigidBodyData.preventRotation = true;
			rigidBodyData.addShapeData(circle);
			rigidBodyData.addShapeData(circle2);
			
			
			//use the definition of the rigid body data to create a body inside the world  
			//_world.createBody(rigidBodyData);

			//this will be the ground 
//			box = new BoxData(0,300,20);
//			rigidBodyData = new RigidBodyData(550 / 2, 330);
//			rigidBodyData.addShapeData(box);
			_physRep = _physWorld.world.createBody(rigidBodyData);
		}
		
		override protected function debugSprite():Sprite
		{
			var sp:Sprite = new Sprite()
			sp.graphics.lineStyle(3, 0xff0000);
			//sp.graphics.drawRect(0,0,32,32);
			sp.graphics.drawCircle(32/2,0,32/2);
			sp.graphics.moveTo(32/2, 0)
			sp.graphics.lineTo(32/2, 32/2);
			
			//
			//sp.graphics.drawRect(0,0,32,32);
			sp.graphics.drawCircle(32/2,32,32/2);
			sp.graphics.moveTo(32/2, 32)
			sp.graphics.lineTo(32/2, 32/2+32);
			
			//sp.graphics.endFill();
			return(sp);
		}
		
	}
}