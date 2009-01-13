package
{
	import com.tinyempire.lamech.game.*;
	import com.tinyempire.lamech.objects.*;
	
	import com.hexagonstar.util.debug.*;
	
	import Box2D.Dynamics.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Dynamics.Joints.*;
	import Box2D.Dynamics.Contacts.*;
	import Box2D.Common.*;
	import Box2D.Common.Math.*;
	
	import flash.geom.Point;
	
	public class TileProto extends GameObject
	{
		private var _map:String;
		
		private var _pA:Point;
		private var _pB:Point;
		private var _pC:Point;
		private var _pD:Point;
		private var _pE:Point;
		private var _pF:Point;
		private var _pG:Point;
		private var _pH:Point;
		private var _pI:Point;
		private var _pJ:Point;
		private var _pK:Point;
		private var _pL:Point;
		private var _pM:Point;
		private var _pN:Point;
		private var _pO:Point;
		private var _pP:Point;
		
		public function TileProto(t_map:String)
		{
			//Debug.trace('NEW TILE 002');
			
			w = 16;
			h = 16;
			
			_pA = new Point(-w/2 * PhysWorld.PHYS_SCALE, -h/2 * PhysWorld.PHYS_SCALE);
			_pC = new Point(0, -h/2 * PhysWorld.PHYS_SCALE);
			_pE = new Point(w/2 * PhysWorld.PHYS_SCALE, -h/2 * PhysWorld.PHYS_SCALE);
			_pG = new Point(w/2 * PhysWorld.PHYS_SCALE, 0);
			_pI = new Point(w/2 * PhysWorld.PHYS_SCALE, h/2 * PhysWorld.PHYS_SCALE);
			_pK = new Point(0, h/2 * PhysWorld.PHYS_SCALE);
			_pM = new Point(-w/2 * PhysWorld.PHYS_SCALE, h/2 * PhysWorld.PHYS_SCALE);
			_pO = new Point(-w/2 * PhysWorld.PHYS_SCALE, 0);
			
			switch(t_map)
			{
				case 'AMI':
					blitKey = [new Point(0,0)];
				break;
				case 'AMIC':
					blitKey = [new Point(1,0)];
				break;
				case 'AMIG':
					blitKey = [new Point(2,0)];
				break;
				case 'AMK':
					blitKey = [new Point(3,0)];
				break;
				case 'AMKC':
					blitKey = [new Point(4,0)];
				break;
				case 'AMIE':
					blitKey = [new Point(5,0)];
				break;
				case 'MIE':
					blitKey = [new Point(0,1)];
				break;
				case 'MIEO':
					blitKey = [new Point(1,1)];
				break;
				case 'MIEC':
					blitKey = [new Point(2,1)];
				break;
				case 'MIG':
					blitKey = [new Point(3,1)];
				break;
				case 'MIGO':
					blitKey = [new Point(4,1)];
				break;
				case 'IEA':
					blitKey = [new Point(0,2)];
				break;
				case 'IEAK':
					blitKey = [new Point(1,2)];
				break;
				case 'IEAO':
					blitKey = [new Point(2,2)];
				break;
				case 'IEC':
					blitKey = [new Point(3,2)];
				break;
				case 'IECK':
					blitKey = [new Point(4,2)];
				break;
				case 'EAM':
					blitKey = [new Point(0,3)];
				break;
				case 'EAMG':
					blitKey = [new Point(1,3)];
				break;
				case 'EAMK':
					blitKey = [new Point(2,3)];
				break;
				case 'EAO':
					blitKey = [new Point(3,3)];
				break;
				case 'EAOG':
					blitKey = [new Point(4,3)];
				break;
				default:
					blitKey = [new Point(3,5)];
				break;
			}
			
			_map = t_map;
		}
		
		override public function construct(t_world:b2World):void
		{
			//
			
			var t_l:uint = _map.length;
			if(t_l > 0)
			{
				var groundBodyDef:b2BodyDef = new b2BodyDef();
				groundBodyDef.position.Set(x * PhysWorld.PHYS_SCALE, y * PhysWorld.PHYS_SCALE);
				
				groundBodyDef.userData = this;
				
				var groundBody:b2Body = t_world.CreateBody(groundBodyDef);
				physObj = groundBody;
				
				var groundShapeDef:b2PolygonDef = new b2PolygonDef();
				groundShapeDef.vertexCount = t_l;
				
				for(var i:uint = 0; i < t_l; i++)
				{
					var t_p:Point = this['_p'+_map.charAt(t_l - 1 - i)];
					groundShapeDef.vertices[ i].Set(t_p.x, t_p.y)
				}
					
				groundShapeDef.density = 0;
				groundShapeDef.friction = .2
				
				groundBody.CreateShape(groundShapeDef);
				
				
				groundBody.SetMassFromShapes();
			}
			
			//
			
		}
	}
}