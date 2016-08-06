package com.component.iconbutton
{
	import spark.components.Button;
	
	public class IconButton extends Button
	{
		private var _up:Class;
		private var _down:Class;
		
		public function IconButton()
		{
			super();
		}

		public function get down():Class
		{
			return _down;
		}

		public function set down(value:Class):void
		{
			_down = value;
		}

		public function get up():Class
		{
			return _up;
		}

		public function set up(value:Class):void
		{
			_up = value;
		}
	}
}