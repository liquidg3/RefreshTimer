package com.refreshdigital
{
	public class SubTask extends Task
	{
		
		private var _parentTask:Task = null;
		
		public function SubTask(params:Object)
		{
			
			super(params);
			this._parentTask 	= params.parentTask;
			this.type			= Remote.TYPE_SUBTASK;
		}
		
		
		override public function setListItemText():void {
			
			this._listItem.isProgressVisible 	= false;
			this._listItem.heading 				= this.name;
			this._listItem.headingFontSize 		= 13;
			this._listItem.subHeading			= this.getDueDateRelative();
			this._listItem.checked				= this.completed;
		}
		
		static public function getDummy(message:String):SubTask {
			return new SubTask({
				id:		'-1',
				name:	message
			});
		}
	}
}