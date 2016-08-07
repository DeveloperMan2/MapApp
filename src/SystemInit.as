package
{
	import com.util.RootDirectory;
	import com.vo.MainVO;
	
	import flash.filesystem.File;

	public class SystemInit
	{
		public function SystemInit()
		{			
		}
		
		/**初始化手机目录
		 * 
		 * @param isCreate-isCreate-是否创建系统缓存目录，默认false*/
		public function initSystemDirectory(isCreate:Boolean=false):void
		{						
			if(isCreate)
			{	
				var paths:Array = [
					MainVO.MbMapsRootPath,
					MainVO.DataCacheRootPath,
					MainVO.CachesRootPath
				];	
				
				/**在内置SD上查找离线缓存-内置SD卡*/
				for each (var path:String in paths) 
				{
					var file:File = RootDirectory.root.resolvePath(path);					
					file.createDirectory();
				}
				
//				//在支持支持SDCard的设备上查找离线缓存-外置SD卡
//				if(RootDirectory.hasExtSDCard())
//				{
//					for each (var extpath:String in paths) 
//					{
						//此处有写权限问题，大部分设备都无法再外置SD卡上面创建文件夹
//						var extfile:File = RootDirectory.extSDCard.resolvePath(extpath);					
//						extfile.createDirectory();
//					}
//				}
//				else
//				{
//					//在内置SD上查找离线缓存-内置SD卡
//					for each (var path:String in paths) 
//					{
//						var file:File = RootDirectory.root.resolvePath(path);					
//						file.createDirectory();
//					}
//				}
			}
		}
	}
}
