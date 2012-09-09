package com.refreshdigital.DataAdapter {
	
	import com.refreshdigital.Checklist;
	import com.refreshdigital.HttpServiceRefresh;
	import com.refreshdigital.Profile;
	import com.refreshdigital.Project;
	import com.refreshdigital.Remote;
	import com.refreshdigital.Task;
	
	import flash.events.EventDispatcher;
	
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	
	public interface IDataAdapter {

		function getHttpService(successCallback:Function = null, failureCallback:Function = null):HttpServiceRefresh;
		function getProjects(successCallback:Function = null, failureCallback:Function = null):void;
		function getTasksForProject(project:Project, successCallback:Function = null, failureCallback:Function = null):void;
		function getSubTasksForTask(task:Task, successCallback:Function = null, failureCallback:Function = null):void;
		function getTasksForChecklist(checklist:Checklist, successCallback:Function = null, failureCallback:Function = null):void;
		function getChecklistsForProject(project:Project, successCallback:Function = null, failureCallback:Function = null):void;
		function setProfile(profile:Profile):void;
		function getTimeForProject(project:Project, callback:Function):void;
		function postTimeForRemoteObject(project:Remote, time:String, billable:Number, comments:String, successCallback:Function, errorCallback:Function):void;
		function markObjectCompleted(remObj:Remote, successCallBack:Function = null, failureCallback:Function = null):void;
		function markObjectOpen(remObj:Remote, successCallBack:Function = null, failureCallback:Function = null):void;
		function testConnection(successCallback:Function = null, failureCallback:Function = null):void;
		function getHasChecklists():Boolean;
		function getTaskDepth():Number;
		function getTaskName():String;
		function getSubTaskName():String;
		function getName():String;
		function getMaxSimultaneousHttpRequests():Number;
		function getDelayBetweenHttpRequests():Number;
		function getProfile():Profile;
		function getHasTimecardTypes():Boolean;
	}
}