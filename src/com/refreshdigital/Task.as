package com.refreshdigital
{
	import com.refreshdigital.DataAdapter.DataAdapterEvent;
	import com.refreshdigital.DataAdapter.IDataAdapter;
	import com.refreshdigital.Drawer.DrawerListItem;
	import com.refreshdigital.Drawer.DrawerListItemObject;

	public class Task extends Remote implements DrawerListItemObject
	{

		protected var _project:Project					= null;
		protected var _subTasks:Array					= null;
		
		public function Task(params:Object)
		{
			super(params);
			
			this._project 		= params.project;
			this.type			= Remote.TYPE_TASK;
		}
		
		override public function getProject():Project {
			return this._project;
		}
		 
		static public function getDummy(message:String):Task 
		{
			var params:Object = {
				id: 			"-1",
				name:			message,
				description: 	message,
				project: 		null
			};
			
			return new Task(params);

		}
		
		public function resetSubTasks():void {
			this._subTasks = null;
		}
		
		public function getSubTasks(successCallback:Function = null, failureCallback:Function = null):void 
		{
			
			if(this.id == "-1") {
				return;
			}
			
			if(this._subTasks == null) {
				
				this.setListItemText();
				var me:Task = this;
				
				this._dataAdapter.getSubTasksForTask(this, function(subTasks:Array):void {
					
					me._subTasks = subTasks;
					me.setListItemText();
					
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
		
		/**
		 * Checks if we have any subtasks. It returns true if subtasks haven't been loaded
		 * yet because we don't know if there are any
		 */
		public function hasSubTasks():Boolean {
			
			//if our data adapter only allows for 1 level of tasks there can be no sub tasks
			if(this._dataAdapter.getTaskDepth() == 1) {
				return false;
			}
			
			//we check if there are subtasks and assume they are loaded
			//if not loaded, we assume they exist so a the sub task drawer pops out
			if(!this.areSubTasksLoaded()) {
				return true;
			}
			
			//if they are loaded and num sub tasks is greater than 0
			if(this.filterRemoteObjects(this._subTasks).length > 0) {
				return true;
			}

			return false;
			
		}
		
		public function areSubTasksLoaded():Boolean {
			return (this._subTasks != null);
		}
		
		override public function setListItemText():void {
			
			this._listItem.heading 				= this.name;
			this._listItem.headingFontSize 		= 13;
			this._listItem.progressLeft			= 65;
			this._listItem.checked				= this.completed;
			this._listItem.isProgressVisible 	= false;
			this._listItem.subHeading 			= '';
			
			//if this is an invalid task return out
			if(this.id == "-1") {
				this._listItem.heading = this.name;
				return;
			}
			
			//if we are loading subtasks
			if(this._subTasks == null) {
				
				this._listItem.subHeading = "Subtasks:     " + this.getDueDateRelative();
				this._listItem.isProgressVisible = true;
				
			} 
			//if subtasks are loaded
			else if(this._subTasks != null) {
				
				
				//drop in sub tasks if there are some
				if(this._subTasks.length > 0) {
					this._listItem.subHeading = this._dataAdapter.getProfile().getSubTaskName() + ": " + this.filterRemoteObjects(this._subTasks).length;
				}
				
				//drop on due date if one is set
				if(this.getDueDateRelative().length > 0) {
					this._listItem.subHeading += (this._subTasks.length > 0) ? ", " + this.getDueDateRelative() : this.getDueDateRelative();	
				}
				
				this._listItem.isProgressVisible = false;
				
			}
			
			
			if(this._listItem.subHeading.length == 0) {
				this._listItem.subHeading = this.description;
			}
			
		}
		
		override public function filter(searchString:String=''):Boolean {
			//check if we are not showing completed and it's completed
			var showCompleted:Boolean = (Preferences.getInstance().getRecord('showCompletedTasks','0') == '1');
			
			return (this.id == '-1' ||
				(super.filter(searchString) && (showCompleted || !this.completed)));
			
		} 
		
		override public function markAsOpen(successCallback:Function = null, failureCallback:Function = null):void {
			
			if(this._listItem != null) {
				this._listItem.isProgressVisible = true;
				this._listItem.checked = false;
			}
			
			var me:Task = this;
			super.markAsOpen(function(event:DataAdapterEvent):void {
				if(me._listItem != null) {
					me.completed = false;
					me.setListItemText();
				}
				
				if(successCallback != null) {
					successCallback(event);
				}
			}, function(event:DataAdapterEvent):void {
				
				if(me._listItem != null) {
					me.setListItemText();
				}
				
				if(failureCallback != null) {
					failureCallback(event);
				}
				
			});
		}
		
		/**
		 * Overridden to show/hide progress
		 */
		override public function markAsCompleted(successCallback:Function = null, failureCallback:Function = null):void {
			
			if(this._listItem != null) {
				this._listItem.isProgressVisible = true;
			}
			
			//don't let it be checked until we're done with our call
			this._listItem.checked = false;
			
			var me:Task = this;
			super.markAsCompleted(function(event:DataAdapterEvent):void {
				if(me._listItem != null) {
					me.setListItemText();
				}
				
				if(successCallback != null) {
					successCallback(event);
				}
			}, function(event:DataAdapterEvent):void {
				
				if(me._listItem != null) {
					me.setListItemText();
				}
				
				if(failureCallback != null) {
					failureCallback(event);
				}
				
			});
		}
		

	}
}