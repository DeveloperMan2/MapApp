package com.util
{
	import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	import flash.filesystem.File;
	public class QueryUtil extends Object
	{
		private var dbConn:SQLConnection;
		private var _dbFilePath:String = "";
		private var _status:String = "";
		private var _opened:Boolean = false;
		public static var _bytefromIsAS:Boolean = false;
		
		public function QueryUtil(filePath:String)
		{
			this._dbFilePath = filePath;
			return;
		}// end function
		
		public function get opened() : Boolean
		{
			return this._opened;
		}// end function
		
		public function open() : Boolean
		{
			var dbfile:File = File.documentsDirectory.resolvePath(this._dbFilePath);
			this.dbConn = new SQLConnection();
			try
			{
				this.dbConn.open(dbfile, SQLMode.READ);
				this._opened = true;
				return true;
			}
			catch (error:Error)
			{
				_status = "数据库文件不存在";
			}
			return false;
		}// end function
		
		public function close() : Boolean
		{
			try
			{
				if (this.dbConn != null)
				{
				}
				if (this._opened)
				{
					this.dbConn.close();
					this._opened = false;
				}
				this.dbConn = null;
				return true;
			}
			catch (error:Error)
			{
				_status = "连接失败";
			}
			return false;
		}// end function
		
		/**根据名称查询*/
		public function queryByName(keyName:String):Array
		{
			var stmtTemp:SQLStatement = new SQLStatement();
			var result:SQLResult;
			var data:Array;
			
			var sql:String = "SELECT *  FROM image WHERE name like  :name or location like :location";
			stmtTemp.text = sql;
			stmtTemp.parameters[":name"] = "%"+keyName + "%";
			stmtTemp.parameters[":location"] = "%"+keyName + "%";
			stmtTemp.sqlConnection = this.dbConn;
			try
			{
				stmtTemp.execute();
				result = stmtTemp.getResult();
				data = result.data;
				if (data != null && data.length > 0)
				{		
					return data as Array;
				}
				else
				{
					this._status = "查询结果为空";
				}
			}
			catch (error:SQLError)
			{
				_status = "查询出错" + error.message;
			}
			return null;	
		}
	}
}
