package com.component.label
{
	import spark.components.Label;
	
	public class LabelItem extends Label
	{
		private var _params:Object;
		public function LabelItem()
		{
			super();
		}

		/**标签附属参数*/
		public function get params():Object
		{
			return _params;
		}

		public function set params(value:Object):void
		{
			_params = value;
		}

	}
}