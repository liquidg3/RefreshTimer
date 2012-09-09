package com.refreshdigital
{
	import com.refreshdigital.DataAdapter.DataAdapterEvent;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.TimerEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.Timer;
	
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	public class HttpServiceRefresh extends URLLoader
	{
		
		
		private static var _serviceQueue:Array		= [];
		private static var _numRequests:Number		= 0;
		private var _storedRequest:URLRequest		= null;
		private var _running:Boolean				= false;
		
		
		public static var maxSimultaneousRequests:Number	= 4;
		public static var delayBetweenRequests:Number		= 0;		
		
		public function HttpServiceRefresh(request:URLRequest = null)
		{
			
			if(request == null) {
				this._storedRequest = new URLRequest();
			} else {
				this._storedRequest = request;
			}
			
			super(request);
		
			var me:HttpServiceRefresh = this;	
			this.addEventListener(Event.COMPLETE,function(event:Event):void {
				
				//run next set in queue
				Logger.log("http call finished: " + getRequest().url);
				HttpServiceRefresh._numRequests --;
				
				HttpServiceRefresh.runQueue(event);
				
				//pass this event to everyone who his waiting for it
				var e:DataAdapterEvent 		= new DataAdapterEvent(DataAdapterEvent.TYPE_RESULT);
				e.results 					= new XML(me.data);
				e.error		= false;
				me.dispatchEvent(e);
				
			});
			
			
			
			this.addEventListener(IOErrorEvent.IO_ERROR,runFail);
			this.addEventListener(SecurityErrorEvent.SECURITY_ERROR, runFail);
		}
		
		public function runFail(event:*):void {
			
			HttpServiceRefresh._numRequests --;			
			HttpServiceRefresh.runQueue();
			Logger.log('CALL FAILED (' + event.text + '): ' + event);
			
			var e:DataAdapterEvent	= new DataAdapterEvent(DataAdapterEvent.TYPE_FAULT);
			e.results				= null;
			e.error					= true;
			e.errorMessage			= event;
			
			this.dispatchEvent(e);
			
		}
		
		public static function runQueue(event:Event = null):void {
			
			Logger.log('http queue started, requests in queue: ' + HttpServiceRefresh._serviceQueue.length);
			
			var run:Function = function():void {
				
				
				if (HttpServiceRefresh._serviceQueue.length > 0) {
					var service:HttpServiceRefresh					= HttpServiceRefresh._serviceQueue.shift();
					service._running = true;
					service.load(service.getRequest());
				}
			}
			
			if(delayBetweenRequests > 0) {
				
				var timer:Timer = new Timer(delayBetweenRequests,0);
				timer.addEventListener(TimerEvent.TIMER_COMPLETE,run);
				timer.start();
				
			} else {
				run();
			}
		}
		
		
		public function send(params:Object = null):void
		{			
			
			//set params to request if they are passed
			if(params != null) {
				var variables:URLVariables = new URLVariables;
				for(var key:String in params) {
					variables[key] = params[key];
				}
				
				this.getRequest().data = variables;
			}
			
			if (HttpServiceRefresh._numRequests > HttpServiceRefresh.maxSimultaneousRequests) {
				
				Logger.log('Maximum http service calls of ' + maxSimultaneousRequests + ' reached: ' + this.getRequest().url);				
				HttpServiceRefresh._serviceQueue.push(this);
				
				return;
			}
			else {
				
				Logger.log('http service call made: ' + this.getRequest().url);
				
				HttpServiceRefresh._numRequests ++;
				this._running = true;
				this.load(this.getRequest());
			}
		}
		
		
		
		public static function cancelAllRequests():void {
			
			Logger.log('cancelling all requests (to boost user requested requests)');
			
			for(var index:Number=0; index<HttpServiceRefresh._serviceQueue.length; index++) {
				
				Logger.log('cancelling call to: '  + HttpServiceRefresh._serviceQueue[index].getRequest().url);
				
				if(HttpServiceRefresh._serviceQueue[index]._running) {
					HttpServiceRefresh._serviceQueue[index].close();
				}
			}
			
			HttpServiceRefresh._numRequests		= 0;
			HttpServiceRefresh._serviceQueue	= [];
		}
		
		public function getRequest():URLRequest {
			return this._storedRequest;
		}
		
		public function set method(method:String):void {
			this.getRequest().method = method;
		}
		
		public function set url(url:String):void {
			this.getRequest().url = url;
		}
		
		
		
	}
}