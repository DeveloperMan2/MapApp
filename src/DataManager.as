package
{
	import com.component.iconbutton.ButtonItem;
	import com.component.map.MapCtrl;
	import com.mapping.FeaturesLayerEx;
	import com.mapping.MBTilesLayerEx;
	import com.supermap.web.core.Feature;
	import com.supermap.web.core.Rectangle2D;
	import com.supermap.web.core.geometry.GeoPoint;
	import com.supermap.web.core.styles.TextStyle;
	import com.supermap.web.mapping.FeaturesLayer;
	import com.supermap.web.mapping.Layer;
	import com.supermap.web.utils.ScaleUtil;
	import com.util.AppEvent;
	import com.util.Coordinate;
	import com.util.QueryUtil;
	import com.util.RootDirectory;
	import com.util.SystemConfigUtil;
	import com.vo.BrowseVO;
	import com.vo.ConstVO;
	import com.vo.MainVO;
	import com.vo.MapVO;
	
	import flash.events.FileListEvent;
	import flash.filesystem.File;
	import flash.text.TextFormat;
	
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
		
		/**APP标题*/
		public var systemTitle:String="地图浏览";
		
		/**系统默认的离线影像数据目录*/
		//	public var defaultMbTilesDir:File = null;
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
		public var map:MapCtrl = null;
		/**地图显示区域*/
		public var mapRect:Rectangle2D = null;
		
		/**影像底图*/
		public var imageBaseLayer:MBTilesLayerEx=null;
		
		/**注记图层*/
		public var mark1Layer:FeaturesLayerEx = null;
		public var mark2Layer:FeaturesLayerEx = null;
		
		/**离线影像图层列表*/
		public var ImgLayerArrCol:ArrayCollection = null;
		
		
		/**系统配置数据查询对象*/
		private var _systemConfigUtil:SystemConfigUtil;
		
		/**系统查询对象*/
		private var _queryUtil:QueryUtil;
		
		public var mapViewBounds:Rectangle2D;
		
		public var mark1Color:Number;
		public var mark1Size:int;
		public var mark2Color:Number;
		public var mark2Size:int;
		
		/**
		 *初始化系统运行参数 
		 * @param dpi:移动设备运行DPi
		 */
		public function initAppParam(dpi:Number=240):void
		{
			multiResolution = Math.ceil(dpi/240);
			mapUIScale = 1.0 * multiResolution;
			headerHeight = headerHeight * multiResolution;
			appIconScale = multiResolution/mapUIScale;
			appIconSize = appIconSize*appIconScale;
			appFontSize = appFontSize*appIconScale;
		}
		
		/**
		 *初始化地图 ,地图图层
		 * @param map
		 */
		public function initMapLayer(map:MapCtrl):void
		{
			this.map = map;
			addTDTLayer();
			
			//初始化影像
			imageBaseLayer = new MBTilesLayerEx();
			imageBaseLayer.layerType = 1;
			map.addLayer(imageBaseLayer);
			
			//初始化两个注记图层
			mark1Layer = new FeaturesLayerEx();
			mark1Layer.layerType = 3;
			mark1Layer.layerIndex = 0;
			mark1Layer.isPanEnableOnFeature = true;
			mark1Layer.visible = false;
			map.addLayer(mark1Layer);
			
			mark2Layer = new FeaturesLayerEx();
			mark2Layer.layerType = 3;
			mark2Layer.layerIndex = 1;
			mark2Layer.isPanEnableOnFeature = true;
			mark2Layer.visible = false;
			map.addLayer(mark2Layer);
			
			map.sortLayers(["layerType","layerIndex"], null,[true,true]);
		}
		
		//设置地图比例尺
		private function initMapResolutions():void
		{
			var resolutions:Array = [];
			var scales:Array = [];
			var resolution:Number;
			var scale:Number;
			for(var i:int=0 ; i<= 20;i++){
				resolution = 156543.0339/Math.pow(2,i);
				scale = ScaleUtil.resolutionToScale(resolution,96,"meter");
				resolutions.push(resolution);
				scales.push(scale);
			}
			map.resolutions = resolutions;
			map.scales = scales;
		}
		
		//显示天地图
		public function addTDTLayer():void
		{
			removeTDTLayer();
			
			initMapResolutions();
			
			//初始化天地图底图,对应多个地图文件
			var tdtBaseMapMbtilesPath:String = getSystemConfigMbtilesPath() + MainVO.TDTBaseMapMbtilesFolder;
			var tdtBaseMapMbtilesFile:File = File.documentsDirectory.resolvePath(tdtBaseMapMbtilesPath);
			if (tdtBaseMapMbtilesFile.exists == false || tdtBaseMapMbtilesFile.isDirectory == false) {
				tdtBaseMapMbtilesFile.createDirectory();
				AppEvent.dispatch(AppEvent.APP_ERROR, "没有底图文件夹");
				return;
			}
			var tdtBaseMapMbtileFileList:Array = tdtBaseMapMbtilesFile.getDirectoryListing();
			var fileItem:File;
			var temp:Array;
			var fileName:String;
			var postfix:String;
			var baseMapTdtLayer:MBTilesLayerEx;
			var layerId:int = 0;
			for each(fileItem in tdtBaseMapMbtileFileList) {
				if (fileItem.isDirectory == false) {
					temp =	fileItem.nativePath.split(File.separator);
					fileName = temp[temp.length-1];
					temp = fileName.split(".");
					if (temp.length == 2) {
						postfix = temp[1];
						if(postfix == ConstVO.postfixMbtiles) {
							baseMapTdtLayer = new MBTilesLayerEx();
							baseMapTdtLayer.mbtilesPath = fileItem.nativePath;
							baseMapTdtLayer.id = ConstVO.TdtLayerPostfix+layerId;
							baseMapTdtLayer.layerType = 0;
							map.addLayer(baseMapTdtLayer);
							layerId ++;
						}
					}
				}
			}
			if (layerId == 0) {
				AppEvent.dispatch(AppEvent.APP_ERROR, "底图文件数是零");
			}
			
			//初始化天地图注记,对应多个地图文件
			var tdtBaseLabelMbtilesPath:String = getSystemConfigMbtilesPath() + MainVO.TDTBaseLabelMbtilesFolder;
			var tdtBaseLabelMbtilesFile:File = File.documentsDirectory.resolvePath(tdtBaseLabelMbtilesPath);
			if (tdtBaseLabelMbtilesFile.exists == false || tdtBaseLabelMbtilesFile.isDirectory == false) {
				tdtBaseLabelMbtilesFile.createDirectory();
				AppEvent.dispatch(AppEvent.APP_ERROR, "没有底图注记文件夹");
				return;
			}
			var tdtBaseLabelMbtileFileList:Array = tdtBaseLabelMbtilesFile.getDirectoryListing();
			layerId = 0;
			for each( fileItem in tdtBaseLabelMbtileFileList) {
				if (fileItem.isDirectory == false) {
					temp =	fileItem.nativePath.split(File.separator);
					fileName = temp[temp.length-1];
					temp = fileName.split(".");
					if (temp.length == 2) {
						postfix = temp[1];
						if(postfix == ConstVO.postfixMbtiles) {
							baseMapTdtLayer = new MBTilesLayerEx();
							baseMapTdtLayer.mbtilesPath = fileItem.nativePath;
							baseMapTdtLayer.id = ConstVO.TdtLabelLayerPostfix +layerId;
							baseMapTdtLayer.layerType = 2;
							map.addLayer(baseMapTdtLayer);
							layerId ++;
						}
					}
				}
			}
			if (layerId == 0) {
				AppEvent.dispatch(AppEvent.APP_ERROR, "底图注记文件数是零");
			}
			map.sortLayers(["layerType","layerIndex"], null,[true,true]);
		}
		
		/**清除天地图*/
		private function removeTDTLayer():void
		{
			//先清除已有天地图图层
			var removeTdtLayer:Array = [];
			var layer:Layer
			for each( layer in map.layers) {
				if (layer is MBTilesLayerEx && (layer.id.search(ConstVO.TdtLayerPostfix) != -1 || layer.id.search(ConstVO.TdtLabelLayerPostfix) != -1)) {
					removeTdtLayer.push(layer);
				}
			}
			for each( layer in removeTdtLayer) {
				map.removeLayer(layer);
			}
		}
		
		/**
		 *重置地图位置 
		 */
		public function resetMapPosition(rect:Rectangle2D):void
		{
			this.mapViewBounds = this.map.viewBounds = rect;
		}
		
		/**
		 *加载影像离线地图 
		 * @param layVo
		 * 
		 */
		public function addMbLayer(bVo:Object):void
		{
			if (bVo != null) {
				var layerUrl:String = getSystemConfigMbtilesPath() +bVo.path;
				var mbtilesFolder:File = File.applicationDirectory.resolvePath(layerUrl);
				if (!mbtilesFolder.exists || mbtilesFolder.isDirectory) {
					imageBaseLayer.mbtilesPath = null;
					AppEvent.dispatch(AppEvent.APP_ERROR, bVo.path+"不存在");
					return
				}
				this.systemTitle = bVo["name"];//设置应用标题
				imageBaseLayer.mbtilesPath =layerUrl;
				var markStr:String = bVo["mark1"];
				creationMarkFeature(markStr, mark1Size, mark1Color, mark1Layer);
				
				markStr = bVo["mark2"];
				creationMarkFeature(markStr, mark2Size, mark2Color, mark2Layer);
				
				dm.resetMapPosition(imageBaseLayer.bounds);
			} else {
				imageBaseLayer.mbtilesPath = null;
				mark1Layer.clear();
				mark2Layer.clear();
			}
		}
		
		private function creationMarkFeature(markStr:String, markSize:int, markColor:uint, featureLayer:FeaturesLayer ):void
		{
			featureLayer.clear();
			if (markStr != null && markStr.length >0 ) {
				var maskStrs:Array = markStr.split(";");
				var textFormat:TextFormat = new TextFormat("嵌入字体", markSize*multiResolution, markColor);
				for each(var itemStr:String in maskStrs) {
					var parts:Array = itemStr.split(",");
					if (parts.length == 3) {
						if (parts[0] >=-180 && parts[0] <= 180 && parts[1] >= -90 && parts[1] <=90)
						{
							var geoPoint:GeoPoint = new GeoPoint(parts[0], parts[1]);
							geoPoint = Coordinate.geographicToMercator(geoPoint) as GeoPoint;
							var feature:Feature = new Feature(geoPoint);
							var textStyle:TextStyle = new TextStyle(parts[2], markColor);
							textStyle.size = markSize*multiResolution;
							textStyle.textFormat = textFormat;
							feature.style = textStyle;
							featureLayer.addFeature(feature);
						}
					}
				}
			}
		}
		
		/**
		 * 初始化注记样式
		 */
		public function initMarkSymbol():void
		{
			var markSymbolStr:String = getSystemConfigUtil().queryMarkSymbol();
			if (markSymbolStr != null && markSymbolStr.split(",").length == 4)
			{
				var marks:Array = markSymbolStr.split(",");
				mark1Color = parseInt(marks[0], 16);
				mark1Size = parseInt(marks[1]);
				mark2Color= parseInt(marks[2], 16);
				mark2Size = parseInt(marks[3]);
			}
		}
		
		/**
		 * 存储样式
		 */
		public function updateMarkSymbol():void
		{
			var markValues:Array = [convertString(mark1Color),mark1Size,convertString(mark2Color),mark2Size];
			var markValue:String = markValues.join(",");
			getSystemConfigUtil().updateMarkSymbol(markValue);
			refreshMarkLayer();
		}
		
		private function convertString(convertValue:Number,converLength:Number=6,leftChar:String="0x"):String
		{
			var convertNewValue:String = convertValue.toString(16);
			while(convertNewValue.length < converLength)
			{
				convertNewValue="0"+convertNewValue;
			}
			convertNewValue = leftChar + convertNewValue;
			return convertNewValue;
		}
		
		public function refreshMarkLayer():void
		{
			var  feature:Feature;
			var textStyle:TextStyle;
			for each(feature in mark1Layer.features) {
				textStyle = feature.style as TextStyle;
				textStyle.textFormat.color = mark1Color;
				textStyle.size = mark1Size*multiResolution;
			}
			for each(feature in mark2Layer.features) {
				textStyle = feature.style as TextStyle;
				textStyle.textFormat.color = mark2Color;
				textStyle.size = mark2Size*multiResolution;
			}
			mark1Layer.refresh();
			mark2Layer.refresh();
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
				
				AppEvent.dispatch(AppEvent.MBTILES_PATH_CHANGE);
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
		
		public function getSystemConfigUtil():SystemConfigUtil
		{
			//如果system.db没有配置路径，获取系统目录,复制查询的image.db
			if (_systemConfigUtil == null) {
				var destinaPath:String = MainVO.SystemConfigPath + MainVO.SystemDBFileName;
				var destinaSystemDbFile:File = File.documentsDirectory.resolvePath(destinaPath);
				var originSystemDbFile:File;
				if (destinaSystemDbFile.exists == false) {
					originSystemDbFile = File.applicationDirectory.resolvePath(MainVO.OriginDBPath+MainVO.SystemDBFileName);
					destinaSystemDbFile.parent.createDirectory();
					originSystemDbFile.copyTo(destinaSystemDbFile,true);
				}
				
				_systemConfigUtil = new SystemConfigUtil(destinaSystemDbFile.nativePath);
				if(_systemConfigUtil.open() == false) {
					AppEvent.dispatch(AppEvent.APP_ERROR, "打开系统数据失败");
				}
//				//针对新建的area表，如果系统运行的库里没有，删除库重新复制到系统里
//				if (_systemConfigUtil.queryCityList() == null) {
//					_systemConfigUtil.close();
//					originSystemDbFile = File.applicationDirectory.resolvePath(MainVO.OriginDBPath+MainVO.SystemDBFileName);
//					originSystemDbFile.copyTo(destinaSystemDbFile,true);
//				}
//				_systemConfigUtil = new SystemConfigUtil(destinaSystemDbFile.nativePath);
//				_systemConfigUtil.open();
			}
			return _systemConfigUtil;
		}
		
		//获取系统影像文件mbtiles文件路径，通过system.db查询
		public function getSystemConfigMbtilesPath():String
		{
			var mbtilesPath:String = getSystemConfigUtil().queryMbtilesFolderPath();
			if (mbtilesPath == "" || mbtilesPath == null || mbtilesPath == File.separator || mbtilesPath.length <= 1) {
				var mbtilesFile:File = File.documentsDirectory.resolvePath(MainVO.MbMapsRootPath);
				if (mbtilesFile.exists == false && mbtilesFile.isDirectory == false) {
					mbtilesFile.createDirectory();
				}
				mbtilesPath = File.documentsDirectory.nativePath;
				setSystemConfigMbtilesPath(mbtilesPath);
			}
			mbtilesPath = mbtilesPath.charAt(mbtilesPath.length - 1) == File.separator ? mbtilesPath+ MainVO.MbMapsRootPath : mbtilesPath + File.separator+ MainVO.MbMapsRootPath;
			
			return mbtilesPath;
		}
		
		private function resolveFileSeparate(path:String):void
		{
			if(path != null && path.lastIndexOf(File.separator) != path.length-1) {
				path = path + File.separator;
			}
		}
		
		//更新系统影像文件mbtiles文件路径，通过system.db查询
		public function setSystemConfigMbtilesPath(selectMbtilesPath:String):Boolean
		{
			var success:Boolean = getSystemConfigUtil().updateMbtilesFolderPath(selectMbtilesPath);
			return success;
		}
		
		/**初始化，关键字查询对象*/
		public function getQueryUtil(reload:Boolean = false):QueryUtil
		{
			//复制查询使用的数据库 , 判断文件是否存在，不存在进行复制操作
			if (_queryUtil == null || reload == true) {
				//路径是绝对路径
				var destinaPath:String = getSystemConfigMbtilesPath() + MainVO.QueryDBFileName;
				var destinaQueryDbFile:File = File.documentsDirectory.resolvePath(destinaPath);
				if (destinaQueryDbFile.exists == false) {
					AppEvent.dispatch(AppEvent.APP_ERROR, "无查询文件,系统复制查询文件");
					var originQueryDbFile:File = File.applicationDirectory.resolvePath(MainVO.OriginDBPath+MainVO.QueryDBFileName);
					destinaQueryDbFile.parent.createDirectory();
					originQueryDbFile.copyTo(destinaQueryDbFile,true);
				} 
				_queryUtil = new QueryUtil(destinaQueryDbFile.nativePath);
				if (_queryUtil.open() == false) {
					AppEvent.dispatch(AppEvent.APP_ERROR, "打开查询数据失败");
				}
			}
			return _queryUtil;
		}
	}
}