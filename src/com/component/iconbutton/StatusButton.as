package com.component.iconbutton
{
	import spark.components.Button;
	
	public class StatusButton extends Button
	{
		public function StatusButton()
		{
			super();
			active = false;
			updateStatus();
		}
		
		private var _up:Class;
		private var _down:Class;
		private var _active:Boolean;
		
		private function updateStatus():void
		{
			if(this.active)
			{
				this.styleName = "ActiveButton";			
				if(up != null)
				{					
					this.setStyle("icon",up);
				}
			}
			else
			{
				this.styleName = "NormalButton";
				if(down != null)
				{					
					this.setStyle("icon",down);
				}
			}
			trace(active);
		}
		
		
		public function get up():Class
		{
			return _up;
		}

		public function set up(value:Class):void
		{
			_up = value;
		}

		public function get down():Class
		{
			return _down;
		}

		public function set down(value:Class):void
		{
			_down = value;
		}

		public function get active():Boolean
		{
			return _active;
		}

		public function set active(value:Boolean):void
		{
			_active = value;
			updateStatus();
		}
	}
}