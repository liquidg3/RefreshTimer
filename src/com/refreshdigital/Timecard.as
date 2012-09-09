package com.refreshdigital
{
	public class Timecard
	{
		public var parent:*;
		public var time:String;
		public var type:String;
		public var comment:String;
		
		private var _project:Project;
		
		
		public function Timecard(params:Object)
		{
			this.time			= params.time;
			this._project		= params.project;
			this.parent			= params.parent;
			this.type			= params.type;
			this.comment		= params.comment;
		}
		
		static public function getDummy(message:String):Timecard 
		{
			
			var params:Object = {
				time:		"0",
				project:	null,
				parent:		null,
				type:		message,
				comment:	message
			};
			
			return new Timecard(params);
		}
		
		public function getFormattedTime():String
		{
			var timeParts:Array		= this.time.split(".");
			var hours:String		= timeParts[0];
			var minutes:Number		= Math.ceil((parseFloat("." + timeParts[1]))*60);
			
			
			return hours+":"+minutes;
		}

	}
}