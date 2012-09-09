package com.refreshdigital.Drawer
{
	import components.DrawerGroup;
	
	import flash.events.Event;
	
	public class DrawerEvent extends Event
	{
		public static var OPEN:String 		= 'open';
		public static var OPENED:String 	= 'opened';
		public static var CLOSE:String	 	= 'string';
		public static var CLOSED:String		= 'closed';
		
		public var drawer:DrawerGroup = null;
		public function DrawerEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			//TODO: implement function
			super(type, bubbles, cancelable);
		}
	}
}