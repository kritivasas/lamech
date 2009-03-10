package {
	import com.hexagonstar.util.debug.Debug;
	import com.thetinyempire.lamech.Director;
	import com.thetinyempire.lamech.Scene;
	import com.thetinyempire.lamech.config.WindowConfig;
	import com.thetinyempire.lamech.scene.MoveInRTransition;
	
	import flash.display.Sprite;
	import flash.display.StageScaleMode;
	
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
			
			var layerAA:LayerAA = new LayerAA();
			var layerAB:LayerAB = new LayerAB();
			var layerBA:LayerBA = new LayerBA();
			var layerBB:LayerBB = new LayerBB();
			var layerCB:LayerCB = new LayerCB();
			
			var control:ControlLayer = new ControlLayer();
			
//			layer.init();
			
			var sceneA:Scene = new Scene([layerAB, layerAA, control]);
			var sceneB:Scene = new Scene([layerBB, layerBA, control]);
			
			//director.run(new MoveInRTransition(sceneA, 2, sceneB));//new MoveInRTransition(sceneA, 2, sceneB));
			
			director.push(new MoveInRTransition(new Scene([layerBB, layerBA, control]), 2, new Scene([layerAB, layerAA, control])))
			director.push(new MoveInRTransition(new Scene([layerCB, layerAA, control]), 2, new Scene([layerBB, layerBA, control])))
			director.push(new MoveInRTransition(new Scene([layerBB, layerBA, control]), 2, new Scene([layerCB, layerAA, control])))
			director.push(new MoveInRTransition(new Scene([layerAB, layerAA, control]), 2, new Scene([layerBB, layerBA, control])))
			director.run(new Scene([layerAB, layerAA, control]));
		}
	}
}
