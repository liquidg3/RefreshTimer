package com.refreshdigital
{
	import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.display.Screen;
	import flash.errors.SQLError;
	import flash.filesystem.File;
	
	import mx.collections.ArrayCollection;
	
	import org.osmf.utils.Version;
	
	public class Preferences
	{
		
		private var _connectionFile:File 					= File.applicationStorageDirectory.resolvePath("refreshTimer.db");
		private static var _connection:SQLConnection		= null;
		
		//singleton
		private static var _instance:Preferences			= null;
		private var _cache:Object							= {};
		public var values:ArrayCollection					= new ArrayCollection();
		
		public static var POSITION_TOP:String				= 'top';
		public static var POSITION_BOTTOM:String			= 'bottom';
		
		
		
		/**
		 * Checks if a local sql database has been created, if not, create one
		 */
		public function Preferences()
		{
			//trace(_connectionFile.nativePath);
			
			//if there is already a connection around, we don't need another one
			if(Preferences._connection != null) {
				return;
			}
			
			var firstRun:Boolean	= true;
			
    		//if the file exists, get out, otherwise, create our preferences
    		if(this._connectionFile.exists) {
				firstRun = false;
    		}
			
			//create databsase connection
			Preferences._connection = new SQLConnection();
			Preferences._connection.open(this._connectionFile, SQLMode.CREATE);
			
			if(!firstRun) {
								
			} else {
			
				//create preferences table
				var sql:SQLStatement= new SQLStatement();
				sql.text 			= "CREATE TABLE preferences (key VARCHAR(128) NOT NULL, value TEXT, PRIMARY KEY (key))";
				sql.sqlConnection	= Preferences._connection;
				sql.execute();	
				
				//create profiles table
				this._createProfilesTable();
				
				//set the current version of the app
				this.setVersion();
				
			}

    	}
		
		public static function getInstance():Preferences {
			
			if(!Preferences._instance) {
				Preferences._instance = new Preferences();
			}
			
			return Preferences._instance;
		}
		
		/**
		 * Returns either POSITION_TOP or POSITION_BOTTOM
		 */
		public function getScreenPosition():String {
			return this.getRecord('screenPosition',Preferences.POSITION_TOP);
		}
		
		public function upgradeIfNeeded():void {
			
			var version:Number 		= this.getVersion();
			
			var sql:SQLStatement	= new SQLStatement();
			sql.sqlConnection		= Preferences.getConnection();
			
			Logger.log("checking if the preferences database needs to be upgraded, current version is: " + version.toString());
			
			//things we need may to save again after upgracde
			var profiles:Array;
			var updateExecuted:Boolean = false;
			
			switch(true) {
				
				//add profile basecamp profile fields
				case (version == .19):
					
					updateExecuted 	= true;
					profiles 		= Profile.getProfiles();
					
					var profileId:Number = +Preferences.getInstance().getRecord('profileId','0');
					
					sql.text 		= "DROP TABLE profiles";
					sql.execute();
					
					this._createProfilesTable();
					
					var isSelected:Boolean = false;
					
					for each(var oldProfile:Profile in profiles) {
						
						//we need to make sure the profile that was originall selected still is
						isSelected = (oldProfile.id == profileId);
						
						oldProfile.id = -1;
						oldProfile.save();
						
						if(isSelected) {
							Profile.setInstance(oldProfile);
						}
					}
				
									
			}
			
			//if we made any updates, set the new version to the version in the updateDescriptor
			if(updateExecuted) {
				this.setVersion();
			}
			
		}
		
		public function setRecord(key:String, value:String):void {
			this.saveRecord(key, value);
		}
		
		private function _createProfilesTable():void {
			
			var sql:SQLStatement	= new SQLStatement();
			sql.sqlConnection		= Preferences.getConnection();
			
			sql.text 	= "CREATE TABLE profiles (" +
								"profile_id INTEGER PRIMARY KEY AUTOINCREMENT, " + 
								"profile_nickname TEXT, " + 
								"profile_type VARCHAR(128), " + 
								"profile_acapikey TEXT, " +
								"profile_acurl TEXT," +
								"profile_basecampuserid INTEGER," +
								"profile_basecampurl TEXT, " +
								"profile_basecampusername TEXT," +
								"profile_basecamppassword TEXT)";
			
			
			sql.execute();
			
		}
		
		
		public function saveRecord(key:String,value:String):void {
			
			var sql:SQLStatement	= new SQLStatement();
			if(this.getRecord(key, null) == null) {
				sql.text				= "INSERT INTO preferences (key, value) VALUES (:key, :value)";
			} else {
				sql.text				= "UPDATE preferences SET value = :value WHERE key = :key";
			}
			
			//bind vars
			sql.parameters[':key']	= key;
			sql.parameters[':value']= value;
			
			//execute and cache
			sql.sqlConnection		= Preferences._connection;
			this._cache[key]		= value;
			
			try {
				sql.execute();
				//sql.sqlConnection.commit();
			}
			catch (error:SQLError) {
				Logger.log("insert error: " + error);
				Logger.log("message: " + error.message);
				Logger.log("details: " + error.details);
			}
		}
		
		/**
		 * Loads a setting based off key, returns the default
		 * val if the the record is not found
		 */
		public function getRecord(key:String, defaultValue:String):* {
			
			//check cache
			if(this._cache.hasOwnProperty(key)) {
				return this._cache[key];
			}
			
			var sql:SQLStatement	= new SQLStatement();
			sql.text				= "SELECT * FROM preferences WHERE key = :key";
			
			//bind
			sql.parameters[':key']	= key;
			
			sql.sqlConnection		= Preferences._connection;
			sql.execute();
			var result:SQLResult	= sql.getResult();
			
			if (result.data != null) {
				return result.data[0].value;
			}
			
			return defaultValue;
		}
		
		public function deleteRecord(key:String):void {
			
			var sql:SQLStatement 	= new SQLStatement();
			sql.text				= "DELETE FROM preferences WHERE key = :key";
		
			sql.parameters[":key"]	= key;
			
			sql.sqlConnection		= Preferences._connection;
			sql.execute();
		}
		
		private function getPreferences():void {
			
			var sql:SQLStatement	= new SQLStatement();
			sql.text				= "SELECT * FROM preferences";
			sql.sqlConnection		= Preferences._connection;
			sql.execute();
			var result:SQLResult	= sql.getResult();
			
			if (result.data != null) {
				var numRows:int = result.data.length;
				for (var i:int = 0; i < numRows; i++) {
					values.addItem({key: result.data[i].key, value: result.data[i].value});
				}
			}
		}
		
		
		public function getSelectedScreenIndex():Number {
			var screenIndex:String = this.getRecord('selectedScreen', null);
			if(screenIndex == null) {
				return 0;
			}
			
			var screen:Number = parseInt(screenIndex);
		
			if(screen < 0 || screen >= Screen.screens.length) {
				return 0;
			}
			
			return screen;
		}
		
		public function getVersion():Number {
			//select the version number
			var version:Number = +this.getRecord('_databaseVersion','0');
			
			return version;
		}
		
		public function setVersion(version:Number = -1):void {
			
			if(version == -1) {
				version = Util.timerBar.getVersion();
			}
			
			this.setRecord('_databaseVersion',version.toString());
		}
		
		public function getSelectedProfile():Profile {
			var profileId:String = this.getRecord('profileId', null);
			if(profileId == null) {
				return null;
			}
			
			return Profile.getFromId(parseInt(profileId));
		}
	
		
		public static function getConnection():SQLConnection {
			if(Preferences._connection == null) {
				new Preferences();
			}
			return Preferences._connection;
		}


	}
}