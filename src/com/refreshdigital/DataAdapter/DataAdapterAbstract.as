package com.refreshdigital.DataAdapter
{
	
	import com.refreshdigital.HttpServiceRefresh;
	import com.refreshdigital.Profile;
	import com.refreshdigital.Util;
	
	public class DataAdapterAbstract
	{
		
		protected var _taskDepth:Number					= 1;
		protected var _hasChecklists:Boolean			= false;
		protected var _profile:Profile					= null;
		protected var _taskName:String					= "Tasks";
		protected var _subTaskName:String				= "Subtasks";
		protected var _endPoint:String;
		
		protected var _serviceParams:Object 			= {};
		protected var _service:HttpServiceRefresh		= null;
		
		protected var _hasTimecardTypes:Boolean			= false;
		
		protected var _maxSimultaneousHttpRequests:Number 	= 5;
		protected var _delayBetweenHttpRequests:Number		= 0;
		
		/**
		 * Anytime an error occures, only the last one
		 * is stored in this variable
		 */
		public static var _lastError:String			= '';
		
		public function DataAdapterAbstract() {}
		public function getName():String {
			return 'Abstract';
		}
		
		public function setProfile(profile:Profile):void {
			this._profile = profile;
		}
		
		public function getProfile():Profile {
			return this._profile;
		}
		
		public function getTaskDepth():Number {
			return this._taskDepth;
		}
		
		public function getHasChecklists():Boolean {
			return this._hasChecklists;
		}
		
		public function getTaskName():String {
			return this._taskName;
		}
		
		public function getSubTaskName():String {
			return this._subTaskName;
		}
		
		public function setEndPoint(endPoint:String):void{
			this._endPoint = endPoint;
		}
		
		public function getLastErrorMessage():String {
			return DataAdapterAbstract._lastError;
		}
		
		public function getHttpService(successCallback:Function = null, failureCallback:Function = null):HttpServiceRefresh {
			
			var service:HttpServiceRefresh 	= new HttpServiceRefresh();
			
			//set max and dleay
			HttpServiceRefresh.delayBetweenRequests 	= this._delayBetweenHttpRequests;
			HttpServiceRefresh.maxSimultaneousRequests	= this._maxSimultaneousHttpRequests;
			
			if(successCallback != null) {
				service.addEventListener('result', successCallback);
			}
			
			service.addEventListener('fault',function(event:DataAdapterEvent):void {
				DataAdapterAbstract._lastError = event.errorMessage;
				if(failureCallback != null) {
					failureCallback(event);
				} else {
					
				}
			});

			service.url 					= this.getEndPoint();
			
			this._service = service;
			
			return service;
		}
		
		/**
		 * Finds where to call adding every _serviceParam into the query string
		 */
		public function getEndPoint():String {
			
			var url:String =  Util.trim(this._endPoint);
			
			//run it twice so vars in vars will be populated
			for(var key:String in this._serviceParams){
				if(key != null) {
					var search:String 	= "{{" + Util.trim(key) + "}}";
					var replace:String 	= Util.trim(String(this._serviceParams[key]));
					url = url.replace(search,replace);
				}
			}
			
			for(var key2:String in this._serviceParams){
				if(key2 != null) {
					var search2:String 		= "{{" + key2 + "}}";
					var replace2:String 	= Util.trim(String(this._serviceParams[key2]));
					url = url.replace(search2,replace2);
				}
			}
			
			return url;	
		}
		
		public function getMaxSimultaneousHttpRequests():Number {
			return this._maxSimultaneousHttpRequests;
		}
		
		public function getDelayBetweenHttpRequests():Number {
			return this._delayBetweenHttpRequests;
		}
		
		public function getHasTimecardTypes():Boolean {
			return this._hasTimecardTypes;
		}
		
	}
}