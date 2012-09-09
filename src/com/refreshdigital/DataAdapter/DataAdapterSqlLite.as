package com.refreshdigital.DataAdapter
{
	import com.refreshdigital.Project;
	
	import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.data.SQLStatement;
	import flash.filesystem.File;
	
	public class DataAdapterSqlLite extends DataAdapterAbstract 
	{
		
		public static const NAME:String				= "localdb";
		/*
		private var _databaseFile:File 			= File.applicationStorageDirectory.resolvePath("timerDB.db");
		private var _database:SQLConnection		= null;
		
		public var dbConn:SQLConnection			= new SQLConnection();
		
		public function DataAdapterSqlLite()
		{
			super();
			this._endPoint 						= "timerDB.db";
			
			_setupDB();
		}
		
		private function _setupDB():void {
			this._database = new SQLConnection();
			
			this._database.open(this._databaseFile, SQLMode.CREATE);
			
			
			//if the file exists, get out, otherwise, create our preferences
			if(this._databaseFile.exists) {
				return;
			}
			
			var sql:SQLStatement				= new SQLStatement();
			
			sql.text = "CREATE TABLE projects (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, overview TEXT)";
			sql.sqlConnection = this._database;
			sql.execute();
			
			sql.text = "CREATE TABLE tasks (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, body TEXT, p_id INTEGER, time REAL)";
			sql.execute();
		}
		/*
		override public function getProjects(callback:Function):void
		{
			
			var me:DataAdapterSqlLite 		= this;
					
			var projects:Array 				= [];
			
			
			var sql:SQLStatement	= new SQLStatement();
			sql.text				= "SELECT * FROM projects";
			sql.sqlConnection		= this._database;
			sql.execute();
			var result:SQLResult	= sql.getResult();
			
			if (result.data != null) {
				var numRows:int = result.data.length;
				for (var i:int = 0; i < numRows; i++) {
					projects.push(new Project(result.data[i].id,result.data[i].name,result.data[i].overview,me));
				}
			}
			
			callback(projects);
		}
		
		override public function getTasksForProject(project:Project, callback:Function):void 
		{
			var sql:SQLStatement	= new SQLStatement();
			sql.text				= "SELECT * FROM tasks WHERE p_id='"+project.id+"'";
			sql.sqlConnection		= this._database;
			sql.execute();
			var result:SQLResult	= sql.getResult();
			
			if (result.data != null) {
				var numRows:int = result.data.length;
				for (var i:int = 0; i < numRows; i++) {
					tasks.push(new Task(result.data[i].id,result.data[i].name,result.data[i].body,project));
				}
			}
			
			callback(projects);
		}
		
		override public function getTimeForProject(project:Project, callback:Function):void {
			var totTime:Number		= 0;
			var sql:SQLStatement	= new SQLStatement();
			sql.text				= "SELECT time FROM tasks WHERE p_id='"+project.id+"'";
			sql.sqlConnection		= this._database;
			sql.execute();
			var result:SQLResult	= sql.getResult();
			
			if (result.data != null) {
				var numRows:int = result.data.length;
				for (var i:int = 0; i < numRows; i++) {
					totTime = totTime + result.data[i].time;
				}
			}
			time.push(new Timecard(String(totTime), project, project, null, null));
			
			callback(projects);
		}
		
*/
	}
}