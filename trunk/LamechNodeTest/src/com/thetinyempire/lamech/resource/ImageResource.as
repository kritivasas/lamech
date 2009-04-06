package com.thetinyempire.lamech.resource
{
	//import com.hexagonstar.util.debug.Debug;
	import com.thetinyempire.lamech.base.BaseLamechResource;
	
	import flash.display.IBitmapDrawable;
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLRequest;
	
	public class ImageResource extends BaseLamechResource
	{
		private var _url:String;
		private var _loader:Loader;
		private var _urlReq:URLRequest;
		
		public function ImageResource(id:String, target:IEventDispatcher=null)
		{
			super(id, target);
		}
		
		public function load(url:String)
		{
			_url = url;
			_loader = new Loader();
			_loader.contentLoaderInfo.addEventListener(Event.INIT, initHandler);
			_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			_loader.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            _loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
			_urlReq = new URLRequest(_url);
			_loader.load(_urlReq);
		}
		
		private function initHandler(event:Event):void {
//            var loader:Loader = Loader(event.target.loader);
//            var info:LoaderInfo = LoaderInfo(loader.contentLoaderInfo);
//            Debug.trace("initHandler: loaderURL=" + info.loaderURL + " url=" + info.url);
        }
        
        private function progressHandler(event:ProgressEvent):void {
//            var loader:Loader = Loader(event.target.loader);
//            var info:LoaderInfo = LoaderInfo(loader.contentLoaderInfo);
//            Debug.trace("initHandler: loaderURL=" + info.loaderURL + " url=" + info.url);
        }
        
        private function completeHandler(event:Event):void {
//            var loader:Loader = Loader(event.target.loader);
//            var info:LoaderInfo = LoaderInfo(loader.contentLoaderInfo);
//            Debug.trace("initHandler: loaderURL=" + info.loaderURL + " url=" + info.url);
            
            _ready = true;
            dispatchEvent(new Event(Event.COMPLETE));
        }

        private function ioErrorHandler(event:IOErrorEvent):void {
            //Debug.trace("ioErrorHandler: " + event);
        }
        
        public function get img():IBitmapDrawable
        {
        	return _loader.content
        }
        
        public function get width():uint
        {
        	return _loader.content.width;
        }
        
        public function get height():uint
        {
        	return _loader.content.height;
        }
	}
}