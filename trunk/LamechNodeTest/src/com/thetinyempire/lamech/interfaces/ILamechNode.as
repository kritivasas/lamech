package com.thetinyempire.lamech.interfaces
{
	import flash.geom.Point;
	
	public interface ILamechNode
	{
		
		function init(...args):void
		
		// Schedule a function every *interval* sexonds
		function scheduleInterval(callback:Function, interval:uint, ...args):void
		
		// Schedule a function to be called every frame
		function schedule(callback:Function, ...args):void
		
		// Remove a function from the schedule
		function unchedule(callback:Function):void
		
		// Time will continue/start passing for this node and callbacks will be called
		function resumeScheduler():void
		
		// Time will stop passing for this node and callbacks will not be called
		function pauseScheduler():void
		
		// Walks the nodes tree upwards until it finds a node of the class *klass* or returns null
		function getAncestor(klass:String):ILamechNode
		
		// Adds a child to the container
		function add(child:ILamechNode, z:int, name:String):ILamechNode
		
		// Removes a child from the container given its name or object
		function remove(obj:*):void
		
		// Gets a child from the container given its name
		function getChild(name:String):Object
		
		// Called everytime just before the node enters the stage
		function onEnter():void
		
		// Called everytime just before the node leaves the stage
		function onExit():void
		
		//  Apply ModelView transformations you will most likely want to wrap calls to this function with glPushMatrix/glPopMatrix
		//function transform():void
		
		// Executes callback on all the subtree starting at self
		function walk(callback:Function, collect:Array = null):Array
		
		// This function "visit's" it's children in a recursive way
		function visit(self:ILamechNode):void
		
		// This function will be overriden if you want your subclassed to draw something on screen
		function draw(...args):void
		
		// Executes an *action*
		function doAction(action:*, target:ILamechNode = null):*
		
		// Removes an action from the queue
		function removeAction(action:*):void
		
		// Suspends the execution of actions
		function pause():void
		
		// Resumes teh execution of actions
		function resume():void
		
		// Removes all actions from the running action list
		function stop():void
		
		// Determine whether any actions are running
		function areActionsRunning():Boolean
		
		///
		function pushAllHandlers():void
		function removeAllHandlers():void
		
		///////////////////////////////////////////////////////////////////////////////////////////
		//                                                                      GETTER / SETTER  //
		///////////////////////////////////////////////////////////////////////////////////////////
		
		// ANCHOR
		function get anchor():Point
		
		function set anchor(p:Point):void
		
		// ANCHORX
		function get anchorX():Number
		
		function set anchorX(n:Number):void
		
		// ANCHORY
		function get anchorY():Number
		
		function set anchorY(n:Number):void
		
		// CHILD_ANCHOR
		function get childrenAnchor():Point
		
		function set childrenAnchor(p:Point):void
		
		// TRANSFORM_ANCHOR
		function get transformAnchor():Point
		
		function set transformAnchor(p:Point):void
		
		// Z
		function get z():int
		
		function set z(i:int):void
		
		//PARENT
		function get parent():ILamechNode
		
		function set parent(p:ILamechNode):void
		
		//CHILDREN
		function get children():Array
		
	}
}