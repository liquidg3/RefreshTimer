package com.refreshdigital.DataAdapter
{
	import com.refreshdigital.Checklist;
	import com.refreshdigital.ChecklistTask;
	import com.refreshdigital.DataAdapter.DataAdapterAbstract;
	import com.refreshdigital.HttpServiceRefresh;
	import com.refreshdigital.Profile;
	import com.refreshdigital.Project;
	import com.refreshdigital.Remote;
	import com.refreshdigital.SubTask;
	import com.refreshdigital.Task;
	import com.refreshdigital.Timecard;
	import com.refreshdigital.Util;
	
	import flash.net.*;
	
	import mx.collections.ArrayCollection;
	import mx.events.Request;
	import mx.rpc.events.*;
	import mx.rpc.http.HTTPService;
	
	
	public class DataAdapterActiveCollab extends DataAdapterAbstract implements IDataAdapter
	{		
		/**
		 * Unique key that can be used to identify this datasource
		 */
		public static const NAME:String 		= "activecollab";
		
		public function DataAdapterActiveCollab(profile:Profile = null)
		{
			super();
			
			if(profile != null) {
				this.setProfile(profile);
			}
			
			this._taskName			= "Tickets";
			this._taskDepth			= 2;	
			this._hasChecklists 	= true;
			
			this._maxSimultaneousHttpRequests 	= 5;
			this._delayBetweenHttpRequests		= 0;
			this._hasTimecardTypes				= true;
		}
		
		override public function getName():String {
			return 'ActiveCollab';
		}
		
		override public function setProfile(profile:Profile):void {
			
			//we'll have to parse this text to figure out if they entered http:// etc.
			this._endPoint				= profile.acUrl + "?path_info={{path_info}}&token={{token}}";
			
			this._serviceParams.token 	= profile.acApiKey;
			this._serviceParams.user_id	= profile.acApiKey.slice(0,profile.acApiKey.search("-"));
			
			super.setProfile(profile);
		}
		
		public function getProjects(successCallback:Function = null, failureCallback:Function = null):void
		{
			
			var me:DataAdapterActiveCollab	= this;
			this._serviceParams.path_info	= "/projects";
			
			var service:HttpServiceRefresh			= this.getHttpService(function(event:DataAdapterEvent):void{
				
				var results:XML 			= event.results;
				var projects:Array 			= [];
				
			
				for each (var item:XML in results.children())
				{
					
					if(item.status == 'active') {
						var params:Object		= new Object;
						params.id				= item.id;
						params.name				= item.name;
						params.description		= item.overview;
						params.permaLink		= item.permalink;
						params.dataAdapter		= new DataAdapterActiveCollab(me._profile);
						params.completed		= (item.completed_on != null);
						
						projects.push(new Project(params));
					}
				}
			
				
				if(successCallback != null) {
					successCallback(projects);
				}
				
			},failureCallback);			
			
			
			service.send();
		}
		
		public function getTasksForProject(project:Project, successCallback:Function = null, failureCallback:Function = null):void 
		{
			this._serviceParams.path_info	= "/projects/{{project_id}}/tickets";
			this._serviceParams.project_id	= project.id;
			var me:DataAdapterActiveCollab	= this;
			var tasks:Array					= [];
			
			var service:HttpServiceRefresh	= this.getHttpService(function(event:DataAdapterEvent):void {
				
				var results:XML = event.results;
				
				
				for each (var item:XML in results.children())
				{

					var params:Object	= new Object;
					params.id			= item.ticket_id;
					params.idActiveCollab = item.id;
					params.name			= item.name;
					params.description	= item.body;
					params.permaLink	= item.permalink;
					params.project		= project;
					params.dataAdapter  = new DataAdapterActiveCollab(me._profile);
					params.completed	= (item.completed_on.text().length() > 0);
					
					if(item.due_on.text().length()) {
						params.dueDate	= item.due_on;
					}
		
					tasks.push(new Task(params));
				}
			
				
				if(successCallback != null) {
					successCallback(tasks);
				}
				
			},failureCallback);
			
			
			
			service.send();
		}
		
		public function getTasksForChecklist(checklist:Checklist, successCallback:Function = null, failureCallback:Function = null):void 
		{
			this._serviceParams.path_info	= "/projects/{{project_id}}/checklists/{{checklist_id}}";
			this._serviceParams.checklist_id = checklist.id;
			this._serviceParams.project_id	= checklist.getProject().id;
			
			var me:DataAdapterActiveCollab	= this;
			var tasks:Array					= [];
			
			var service:HttpServiceRefresh	= this.getHttpService(function(event:DataAdapterEvent):void {
				
				var results:XML = event.results;
				
				for each (var item:Object in results.tasks.children()) {
			
					var params:Object	= new Object;
					
					params.id			= item.id;
					params.idActiveCollab = item.id;
					params.name			= item.name;
					params.description	= item.body;
					params.permaLink	= item.permalink;
					params.checklist	= checklist;
					params.completed	= (item.completed_on.text().length() > 0);
					params.project		= checklist.getProject();
					params.dataAdapter  = new DataAdapterActiveCollab(me._profile);
					
					if(item.due_on.text().length()) {
						params.dueDate	= item.due_on;
					}
					
					tasks.push(new ChecklistTask(params));
				}
			
				
				if(successCallback != null) {
					successCallback(tasks);
				}
				
			},failureCallback);
			
			
			
			service.send();
		}
		
		public function getChecklistsForProject(project:Project, successCallback:Function = null, failureCallback:Function = null):void 
		{
			this._serviceParams.path_info	= "/projects/{{project_id}}/checklists";
			this._serviceParams.project_id	= project.id;
			
			var me:DataAdapterActiveCollab	= this;
			
			var service:HttpServiceRefresh	= this.getHttpService(function(event:DataAdapterEvent):void {
				
				var results:XML 		= event.results;
				var checklists:Array 	= [];

				for each (var item:XML in results.children())
				{
					
					var params:Object		= new Object;
					params.id				= item.id;
					params.name				= item.name;
					params.description		= item.body;
					params.project			= project;
					params.completed		= (item.completed_on.text().length() > 0);
					params.mine				= true;
					params.permaLink		= item.permalink;
					params.dataAdapter		= new DataAdapterActiveCollab(me._profile);
					
					if(item.due_on.text().length()) {
						params.dueDate		= item.due_on;
					}
					
					checklists.push(new Checklist(params));
				}
			
				if(successCallback != null) {
					successCallback(checklists);
				}
				
			},failureCallback);
			
			
			service.send();
		}
		
		public function getSubTasksForTask(task:Task, successCallback:Function = null, failureCallback:Function = null):void {
			
			this._serviceParams.path_info	= "/projects/{{project_id}}/tickets/{{ticket_id}}";
			this._serviceParams.project_id	= task.getProject().id;
			this._serviceParams.ticket_id	= task.id;
			var me:DataAdapterActiveCollab	= this;
			
			var service:HttpServiceRefresh	= this.getHttpService(function(event:DataAdapterEvent):void {
				
				var results:XML = event.results;
				
				
				for each (var item:XML in results.tasks.children()) {
					
					//see if we are one of the people assigned to this subtask
					var mine:Boolean				= false;
					
					//assignees is null if no one is assigned at all
					if(item.assignees.assignee.length()) {
						for each(var assignee:XML in item.assignees.children()) {
							if(assignee.user_id == me._serviceParams.user_id) {
								mine = true;
							}
						}
						
					}
					
					var params:Object	= new Object;
					params.id			= item.id;
					params.idActiveCollab = item.id;
					params.name			= item.name;
					params.description	= item.body;
					params.permaLink	= item.permalink;
					params.project		= task.getProject();
					params.parentTask	= task;
					params.isMine		= mine;
					params.dataAdapter  = new DataAdapterActiveCollab(me._profile); 
					params.completed	= (item.completed_on.text().length() > 0);
					
					if(item.due_on.text().length()) {
						params.dueDate		= item.due_on;
					}
					
					subtasks.push(new SubTask(params));
				}
			
				
				if(successCallback != null) {
					successCallback(subtasks);
				}
				
			},failureCallback);
			
			var subtasks:Array					= [];
			
			service.send();
			
		}

		public function getTimeForProject(project:Project, callback:Function):void {
			
			this._serviceParams.path_info	= "/projects/{{project_id}}/time";
			this._serviceParams.project_id	= project.id;
			
			var service:HttpServiceRefresh	= this.getHttpService(callback);
			var time:Array					= [];
			
			service.addEventListener("result", function(event:ResultEvent):void {
				var results:Object			= event.result;
				var totTime:Number				= 0;
				
				if (results.time_records == null) {
					time[0] = ["none"];
				}
				else {
					
					if (!(results.time_records.time_record is ArrayCollection)) {
						results.time_records.time_record = [results.time_records.time_record];
					}
					
					for each (var item:Object in results.time_records.time_record)
					{
						totTime = totTime + Number(item.value.valueOf());
					}
					var params:Object		= new Object;
					params.time				= String(totTime);
					params.project			= project;
					params.parent			= project;
					params.type				= null;
					params.comment			= null;
					time.push(new Timecard(params));
				}
				
				callback(time);
			});
			
			service.send();
		}
		
		public function postTimeForRemoteObject(remObj:Remote, time:String, billable:Number, comments:String, successCallback:Function, errorCallback:Function):void {
			this._serviceParams.path_info 	= "projects/{{project_id}}/time/add";
			this._serviceParams.project_id	= remObj.getProject().id;
			
			
			var now:Date					= new Date;
			var dateStr:String				= String(now.fullYear)+"-"+String(now.month+1)+"-"+String(now.date);

			var postData:Object = {
				'submitted':			'submitted',
				'time[user_id]':		this._serviceParams.user_id,
				'time[value]': 			time,
				'time[body]':			comments,
				'time[record_date]': 	dateStr,
				'time[parent_id]':		remObj.idActiveCollab, 
				'time[billable_status]': String(billable)
					
			};
			
			//time[parent_id] must be TASK id, not project id
			
			var service:HttpServiceRefresh		= this.getHttpService(null);
			service.addEventListener("result", function(event:DataAdapterEvent):void {
				var results:Object			= event.results;
				var totTime:Number			= 0;
				
				successCallback();
			
				
			});
			
			service.addEventListener('fault',function(event:DataAdapterEvent):void {
				errorCallback(event.errorMessage, "Cannot Submit Time!");
			});
			
			service.send(postData);
			
		}
		
		public function markObjectOpen(remObj:Remote, successCallBack:Function = null, failureCallback:Function = null):void {
			this._serviceParams.path_info	= "projects/{{project_id}}/objects/{{obj_id}}/open";
			this._serviceParams.project_id	= remObj.getProject().id;
			this._serviceParams.obj_id		= remObj.idActiveCollab;
			
			var postData:Object = {
				'submitted':			'submitted'				
			};
			
			var service:HttpServiceRefresh	= this.getHttpService(null);
			
			if(successCallBack != null) {
				service.addEventListener("result", successCallBack);
			}
			if(failureCallback != null) {
				service.addEventListener("fault", failureCallback);
			}
			
			service.send(postData);
		}
		
		public function markObjectCompleted(remObj:Remote, successCallBack:Function = null, failureCallback:Function = null):void {
			this._serviceParams.path_info	= "projects/{{project_id}}/objects/{{obj_id}}/complete";
			this._serviceParams.project_id	= remObj.getProject().id;
			this._serviceParams.obj_id		= remObj.idActiveCollab;
			
			var postData:Object = {
				'submitted':			'submitted'				
			};
			
			var service:HttpServiceRefresh	= this.getHttpService(null);
			
			if(successCallBack != null) {
				service.addEventListener("result", successCallBack);
			}
			if(failureCallback != null) {
				service.addEventListener("fault", failureCallback);
			}
			
			service.send(postData);
		}
		
		
		public function testConnection(successCallback:Function = null, failureCallback:Function = null):void {
			
			this._serviceParams.path_info 	= '/info';
			var service:HttpServiceRefresh	= this.getHttpService(successCallback, failureCallback);
			
			service.send();
		}
	
		
		/**
		 * Returns an httpServices object that will allow connection
		 * to the datasource
		 */
		override public function getHttpService(successCallback:Function = null, failureCallback:Function = null):HttpServiceRefresh {
						
			var service:HttpServiceRefresh  = super.getHttpService(successCallback, failureCallback);			
			service.method 					= "POST";
			
			
			return service;
		}
		
		

		
	}
}