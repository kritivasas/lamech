package com.thetinyempire.lamech.base
{
	import com.adobe.utils.ArrayUtil;
	import com.thetinyempire.lamech.EventLoop;
	import com.thetinyempire.lamech.Grid2D;
	import com.thetinyempire.lamech.KeyboardManager;
	import com.thetinyempire.lamech.KeyboardManagerEvent;
	import com.thetinyempire.lamech.Window;
	
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.display.IBitmapDrawable;
	import flash.events.Event;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class BaseLamechNode //implements ILamechNode
	{
		public static const KLASS:String 	= "com.thetinyempire.lamech.base.BaseLamechNode";
		
		// list of children
		protected var _children:Array;
		// directory that naps children names with children references
		protected var _childrenNames:Object;
		protected var _parent:BaseLamechNode;
		// x-position of the object relative to it's parent's childrenAnchorX value
		protected var _x:Number
		// y-position of the object relative to it's parent's childrenAnchorY value
		protected var _y:Number;
		protected var _z:int;
		protected var _width:uint;
		protected var _height:uint;
		// alters the scale of this node and it's children
		protected var _scale:Number;
		// in degrees, alters teh rotation of this node and it's children
		protected var _rotation:Number;
		// eye, center and up vector for the Camera(object)
		protected var camera:Object;
		// offset from (x, 0) from where children will have its(0, 0) coordinate
		protected var _childrenAnchorX:Number
		// offset from (0, y) from where children will have its(0, 0) coordinate
		protected var _childrenAnchorY:Number
		// offset from (x,0) from where rotation and scale will be applied.
		protected var _transformAnchorX:Number
		// offset from (0,y) from where rotation and scale will be applied.
		protected var _transformAnchorY:Number
		// whether or not the object is visible
		protected var _visible:Boolean
		// the grid onject for actions
		protected var _grid:Grid2D;
		// list of Action objects that are running
		protected var _actions:Array;
		// list of Action objects to be removed
		protected var _toRemove:Array;
		// whether or not the next frame will be skipped
		protected var _skipFrame:Boolean;
		// list of scheduled callbacks
		protected var _scheduledCalls:Array;
		// list of scheduled interval callbacks
		protected var _scheduledIntervalCalls:Array
		// whether or not teh object is running
		protected var _isRunning:Boolean;
		// whether or not there is an action running
		protected var _runningActions:Boolean;
		
		public var _BMD:BitmapData;
		
		protected var _eventLoop:EventLoop;
		protected var _keyboardManager:KeyboardManager;
		
		public function BaseLamechNode()
		{
			_children = new Array();
			_childrenNames = new Object();
			_parent = null;
			
			//drawing inits
			_x = 0;
			_y = 0;
			_scale = 1;
			_rotation = 0;
			//_camera = ??
			_childrenAnchorX = 0;
			_childrenAnchorY = 0;
			_transformAnchorX = 0;
			_transformAnchorY = 0;
			_visible = true;
			_grid = null;
			
			_actions = new Array();
			_toRemove = new Array();
			
			_skipFrame = false;
			_scheduledCalls = new Array();
			_scheduledIntervalCalls = new Array();
			_isRunning = false;
			
			_eventLoop = EventLoop.getInstance();
			
			_keyboardManager = KeyboardManager.getInstance();
//			_keyboardManager.addEventListener(KeyboardManagerEvent.DOWN, onKeyDown)
//			_keyboardManager.addEventListener(KeyboardManagerEvent.UP, onKeyUp);
//			_keyboardManager.addEventListener(KeyboardManagerEvent.PERSIST, onKeyPersist);

			_runningActions = false;
			
			_BMD = new BitmapData(100,100,true,0xff000000);
		}
		
		// Schedule a function every *interval* sexonds
		public function scheduleInterval(t_callback:Function, t_interval:uint, ...args):void
		{
			/*Schedule a function to be called every `interval` seconds.
	
	        Specifying an interval of 0 prevents the function from being
	        called again (see `schedule` to call a function as often as possible).
	
	        The callback function prototype is the same as for `schedule`.
	
	        :Parameters:
	            `callback` : function
	                The function to call when the timer lapses.
	            `interval` : float
	                The number of seconds to wait between each call.
	
	        This function is a wrapper to pyglet.clock.schedule_interval.
	        It has the additional benefit that all calllbacks are paused and
	        resumed when the node leaves or enters a scene.
	
	        You should not have to schedule things using pyglet by yourself.*/
        	if(_isRunning)
        	{
        		// TODO:setup the interval/callback mechanism
        	}
        	_scheduledIntervalCalls.push({callback:t_callback, interval:t_interval});
		}
		
		// Schedule a function to be called every frame
		public function schedule(t_callback:Function, ...args):void
		{
			/*
			Schedule a function to be called every frame.

	        The function should have a prototype that includes ``dt`` as the
	        first argument, which gives the elapsed time, in seconds, since the
	        last clock tick.  Any additional arguments given to this function
	        are passed on to the callback::
	
	            def callback(dt, *args, **kwargs):
	                pass
	
	        :Parameters:
	            `callback` : function
	                The function to call each frame.
	
	        This function is a wrapper to pyglet.clock.schedule.
	        It has the additional benefit that all calllbacks are paused and
	        resumed when the node leaves or enters a scene.
	
	        You should not have to schedule things using pyglet by yourself.
	        */
	        if(_isRunning)
        	{
        		_eventLoop.addEventListener(EventLoop.TICK, t_callback);
        		// TODO:setup the interval/callback mechanism
        	}
        	_scheduledCalls.push({callback:t_callback});
		}
		
		// Remove a function from the schedule
		public function unchedule(t_callback:Function):void
		{
			/*
			Remove a function from the schedule.

	        If the function appears in the schedule more than once, all occurances
	        are removed.  If the function was not scheduled, no error is raised.
	
	        :Parameters:
	            `callback` : function
	                The function to remove from the schedule.
	
	        This function is a wrapper to pyglet.clock.unschedule.
	        It has the additional benefit that all calllbacks are paused and
	        resumed when the node leaves or enters a scene.
	
	        You should not unschedule things using pyglet that where scheduled
	        by node.schedule/node.schedule_interface.
	        */
	        
	        var hit:Object = null
	        for each(var i:Object in _scheduledCalls)
	        {
	        	if(i.callback == t_callback)
	        	{
	        		hit = i
	        	}
	        }
	        hit != null ? ArrayUtil.removeValueFromArray(_scheduledCalls, hit) : {};
	        
	        hit = null;
	        i = null
	        for each(i in _scheduledIntervalCalls)
	        {
	        	if(i.callback == t_callback)
	        	{
	        		hit = i
	        	}
	        }
	        hit != null ? ArrayUtil.removeValueFromArray(_scheduledIntervalCalls, hit) : {};
	        
	        
	        // UNSCHEDULE THAT SHIT WITH THE UNSCHEDULE MECHANISM SUCKAH!
		}
		
		// Time will continue/start passing for this node and callbacks will be called
		public function resumeScheduler():void
		{
			for each(var i:Object in _scheduledCalls)
	        {
	        	// register callback object with timing mechanizm
	        }
	       
	        i = null
	        for each(i in _scheduledIntervalCalls)
	        {
	        	// register callback object with timing mechanizm
	        }
		}
		
		// Time will stop passing for this node and callbacks will not be called
		public function pauseScheduler():void
		{
			for each(var i:Object in _scheduledCalls)
	        {
	        	_eventLoop.removeEventListener(EventLoop.TICK, i.callback);
        		
	        	// unregister callback object from timing mechanizm
	        }
	       
	        i = null
	        for each(i in _scheduledIntervalCalls)
	        {
	        	// unregister callback object from timing mechanizm
	        }
		}
		
		// Walks the nodes tree upwards until it finds a node of the class *klass* or returns null
		public function getAncestor(klass:String):BaseLamechNode
		{
			var t_obj:BaseLamechNode;
			
			if(KLASS == klass)
			{
				return(this);
			}
			
			if(_parent!=null)
			{
				return(_parent.getAncestor(klass));
			}
			else
			{
				return null;
			}
		}
		
		// Adds a child to the container
		public function add(child:BaseLamechNode, t_z:int, name:String):BaseLamechNode
		{
			if(name)
			{
				if(_childrenNames[name])
				{
					// throw error :name already exists
				}
				else
				{
					_childrenNames[name] = child
				}
			}
			
			child.parent = this;
			
			child.z = t_z
			_children.push(child)
			_children.sortOn(z,Array.NUMERIC);
			
			if (_isRunning)
			{
				child.onEnter();
			}
			
			return this;
		}
		
		// Removes a child from the container given its name or object
		public function remove(obj:*):void
		{
			if(obj is String)
			{
				if(_childrenNames[obj])
				{
					var child:BaseLamechNode = _childrenNames[obj]
					_childrenNames[obj] = null;
					_remove(child);
				}
				else
				{
					// throw exception: child not in list
				}
			}
			else if(obj is BaseLamechNode)
			{
				_remove(obj);
			}
		}
		
		protected function _remove(child:BaseLamechNode):void
		{
			var len_old:uint = _children.length;
			ArrayUtil.removeValueFromArray(_children, child);
			
			if(len_old == _children.length)
			{
				//throw exception: child not found
			}
			
			if(_isRunning)
			{
				child.onExit();
			}
		}
		
		public function contains(child:BaseLamechNode):Boolean
		{
			return(ArrayUtil.arrayContainsValue(_children, child));
		}
		
		// Gets a child from the container given its name
		public function getChild(name:String):Object
		{
			if(_childrenNames[name])
			{
				return _childrenNames[name];
			}
			else
			{
				//throw exception:child not in list
				return null;
			}
		}
		
		// Called everytime just before the node enters the stage
		public function onEnter():void
		{
			_isRunning = true;
			
			resume();
			resumeScheduler();
			
			for each(var i:BaseLamechNode in _children)
			{
				i.onEnter();
			}
			
		}
		
		// Called everytime just before the node leaves the stage
		public function onExit():void
		{
			_isRunning = false;
			
			pause();
			pauseScheduler();
			
			for each(var i:BaseLamechNode in _children)
			{
				i.onExit();
			}
		}
		
		//  Apply ModelView transformations you will most likely want to wrap calls to this function with glPushMatrix/glPopMatrix
		//function transform():void
		
		// Executes callback on all the subtree starting at self
		public function walk(callback:Function, collect:Array = null):Array
		{
			/*
			Executes callback on all the subtree starting at self.
		    returns a list of all return values that are not none
		
		    :Parameters:
		        `callback` : function
		            callable, takes a cocosnode as argument
		        `collect` : list
		            list of visited nodes
		
		    :rtype: list
		    :return: the list of not-none return values
		    */
        
			if(collect == null)
			{
				collect = new Array();
			}
			
			//call the function, collect any return values
			var r:Object = callback();
			if(r != null)
			{
				collect.push(r);
			}
			
			for each(var i:BaseLamechNode in _children)
			{
				i.walk(callback, collect);
			}
			
			return(collect)
		}
		
		// This function "visit's" it's children in a recursive way
		public function visit():void
		{
			/*
			This function *visits* it's children in a recursive
		    way.
		
		    It will first *visit* the children that
		    that have a z-order value less than 0.
		
		    Then it will call the `draw` method to
		    draw itself.
		
		    And finally it will *visit* the rest of the
		    children (the ones with a z-value bigger
		    or equal than 0)
		
		    Before *visiting* any children it will call
		    the `transform` method to apply any possible
		    transformation.
		    */
		    _BMD.fillRect(new Rectangle(0,0,_width,_height),0x00000000);
		    
		    if(!_visible)
		    {
		    	return;
		    }
		    
		    var pos:uint = 0;
		    
		    if(_grid && _grid.active)
		    {
		    	_grid.beforeDraw();
		    }
		    
		    
//		    if(_children.length > 0)
//		    {
//		    	//transform()
//		    	for(var i:uint = 0; i < _children.length; i++)
//		    	{
//		    		if(_children[i].z < 0)
//		    		{
//		    			pos++;
//		    			_children[i].visit();
//		    		}
//		    		else
//		    		{
//		    			break;
//		    		}
//		    	}
//		    }
		    
		  	//self !=null ? self.draw() : {};
		  	
		    
		    
		    if(pos < _children.length)
		    {
		    	//transform();
		    	for(var i:uint = pos; i < _children.length; i++)
		    	{
		    		_children[i].visit();
		    	}
		    }
		    
		    if(_grid && _grid.active)
		    {
		    	_grid.afterDraw();//_camera
		    }
		    
		    draw();
		   
		}
		
		// This function will be overriden if you want your subclassed to draw something on screen
		public function draw(...args):void
		{
			//_BMD.fillRect(new Rectangle(0,0,_width,_height),0x00000000);
			if(_parent != null)
			{
				var matrix:Matrix = new Matrix();
				matrix.translate(_x, _y);
				matrix.scale(_scale,_scale);
				
				if(_grid && _grid.active)
				{
					var ibmd:IBitmapDrawable =  _grid.blit() as IBitmapDrawable;
					_parent._BMD.draw(ibmd, matrix, null, BlendMode.NORMAL);
				
				}
				else
				{
					_parent._BMD.draw(myBitmapDrawable, matrix, null, BlendMode.NORMAL);
				
				}
				
				//_BMD.fillRect(new Rectangle(0,0,_width,_height),0x00000000);
			}
			else
			{
				var win:Window = Window.getInstance();
				
				if(_grid && _grid.active)
				{
					var ibmd:IBitmapDrawable =  _grid.blit() as IBitmapDrawable;
					win.draw({obj:ibmd, x:_x, y:_y});
				
				}
				else
				{
					win.draw({obj:myBitmapDrawable, x:_x, y:_y});
				
				}
				
			}
		}
		
		// Executes an *action*
		public function doAction(action:*, target:BaseLamechNode = null):*
		{
			if(target == null)
			{
				action.target = this
			}
			else
			{
				action.target = target
			}
			
			action.start();
			_actions.push(action);
			
			if(!_runningActions)
			{	
				if(_isRunning)
				{
					_runningActions = true;
					// register the _step function with the timing mechanism
					_eventLoop.addEventListener(EventLoop.TICK, _step); 
				}
			}
			
			return action;
		}
		
		// Removes an action from the queue
		public function removeAction(action:*):void
		{
			_toRemove.push(action);
		}
		
		// Suspends the execution of actions
		public function pause():void
		{
			if(!_runningActions)
			{
				return;
			}
			_runningActions = false;
			_eventLoop.removeEventListener(EventLoop.TICK, _step);
			// remove the _step function from the timer mechanism
		}
		
		// Resumes teh execution of actions
		public function resume():void
		{
			if(_runningActions)
			{
				return
			}
			_runningActions = true;
			_eventLoop.addEventListener(EventLoop.TICK, _step);
			_skipFrame = true;
		}
		
		// Removes all actions from the running action list
		public function stop():void
		{
			for each(var i:* in _actions)
			{
				_toRemove.push(i)
			}
		}
		
		// Determine whether any actions are running
		public function areActionsRunning():Boolean
		{
			var hit:uint = 0
			for each(var i:* in _actions)
			{
				if(!ArrayUtil.arrayContainsValue(_toRemove,i))
				{
					hit++;
				}
			}
			
			return(hit > 0);
		}
		
		protected function _step(e:Event):void
		{
			
			var dt:Number = e.target.dt;
			
			for each(var x:* in _toRemove)
			{
				if(ArrayUtil.arrayContainsValue(_actions, x))
				{
					ArrayUtil.removeValueFromArray(_actions, x)
				}
			}
			
			_toRemove = new Array();
			
			if(_skipFrame)
			{
				_skipFrame = false;
				return;
			}
			
			if(_actions.length == 0)
			{
				_runningActions = false;
				_eventLoop.removeEventListener(EventLoop.TICK, _step);
			}
			
			for each(var action:* in _actions)
			{
				action.step(dt)
				if(action.done)
				{
					action.stop()
					removeAction(action);
				}
			}
		}
		
		////
		
		public function pushAllHandlers():void
		{
			
		}
		
		public function removeAllHandlers():void
		{
			
		}
		
		///////////////////////////////////////////////////////////////////////////////////////////
		//                                                                         EVENT HANDLE  //
		///////////////////////////////////////////////////////////////////////////////////////////
		
		protected function onKeyDown(e:KeyboardManagerEvent):void
		{
			//Debug.trace('KEY DOWN SUCKAH:'+e.keyCode);
		}
		
		protected function onKeyUp(e:KeyboardManagerEvent):void
		{
			//Debug.trace('KEY UP SUCKAH:'+e.keyCode);
		}
		
		protected function onKeyPersist(e:KeyboardManagerEvent):void
		{
			//Debug.trace('KEY PERSIST SUCKAH:'+e.keyCode);
		}
		
		///////////////////////////////////////////////////////////////////////////////////////////
		//                                                                      GETTER / SETTER  //
		///////////////////////////////////////////////////////////////////////////////////////////
		
		// ANCHOR
		public function get anchor():Point
		{
			return new Point(_x, _y);	
		}
		
		public function set anchor(p:Point):void
		{
			_x = p.x
			_y = p.y	
		}
		
		// ANCHORX
		public function get anchorX():Number
		{
			return _x;	
		}
		
		public function set anchorX(n:Number):void
		{
			_x = n;
		}
		
		// ANCHORY
		public function get anchorY():Number
		{
			return _y;	
		}
		
		public function set anchorY(n:Number):void
		{
			_y = n;	
		}
		
		// CHILD_ANCHOR
		public function get childrenAnchor():Point
		{
			return new Point(_childrenAnchorX, _childrenAnchorY);	
		}
		
		public function set childrenAnchor(p:Point):void
		{
			_childrenAnchorX = p.x
			_childrenAnchorY = p.y	
		}
		// TRANSFORM_ANCHOR
		public function get transformAnchor():Point
		{
			return new Point(_transformAnchorX, _transformAnchorY);	
		}
		
		public function set transformAnchor(p:Point):void
		{
			_transformAnchorX = p.x
			_transformAnchorY = p.y	
		}
		
		//Z
		public function get z():int
		{
			return _z;
		}
		
		public function set z(i:int):void
		{
			_z = i;	
		}
		
		//PARENT
		public function get parent():BaseLamechNode
		{
			return _parent;
		}
		
		public function set parent(p:BaseLamechNode):void
		{
			_parent = p;	
		}
		
		//CHILDREN
		public function get children():Array
		{
			return _children;
		}
		
		//SCHEDULED
		public function get runningActions():Boolean
		{
			var t_bool:Boolean = new Boolean();
			_actions.length == 0 ? t_bool = false: t_bool = true;	
			return t_bool;
		}
		
		//VISIBLE
		public function get visible():Boolean
		{
			return _visible;
		}
		
		public function set visible(v:Boolean):void
		{
			_visible = v
		}
		
		// MY_BITMAP_DRAWABLE
		public function get myBitmapDrawable():IBitmapDrawable
		{
			return _BMD;
		}
		
		// GRID
		public function get grid():Grid2D
		{
			return _grid;
		}
		
		public function set grid(g:Grid2D):void
		{
			_grid = g;
			_grid.parent = this;
		}
		
		// SCALE
		public function set scale(s:Number):void
		{
			_scale = s
			for each(var c:BaseLamechNode in _children)
			{
				c.scale = s;
			}
		}
	}
}