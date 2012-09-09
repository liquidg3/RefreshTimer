package com.refreshdigital
{
	import com.refreshdigital.DataAdapter.*;
	import com.refreshdigital.Drawer.DrawerListItem;
	import com.refreshdigital.Drawer.DrawerListItemObject;
	
	import flash.events.Event;
	
	import mx.messaging.Producer;
	import mx.rpc.Fault;
	import mx.rpc.events.FaultEvent;
	
	public class Project extends Remote
	{

		protected var _tasks:Array 								= null;
		protected var _checklists:Array							= null;
		
		
		public static var profile:Profile						= profile;
		
		/**
		 * Event Types
		 */
		public static var EVENT_PROJECS_LOADED:String			= 'projectsloaded';
		public static var EVENT_PROJECTS_LOAD_FAILED:String		= 'projectsloadfailed';
		public static var EVENT_TASKS_LOADED:String				= 'tasksloaded';
		public static var EVENT_TASKS_LOAD_FAILED:String		= 'tasksloadfailed';
		public static var EVENT_CHECKLISTS_LOADED:String		= 'checklistsloaded';
		public static var EVENT_CHECKLISTS_LOAD_FAILED:String	= 'checklistsloadfailed';
		
		public function Project(params:Object)
		{

			super(params);
			
			this.idActiveCollab = params.id;			
			this.type			= Remote.TYPE_PROJECT;
			
			if(params.loadTasks) {
				
				var me:Project = this;
				
				//load tasks
				var onFailure:Function = function(event:FaultEvent):void {
					me.dispatchEvent(new Event(Project.EVENT_TASKS_LOAD_FAILED));
				}
				
				this.getTasks(null, onFailure);
				
				//load checklists if necessary
				if(this._dataAdapter.getHasChecklists()) {
					var onChecklistFailure:Function = function(event:FaultEvent):void {
						me.dispatchEvent(new Event(Project.EVENT_CHECKLISTS_LOAD_FAILED));
					}
						
					this.getChecklists(null, onChecklistFailure);
				}
			}
			
			
		}
		
		public static function getProjects(successCallback:Function = null, failureCallback:Function = null):void {
			
			//try {
				Project.profile.getDataAdapter().getProjects(successCallback, failureCallback);
			//} catch(error:*) {
			//	failureCallback(error);
			//}
		}
		
		public function resetTasks():void {
			this._tasks = null;
		}
		
		public function resetChecklists():void {
			this._checklists = null;
		}
		
		
		public function getTasks(successCallback:Function = null, failureCallback:Function = null):void 
		{
			if(this._tasks == null) {
				
				this.setListItemText();
				
				var me:Project = this;
				
				this._dataAdapter.getTasksForProject(this, function(tasks:Array):void {
					
					me._tasks = tasks;
					me.setListItemText();
					
					if(successCallback != null) {
						successCallback(tasks);
					}
					
				}, failureCallback);
				
			} else {
				if (successCallback != null) {
					successCallback(this._tasks);
				}
			}
		}
		
		public function getChecklists(successCallback:Function = null, failureCallback:Function = null):void 
		{
			
			//if checklists don't exist for this management system we skip all this logic
			if(this._dataAdapter.getProfile().getHasChecklists()) {
				
				if(this._checklists == null) {
					
					this.setListItemText();
					
					var me:Project = this;
					
					this._dataAdapter.getChecklistsForProject(this, function(checklists:Array):void {
						
						me._checklists = checklists;
						me.setListItemText();
						
						if(successCallback != null) {
							successCallback(checklists);
						}
						
					}, failureCallback);
					
				} else {
					if (successCallback != null) {
						successCallback(this._checklists);
					}
				}
			
			
			} else {
				if (successCallback != null) {
					successCallback([]);
				}
			}
		}
		
		public function getTime(callback:Function):void
		{
			this._dataAdapter.getTimeForProject(this, callback);
		}
		
		public function areTasksLoaded():Boolean {
			return (this._tasks != null);
		}
		
		
		public function areChecklistsLoaded():Boolean {
			//if this project management suite does not have checklists, tell the system they are loaded
			//so the app continues to run, but calling getChecklists will simply return []
			return (!this._dataAdapter.getProfile().getHasChecklists() || this._checklists != null);
		}
		

		public function hasTasks():Boolean {
			
			//if no tasks were attempted to be loaded yet, then lets assume there
			//could be and show the tasks drawer
			if(!this.areTasksLoaded()) {
				return true;
			}
			
			if(this.filterRemoteObjects(this._tasks).length > 0) {
				return true;
			}
			
			return false;
			
		}
		
		public function hasChecklists():Boolean {
			
			if(!this._dataAdapter.getProfile().getHasChecklists()) {
				return false;
			}
			
			if(!this.areChecklistsLoaded()) {
				return true;
			}
			
	
			if(this.filterRemoteObjects(this._checklists).length > 0) {
				return true;
			}
			
			return false;
		}

		static public function getDummy(message:String):Project 
		{
			return new Project({
				id: "-1"
			});
		}
		
		override public function setListItemText():void {
			
			if(this._listItem == null) {
				return;
			}
			
			//default values for list item
			this._listItem.heading				= this.name;
			var taskName:String					= this._dataAdapter.getTaskName();

			//drop in task name and due date
			if(this._tasks == null) {

				this._listItem.subHeading			= "Total " + taskName + ":  " + this.getDueDateRelative();
				this._listItem.isProgressVisible 	= true;
				this._listItem.progressLeft			= 50 + ( 5 * taskName.length);
				
			} else {
				
				var filteredTasks:Array = this.filterRemoteObjects(this._tasks);
				
				//set list item text if we have tasks or we are shoing empty projects
				if(Preferences.getInstance().getRecord('showEmptyProjects','0') == '1' ||
					filteredTasks.length > 0) {
					
					this._listItem.subHeading 			= "Total " + taskName + ": " + this.filterRemoteObjects(this._tasks).length + "  " + this.getDueDateRelative();
					this._listItem.isProgressVisible 	= false;
					
				} else {
					
					//refreshes the drawer list to remove this istem
					this.getListItem().refresh();
					
				}
				
			}
			
			//drop in checklists
			if(this._dataAdapter.getHasChecklists() && this._checklists == null) {
			} else if(this._dataAdapter.getHasChecklists() && this._checklists.length > 0) {
				this._listItem.subHeading			+= " Checklists: " + this.filterRemoteObjects(this._checklists).length;
			}
			
			
		}
		
		override public function filter(searchString:String = ''):Boolean {
			
			
			if(super.filter(searchString) &&
				//if we are showing empty projects or this project has tasks
				(Preferences.getInstance().getRecord('showEmptyProjects','0') == '1' ||
				this._tasks == null ||
				this.filterRemoteObjects(this._tasks).length > 0)) {
				return true;
			}
			
			return false;
		}
		
		override public function getProject():Project {
			return this;
		}
		
		public static function getFromId(id:String, successCallback:Function, failureCallback:Function = null):void {
			
			Project.getProjects(function(projects:Array):void {
				
				for(var c:Number=0; c<projects.length; c++) {
					if(projects[c].id == id) {
						successCallback(projects[c]);
						return;
					}
				}
				
				successCallback(null);
				
			},failureCallback);
		}
		
		public static function setProfile(profile:Profile):void {
			Project.profile = profile;
		}
		
		override public function getType():String {
			return this.type;
		}

	}
}