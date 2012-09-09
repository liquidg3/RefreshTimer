package com.refreshdigital
{
	public class Checklist extends Task
	{
		
		private var _tasks:Array = null;
		
		public function Checklist(params:Object)
		{
			super(params);
			this.type	= Remote.TYPE_CHECKLIST;
		}
		
		override public function setListItemText():void {
			this._listItem.heading = this.name;	
		}
		
		override public function getSubTasks(successCallback:Function=null, failureCallback:Function=null):void {
			this.getTasks(successCallback, failureCallback);
		}
		
		public function getTasks(successCallback:Function = null, failureCallback:Function = null):void 
		{
			
			if(this.id == "-1") {
				return;
			}
			
			if(this._subTasks == null) {
				
				var me:Checklist = this;
				
				this._dataAdapter.getTasksForChecklist(this, function(subTasks:Array):void {
					
					me._subTasks = subTasks;
					
					if(successCallback != null) {
						successCallback(subTasks);
					}
					
				}, failureCallback);
				
			} else {
				if (successCallback != null) {
					successCallback(this._subTasks);
				}
			}
		}
	}
}