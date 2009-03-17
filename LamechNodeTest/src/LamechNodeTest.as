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
			
//			var layerAA:LayerAA = new LayerAA();
//			var layerAB:LayerAB = new LayerAB();
//			var layerBA:LayerBA = new LayerBA();
//			var layerBB:LayerBB = new LayerBB();
//			var layerCB:LayerCB = new LayerCB();
//			
//			var control:ControlLayer = new ControlLayer();
			
//			layer.init();
			
//			var sceneA:Scene = new Scene([layerAB, layerAA, control]);
//			var sceneB:Scene = new Scene([layerBB, layerBA, control]);
			
//			director.push(new MoveInRTransition(new Scene([layerBB, layerBA, control]), 2, new Scene([layerAB, layerAA, control])))
//			director.push(new MoveInRTransition(new Scene([layerCB, layerAA, control]), 2, new Scene([layerBB, layerBA, control])))
//			director.push(new MoveInRTransition(new Scene([layerBB, layerBA, control]), 2, new Scene([layerCB, layerAA, control])))
//			director.run(new Scene([layerAB, layerAA, control]));
			
			//director.push(new MoveInRTransition(new Scene([layerAB, layerAA, control]), 2, new Scene([layerBB, layerBA, control])))
			//director.run(sceneA)//.doAction(new Liquid(2,20,new Point(4, 4), 5)));
			//sceneA.doAction(new Liquid(10, 40,new Point(5, 5), 20));
			
			////////////////////////
			//  IMAGE LAYER TEST  //
			////////////////////////
			
//			var imgRes:ImageResource = new ImageResource();
//			imgRes.load('maps/test.jpg');
//			var imgLayer:ImageLayer = new ImageLayer(imgRes);
//			var imgScene:Scene = new Scene([imgLayer]);
//			director.run(imgScene);

			/////////////////////////////////////////////
			//  IMAGE LAYER TEST  w/ SCROLLABLE LAYER  //
			/////////////////////////////////////////////
			
//			var imgRes:ImageResource = new ImageResource('imgRes');
//			imgRes.load('maps/test.jpg');
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
//			imgRes.load('maps/test.jpg');
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
//			tileMapRes.load('maps/testMap.xml');
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
//			imgRes.load('maps/test.jpg');
			
			var tileMapRes:TileMapResource = new TileMapResource('tileMapRes001');
			var mapLayer:RectMapLayer = new RectMapLayer('test', 32, 32, tileMapRes, new Point(0,0));
			tileMapRes.load('maps/testMap.xml');
//			
			var scrollManager:ScrollManager = new ScrollManager();
			//scrollManager.add(imgLayer, 0, 'imgLayer');
			scrollManager.add(mapLayer, 0, 'mapLayer');
//			
			var controlLayer:scrollControlLayer = new scrollControlLayer(scrollManager);
//			
			var layerAA:LayerAA = new LayerAA();
			var layerAB:LayerAB = new LayerAB();
			var scene:Scene = new Scene([layerAA, scrollManager, controlLayer, layerAB])
//			
			director.run(scene);
			
			
			layerAA.doAction(new Liquid(100, 5,new Point(5, 5), 200));
		}
	}
}
