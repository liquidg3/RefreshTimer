package com.refreshdigital
{
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;

	public class ChecklistTask extends Task
	{
		
		protected var _checklist:Checklist				= null;
		
		public function ChecklistTask(params:Object)
		{
			super(params);
			
			this._checklist = params.checklist;
			this.type	= Remote.TYPE_CHECKLIST_TASK;
		}
		
		
		override public function setListItemText():void {
			super.setListItemText();
			this._listItem.isProgressVisible = false;
		}
		
		override public function filter(searchString:String=''):Boolean {
			
			var showCompleted:Boolean = (Preferences.getInstance().getRecord('showCompletedChecklistTasks', '0') == '1');
			
			
			//check if the name matches
			if(searchString.length > 0) {
				var nameMatch:Boolean = (this.name.toLowerCase().indexOf(searchString) > -1);
				if(!nameMatch) {
					return false;
				}
			}
			
			var pass:Boolean = ((showCompleted || !this.completed));
			
			return pass;
		}
		
		
	
		
	}
}