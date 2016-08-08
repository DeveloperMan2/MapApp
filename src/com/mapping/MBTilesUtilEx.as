package com.mapping
{
	import com.supermap.web.mapping.supportClasses.MetadataObj;
	import com.supermap.web.sm_internal;
	
	import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	import flash.filesystem.File;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	use namespace sm_internal;
	public class MBTilesUtilEx extends Object
	{
		private var dbConn:SQLConnection;
		private var _dbFilePath:String = "";
		private var _status:String = "";
		private var _opened:Boolean = false;
		public static var _bytefromIsAS:Boolean = false;
		
		public function MBTilesUtilEx(filePath:String)
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
			var dbfile:File;
//			if (_dbFilePath.search(":") != -1) {
//				dbfile = File.documentsDirectory.resolvePath(
//			}
			dbfile = File.documentsDirectory.resolvePath(this._dbFilePath);
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
		
		public function getTile2(row:int,col:int ,tile_level:int):ByteArray
		{
			var tile_id:String = getTileID(row,col,tile_level);
			if(tile_id != null)
			{
				return getTileData(tile_id);
			}
			return null;
		}
		public function getTile4(row:int ,col:int,resolution:Number):ByteArray
		{
			var stmtTemp:SQLStatement = new SQLStatement();
			var result:SQLResult;
			var data:Array;
			
			var sql:String = "SELECT CAST(tile_data AS ByteArray) AS tile FROM tiles WHERE tile_column=:col and tile_row = :row and resolution = :resolution";
			stmtTemp.text = sql;
			stmtTemp.parameters[":row"] = row;
			stmtTemp.parameters[":col"] = col;
			stmtTemp.parameters[":resolution"] = resolution;
			stmtTemp.sqlConnection = this.dbConn;
			try
			{
				stmtTemp.execute();
				result = stmtTemp.getResult();
				data = result.data;
				if (data != null && data.length == 1)
				{					
					return data.tile as ByteArray;
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
		public function getTile3(row:int ,col:int ,resolution:Number):ByteArray{
			var stmtTemp:SQLStatement = new SQLStatement();
			var result:SQLResult;
			var data:Array;
			
			var sql:String = "SELECT tile_id FROM map  where tile_column=:col and tile_row = :row and resolution like :resolution";
			stmtTemp.text = sql;
			stmtTemp.parameters[":row"] = row;
			stmtTemp.parameters[":col"] = col;
			stmtTemp.parameters[":resolution"] = resolution+"%";
			stmtTemp.sqlConnection = this.dbConn;
			try
			{
				stmtTemp.execute();
				result = stmtTemp.getResult();
				data = result.data;
				if (data != null && data.length == 1)
				{					
					var tile_id:String = data[0].tile_id as String;					
					sql = "SELECT CAST(tile_data AS ByteArray) AS tile FROM images WHERE tile_id = :tile_id";
					var stmt2:SQLStatement = new SQLStatement();
					stmt2.text = sql;
					stmt2.parameters[":tile_id"] = tile_id;
					stmt2.sqlConnection = this.dbConn;
					stmt2.execute();
					var ret:Object = stmt2.getResult().data;
					if(ret != null && ret.length == 1)
					{
						return ret.tile as ByteArray;
					}
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
		
		private function getTileID(row:int,col:int,level:int):String
		{
			var stmtTemp:SQLStatement = new SQLStatement();
			var result:SQLResult;
			var data:Array;
			var tileDataName:String ="tile_id";
			var tableName:String ="map";
			var rowName:String ="tile_row";
			var colName:String ="tile_column";
			var levelName:String ="tile_level";
			var sql:String = "SELECT "+ tileDataName +" FROM "+tableName  + " where "+rowName +" = :tile_row AND "+ colName +" = :tile_column AND "+levelName+" = :tile_level";
			
			stmtTemp.text = sql;
			stmtTemp.parameters[":tile_row"] = row;
			stmtTemp.parameters[":tile_column"] = col;
			stmtTemp.parameters[":tile_level"] = level;
			stmtTemp.sqlConnection = this.dbConn;
			try
			{
				stmtTemp.execute();
				result = stmtTemp.getResult();
				data = result.data;
				if (data != null && data.length == 1)
				{
					return result.data[0].tile_id;					
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
		
		private function getTileData(tileId:String):ByteArray
		{
			var stmtTemp:SQLStatement = new SQLStatement();
			var result:SQLResult;
			var data:Array;			
			var tableName:String ="images";
			var tile_id:String ="tile_id";
			var sql:String = "SELECT CAST(tile_data AS ByteArray) AS tile FROM "+tableName  + " where "+tile_id +" = :tile_id";			
			stmtTemp.text = sql;
			stmtTemp.parameters[":tile_id"] = tileId;
			stmtTemp.sqlConnection = this.dbConn;
			try
			{
				stmtTemp.execute();
				result = stmtTemp.getResult();
				data = result.data;
				if (data != null && data.length == 1)
				{
					return result.data[0].tile as ByteArray;					
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
		
		public function getTile(tableName:String,tile_id:String,tile_id_name:String, tileDataName:String) : ByteArray
		{
			var result:SQLResult;
			var data:Array;
			var byteArray:ByteArray;
			var tile_id:String = tile_id;
			var stmtTemp:SQLStatement = new SQLStatement();
			var sql:String;
			if (_bytefromIsAS)
			{
				sql = "SELECT "+ tileDataName +" FROM "+tableName  + " where "+tile_id_name +" like :tile_id ";
			}
			else
			{
				sql = "SELECT CAST("+ tileDataName+" AS ByteArray) AS tile_data " +" FROM "+tableName  + " where "+tile_id_name +" like  :tile_id";
			}
			stmtTemp.text = sql;
			stmtTemp.parameters[":tile_id"] = tile_id;
			stmtTemp.sqlConnection = this.dbConn;
			try
			{
				stmtTemp.execute();
				result = stmtTemp.getResult();
				data = result.data;
				if (data != null && data.length == 1)
				{
					byteArray = result.data[0].tile_data;
					return byteArray;
				}
				else
				{
					var bgSql:String;
					if (_bytefromIsAS)
					{
						bgSql = "SELECT "+ tileDataName +" FROM "+tableName  + " where "+tile_id_name +" like '%background%' ";
					}
					else
					{
						bgSql = "SELECT CAST("+ tileDataName+" AS ByteArray) AS tile_data " +" FROM "+tableName  + " where "+tile_id_name +" like '%background%' ";
					}
					stmtTemp.text = bgSql;
					delete stmtTemp.parameters[":tile_id"];
					stmtTemp.execute();
					result = stmtTemp.getResult();
					data = result.data;
					if (data != null && data.length == 1)
					{
						byteArray = result.data[0].tile_data;
						return byteArray;
					}
					return null;
				}
			}
			catch (error:SQLError)
			{
				_status = "查询出错" + error.details;
				trace(_status);
			}
			return null;
		}// end function
		
		public function insertTile(row:int, col:int, level:int, resolution:Number, bytes:ByteArray) : Boolean
		{
			var row:int = row;
			var col:int = col;
			var level:int = level;
			var resolution:Number = resolution;
			var bytes:ByteArray = bytes;
			if (bytes == null)
			{
				this._status = "存储数据为空";
				return false;
			}
			var insertStmt:* = new SQLStatement();
			insertStmt.sqlConnection = this.dbConn;
			var sql:* = "INSERT INTO tiles (tile_row, tile_column, zoom_level, tile_data) " + "values(:tile_row, :tile_column, :zoom_level, :resolution, :tile_data);";
			insertStmt.text = sql;
			insertStmt.parameters[":tile_row"] = row;
			insertStmt.parameters[":tile_column"] = col;
			insertStmt.parameters[":zoom_level"] = level;
			insertStmt.parameters[":resolution"] = resolution;
			insertStmt.parameters[":tile_data"] = bytes;
			try
			{
				insertStmt.execute();
				return true;
			}
			catch (error:SQLError)
			{
				_status = "存储失败" + error.message;
			}
			return false;
		}// end function
		
		public function setTile(row:int, col:int, level:int, bytes:ByteArray) : Boolean
		{
			var row:* = row;
			var col:* = col;
			var level:* = level;
			var bytes:* = bytes;
			if (bytes == null)
			{
				this._status = "存储数据为空";
				return false;
			}
			var updateStmt:* = new SQLStatement();
			updateStmt.sqlConnection = this.dbConn;
			var sql:* = "update tiles set tile_data = :tile_data" + " where tile_row = :tile_row AND tile_column = :tile_column AND zoom_level = :zoom_level";
			updateStmt.text = sql;
			updateStmt.parameters[":tile_data"] = bytes;
			updateStmt.parameters[":tile_row"] = row;
			updateStmt.parameters[":tile_column"] = col;
			updateStmt.parameters[":zoom_level"] = level;
			try
			{
				updateStmt.execute();
				return true;
			}
			catch (error:SQLError)
			{
				_status = "存储失败" + error.message;
			}
			return false;
		}// end function
		
		public function deleteTile(row:int, col:int, resolution:Number) : Boolean
		{
			var row:* = row;
			var col:* = col;
			var resolution:* = resolution;
			var deleteStmt:* = new SQLStatement();
			deleteStmt.sqlConnection = this.dbConn;
			var sql:* = "delete from tiles" + " where tile_row = :tile_row AND tile_column = :tile_column AND resolution = :resolution";
			deleteStmt.text = sql;
			deleteStmt.parameters[":tile_row"] = row;
			deleteStmt.parameters[":tile_column"] = col;
			deleteStmt.parameters[":resolution"] = resolution;
			try
			{
				deleteStmt.execute();
				return true;
			}
			catch (error:SQLError)
			{
				_status = "存储失败" + error.message;
			}
			return false;
		}// end function
		
		public function readMetadataObj() : MetadataObj
		{
			var result:SQLResult;
			var data:Array;
			var metadata:MetadataObj;
			var i:int;
			var obj:Object;
			var key:String;
			var value:String;
			var unitStr:String;
			var stmtTemp:SQLStatement = new SQLStatement();
			var sql:String = "select * from metadata";
			stmtTemp.text = sql;
			stmtTemp.sqlConnection = this.dbConn;
			try
			{
				stmtTemp.execute();
				result = stmtTemp.getResult();
				data = result.data;
				if (data.length < 5)
				{
					this._status = "信息确实";
					return null;
				}
				metadata = new MetadataObj();
				i;
				while (i < data.length)
				{
					
					obj = data[i];
					key = String(obj.name).toLowerCase();
					value = data[i].value as String;
					switch(key)
					{
						case "bounds":
						{
							metadata.bounds = metadata.getLayerBounds(value);
							break;
						}
						case "name":
						{
							metadata.name = value;
							break;
						}
						case "type":
						{
							metadata.type = value;
							break;
						}
						case "version":
						{
							metadata.version = value;
							break;
						}
						case "description":
						{
							metadata.description = value;
							break;
						}
						case "format":
						{
							metadata.format = value;
							break;
						}
						case "resolutions":
						{
							metadata.resolutions = metadata.getResolutionsFromStr(value);
							break;
						}
						case "scales":
						{
							metadata.scales = metadata.getScalesFromStr(value);
							break;
						}
						case "crs_wkid":
						{
							metadata.crs_wkid = int(value);
							break;
						}
						case "crs_wkt":
						{
							unitStr = value.slice(value.lastIndexOf("UNIT"), -1);
							metadata.unit = this.comfirmUnit(unitStr);
							break;
						}
						case "compatible":
						{
							metadata.compatible = value == "true";
							break;
						}
						case "tile_height":
						{
							metadata.tileSize = int(value);
							break;
						}
						default:
						{
							metadata.addAttribution(data.name, data[i].value);
							break;
							break;
						}
					}
					i = (i + 1);
				}
				return metadata;
			}
			catch (error:SQLError)
			{
				_status = "查询出错" + error.message;
			}
			return null;
		}// end function
		
		private function comfirmUnit(unitStr:String) : String
		{
			var _loc_2:String = null;
			if (unitStr.indexOf("METER") > 0)
			{
				_loc_2 = "meter";
			}
			else if (unitStr.indexOf("DEGREE") > 0)
			{
				_loc_2 = "degree";
			}
			else if (unitStr.indexOf("DECIMAL_DEGREE") > 0)
			{
				_loc_2 = "decimal_degree";
			}
			else if (unitStr.indexOf("CENTIMETER") > 0)
			{
				_loc_2 = "centimeter";
			}
			else if (unitStr.indexOf("DECIMETER") > 0)
			{
				_loc_2 = "decimeter";
			}
			else if (unitStr.indexOf("FOOT") > 0)
			{
				_loc_2 = "foot";
			}
			else if (unitStr.indexOf("INCH") > 0)
			{
				_loc_2 = "inch";
			}
			else if (unitStr.indexOf("KILOMETER") > 0)
			{
				_loc_2 = "kilometer";
			}
			else if (unitStr.indexOf("MILE") > 0)
			{
				_loc_2 = "mile";
			}
			else if (unitStr.indexOf("MILIMETER") > 0)
			{
				_loc_2 = "milimeter";
			}
			else if (unitStr.indexOf("MINUTE") > 0)
			{
				_loc_2 = "minute";
			}
			else if (unitStr.indexOf("RADIAN") > 0)
			{
				_loc_2 = "radian";
			}
			else if (unitStr.indexOf("SECOND") > 0)
			{
				_loc_2 = "second";
			}
			else if (unitStr.indexOf("YARD") > 0)
			{
				_loc_2 = "yard";
			}
			return _loc_2;
		}// end function
		
		private function setLevel(metadata:MetadataObj) : void
		{
			var result:SQLResult;
			var data:Array;
			var metadata:MetadataObj = metadata;
			var sqlStatement:SQLStatement = new SQLStatement();
			var sql:String;
			sqlStatement.text = sql;
			sqlStatement.sqlConnection = this.dbConn;
			try
			{
				sqlStatement.execute();
				result = sqlStatement.getResult();
				data = result.data;
				if (data.length < 0)
				{
					return;
				}
				metadata.minzoom = data[0].minlevel;
				metadata.maxzoom = data[0].maxlevel;
			}
			catch (error:SQLError)
			{
				_status = "查询出错" + error.message;
			}
			return;
		}// end function
		
		public function writeMetadataObj(metadataObj:MetadataObj) : Boolean
		{
			var sql:String;
			var staticAtt:Dictionary;
			var key:Object;
			var att:Dictionary;
			var value:String;
			var metadataObj:MetadataObj = metadataObj;
			if (metadataObj == null)
			{
				return false;
			}
			if (!this.clearMetadata())
			{
				return false;
			}
			var stmtTemp:SQLStatement = new SQLStatement();
			stmtTemp.sqlConnection = this.dbConn;
			try
			{
				sql;
				stmtTemp.text = sql;
				staticAtt = metadataObj.staticAttribution;
				var _loc_3:int = 0;
				var _loc_4:Dictionary = staticAtt;
				while (_loc_4 in _loc_3)
				{
					
					key = _loc_4[_loc_3];
					stmtTemp.parameters[":name"] = key;
					stmtTemp.parameters[":value"] = staticAtt[key];
					stmtTemp.execute();
				}
				att = metadataObj.attribution;
				var _loc_30:int = 0;
				var _loc_40:Dictionary = att;
				while (_loc_40 in _loc_30)
				{
					
					key = _loc_40[_loc_30];
					value = att[key];
					if (value != null)
					{
					}
					if (value.length == 0)
					{
						continue;
					}
					stmtTemp.parameters[":name"] = key;
					stmtTemp.parameters[":value"] = att[key];
					stmtTemp.execute();
				}
				return true;
			}
			catch (error:SQLError)
			{
				_status = "信息存储失败" + error.message;
			}
			return false;
		}// end function
		
		private function clearMetadata() : Boolean
		{
			var stmtTemp:SQLStatement = new SQLStatement();
			stmtTemp.sqlConnection = this.dbConn;
			var sql:String;
			try
			{
				stmtTemp.text = sql;
				stmtTemp.execute();
				return true;
			}
			catch (error:SQLError)
			{
				_status = "更新前删除失败" + error.message;
			}
			return false;
		}// end function
		
	}
}
