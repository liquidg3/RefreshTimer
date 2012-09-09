package com.refreshdigital
{
	import flash.events.EventDispatcher;

	public class Logger extends EventDispatcher
	{
		[Bindable]
		public var logMessage:String = '';
		
		private static var _instance:Logger = null;
		
		public function Logger(){}
		
		public static function getInstance():Logger {
			if(Logger._instance == null) {
				Logger._instance = new Logger();
			}
			
			return Logger._instance;
		}
		
		public static function log(message:String):void {
			
			var instance:Logger = Logger.getInstance();
			
			instance.logMessage += instance.getTimestamp() + " - " + message + "\n"; 
			
			var event:LoggerEvent 	= new LoggerEvent(LoggerEvent.TYPE_MESSAGE_LOGGED);
			event.lastMessage 		= message;
			event.logger			= instance;
			
			instance.dispatchEvent(event);
			
			//trace(message);
		}
		
		public static function addEventListener(type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void {
			var instance:Logger = Logger.getInstance();
			instance.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}
		
		public function getTimestamp():String {
			var now:Date = new Date();
			return ("00"+ now.hoursUTC.toString()).substr(-2) + ":" + ("00"+ now.minutes.toString()).substr(-2) + ":" + ("00"+ now.seconds.toString()).substr(-2);
		}
		
		
	}
}