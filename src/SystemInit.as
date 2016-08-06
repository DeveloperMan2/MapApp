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
				
				for each (var path:String in paths) 
				{
					var file:File = RootDirectory.root.resolvePath(path);					
					file.createDirectory();
				}
			}
		}
	}
}
