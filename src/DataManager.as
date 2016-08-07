package
{
	import com.component.iconbutton.ButtonItem;
	import com.mapping.MBTilesLayerEx;
	import com.mapping.TiledTDTLayer;
	import com.supermap.web.core.Rectangle2D;
	import com.supermap.web.mapping.Map;
	import com.supermap.web.mapping.OfflineStorage;
	import com.supermap.web.mapping.TiledCachedLayer;
	import com.util.AppEvent;
	import com.util.Coordinate;
	import com.util.RootDirectory;
	import com.util.SystemConfigUtil;
	import com.vo.BrowseVO;
	import com.vo.MainVO;
	import com.vo.MapVO;
	
	import flash.events.FileListEvent;
	import flash.filesystem.File;
	
	import mx.collections.ArrayCollection;
	import mx.core.IVisualElement;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.transitions.CrossFadeViewTransition;
	import spark.transitions.SlideViewTransition;
	import spark.transitions.ViewTransitionBase;
	
	import dpi.Dpi160;
	import dpi.Dpi240;
	import dpi.Dpi320;
	import dpi.Dpi480;
	
	/**系统数据管理类*/
	[Bindable]
	public class DataManager
	{
		private static var dm:DataManager;
		
		public static function getInstance():DataManager
		{
			if(dm == null)
			{
				dm = new DataManager();
			}
			return dm;
		}
		
		//单例模式
		public function DataManager()
		{
			if(dm != null)
			{
				throw new Error("不能通过该方式创建类型的实例，请采用静态方法getInstance()初始化对象！");
			}
		}	
		
		/**系统默认的离线影像数据目录*/
		public var defaultMbTilesDir:File = null;
		/**用户设定的离线影像数据目录*/
		public var customMbTilesDir:File = null;
		
		/** iOS预读数据状态 
		 * Android设备上值为0.
		 * iOS设备默认为-1，
		 * iOS设备联网失败为-2，
		 * iOS设备下载数据失败后为-3，
		 * iOS设备读取数据失败为-4
		 * 
		 * */
		public var iOSDataState:int = 0;
		
		/**多分辨率缩放参数,采用DPI240作为基数*/
		public var multiResolution:Number = 1; 
		
		/**地图UI缩放级别,需要根据设备调整*/
		public var mapUIScale:Number = 1;
		
		/**APP UI 顶部面板高度*/
		public var headerHeight:Number = 72;
		
		/**系统图标缩放级别,采用dpi240作为基数*/
		public var appIconScale:Number = 1; 
		
		/**系统图标缩放级别,采用dpi240,48px作为基数*/
		public var appIconSize:Number = 48;
		
		/**系统字体缩放级别,采用dpi240,32作为基数*/
		public var appFontSize:Number = 32;
		
		/**系统图标集装箱*/
		public var iconAssembly:*;
		
		/**系统是否已经登录*/
		public var isLogined:Boolean = false;
		
		/**移动设备网络变更*/
		public var isNetChange:Boolean = false;
		
		//系统服务地址
		public var uploadService:String;
		//用户登录服务地址
		public var userLoginService:String;
		
		/**存储上传对象*/
		public var uploadList:ArrayCollection = null;
		
		//VO实例
		public var mapVo:MapVO = new MapVO();
		
		/**地图对象*/
		public var map:Map = null;
		/**地图显示区域*/
		public var mapRect:Rectangle2D = null;
		
		/**影像底图*/
		public var imageBaseLayer:TiledCachedLayer=null;
		/**矢量底图*/
		public var vectorBaseLayer:TiledCachedLayer = null;
		/**矢量底图标注*/
		public var vectorLabelBaseLayer:TiledCachedLayer = null;
		
		/**离线影像图层列表*/
		public var ImgLayerArrCol:ArrayCollection = null;
		
		
		/**系统配置数据查询对象*/
		private var systemConfigUtil:SystemConfigUtil;
		
		public var mapViewBounds:Rectangle2D;
		
		/**
		 * 
		 * 
		 *初始化系统运行参数 
		 * @param dpi:移动设备运行DPi
		 */
		public function initAppParam(dpi:Number=240):void
		{
			multiResolution = dpi/240;
			mapUIScale = 1.0 * multiResolution;
			headerHeight = headerHeight * multiResolution;
			appIconScale = multiResolution/mapUIScale;
			appIconSize = appIconSize*appIconScale;
			appFontSize = appFontSize*appIconScale;
			
		}
		
		/**
		 *初始化地图 
		 * @param map
		 */
		public function initMap(map:Map):void
		{
			var resolutions:Array = [];
			for(var i:int=-1 ; i<=18;i++){
				resolutions.push(156543.0339/2/Math.pow(2,i));
			}
			map.resolutions = resolutions;
			this.map = map;
		}
		
		/**
		 *重置地图位置 
		 * 
		 */
		public function resetMapPosition(rect:Rectangle2D):void
		{
			this.mapViewBounds = this.map.viewBounds = rect;
		}
		
		/**
		 *加载离线地图 
		 * @param layVo
		 * 
		 */
		public function addMbLayer(bVo:Object):void
		{
			var systemMbitlesPath:String = querySystemMbtilesFolderPath();
			var layerUrl:String;
			if (systemMbitlesPath != null || systemMbitlesPath.length > 0) {
				var mbtilesFolder:File = File.applicationDirectory.resolvePath(systemMbitlesPath);
				if (mbtilesFolder.exists && mbtilesFolder.isDirectory) {
					layerUrl = systemMbitlesPath.charAt(systemMbitlesPath.length -1 ) == File.separator ? systemMbitlesPath + bVo.path : systemMbitlesPath +File.separator+ bVo.path;
				}
			} 
			if (layerUrl == null) {
				layerUrl =  RootDirectory.extSDCard.resolvePath(MainVO.MbMapsRootPath+bVo.path).nativePath;
			}
			
			if(this.imageBaseLayer != null)
			{
				(this.imageBaseLayer as MBTilesLayerEx).mbtilesPath =layerUrl
				this.map.refresh();
			}
			else
			{
				var mbtilesLayer:MBTilesLayerEx;
				mbtilesLayer = new MBTilesLayerEx();
				mbtilesLayer.mbtilesPath = layerUrl;
				this.map.addLayer(mbtilesLayer);
				this.imageBaseLayer = mbtilesLayer;
			}
			dm.resetMapPosition(imageBaseLayer.bounds);
		}
		
		/**
		 *加载天地图 
		 * 
		 */
		public function addTdtLayer():void
		{
			var superOfflineStorage:OfflineStorage = new OfflineStorage();
			superOfflineStorage.userRootDirectory = MainVO.CachesRootPath + "tdt";
			
			var tdtLayer:TiledTDTLayer = new TiledTDTLayer();
			tdtLayer.projection = "10010";
			tdtLayer.offlineStorage = superOfflineStorage;
			map.addLayer(tdtLayer);
			
			var superLabelOfflineStorage:OfflineStorage = new OfflineStorage();
			superLabelOfflineStorage.userRootDirectory = MainVO.CachesRootPath + "tdtLabel";
			
			var tdtLabelLayer:TiledTDTLayer = new TiledTDTLayer();
			tdtLabelLayer.projection = "10010";
			tdtLabelLayer.offlineStorage = superLabelOfflineStorage;
			tdtLabelLayer.isLabel = true;
			map.addLayer(tdtLabelLayer);
			
			this.vectorBaseLayer = tdtLayer;
			this.vectorLabelBaseLayer = tdtLabelLayer;
			
//			var mbtilesLayer:MBTilesLayerEx = new MBTilesLayerEx();
//			mbtilesLayer.mbtilesPath = "/storage/sdcard1/outsd/mappng15.mbtiles";
//			mbtilesLayer.bounds =  new Rectangle2D(Coordinate.lon2Mercator(116.091343), Coordinate.lat2Mercator(29.738883), Coordinate.lon2Mercator(116.209089),Coordinate.lat2Mercator(29.760974));
//			mbtilesLayer.origin = new Point2D(-20037508.3392, 20037508.3392);
//			map.addLayer(mbtilesLayer);
		}
		
		/**视图切换特效*/
		public function getTransition(name:String="cross"):ViewTransitionBase
		{
			var comTransition:ViewTransitionBase = null;
			switch(name)
			{
				case "slider":
				{
					comTransition = new SlideViewTransition();
					break;
				}
				case "cross":
				{
					comTransition = new CrossFadeViewTransition();
					break;
				}
				default:
				{
					comTransition = new CrossFadeViewTransition();
					break;
				}
			}
			comTransition.duration = 5;
			//var bounce:Bounce = new Bounce();
			//var sine:Sine = new Sine();
			//var linear:Linear = new Linear();
			//comTransition.easer = sine;
			return comTransition;
		}
		
		/**初始化App图层数据*/
		public function initAppLayerCol():void
		{
			//			var directory:File = null;
			//			/**在支持支持SDCard的设备上查找离线缓存-外置SD卡*/
			//			if(RootDirectory.hasExtSDCard())
			//			{
			//				//此处存在外置SD卡访问的写权限问题
			//				directory = RootDirectory.extSDCard.resolvePath(MainVO.MbMapsRootPath); 
			//			}
			//			else
			//			{
			//				/**在内置SD上查找离线缓存-内置SD卡*/
			//				directory = RootDirectory.root.resolvePath(MainVO.MbMapsRootPath); 
			//			}
			//			findOfflineMap(directory);
			
			//直接访问内置SD卡
			var directory:File = RootDirectory.root.resolvePath(MainVO.MbMapsRootPath); 
			this.defaultMbTilesDir = directory;
			
			findOfflineMap(directory);
		}
		
		//异步加载影像离线地图列表
		public function findOfflineMap(_directory:File):void{
			if(_directory.exists)
			{
				_directory.getDirectoryListingAsync(); 
				_directory.addEventListener(FileListEvent.DIRECTORY_LISTING, dirImageLayerListHandler); 
			}
		}
		
		private function dirImageLayerListHandler(event:FileListEvent):void 
		{ 
			var contents:Array = event.files; 
			var len:int = contents.length;
			if(len > 0)
			{
				ImgLayerArrCol = new ArrayCollection();
				for (var i:uint = 0; i < len; i++)  
				{ 
					var item:Object = contents[i];
					if(!item["isDirectory"])
					{
						var bvo:BrowseVO = new BrowseVO();
						bvo.layerName = item["name"].toString().substr(0, item["name"].toString().indexOf("."));
						bvo.layerUrl = item["nativePath"];
						bvo.extension = item["type"];
						if(bvo.extension == ".mbtiles")
						{
							ImgLayerArrCol.addItem(bvo);
						}
					}
				} 
				
				AppEvent.dispatch(AppEvent.MB_DATACHANGE);
			}
		}
		
		/**高亮置顶按钮（按钮处于选中状态）*/
		public function highlightSelectedItem(item:ButtonItem, container:Group):void
		{
			if(item != null && container != null)
			{
				var num:int = container.numElements;
				for (var i:int = 0; i < num; i++) 
				{
					var element:IVisualElement = container.getElementAt(i);
					if(element is Button)
					{
						var bi:ButtonItem = element as ButtonItem;
						if(bi != item)
						{
							bi.keepSelected = false;
							bi.invalidateSkinState();
						}
						else
						{
							bi.keepSelected = true;
							bi.invalidateSkinState();
						}
					}
				}
			}
		}
		
		//图标库
		private var iconCol:Array=[];
		public function registerIcon(key:String, iconClass:Class):void
		{
			var iconObj:Object = {};
			iconObj["key"] = key;
			iconObj["icon"] = iconClass;
			iconCol.push(iconObj);
		}
		
		/**获取指定Key的图标*/
		public function getIconByKey(key:String):Class
		{
			var icon:Class = null;
			if(iconCol.length > 0)
			{
				for each (var iconObj:Object in iconCol) 
				{
					if(key == iconObj["key"])
					{
						icon = iconObj["icon"];
						break;
					}
				}
				
			}
			return icon;
		}
		
		/**加载图标工具箱*/
		public function loadIconAssembly(dpi:Number):void
		{
			/*trace("dpi=" + dpi);
			trace("Capabilities.screenDPI=" + Capabilities.screenDPI);
			trace("FlexGlobals.topLevelApplication.runtimeDPI=" + FlexGlobals.topLevelApplication.runtimeDPI);*/
			switch(dpi)
			{
				case 160:
				{
					//iconSize width=24, 24, 42, 54, 54
					//--数值说明（按顺序）： 常用图标，地图面板子菜单图标， 图层切换图标， 图层切换关闭按钮图标， APP功能区按钮图标
					iconAssembly = new Dpi160();
					break;
				}
				case 240:
				{
					//iconSize width=36, 36, 64, 80, 96
					iconAssembly = new Dpi240();
					break;
				}
				case 320:
				{
					//iconSize width=48, 48, 96, 106, 128
					iconAssembly = new Dpi320();
					break;
				}
				case 480:
				{
					//iconSize width=72, 72, 128, 160, 192
					iconAssembly = new Dpi480();
					break;
				}
				default:
				{
					iconAssembly = new Dpi240();
					break;
				}
			}
		}
		
		//获取系统影像文件mbtiles文件路径，通过system.db查询
		private function querySystemMbtilesFolderPath():String
		{
			if (systemConfigUtil == null) {
				
				var destinaPath:String = MainVO.DataCacheRootPath + MainVO.SystemDBFileName;
				var destinaSystemDbFile:File = RootDirectory.extSDCard.resolvePath(destinaPath);
				if (destinaSystemDbFile.exists == false) {
					var originSystemDbFile:File = File.applicationDirectory.resolvePath(MainVO.OriginDBPath+MainVO.SystemDBFileName);
					destinaSystemDbFile.parent.createDirectory();
					originSystemDbFile.copyTo(destinaSystemDbFile,true);
				}
				
				systemConfigUtil = new SystemConfigUtil(destinaSystemDbFile.nativePath);
				systemConfigUtil.open();
			}
			return systemConfigUtil.queryMbtilesFolderPath();
		}
	}
}