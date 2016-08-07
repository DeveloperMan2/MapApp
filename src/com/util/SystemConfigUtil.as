package com.util
{
	import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	import flash.filesystem.File;
	public class SystemConfigUtil extends Object
	{
		private var dbConn:SQLConnection;
		private var _dbFilePath:String = "";
		private var _status:String = "";
		private var _opened:Boolean = false;
		public static var _bytefromIsAS:Boolean = false;
		
		public const mbtilesPath:String ="mbtilesPath";
		
		public function SystemConfigUtil(filePath:String)
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
				this.dbConn.open(dbfile, SQLMode.UPDATE);
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
		
		/**根据系统配置的外部影像文件夹路径*/
		public function queryMbtilesFolderPath():String
		{
			var stmtTemp:SQLStatement = new SQLStatement();
			var result:SQLResult;
			var data:Array;
			
			var sql:String = "SELECT value  FROM system WHERE key =  :mbtilesPath";
			stmtTemp.text = sql;
			stmtTemp.parameters[":mbtilesPath"] = mbtilesPath;
			stmtTemp.sqlConnection = this.dbConn;
			try
			{
				stmtTemp.execute();
				result = stmtTemp.getResult();
				data = result.data;
				if (data != null && data.length == 1)
				{		
					return data[0].value as String;
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
			return "";	
		}
		
		/**更新外部影像文件夹路径*/
		public function updateMbtilesFolderPath(path:String):Boolean
		{
			var stmtTemp:SQLStatement = new SQLStatement();
			var result:SQLResult;
			var data:Array;
			
			var sql:String = "delete  FROM system WHERE key =  '"+mbtilesPath+"'";
			stmtTemp.text = sql;
			stmtTemp.sqlConnection = this.dbConn;
			try
			{
				stmtTemp.execute();
				
				sql = "INSERT INTO system (key, value)  values (:key, :value)";
				stmtTemp.text = sql;
				stmtTemp.parameters[":key"] = mbtilesPath;
				stmtTemp.parameters[":value"] = path;
				stmtTemp.execute();
				return true;
			}
			catch (error:SQLError)
			{
				return false;
			}
			return false;	
		}
	}
}
