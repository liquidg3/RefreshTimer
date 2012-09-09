package com.refreshdigital.DataAdapter
{
	import flash.events.Event;

	public class DataAdapterEvent extends Event
	{
		public var results:*;
		public var error:Boolean = false;
		public var errorMessage:String;
		
		public static const TYPE_RESULT:String			= 'result';
		public static const TYPE_FAULT:String			= 'fault';
		
		public function DataAdapterEvent(type : String, bubbles : Boolean = false, cancelable : Boolean = false) {
			super (type, bubbles, cancelable);
		}
	}
}