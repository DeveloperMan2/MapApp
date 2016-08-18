package  com.mapping
{
	import com.supermap.web.sm_internal;
	import com.supermap.web.core.Point2D;
	import com.supermap.web.mapping.ImageFormat;
	import com.supermap.web.mapping.TiledCachedLayer;
	import com.supermap.web.mapping.supportClasses.MetadataObj;
	import com.util.AppEvent;
	import com.util.Coordinate;
	
	import flash.utils.ByteArray;
	
	use namespace sm_internal;
	
	public class MBTilesLayerEx extends TiledCachedLayer
	{
		public var layerType:int = 0;
		public var layerIndex:int = 0;
		
		private var _mbtilesPath:String = "";
		private var _mbtilesHelper:MBTilesUtilEx;
		private var _metadataObj:MetadataObj;
		private var _compatible:Boolean;
		
		private var _minzoom:int = -1;
		private var _maxzoom:int = -1;
		
		public function MBTilesLayerEx()
		{
			_offlineFilestored = true;
			return;
		}
		
		public function set mbtilesPath(value:String) : void
		{
			this._mbtilesPath = value;
			if (this._mbtilesPath == null || this._mbtilesPath == "") {
				this._mbtilesHelper = null;
				removeAllChildren();
				setLoaded(true);
			} else {
				this._mbtilesHelper = new MBTilesUtilEx(this._mbtilesPath);
				if (this._mbtilesHelper.open())
				{
					this._metadataObj = this._mbtilesHelper.readMetadataObj();
					if (this._metadataObj != null)
					{
						if (this._metadataObj.bounds.width <= 360) {
							this.bounds =  Coordinate.rectangle2DToMercator(this._metadataObj.bounds);
						} else {
							this.bounds  = this._metadataObj.bounds;
						}
						this.origin = new Point2D(-20037508.342787,  20037508.342787);
						this._minzoom = this._metadataObj.minzoom;
						this._maxzoom = this._metadataObj.maxzoom;
						this.tileSize = 256; //this._metadataObj.tileSize ;
						this.imageFormat = this._metadataObj.format.toLowerCase() == "jpg" ? (ImageFormat.JPG) : (ImageFormat.PNG);
						//	this.CRS = new CoordinateReferenceSystem(this._metadataObj.crs_wkid, this._metadataObj.unit);
						setLoaded(true);					
					}
					else
					{
						AppEvent.dispatch(AppEvent.APP_ERROR,"地图元数据错误");
						throw new Error("数据错误");
					}
				}
				else
				{
					AppEvent.dispatch(AppEvent.APP_ERROR,"离线数据包路径设置错误");
					throw new Error("离线数据包路径设置错误");
				}
			}
		}
		
		override protected function addMapListeners():void
		{
			super.addMapListeners();
			if (map != null) {
				this.resolutions =  map.resolutions;
			}
		}
		
		override protected function getLocalTile(row:int, col:int, level:int) : ByteArray
		{
			if (_mbtilesHelper == null || this._mbtilesHelper.opened == false)
			{
				return null;
			}
			
//			if (_minzoom >= 0 && level < _minzoom) {
//				return null;
//			}
//			
//			if (_maxzoom > 0 && level > _maxzoom) {
//				return null;
//			}
			
			row = Math.pow(2, level) - row - 1;
			var byteArray:ByteArray = this._mbtilesHelper.getTile(row, col, level);
			return byteArray;
		}
	}
}