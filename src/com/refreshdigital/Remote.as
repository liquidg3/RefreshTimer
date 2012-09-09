package com.refreshdigital
{
	import com.refreshdigital.DataAdapter.*;
	import com.refreshdigital.Drawer.DrawerListItem;
	import com.refreshdigital.Drawer.DrawerListItemObject;
	
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import mx.rpc.events.ResultEvent;

	public class Remote extends EventDispatcher implements DrawerListItemObject
	{
		
		protected var _listItem:DrawerListItem			= null;
	
		public var type:String							= "remote";
		
		public static var TYPE_REMOTE:String			= 'remote';
		public static var TYPE_PROJECT:String			= 'project';
		public static var TYPE_TASK:String				= 'task';
		public static var TYPE_SUBTASK:String			= 'subtask';
		public static var TYPE_CHECKLIST:String			= 'checklist';
		public static var TYPE_CHECKLIST_TASK:String	= 'checklisttask';
		
		/**
		 * Data pulled from project management system
		 */
		public var id:String;
		public var idActiveCollab:String;
		public var name:String;
		public var permaLink:String;
		public var completed:Boolean					= false;
		public var isMine:Boolean						= true;

		
		[Bindable]
		public var description:String;
		
		protected var _dataAdapter:IDataAdapter 	= null;
		protected var _dueDate:Date						= null;
		
		public function Remote(params:Object) {
			this.id 			= params.id;
			this.idActiveCollab	= params.idActiveCollab;
			this.name 			= params.name;
			this.description 	= params.description;
			this._dataAdapter	= params.dataAdapter;
			this.permaLink		= params.permaLink;
			this.isMine			= params.mine;
			this.completed		= params.completed;
			
			if(this.description != null && this.description.length > 0) {
				this.description = this.description.replace(new RegExp("<[^<]+?>", "gi"),'');
			}
			
			if(!(params.dueDate is Date)) {
				this._setDueDateFromString(params.dueDate);
			} else {
				this._dueDate = params.dueDate;
			}
		}
		
		public function setListItem(listItem:DrawerListItem):void {
			this._listItem 			= listItem;
			
			//populate default values for list item
			this.setListItemText();
			
		}
		
		public function getListItem():DrawerListItem {
			return this._listItem;
		}
		
		protected function _setDueDateFromString(dueDate:String):void {
			if(dueDate != null) {
				var dateParts:Array = dueDate.split("-");
				this._dueDate = new Date(dateParts[0],dateParts[1] - 1,dateParts[2]);
			}
		}
		
		/**
		 * Returns the due date in as a relative string, eg 2 days or 3 days late
		 */
		public function getDueDateRelative():String {
			
			var dateString:String = '';
			
			if(this._dueDate) {
				
				var now:Date			= new Date();
				var timeElapsed:Number 	= this._dueDate.valueOf() - now.valueOf();

				if(this._dueDate.dateUTC == now.dateUTC && this._dueDate.monthUTC == now.monthUTC && this._dueDate.fullYearUTC == now.fullYearUTC) {
					return "Due Today";
				//if it's late
				}else if(timeElapsed < 0) {
					dateString = "Late: ";
					timeElapsed *= -1;
				} 
				//if it's on time
				else {
					dateString = "Due: ";
				}
				
				//convert time to days
				var seconds:Number	= timeElapsed/1000;
				var hours:Number 	= seconds/60/60;
				var days:Number		= hours/24;
				
				dateString += Math.floor(days) + " Days";
				
			}
			
			return dateString;
		}
		
		public function setListItemText():void {
			if(this._listItem) {
				this._listItem.heading = this.name;
				this._listItem.subHeading = this.name;
				this._listItem.isMine = this.isMine;
			}
		}
		
		public function getProject():Project {
			return null;
		}
		
		public function markAsCompleted(successCallback:Function = null, failureCallback:Function = null):void {
			var me:Remote = this;
			this._dataAdapter.markObjectCompleted(this,function(event:DataAdapterEvent):void {
				me.completed = true;
				if(successCallback != null) {
					successCallback(event);
				}
			}, failureCallback);
		}
		
		public function markAsOpen(successCallback:Function = null, failureCallback:Function = null):void {
			var me:Remote = this;
			this._dataAdapter.markObjectOpen(this,function(event:DataAdapterEvent):void {
				me.completed = true;
				if(successCallback != null) {
					successCallback(event);
				}
			}, failureCallback);
		}
		
		/**
		 * Takes an array of remote objects and runs the filter on each to return
		 * an array of remote objects who's filter() return true
		 */
		public function filterRemoteObjects(remoteObjects:Array):Array {
			var filteredObjects:Array = [];
			for(var index:Number = 0; index < remoteObjects.length; index++) {
				if(remoteObjects[index].filter()){ 
					filteredObjects.push(remoteObjects[index]);
				}
			}
			
			return filteredObjects;
		}
		
		
		public function filter(searchString:String = ''):Boolean {
			
			//check if the name matches
			if(searchString.length > 0) {
				var nameMatch:Boolean = (this.name.toLowerCase().indexOf(searchString) > -1);
				if(!nameMatch) {
					return false;
				}
			}
			
			return true;
		}
		
		public static function getFromId(id:String, successCallback:Function = null, failureCallback:Function = null):void {
			
		}
		
		public function getType():String {
			return this.type;
		}
		
		public function jumpTo():void {
			var urlReq:URLRequest 	= new URLRequest(this.permaLink);
			navigateToURL(urlReq, "_blank");
		}
	}
}