package com.thetinyempire.lamech
{
	import com.thetinyempire.lamech.config.WindowConfig;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import flash.geom.Point;
	
	import org.casalib.util.StageReference;
	
	public class Director extends EventDispatcher
	{
		/*
		Singleton that handles the logic behind the Scenes

		Director
		========
		
		Initializing
		------------
		
		The director is the singleton that creates and handles the main ``Window``
		and manages the logic behind the ``Scenes``. 
		
		The first thing to do, is to initialize the ``director``::
		
		    from cocos.director import *
		    director.init( list_of_arguments )
		
		This will initialize the director, and will create a display area 
		(a 640x480 window by default).
		The parameters that are supported by director.init() are the same
		parameters that are supported by pyglet.window.Window().
		
		Some of the supported parameters are:
		
		    * ``fullscreen``: Boolean. Window is created in fullscreen. Default is False
		    * ``resizable``: Boolean. Window is resizable. Default is False
		    * ``vsync``: Boolean. Sync with the vertical retrace. Default is True
		    * ``width``: Integer. Window width size. Default is 640
		    * ``height``: Integer. Window height size. Default is 480
		    * ``caption``: String. Window title.
		    * ``visible``: Boolean. Window is visible or not. Default is True.
		
		The full list of valid arguments can be found here:
		
		    - http://www.pyglet.org/doc/1.1/api/pyglet.window.Window-class.html
		
		
		Example::
		
		    director.init( caption="Hello World", fullscreen=True )
		
		For a complete list of the supported parameters, see the pyglet Window
		documentation.
		
		Running a Scene
		----------------
		
		Once you have initialized the director, you can run your first ``Scene``::
		
		    director.run( Scene( MyLayer() ) )
		
		This will run a scene that has only 1 layer: ``MyLayer()``. You can run a scene
		that has multiple layers. For more information about ``Layers`` and ``Scenes``
		refer to the ``Layers`` and ``Scene`` documentation.
		
		`cocos.director.Director`
		
		Once a scene is running you can do the following actions:
		
		    * ``director.replace( new_scene ):``
		        Replaces the running scene with the new_scene 
		        You could also use a transition. For example:
		        director.replace( SplitRowsTransition( new_scene, duration=2 ) )
		
		    * ``director.push( new_scene ):``
		        The running scene will be pushed to a queue of scenes to run,
		        and new_scene will be executed.
		
		    * ``director.pop():``
		        Will pop out a scene from the queue, and it will replace the running scene.
		
		    * ``director.scene.end( end_value ):``
		        Finishes the current scene with an end value of ``end_value``. The next scene
		        to be run will be popped from the queue.
		
		Other functions you can use are:
		
		    * ``director.get_window_size():``
		      Returns an (x,y) pair with the _logical_ dimensions of the display.
		      The display might have been resized, but coordinates are always relative
		      to this size. If you need the _physical_ dimensions, check the dimensions
		      of ``director.window``
		
		    
		    * ``get_virtual_coordinates(self, x, y):``
		      Transforms coordinates that belongs the real (physical) window size, to
		      the coordinates that belongs to the virtual (logical) window. Returns
		      an x,y pair in logical coordinates.
		
		The director also has some useful attributes:
		
		    * ``director.return_value``: The value returned by the last scene that
		      called ``director.scene.end``. This is useful to use scenes somewhat like
		      function calls: you push a scene to call it, and check the return value
		      when the director returns control to you.
		
		    * ``director.window``: This is the pyglet window handled by this director,
		      if you happen to need low level access to it.
		            
		    * ``self.show_FPS``: You can set this to a boolean value to enable, disable
		      the framerate indicator.
		            
		    * ``self.scene``: The scene currently active
		    */
		    
		private static var _instance:Director;
		
		private var _eventLoop:EventLoop;
		
		private var _window:Window;
		private var _windowOriginalWidth:uint;
		private var _windowOriginalHeight:uint;
		private var _windowAspect:Number;
		private var _offsetX:uint;
		private var _offsetY:uint;
		private var _doNotScaleWindow:Boolean;
		private var _showFPS:Boolean;
		
		private var _sceneStack:Array;
		private var _scene:Scene;
		private var _nextScene:Scene;
		
		private var _returnedValue:Object;
		
		public function Director(target:IEventDispatcher=null)
		{
			super(target);
		}
		
		public static function getInstance() : Director 
        {
            if ( _instance == null ) _instance = new Director();
            return _instance as Director;
        }
        
        public function init(config:WindowConfig):Window
        {
        	StageReference.setStage(config.viewComponent.stage);
        	
        	_doNotScaleWindow = config.doNotScale;
        	//the main view component
        	_window = Window.getInstance();
        	_window.init(config);
        	
        	_showFPS = false;
        	
        	_sceneStack = new Array();
        	
        	_scene = null
        	
        	_nextScene = null
        	
        	_eventLoop = EventLoop.getInstance();
        	_eventLoop.init(config.fps);
        	
        	if(_doNotScaleWindow)
        	{
        		// onResize, unscaledResizeWindow)
        		//_window.pushHandlers()
        	}
        	else
        	{
        		// onResize, scaledResizeWindow)
        		//_window.pushHandlers()
        	}
        	
        	_eventLoop.addEventListener(EventLoop.TICK, onDraw);
        	
        	_windowOriginalWidth = _window.width
        	_windowOriginalHeight = _window.height
        	_windowAspect = _window.width / _window.height
        	_offsetX = 0;
        	_offsetY = 0;
        	
        	//_fpsDisplay = new ClockDisplay();
        	
        	// where defaultHandler manages input events
        	//_window.pushHandlers(new DefaultHandler());
        	
        	return _window;
        }
        
        public function run(scene:Scene):void
        {
        	//_sceneStack.push(scene)
        	_setScene(scene);
        	
        	_eventLoop.run();
        }
        
        public function onDraw(e:Event):void
        {
        	_window.clear();
        	_window.lock();
        	
        	if(_nextScene != null)
        	{
        		_setScene(_nextScene)
        	}
        	
        	if(_sceneStack.length == 0)
        	{
        		//kill 'pyglet'
        	}
        	
        	_scene.visit();
        	
        	if(_showFPS)
        	{
        		//_fpsDisplay.draw()
        	}
        	
        	_window.unlock();
        }
        
        public function push(scene:Scene):void
        {
        	/*
        	Suspends the execution of the running scene, pushing it
        on the stack of suspended scenes. The new scene will be executed.

        :Parameters:   
            `scene` : `Scene`
                It is the scene that will be run.
                */
			//dispatchEvent(new Event("on_push"));//need to send scene with this message
			if(scene != null)
			{
				_nextScene = scene
    	    	_sceneStack.push(scene);
 			}
        }
        
        public function onPush():void
        {
        	
        }
        
        public function pop():void
        {
        	/*
        	Pops out a scene from the queue. This scene will replace the running one.
           The running scene will be deleted. If there are no more scenes in the stack
           the execution is terminated.
           */
           //dispatchEvent(new Event("on_pop"));
           
           _nextScene = _sceneStack.pop();
        }
        
        public function onPop(e:Event):void
        {
        	
        }
        
        public function replace(scene:Scene):void
        {
        	
        	_nextScene = scene
        }
        
        private function _setScene(scene:Scene):Scene
        {
        	_nextScene = null;
        	
        	if(_scene != null)
        	{
        		_scene.onExit()
        		_scene.enableHandlers(false);
        	}
        	
        	var old:Scene = _scene
        	
        	_scene = scene
        	_scene.enableHandlers(true);
        	_scene.parent = null;
        	_scene.onEnter();
        	
        	return old
        }
        
        //  HELPER FUNCTIONS  //
        
        public function get windowSize():Point
        {
        	return new Point(_windowOriginalWidth, _windowOriginalHeight);
        }
        
        public function getVirtualCoordinates(p:Point):Point
        {
        	var xDiff:Number = _windowOriginalWidth / (_window.width - _offsetX * 2);
        	var yDiff:Number = _windowOriginalHeight / (_window.height - _offsetY * 2);
        	
        	var adjustX:Number = (_window.width * xDiff - _windowOriginalWidth) / 2;
        	var adjustY:Number = (_window.height * yDiff - _windowOriginalHeight) / 2;
        	
        	return (new Point((xDiff * p.x) - adjustX,(yDiff *p.y) - adjustY));
        }
        
        public function scaledResizedWindow(w:uint, h:uint):void
        {
        	setProjection();
        	dispatchEvent(new Event('on_resize'))//w, h
        	//return pyglet.event.EVENT_HANDLED;
        }
        
        public function unscaledResizeWindow(w:uint, h:uint):void
        {
        	dispatchEvent(new Event('on_resize'))//w, h
        }
        
        public function setProjection():void
        {
        	
        }
        
        //  MISC FUNCTIONS  //
        
        //  GETTER / SETTER //
        public function get window():Window
        {
        	return _window;
        }
        
        public function get returnedValue():Object
        {
        	return _returnedValue;	
        }
        
        public function set returnedValue(o:Object):void
        {
        	_returnedValue = o;
        }
        
        public function get scene():Scene
        {
        	return _scene;
        }
	}
}