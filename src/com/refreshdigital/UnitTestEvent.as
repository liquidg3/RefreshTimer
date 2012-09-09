package com.refreshdigital
{
	import flash.events.Event;
	
	public class UnitTestEvent extends Event
	{
		public var message:String = '';
		
		/**
		 * Event types
		 */
		public static var TYPE_STOP:String 		= 'stop';
		public static var TYPE_START:String 	= 'start';
		public static var TYPE_STEP:String 		= 'step';
		
		public function UnitTestEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
		}
	}
}