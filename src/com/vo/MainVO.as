package com.vo
{
	import flash.filesystem.File;
	public class MainVO extends BaseVO
	{
		public function MainVO()
		{
		}
		
		private static const RootPath:String = "MapApp"+File.separator;
		
		/**数据离线缓存路径*/
		public static const DataCacheRootPath:String = RootPath + "Datas"+File.separator;
		
		/**在线地图缓存路径*/
		public static const CachesRootPath:String = RootPath + "MapCaches"+File.separator;
		
		/**离线地图缓存路径*/
		public static const MbMapsRootPath:String = RootPath + "MbMaps"+File.separator;
		
		/**查询数据文件系统原始路径*/
		public static const QueryOriginPath:String = "query";
		
		/**查询数据库文件名称*/
		public static const QueryDBFileName:String= "imageinfo.db";
	}
}