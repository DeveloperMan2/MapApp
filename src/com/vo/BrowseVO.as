package com.vo
{
	public class BrowseVO extends BaseVO
	{
		public function BrowseVO()
		{
		}
		
		/**图层名称*/
		public var layerName:String;
		
		/**图层地址*/
		public var layerUrl:String;
		
		/**图层类型*/
		public var layerType:String;
		
		/**文件后缀*/
		public var extension:String;
	}
}