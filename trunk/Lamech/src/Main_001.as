package
{
	import flash.display.MovieClip;
	import flash.display.Loader;
	import flash.utils.Dictionary;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.display.*;
	
	import com.tinyempire.lamech.*;
	import com.tinyempire.lamech.game.*;
	import com.tinyempire.lamech.objects.*;
	
	import com.hexagonstar.util.debug.*;
	
	import org.casalib.util.StageReference;
	
	public class Main_001 extends MovieClip
	{
		private var _lamech:Lamech;
		private var level:Array;
		private var key:Dictionary;
		
		public function Main_001()
		{
			Debug.monitor(stage, 1000);
			StageReference.setStage(this.stage);
			
			//
			
			var pictLdr:Loader = new Loader();
			var pictURL:String = "png/map.png";
			var pictURLReq:URLRequest = new URLRequest(pictURL);
			pictLdr.load(pictURLReq);
			
			pictLdr.contentLoaderInfo.addEventListener(Event.COMPLETE, imgLoaded); 
			
			//
			
			level = [
					[6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6,6],
[6,6,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,6,6],
[6,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,6,6],
[6,24,24,24,24,24,24,24,24,24,24,24,4,24,24,24,24,24,24,10,11,11,11,6,6],
[6,24,24,24,24,24,24,24,24,24,24,10,6,22,18,24,24,24,24,24,24,24,16,6,6],
[6,24,24,24,24,11,24,24,8,20,24,24,15,4,24,24,24,24,24,24,24,24,10,6,6],
[6,24,24,24,24,11,24,24,24,24,24,24,24,14,5,24,5,5,24,24,24,24,24,14,6],
[6,11,24,24,24,24,24,24,24,24,11,11,24,17,5,24,24,5,5,24,24,24,24,17,6],
[6,24,24,24,24,24,24,24,24,24,24,24,24,9,5,24,24,24,5,5,24,24,24,16,6],
[6,24,24,24,24,24,24,24,7,6,6,6,20,22,24,24,24,24,24,24,24,24,24,7,6],
[6,11,11,11,11,11,11,8,20,23,14,22,24,24,24,24,24,24,24,24,24,24,24,6,6],
[6,21,24,24,24,24,24,24,24,24,16,24,24,24,24,24,24,24,24,24,24,10,24,14,6],
[6,5,24,24,24,24,24,24,24,24,24,24,24,24,24,7,6,6,6,6,6,20,24,17,6],
[6,2,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,24,9,6],
[6,6,6,6,6,6,6,6,6,6,11,11,6,6,6,6,6,6,6,6,6,6,6,6,6]
					]

			
			key = new Dictionary();
			key[1] = {tile:TileProto, map:'AMI'};
			key[2] = {tile:TileProto, map:'AMIC'};
			key[3] = {tile:TileProto, map:'AMIG'};
			key[4] = {tile:TileProto, map:'AMK'};
			key[5] = {tile:TileProto, map:'AMKC'};
			key[6] = {tile:TileProto, map:'AMIE'};
			key[7] = {tile:TileProto, map:'MIE'};
			key[8] = {tile:TileProto, map:'MIEO'};
			key[9] = {tile:TileProto, map:'MIEC'};
			key[10] = {tile:TileProto, map:'MIG'};
			key[11] = {tile:TileProto, map:'MIGO'};
			key[12] = {tile:TileProto, map:''};
			key[13] = {tile:TileProto, map:'IEA'};
			key[14] = {tile:TileProto, map:'IEAK'};
			key[15] = {tile:TileProto, map:'IEAO'};
			key[16] = {tile:TileProto, map:'IEC'};
			key[17] = {tile:TileProto, map:'IECK'};
			key[18] = {tile:TileProto, map:''};
			key[19] = {tile:TileProto, map:'EAM'};
			key[20] = {tile:TileProto, map:'EAMG'};
			key[21] = {tile:TileProto, map:'EAMK'};
			key[22] = {tile:TileProto, map:'EAO'};
			key[23] = {tile:TileProto, map:'EAOG'};
			key[24] = {tile:TileProto, map:''};
			key['pc'] = {tile:Tile};
			
			/*key[1] = {tile:Tile001};
			key[2] = {tile:Tile};
			key[3] = {tile:Tile003};
			key[4] = {tile:Tile};
			key[0] = {tile:Tile002};
			*/
			
			
			//
			
			/**/
		}
		private function imgLoaded(event:Event):void
		{
			//addChild(event.target.content);
			
			var _master:BitmapData = new BitmapData(event.target.content.width, event.target.content.height);
			_master.draw(event.target.content);
			
			_lamech = new Lamech(this.stage);
			
			_lamech.world.gridSize = 16;
			
			_lamech.world.gridWidth = level[0].length - 1;
			_lamech.world.gridHeight = level.length - 1;
			
			_lamech.buildLevel(level, key, _master);
			
			var t_pc:PlayerGO = new PlayerGO();
			var t_input:InputObject = new InputObject();
			t_input.doStageCapture(this.stage);
			
			t_pc.x = 25
			t_pc.y = 25
			t_pc.id = 'pc';
			t_pc.input = t_input;
			t_pc.blitSource = _master;
			
			_lamech.addGameObject(t_pc);
			_lamech.setCamera(t_pc, 250, 150);
			
			_lamech.startTime();
		}
	}
}