package com.vo
{
	import com.supermap.web.core.Rectangle2D;

	[Bindable]
	public class MapVO extends BaseVO
	{
		public function MapVO()
		{
			super();
		}
		/**影像类型*/
		public const JxImageLayer:String = "JxImageLayer";
		/**2.5影像类型*/
		public const Jx25ImageLayer:String = "Jx25ImageLayer";
		/**矢量类型*/
		public const JxVectorLayer:String = "JxVectorLayer";
		
		/**地图窗口视域范围*/
		public var viewBounds:Rectangle2D = new Rectangle2D(113.95,24.99,117.23,30.12);
		
		/**地图范围*/
		public var bounds:Rectangle2D = new Rectangle2D(-180,-90,180,90);
		
		/**地图比例尺*/
		public var scales:Array = [];
		
		/**地图分辨率*/
		public var resolutions:Array = [];
		
		/**江西水利厅发布天地图矢量*/
		public var jxTDTVector:BaseLayerVO = new BaseLayerVO();
		
		/**江西水利厅发布天地图影像*/
		public var jxTDTImage:BaseLayerVO = new BaseLayerVO();
		
		/**江西2.5米影像*/
		public var jx25Image:BaseLayerVO = new BaseLayerVO();
		
		/**江西全要素专题*/
		public var jxFeatureLayer:BaseLayerVO = new BaseLayerVO();
		
		/**江西交通地图*/
		public var jxTrafficLayer:BaseLayerVO = new BaseLayerVO();
		
		/**江西湖泊河流图层*/
		public var jxLakeRiverLayer:BaseLayerVO = new BaseLayerVO();
		
		/**最佳缩放级别*/
		public var bestZoomLevel:int = resolutions.length - 2;
	}
}