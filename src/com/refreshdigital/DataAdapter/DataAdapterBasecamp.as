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
	
	import flash.net.URLRequestHeader;
	
	import mx.collections.ArrayCollection;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.utils.Base64Encoder;


	public class DataAdapterBasecamp extends DataAdapterAbstract implements IDataAdapter
	{
		
		public static const NAME:String				= "basecamp";
		
		public function DataAdapterBasecamp(profile:Profile = null) {
			
			super();
			
		
			if(profile) {
				this.setProfile(profile);
			}
			
			this._taskName			= "Todo Lists";
			this._subTaskName		= "Toto Items";
			this._taskDepth			= 2;	
			this._hasChecklists 	= false;

			this._maxSimultaneousHttpRequests 	= 1;
			this._delayBetweenHttpRequests		= 250;
			this._hasTimecardTypes				= false;
		}
		
		override public function getName():String {
			return "Basecamp";
		}
		
		override public function setProfile(profile:Profile):void {
			
			this._endPoint		= profile.basecampUrl + "{{path_info}}";
			super.setProfile(profile);
		}
		
		override public function getHttpService(successCallback:Function = null, failureCallback:Function = null):HttpServiceRefresh {
			
			var service:HttpServiceRefresh 	= super.getHttpService(successCallback, failureCallback);
	
			//setup authentication and accept headers
			var encoder:Base64Encoder = new Base64Encoder();
			encoder.encode(this._profile.basecampUsername + ":" + this._profile.basecampPassword);
			
			service.getRequest().requestHeaders.push(new URLRequestHeader("Authorization", "Basic " + encoder.toString()));
			service.getRequest().requestHeaders.push(new URLRequestHeader("Accept", "application/xml"));
			service.getRequest().contentType = "application/xml";
						
			service.method 	= "GET";
			
			this._service = service;
			
			return service;
		}
		
		
		
		public function testConnection(successCallback:Function=null, failureCallback:Function=null):void {
			this._serviceParams.path_info = "/me.xml";
			var service:HttpServiceRefresh = this.getHttpService(successCallback, failureCallback);
			service.send();
		}
		
		public function getProjects(successCallback:Function=null, failureCallback:Function=null):void {
			
			this._serviceParams.path_info = "/projects.xml";
			var me:DataAdapterBasecamp = this;
				
			var service:HttpServiceRefresh = this.getHttpService(function(event:DataAdapterEvent):void {
			
				var results:XML 	= event.results;
				var projects:Array 	= [];
				
			
				for each (var item:XML in results.children()) {
					
					if(item.status == 'active') {
						var params:Object		= new Object;
						params.id				= item.id.valueOf();
						params.name				= item.name.valueOf();
						params.permaLink		= me._profile.basecampUrl + "/projects/" + params.id;
						params.dataAdapter		= new DataAdapterBasecamp(me._profile);
						params.completed		= false;
						
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
			this._serviceParams.path_info	= "/projects/{{project_id}}/todo_lists.xml";
			this._serviceParams.project_id	= project.id;
			
			var me:DataAdapterBasecamp		= this;
			var tasks:Array					= [];
			
			var service:HttpServiceRefresh	= this.getHttpService(function(event:DataAdapterEvent):void {
				
				var results:XML = event.results;
				
				for each (var item:XML in results.children()) {
					
					var params:Object	= new Object;
					params.id			= item.id.valueOf();
					params.name			= item.name;
					params.description	= item.description;
					params.permaLink	= me._profile.basecampUrl + "/projects/" + project.id + "/todo_lists/" + params.id;
					params.project		= project;
					params.dataAdapter	= new DataAdapterBasecamp(me._profile);
					params.completed	= (item.complete == 'true');
					
					
					tasks.push(new Task(params));
				}
				
				
				if(successCallback != null) {
					successCallback(tasks);
				}
				
			},failureCallback);
			
			
			
			service.send();
		}
		
		public function getSubTasksForTask(task:Task, successCallback:Function = null, failureCallback:Function = null):void {
			
			this._serviceParams.path_info	= "/todo_lists/{{task_id}}/todo_items.xml";
			this._serviceParams.task_id		= task.id;
			
			var me:DataAdapterBasecamp		= this;
			
			var service:HttpServiceRefresh	= this.getHttpService(function(event:DataAdapterEvent):void {
				
				var results:XML = event.results;

				for each (var item:XML in results.children()) {
					
					var params:Object	= new Object;
					params.id			= item.id.valueOf();
					params.name			= item.content;
					params.permaLink	= me._profile.basecampUrl + "/projects/" + task.getProject().id + "/todo_lists/" + task.id;
					params.project		= task.getProject();
					params.parentTask	= task;
					params.isMine		= true;
					params.dataAdapter  = new DataAdapterBasecamp(me._profile); 
					params.completed	= (item.completed.valueOf() == "true");
					
					if(item['due-at'].attribute("nil") != "true") {
						params.dueDate = Util.utcDateTimeToDate(item['due-at']);
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
		
		public function getTasksForChecklist(checklist:Checklist, successCallback:Function = null, failureCallback:Function = null):void {}
		public function getChecklistsForProject(project:Project, successCallback:Function = null, failureCallback:Function = null):void {}
		
		public function getTimeForProject(project:Project, callback:Function):void  {}
		public function postTimeForRemoteObject(remote:Remote, hours:String, billable:Number, comments:String, successCallback:Function, failureCallback:Function):void  {
			
			var now:Date 		= new Date();
			var date:String		= String(now.fullYear)+"-"+String(now.month+1)+"-"+String(now.date);
			
			
			//you can only post to a project or a subtask (todo-item)
			var xml:String 		= "<time-entry><person-id>" + this._profile.basecampUserId + "</person-id><date>" + date + "</date><hours>" + hours + "</hours><description>" + comments + "</description></time-entry>";
			var endPoint:String = "";
			
			switch(remote.type) {
				case "subtask":
					endPoint = "/todo_items/" + remote.id + "/time_entries.xml";
					break;
				default:
					endPoint = "/projects/" + remote.getProject().id + "/time_entries.xml";
				
			}
			
			this._serviceParams.path_info = endPoint;
			var service:HttpServiceRefresh = this.getHttpService(successCallback, failureCallback);
			service.method = "POST";
			service.getRequest().data = xml;
			service.send();
				
		
			
		}
		
		public function markObjectCompleted(remote:Remote, successCallBack:Function = null, failureCallback:Function = null):void {
			if(remote.type == 'subtask') {
				this._serviceParams.path_info	= "/todo_items/{{subtask_id}}/complete.xml";
				this._serviceParams.subtask_id	= remote.id;
				var service:HttpServiceRefresh	= this.getHttpService(successCallBack, failureCallback);
				service.method = "PUT";
				service.send();
			}
		}
		
		public function markObjectOpen(remote:Remote, successCallBack:Function = null, failureCallback:Function = null):void {
			if(remote.type == 'subtask') {
				this._serviceParams.path_info	= "/todo_items/{{subtask_id}}/uncomplete.xml";
				this._serviceParams.subtask_id	= remote.id;
				var service:HttpServiceRefresh	= this.getHttpService(successCallBack, failureCallback);
				service.method = "PUT";
				service.send();
			}
		}
	
	}
}