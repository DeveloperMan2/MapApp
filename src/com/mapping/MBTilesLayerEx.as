package  com.mapping
{
	import com.supermap.web.core.Point2D;
	import com.supermap.web.mapping.ImageFormat;
	import com.supermap.web.mapping.TiledCachedLayer;
	import com.supermap.web.mapping.supportClasses.MetadataObj;
	import com.supermap.web.sm_internal;
	import com.supermap.web.utils.CoordinateReferenceSystem;
	
	import flash.utils.ByteArray;
	
	use namespace sm_internal;
	
	public class MBTilesLayerEx extends TiledCachedLayer
	{
		private var _mbtilesPath:String = "";
		private var _mbtilesHelper:MBTilesUtilEx;
		private var _metadataObj:MetadataObj;
		private var _compatible:Boolean;
		
		//		private var dm:DataManager = DataManager.getInstance();
		
		public function MBTilesLayerEx()
		{
			_offlineFilestored = true;
			return;
		}// end function
		
		public function set mbtilesPath(value:String) : void
		{
			this._mbtilesPath = value;
			this._mbtilesHelper = new MBTilesUtilEx(this._mbtilesPath);
			if (this._mbtilesHelper.open())
			{
				this._metadataObj = this._mbtilesHelper.readMetadataObj();
				if (this._metadataObj != null)
				{
					//		this.bounds =  this._metadataObj.bounds;
					//					this.resolutions = this._metadataObj.resolutions;				
					//	this.scales = this._metadataObj.scales;					
					//					this.origin = new Point2D(this.bounds.left, this.bounds.top);
					//    this.origin = new Point2D(-20037508.3392,20037508.3392);
					this._compatible = this._metadataObj.compatible;
					this.tileSize = this._metadataObj.tileSize;
					this.imageFormat = this._metadataObj.format.toLowerCase() == "jpg" ? (ImageFormat.JPG) : (ImageFormat.PNG);
					this.CRS = new CoordinateReferenceSystem(this._metadataObj.crs_wkid, this._metadataObj.unit);
					
					//					dm.mapVo.bounds = this.bounds;
					//					dm.mapVo.resolutions = this.resolutions;
					//					dm.map.resolutions = dm.mapVo.resolutions;					
					setLoaded(true);					
					
					// debug
					//dm.map.resolutions = this.resolutions;
				}
				else
				{
					throw new Error("数据错误");
				}
			}
			else
			{
				throw new Error("离线数据包路径设置错误");
			}
			return;
		}// end function
		
		override protected function addMapListeners():void
		{
			super.addMapListeners();
			if (map != null) {
				this.resolutions = map.resolutions;
			}
		}
		
//		override protected function getLocalTile(row:int, col:int, level:int) : ByteArray
//		{
//			if (this._mbtilesPath != "" && this._mbtilesHelper != null &&  this._mbtilesHelper.opened && level < 0)
//			{
//				return null;
//			}
//			var ret:ByteArray = null;
//			var _loc_4:Number = this.resolutions[level];
//			if (!this._compatible)
//			{
//				return this._mbtilesHelper.getTile(row, col, level);
//			}
//			return this._mbtilesHelper.getTile(Math.pow(2, level) - row - 1, col, _loc_4);
//			
//		}
		
		override protected function getLocalTile(row:int, col:int, level:int) : ByteArray
		{
			if (this._mbtilesPath != "" && this._mbtilesHelper != null &&  this._mbtilesHelper.opened && map.level <0)
			{
				return null;
			}
			var tile_id:String = level+"/"+col+"/"+row;
				return this._mbtilesHelper.getTile("images",tile_id,"tile_id","tile_data");
		}// end function
	}
}