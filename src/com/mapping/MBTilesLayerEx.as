package  com.mapping
{
	import com.supermap.web.sm_internal;
	import com.supermap.web.core.Point2D;
	import com.supermap.web.core.Rectangle2D;
	import com.supermap.web.mapping.ImageFormat;
	import com.supermap.web.mapping.TiledCachedLayer;
	import com.supermap.web.mapping.supportClasses.MetadataObj;
	import com.util.Coordinate;
	
	import flash.display.BitmapData;
	import flash.utils.ByteArray;
	
	import mx.graphics.codec.PNGEncoder;
	
	import spark.components.Image;
	
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
					if (this._metadataObj.bounds.width <= 360) {
						this.bounds =  Coordinate.rectangle2DToMercator(this._metadataObj.bounds);
					} else {
						this.bounds  = this._metadataObj.bounds;
					}
					this.origin = new Point2D(-20037508.342787,  20037508.342787);
					this.tileSize = 256; //this._metadataObj.tileSize ;
					this.imageFormat = this._metadataObj.format.toLowerCase() == "jpg" ? (ImageFormat.JPG) : (ImageFormat.PNG);
					//					this.CRS = new CoordinateReferenceSystem(this._metadataObj.crs_wkid, this._metadataObj.unit);
					setLoaded(true);					
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
		
		
		override protected function getLocalTile(row:int, col:int, level:int) : ByteArray
		{
			if (this._mbtilesPath != "" && this._mbtilesHelper != null &&  this._mbtilesHelper.opened && map.level <0)
			{
				return null;
			}
			row = Math.pow(2, level) - row - 1;
			var byteArray:ByteArray = this._mbtilesHelper.getTile(row, col, level);
//			if (byteArray !=null) {
//				var pngEncode:PNGEncoder = new PNGEncoder();
//				byteArray = pngEncode.encodeByteArray(byteArray,256,256,true);
//			}
			return byteArray;
		}// end function
		
		public static function ByteArrayToBitmap(byArr:ByteArray):ByteArray{   
			if(byArr==null){   
				return null;   
			}   
			//读取出存入时图片的高和宽,因为是最后存入的数据,所以需要到尾部读取   
			var bmd:ByteArray= byArr;   
			var image:Image = new Image()
			image.source = bmd;
			var srcBmp:BitmapData = new BitmapData( 256, 256 );   
			//将组件读取为BitmapData对象，bitmagData的数据源   
			srcBmp.draw( image );   
			var encoder:PNGEncoder = new PNGEncoder(); 
			var bytes:ByteArray = encoder.encode(srcBmp); 
			return bytes; 
		}   
	}
}