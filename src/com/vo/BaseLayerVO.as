package com.vo
{
	public class BaseLayerVO extends BaseVO
	{
		public function BaseLayerVO()
		{
			super();
		}
		
		/**地图服务地址*/
		public var baseLayerUrl:String;
		
		/**地图标注服务地址*/
		public var baseLabelLayerUrl:String;
		
		/**地图名称*/
		public var baseLayerName:String;
		
		/**底图为影像时，要素服务地址*/
		public var featureLayerForImageUrl:String;
		
		/**底图为矢量时，要素服务地址*/
		public var featureLayerForVectorUrl:String;
	}
}