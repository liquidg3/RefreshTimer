package com.refreshdigital
{
	
	import com.refreshdigital.DataAdapter.DataAdapterActiveCollab;
	import com.refreshdigital.DataAdapter.DataAdapterBasecamp;
	import com.refreshdigital.DataAdapter.DataAdapterSqlLite;
	import com.refreshdigital.DataAdapter.IDataAdapter;
	import com.refreshdigital.Project;
	
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	import flash.events.*;
	
	[Bindable]
	public class Profile extends EventDispatcher
	{
		
		private static var _instance:Profile				= null;
		private var _dataAdapter:IDataAdapter		= null;	
		private static var _prefs:Preferences				= new Preferences();
		private var _currentProject:Project					= null;
		
		public var id:Number			= -1;
		
		public var nickname:String		= '';
		public var type:String			= '';
		
		/**
		 * Lay out tabs
		 */
		public static const TYPE_ACTIVECOLLAB:String	= DataAdapterActiveCollab.NAME;
		public static const TYPE_BASECAMP:String		= DataAdapterBasecamp.NAME;
		public static const TYPE_SQLLITE:String			= DataAdapterSqlLite.NAME;
		
		
		/**
		 * Acitve collab fields
		 */
		public var acUrl:String		= '';
		public var acApiKey:String	= '';
		
		/**
		 * Basecamp fields
		 */
		public var basecampUserId:Number	= 0;
		public var basecampUrl:String		= '';
		public var basecampUsername:String 	= '';
		public var basecampPassword:String 	= '';
		
		/**
		 * Event types
		 */
		public static const EVENT_PROFILE_INSTANCE_SET:String = 'profile_instance_set';
		
		public function Profile() {
			
		}
		
		public static function getFromId(id:Number):Profile {
			
			//consolidate sql commands
			var profiles:Array = Profile.getProfiles();
			for each(var profile:Profile in profiles) {
				if(profile.id == id) {
					return profile;
				}
			}
			
			return null;
		}

		
		/**
		 * returns an array of profile objects
		 */
		public static function getProfiles():Array {
			
			var sql:SQLStatement			= new SQLStatement();
			var profiles:Array				= [];
			
			sql.text						= "SELECT * FROM profiles";
			sql.sqlConnection				= Preferences.getConnection();
			sql.execute();
			
			var results:SQLResult			= sql.getResult();
			if (results.data != null) {
				for (var i:int = 0; i < results.data.length; i++) {
					
					/**
					 * Instantiate and populate a new profile class
					 */
					var profile:Profile = new Profile();
					
					profile.id 			= parseInt(results.data[i].profile_id);
					profile.type		= results.data[i].profile_type;
					profile.nickname	= results.data[i].profile_nickname;
					profile.acUrl		= results.data[i].profile_acurl;
					profile.acApiKey	= results.data[i].profile_acapikey;
					
					profile.basecampUserId		= +results.data[i].profile_basecampuserid;
					profile.basecampUsername 	= results.data[i].profile_basecampusername;
					profile.basecampUrl 		= results.data[i].profile_basecampurl;
					profile.basecampPassword 	= results.data[i].profile_basecamppassword;
					
					profiles.push(profile);
				}
			}
			
			return profiles;
		}
		

		
		/**
		 * Sets the main profile using a singleton approach
		 */
		public static function setInstance(profile:Profile):void {
			
			if(profile == null) {
				return;
			}
			
			/**
			 * Do a deep copy on certain vars only so event listeners 
			 * are retained for the singleton instance
			 */
			var instance:Profile = Profile.getInstance();
			
			instance.id 		= profile.id;
			instance.type		= profile.type;
			instance.nickname	= profile.nickname;
			
			/**
			 * Active Collab
			 */
			instance.acUrl		= profile.acUrl;
			instance.acApiKey	= profile.acApiKey;
			
			/**
			 * Basecamp
			 */
			instance.basecampUserId		= profile.basecampUserId;
			instance.basecampUrl 		= profile.basecampUrl;
			instance.basecampUsername	= profile.basecampUsername;
			instance.basecampPassword	= profile.basecampPassword;
			
			//save that this selection was made
			var prefs:Preferences = new Preferences();
			prefs.saveRecord('profileId', profile.id.toString());
						
			//tell the world
			Profile._instance.dispatchEvent(new Event(Profile.EVENT_PROFILE_INSTANCE_SET));
		}
		
		public static function getInstance():Profile {
			if(Profile._instance == null) {
				Profile._instance = new Profile;
			}
			
			return Profile._instance;
		}
		
		public static function resetInstance():Profile {
			Profile._instance = new Profile;
			
			return Profile._instance;
		}
		
		public function isValid():Boolean {
			try {
				
				this.getDataAdapter();
				
				//if this is basecamp, we need a user id
				if(this.type == Profile.TYPE_BASECAMP && isNaN(this.basecampUserId)) {
					return false;
				}
				
				return true;
			} catch(e:Error) {
				return false;
			}
			
			return false;
		}
		
		/**
		 * Saves this profile to the databse, inserts if new, updates if old
		 */
		public function save():Boolean {
			
			var sql:SQLStatement	= new SQLStatement();
			if(this.id == -1) {
				sql.text		= 	"INSERT INTO profiles (" +
									"profile_nickname, " +
									"profile_type, " +
									"profile_acapikey, " +
									"profile_acurl, " +
									"profile_basecampuserid, " +
									"profile_basecampurl, " +
									"profile_basecampusername, " +
									"profile_basecamppassword" +
									
									") VALUES (" + 
									
									":nickname," + 
									":type, " + 
									":acApiKey, " + 
									":acUrl, " +
									":basecampUserId, " +
									":basecampUrl, " +
									":basecampUsername, " +
									":basecampPassword)";
			} else {
				sql.text		= 	"UPDATE profiles SET profile_nickname = :nickname, " +
									"profile_type = :type, " +
									"profile_acapikey = :acApiKey, " +
									"profile_acurl = :acUrl, " +
									"profile_basecampuserid = :basecampUserId, " +
									"profile_basecampurl = :basecampUrl, " +
									"profile_basecampusername = :basecampUsername, " +
									"profile_basecamppassword = :basecampPassword " +
									"WHERE profile_id = :id";
			}
			
			//bind values
			sql.parameters[':nickname']			= this.nickname;
			sql.parameters[':type']				= this.type;
			sql.parameters[':acApiKey']			= this.acApiKey;
			sql.parameters[':acUrl']			= this.acUrl;
			sql.parameters[':basecampUserId']	= this.basecampUserId;
			sql.parameters[':basecampUrl']		= this.basecampUrl;
			sql.parameters[':basecampUsername']	= this.basecampUsername;
			sql.parameters[':basecampPassword']	= this.basecampPassword;
			
			//if updating, set id
			if(this.id != -1) {
				sql.parameters[':id']				= this.id;
			}
			
			sql.sqlConnection		= Preferences.getConnection();
		
			try {
				sql.execute();
				
				//get the id
				if(this.id == -1) {
					this.id = sql.sqlConnection.lastInsertRowID;
				}
				
			}
			catch (error:SQLError) {
				
				Logger.log('profile.save failed');
				Logger.log("insert error: " + error);
				Logger.log("message: " + error.message);
				Logger.log("details: " + error.details);
				
				return false;
			}
			
			return true;
		}
		
		/**
		 * Returns the proper data adapter for this profile depending on
		 * which type it is. Types coorelate to dataadatpers
		 */
		public function getDataAdapter():IDataAdapter {
				
			switch(this.type) {
				case DataAdapterActiveCollab.NAME:
					return new DataAdapterActiveCollab(this);
				case DataAdapterBasecamp.NAME:
					return new DataAdapterBasecamp(this);
				default:
					throw new Error("No type set for profile.");
			}
		
		}
		
		public function remove():void {
			var sql:SQLStatement			= new SQLStatement();
			var profiles:Array				= [];
			
			sql.text						= "DELETE FROM profiles WHERE profile_id = :id";
			
			//bind parameters
			sql.parameters[':id']			= this.id;
			
			//execute
			sql.sqlConnection				= Preferences.getConnection();
			sql.execute();
			
			if(Profile._instance.id == this.id) {
				Profile._instance = null;
			}
			
		}
		
		public function testAccountSettings(successCallback:Function = null, failureCallback:Function = null):void {
			var dataAdapter:IDataAdapter = this.getDataAdapter();
			dataAdapter.testConnection(successCallback, failureCallback);
		}
		
		public function getProjects(successCallback:Function = null, failureCallback:Function = null):void {
			Project.profile = this;
			Project.getProjects(successCallback, failureCallback);
		}
		
		
		public function postTimeForRemoteObject(remoteObject:Remote, elapsedTime:Number, billingType:Number = 0, comments:String = "", successCallback:Function = null, errorCallback:Function = null):void {
			
			var date:Date			= new Date(elapsedTime);
			var time:String			= String((date.hoursUTC) + ((date.minutes + date.seconds/60)/60));
			
			var dataAdapter:IDataAdapter	= this.getDataAdapter();
			dataAdapter.postTimeForRemoteObject(remoteObject, time, billingType, comments, successCallback, errorCallback);
		}
		
		public function get typeFormatted():String {
			switch (this.type) {
				case TYPE_ACTIVECOLLAB:
					return "ActiveCollab";
				case TYPE_BASECAMP:
					return "BaseCamp";
				case TYPE_SQLLITE:
					return "SQLite";
				default:
					return "None";
			}
		}
		
		public function getTaskName():String {
			return this.getDataAdapter().getTaskName();
		}
		
		public function getSubTaskName():String {
			return this.getDataAdapter().getSubTaskName();
		}
		
		public function getHasChecklists():Boolean {
			return (this.getDataAdapter().getHasChecklists() && (Preferences.getInstance().getRecord('enableChecklists','0') == '1'));
		}
		
		public function getUseCheckboxesForSubTasks():Boolean {
			return (this.type == Profile.TYPE_BASECAMP && (Preferences.getInstance().getRecord('useCheckboxesForSubTasks','0') == '1'));
		}
		
		public function getHasTimecardTypes():Boolean {
			return this.getDataAdapter().getHasTimecardTypes();
		}
	}
}