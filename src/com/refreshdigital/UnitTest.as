package com.refreshdigital
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Timer;
	
	import mx.charts.AreaChart;

	public class UnitTest extends EventDispatcher
	{
		
		private var _profile:Profile;
		private var _sequence:Array;
		private var _frame:Number;
		private var _cancel:Boolean = false;
		
		//fired each step in the sequence
		public static var EVENT_STEP:String		= 'step';
		
		public function UnitTest() {}
		
		public function setProfile(type:String):void {
			
			var profile:Profile = null;
			
			switch(type) {
				case Profile.TYPE_ACTIVECOLLAB:
					
					profile 			= new Profile();
					profile.type 		= Profile.TYPE_ACTIVECOLLAB;
					profile.acUrl		= 'http://projects.liquidfire.com/public/api.php';
					profile.acApiKey	= '25-a3eJTae2TWikOVrGuYrQbEmUJFW70R1I5Ir5NiNy';
					
					break;
			}
			
			
			if(profile == null) {
				throw new Error('profile by type ' + type + ' not found');
			}
			
			this._profile = profile;
		}
		
		
		public function setSequence(sequence:Array):void {
			this._sequence 	= sequence;
			
		}
		
		public function start():void {
			this._frame		= 1;
			this._cancel	= false;
			this.step();
		}
		
		public function step(results:* = null):void {
			
			//if we are done
			if(this._cancel || this._frame > this._sequence.length) {
				this.stop('action stopped');
				return;
			}
			
			var action:String = this._sequence[this._frame - 1];
			
			//remove () and get references for the agruments
			var arguments:Array = this._getActionAgruments(results, action);
			
			
			//i expect each sequence to be in the form of 'Profile.getProfiles'
			var sequenceParts:Array = action.split('.');
			
			//get the function/method we are calling
			var classRef:* 				= this.getClassReferenceFromName(sequenceParts[0]); 
			var functionName:String		= sequenceParts[1];
			
			//dispatch event describing command being run
			this.dispatchTestEvent(UnitTestEvent.TYPE_STEP,'Frame ' + this._frame + ' Action: ' + this._sequence[this._frame - 1]);
				
			/**
			 * If results are null, then we are running the first frame or
			 * we are running a static function
			 */
			if(results == null) {
				var nextResults:* = classRef[functionName](next,failure);
				
				//if this call resulted in any return value,
				if(nextResults != null) {
					this.next(nextResults);
					return;
				}
				
				return;
			} 
			//if we are receiving an array
			else if(results is Array) {
				
				if(results.length == 0) {
					this.stop('results came back with emty array');
				}
				
				var resultObject:* = results[0];
				resultObject[functionName]();
				
				return this.next();
			}
			
			throw new Error('test could not translate: ' + this._sequence[this._frame]);
		}
		
		public function next(results:* = null):void {
			
			this.dispatchTestEvent(UnitTestEvent.TYPE_STEP,'Frame ' + this._frame + ' completed');
			
			//increment to next frame
			this._frame ++;
			this.step(results);
			
		}
		
		public function stop(message:String = ''):void {
			
			
			if(message.length > 0) {
				message = ': ' + message;
			}
			
			this.dispatchTestEvent(UnitTestEvent.TYPE_STOP,'stopping test' + message);
			this._cancel = true;
			
		}
		
		public function failure():void {
			trace('failure');
		}
		
		public function dispatchTestEvent(type:String, message:String):void {
			var event:UnitTestEvent = new UnitTestEvent(type);
			event.message	= message;
			
			this.dispatchEvent(event);
		}
		
		public function getClassReferenceFromName(name:String):* {
			switch(name) {
				case 'Profile':
					return Profile;
				case 'Project':
					return Project;
			}
			
			return null;
		}
		
		/**
		 * takes a string that represents a method call and return relavent references
		 * for the agruments.
		 * 
		 * Passing null, "Project.getProjects(this.next, this.failure)" will return 
		 * an array like [this.next:Function, this.failure:Function]
		 * 
		 */
		private function _getActionAgruments(results:*, action:String):Array {
			
			var references:Array 	= [];
			var arguments:Array		= [];
			
			//split out actions
			var reg:RegExp = /.*\((.*?)\)/ig;
			var matches:Array = reg.exec(action);
			
			if(matches.length == 2) {
				
				arguments = matches[1].split(',');
				
				//loop through argument as string and create references	
				for(var index:Number = 0; index<arguments.length; index++) {
					//if this argument references self - Project.getProjects(**this.next**, this.failure)
					if(arguments[index].search('this.') > -1) {
						
					} 
					//if the argument references a result
					else {
						
					}
				}
			} 
			//if our regex matched more than one set of arguments it would mean 
			//the action came like this: Project.getProjects()() 
			//with two set of parens
			else if(matches.length > 2) {
				throw new Error('Could not find arguments for: ' + action);
			}
			
			return references;
		}
	}
}