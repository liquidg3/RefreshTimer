package com.refreshdigital
{
	import flash.events.Event;
	
	public class TimePostDrawerEvent extends Event
	{
		
		public static var SUBMIT:String 	= 'submit';
		
		public var elapsedTime:Number;
		public var billingType:Number;
		public var comments:String;
		
		public function TimePostDrawerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}