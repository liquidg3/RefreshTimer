package com.refreshdigital
{
	import flash.events.Event;
	
	public class LoggerEvent extends Event
	{
		
		public static var TYPE_MESSAGE_LOGGED:String = 'messagelogged';
		
		
		public var lastMessage:String 	= '';
		public var logger:Logger 		= null;
		
		public function LoggerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}