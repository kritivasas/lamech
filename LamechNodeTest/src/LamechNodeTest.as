package {
	import com.hexagonstar.util.debug.Debug;
	import com.thetinyempire.lamech.*;
	import com.thetinyempire.lamech.action.*;
	import com.thetinyempire.lamech.config.WindowConfig;
	import com.thetinyempire.lamech.layer.*;
	import com.thetinyempire.lamech.resource.*;
	import com.thetinyempire.lamech.scene.*;
	
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	import flash.geom.Point;
	
	[SWF( frameRate='60')]
	
	public class LamechNodeTest extends Sprite
	{
		public function LamechNodeTest()
		{
			Debug.monitor(this.stage);
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			var director:Director = Director.getInstance();
			
			var config:WindowConfig = new WindowConfig();
			
			config.viewComponent = this;
			
			director.init(config);
			
			//
			
			///////////////////
			//  HELLO WORLD  //
			///////////////////
			
//			var helloWorld:LayerAA = new LayerAA();
//			var scene:Scene = new Scene([helloWorld]);
//			director.run(scene);
			
			////////////////////////
			//  IMAGE LAYER TEST  //
			////////////////////////
			
//			var imgRes:ImageResource = new ImageResource("imgRes");
//			imgRes.load('maps2/test.jpg');
//			var imgLayer:ImageLayer = new ImageLayer(imgRes);
//			var imgScene:Scene = new Scene([imgLayer]);
//			director.run(imgScene);

			/////////////////////////////////////////////
			//  IMAGE LAYER TEST  w/ SCROLLABLE LAYER  //
			/////////////////////////////////////////////
			
//			var imgRes:ImageResource = new ImageResource('imgRes');
//			imgRes.load('maps2/test.jpg');
//			var imgLayer:ImageLayer = new ImageLayer(imgRes);
//			var scrollManager:ScrollManager = new ScrollManager();
//			scrollManager.add(imgLayer, 0, 'imgLayer');
//			var controlLayer:scrollControlLayer = new scrollControlLayer(scrollManager);
//			var scene:Scene = new Scene([scrollManager, controlLayer])
//			director.run(scene);

			//////////////////////////////////////////////////////////
			//  IMAGE LAYER TEST  w/ SCROLLABLE LAYER  + w/ LIQUID  //
			//////////////////////////////////////////////////////////
			
//			var imgRes:ImageResource = new ImageResource('imgRes');
//			imgRes.load('maps2/test.jpg');
//			var imgLayer:ImageLayer = new ImageLayer(imgRes);
//			var scrollManager:ScrollManager = new ScrollManager();
//			scrollManager.add(imgLayer, 0, 'imgLayer');
//			var controlLayer:scrollControlLayer = new scrollControlLayer(scrollManager);
//			var scene:Scene = new Scene([scrollManager, controlLayer])
//			director.run(scene);
//			scene.doAction(new Liquid(100, 5,new Point(5, 5), 200));

			///////////////////////////////////////////////
			//  RECTMAP LAYER TEST  w/ SCROLLABLE LAYER  //
			///////////////////////////////////////////////
//			var tileMapRes:TileMapResource = new TileMapResource('tileMapRes001');
//			var mapLayer:RectMapLayer = new RectMapLayer('test', 32, 32, tileMapRes, new Point(0,0));
//			tileMapRes.load('maps2/testMap.xml');
////			
//			var scrollManager:ScrollManager = new ScrollManager();
//			scrollManager.add(mapLayer, 0, 'mapLayer');
////			
//			var controlLayer:scrollControlLayer = new scrollControlLayer(scrollManager);
////			
//			var scene:Scene = new Scene([scrollManager, controlLayer])
////			
//			director.run(scene);
			
			
			////////////////////////////////////////////////////////////////////////
			//  RECTMAP LAYER TEST  w/ IMAG LAYER w/ SCROLLABLE LAYER  w/ LIQUID  //
			////////////////////////////////////////////////////////////////////////
//			var imgRes:ImageResource = new ImageResource('imgRes');
//			var imgLayer:ImageLayer = new ImageLayer(imgRes);
//			imgRes.load('maps2/test.jpg');
//			
//			var tileMapRes:TileMapResource = new TileMapResource('tileMapRes001');
//			var mapLayer:RectMapLayer = new RectMapLayer('test', 32, 32, tileMapRes, new Point(0,0));
//			tileMapRes.load('maps2/testMap.xml');
//				
//			var scrollManager:ScrollManager = new ScrollManager();
//			scrollManager.add(imgLayer, 0, 'imgLayer');
//			scrollManager.add(mapLayer, 0, 'mapLayer');
//			
//			var controlLayer:scrollControlLayer = new scrollControlLayer(scrollManager);
//			
//			var layerAA:LayerAA = new LayerAA();
//			var layerAB:LayerAB = new LayerAB();
//			var scene:Scene = new Scene([layerAA, scrollManager, controlLayer, layerAB])
//	
//			director.run(scene);
//			layerAA.doAction(new Liquid(100, 5,new Point(5, 5), 200));


			/////////////////////////////////////////////////////////////////////////////////////////
			//  PHYSWORLD TEST + RECTMAP LAYER TEST  w/ IMAG LAYER w/ SCROLLABLE LAYER  w/ LIQUID  //
			/////////////////////////////////////////////////////////////////////////////////////////
//			var phsyWorld:PhysWorld = PhysWorld.getInstance();
////		
//			var tileMapRes:TileMapResource = new TileMapResource('tileMapRes001');
//			var mapLayer:RectMapLayer = new RectMapLayer('test', 32, 32, tileMapRes, new Point(0,0));
//			tileMapRes.load('maps2/testMap.xml');
////			
//			var scrollManager:ScrollManager = new ScrollManager();
//			scrollManager.add(mapLayer, 0, 'mapLayer');
////			
//			var controlLayer:scrollControlLayer = new scrollControlLayer(scrollManager);
////			
//			var layerAA:PhysLayer = new PhysLayer();
//			var imgRes:ImageResource = new ImageResource('imgRes');
//			var imgLayer:ImageLayer = new ImageLayer(imgRes);
//			imgRes.load('maps2/test.jpg');
////
//			scrollManager.add(layerAA, 1, 'physLayer');
//			
//			scrollManager.doAction(new Liquid(100, 5,new Point(5, 5), 200));
//			
//			//
//			//
//			var layerGameBG:LayerGameBG = new LayerGameBG();
//			var layerGameStart:LayerGameStart = new LayerGameStart();
//			var layerGameEnd:LayerGameEnd = new LayerGameEnd();
//			var layerGameControl:ControlLayer = new ControlLayer();
//			
//			var sceneA:Scene = new  Scene([layerGameBG, layerGameStart, layerGameControl])
//			var sceneB:Scene = new Scene([ scrollManager, imgLayer, controlLayer, layerGameControl])
//			var sceneC:Scene = new Scene([layerGameBG, layerGameEnd])
//
//			director.push(new MoveInRTransition(sceneB, 2, sceneC));
//			director.push(new MoveInRTransition(sceneA, 2, sceneB))
//		//	director.push(new MoveInRTransition(new Scene([layerCB, layerAA, control]), 2, new Scene([layerBB, layerBA, control])))
//			
//			///
//			///
//			///
//			
//			director.run(sceneA);

			/////////////////////////////////////////////////////////////////////////////////////////
			//  PHYSWORLD TEST + RECTMAP LAYER TEST  w/ IMAG LAYER w/ SCROLLABLE LAYER  w/ LIQUID  //
			/////////////////////////////////////////////////////////////////////////////////////////
			var phsyWorld:PhysWorld = PhysWorld.getInstance();

			var tileMapRes:TileMapResource = new TileMapResource('tileMapRes001');
			var mapLayer:RectMapLayer = new RectMapLayer('test', 32, 32, tileMapRes, new Point(0,0));
			tileMapRes.load('maps2/testMap.xml');
			
			var imgRes:ImageResource = new ImageResource('imgRes');
			var imgLayer:ImageLayer = new ImageLayer(imgRes);
			imgRes.load('maps2/test.jpg');
			
			var physLayer:PhysLayer = new PhysLayer();
			
			var scrollManager:ScrollManager = new ScrollManager();
			
			scrollManager.add(imgLayer, 0, 'imgLayer');
			scrollManager.add(mapLayer, 1, 'mapLayer');
			scrollManager.add(physLayer, 2, 'physLayer');
			
			var controlLayer:scrollControlLayer = new scrollControlLayer(scrollManager);
			
			//var layerGameBG:LayerGameBG = new LayerGameBG();
			//var layerGameControl:ControlLayer = new ControlLayer();
			
			var sceneB:Scene = new Scene([scrollManager, controlLayer])

			director.run(sceneB);
			//sceneB.doAction(new Liquid(100, 5,new Point(5, 5), 200));
		}
	}
}
