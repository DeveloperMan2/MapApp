package com.util
{
	import com.vo.BaseVO;
	import com.vo.MainVO;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	public class RootDirectory
	{		
		/**离线读写数据库*/
//		public static var root:File = File.documentsDirectory;
		private static var _extSDCard:File = null;
		
		public function RootDirectory()
		{			
			
		}	
		
		/**离线大型地图缓存路径*/
		public static function get extSDCard():File
		{
			if (_extSDCard == null) {
				_extSDCard = File.documentsDirectory;
				var paths:Array = ["/storage/sdcard1","/mnt/external",
					"/storage/extSdCard","/storage/emulated/1"];
				for each(var path:String in paths)
				{
					var fi:File = new File(path);
					if(fi.exists && fi.isDirectory && !fi.isSymbolicLink)
					{
						_extSDCard.nativePath = path;
					}
				}
			} 
			
			return _extSDCard;
		}

		public static function findOfflineDB():Boolean
		{
			/**离线数据存放的路径*/
			var paths:Array = [
				"/storage/emulated/0",
				"/sdcard",	
				"/storage/sdcard"];
			for each(var path:String in paths)
			{
				if(isDBExist(path))
				{
					root.nativePath = path;
					return true;
				}
			}
			return false;
		}	
		
		private static function isDBExist(path:String):Boolean
		{
			var flag:Boolean = false;
			var f:File = new File(path);
			if(f.exists && f.isDirectory && !f.isSymbolicLink)
			{	
				try
				{
					f = f.resolvePath( MainVO.SystemConfigPath + File.separator + BaseVO.SystemDbName);						
				
					/**测试目录是否可写入*/
					var fnew:File = new File(path);
					fnew.resolvePath("test.txt");
					var fs:FileStream = new FileStream();
					fs.open(fnew,FileMode.WRITE);
					fs.writeByte(1);
					fs.close();
					
					flag = f.exists;
				}
				catch(ex:Error)
				{
					trace(ex.message);
				}
				finally
				{					
					return false;
				}					
			}
			return flag;
		}
		
		private static function hasExtSDCard():Boolean
		{
			var paths:Array = ["/storage/sdcard1","/mnt/external",
				"/storage/extSdCard","/storage/emulated/1"];
			for each(var path:String in paths)
			{
				var fi:File = new File(path);
				if(fi.exists && fi.isDirectory && !fi.isSymbolicLink)
				{
					extSDCard.nativePath = path;
					return true;
				}
			}
			return false;
		}		
	}
}