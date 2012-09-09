/*
	Copyright (c) 2008 Narciso Jaramillo
	All rights reserved.

	Redistribution and use in source and binary forms, with or without 
	modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, 
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright 
      notice, this list of conditions and the following disclaimer in the 
      documentation and/or other materials provided with the distribution.
    * Neither the name of Narciso Jaramillo nor the names of other 
      contributors may be used to endorse or promote products derived from 
      this software without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" 
	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE 
	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE 
	DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE 
	FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL 
	DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR 
	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
	CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
	OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE 
	USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

package model.feeds.readers
{
	import flash.data.SQLConnection;
	import flash.data.SQLResult;
	
	import model.feeds.FeedItemDescriptor;
	import model.feeds.FeedStatements;
	import model.feeds.LoggingStatement;
	
	import mx.collections.ArrayCollection;
	
	/**
	 * Model class for managing the feed reader operations that are pending synchronization with the server.
	 * Note that the PendingOperationModel assumes it is the only class that is screwing with the pendingops table,
	 * and may function incorrectly if another class inserts, removes, or updates rows without going through it.
	 * @author Rob Adams
	 */
	public class PendingOperationModel
	{
		private var _statements: FeedStatements;
		private var _sqlConnection: SQLConnection;
		private var _operations: ArrayCollection = new ArrayCollection();
		
		public function PendingOperationModel(sqlConnection: SQLConnection)
		{
			_statements = new FeedStatements(sqlConnection);
			_sqlConnection = sqlConnection;
			initializeDB();
			loadOperations();
		}
		
		private function initializeDB(): void {
			var createTable: LoggingStatement = new LoggingStatement();
			createTable.sqlConnection = _sqlConnection;
			createTable.text = 
				"CREATE TABLE IF NOT EXISTS main.pendingops (" +
				"	opId INTEGER PRIMARY KEY AUTOINCREMENT, " +
				"	opCode INTEGER, " +
				"	feedURL TEXT, " + 
				"	feedItemGuid TEXT " +
				")";
			createTable.execute();
		}
		
		public function get operations(): ArrayCollection {
			return _operations;
		}
		
		private function loadOperations(): void {
			var loadOps: LoggingStatement = new LoggingStatement();
			loadOps.sqlConnection = _sqlConnection;
			loadOps.text = "SELECT * FROM main.pendingops LEFT JOIN main.feeditems ON feedItemGuid ORDER BY opId";
			loadOps.execute();
			
			var opsResult: SQLResult = loadOps.getResult();
			var opsList: Array = null;
			if(opsResult.data != null ) {
				opsList = new Array(opsResult.data.length);
				for(var i:int = 0; i < opsResult.data.length; i++) {
					var result: Object = opsResult.data[i];
					var feedItemDescriptor : FeedItemDescriptor = new FeedItemDescriptor(result.guid, result.link);
					var pendingOp: PendingOperation = new PendingOperation(result.opCode, result.feedURL, feedItemDescriptor);
					opsList[i] = pendingOp;
				}
			}
			_operations = new ArrayCollection(opsList);
		}
		
		public function clearOperations(): void {
			_operations = new ArrayCollection();
			
			var deleteOps: LoggingStatement = new LoggingStatement();
			deleteOps.sqlConnection = _sqlConnection;
			deleteOps.text = "DELETE FROM main.pendingops WHERE 1=1";
			deleteOps.execute();
		}
		
		public function addOperation(operation: PendingOperation): void {
			_operations.addItem(operation);
						
			var addOp: LoggingStatement = new LoggingStatement();
			addOp.sqlConnection = _sqlConnection;
			addOp.text = "INSERT INTO main.pendingops (opCode, feedURL, feedItemGuid) VALUES (:opCode, :feedURL, :feedItemGuid)";
			addOp.parameters[":opCode"] = operation.opCode;
			addOp.parameters[":feedURL"] = operation.feedURL;
			addOp.parameters[":feedItemGuid"] = operation.feedItemDescriptor != null ? operation.feedItemDescriptor.guid : null;				
			addOp.execute();
		}
		
		public function isMarkedForAdd(feedURL: String) : Boolean {
			for each (var pendingOp: PendingOperation in _operations) {
				if (pendingOp.opCode == PendingOperation.ADD_FEED_OPCODE && pendingOp.feedURL == feedURL) {
					return true;
				}
			}
			return false;
		}

		public function isMarkedForDelete(feedURL: String) : Boolean {
			for each (var pendingOp: PendingOperation in _operations) {
				if (pendingOp.opCode == PendingOperation.DELETE_FEED_OPCODE && pendingOp.feedURL == feedURL) {
					return true;
				}
			}
			return false;
		}
		
		public function isMarkedForReadStatusAssignment(itemURL: String, guid: String) : Boolean {
			for each (var pendingOp: PendingOperation in _operations) {
				if (pendingOp.opCode == PendingOperation.MARK_READ_OPCODE && (pendingOp.feedItemDescriptor.link == itemURL || pendingOp.feedItemDescriptor.guid == guid)) {
					return true;
				}
			}
			return false;
		}


	}
}