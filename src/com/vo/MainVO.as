package com.vo
{
	import flash.filesystem.File;
	public class MainVO extends BaseVO
	{
		public function MainVO()
		{
		}
		
		private static const RootPath:String = "MapApp"+File.separator;
		
		/**系统配置数据库文件路径*/
		public static const SystemConfigPath:String = RootPath + "Configs"+File.separator;
		
		/**在线地图缓存路径*/
//		public static const CachesRootPath:String = RootPath + "MapCaches"+File.separator;
		
		/**天地图底图mbtiles文件存放文件夹*/
		public static const TDTBaseMapMbtilesFolder:String = "tdt"+File.separator + "basemap";
		
		/**天地图底图注记mbtiles文件存放文件夹*/
		public static const TDTBaseLabelMbtilesFolder:String = "tdt"+File.separator + "baselabel";
		
		/**离线地图缓存路径*/
		public static const MbMapsRootPath:String = "MbMaps"+File.separator;
		
		/**查询数据文件系统原始路径*/
		public static const OriginDBPath:String = "query" + File.separator;
		
		/**查询数据库文件名称*/
		public static const QueryDBFileName:String= "imageinfo.db";
		
		/**系统配置数据库文件名称*/
		public static const SystemDBFileName:String = "system.db"; 
	}
}