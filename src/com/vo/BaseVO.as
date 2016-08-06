package com.vo
{
	[Bindable]
	public class BaseVO
	{
		public function BaseVO()
		{
		}
		/**
		 *系统公用文件数据库 
		 */
		public static const SystemDbName:String = "System.db";
		private var _userId:String="";
		private var _pageIndex:int = -1;
		private var _pageSize:int = -1;
		private var _pageCount:int = -1;
		private var _totalCount:int = 0;
		
		/**系统用户ID*/
		public function get userId():String
		{
			return _userId;
		}

		public function set userId(value:String):void
		{
			_userId = value;
		}

		/**查询记录总数*/
		public function get totalCount():int
		{
			return _totalCount;
		}
		
		public function set totalCount(value:int):void
		{
			_totalCount = value;
		}
		
		/**结果页面总数*/
		public function get pageCount():int
		{
			return _pageCount;
		}
		
		public function set pageCount(value:int):void
		{
			_pageCount = value;
		}
		
		/**每页记录数*/
		public function get pageSize():int
		{
			return _pageSize;
		}
		
		public function set pageSize(value:int):void
		{
			_pageSize = value;
		}
		
		/**当前页面索引*/
		public function get pageIndex():int
		{
			return _pageIndex;
		}
		
		public function set pageIndex(value:int):void
		{
			_pageIndex = value;
		}
		
	}
}