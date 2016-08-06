package com.skin
{
	import com.component.iconbutton.IconButton;
	
	import spark.skins.mobile.ButtonSkin;

	public class IconButtonSkin extends ButtonSkin
	{
		private var _iconButton:IconButton;

		public function IconButtonSkin()
		{
			super();
			this.width = 43;
			this.height = 31;
		}

		override protected function getBorderClassForCurrentState():Class
		{
			if(!_iconButton)
			{
				_iconButton = this.parent as IconButton;
			}

			//此处需要判断是否down,up是否为空，如果为空，需要使用默认的值。
			if(currentState == "down")
				return _iconButton.down;
			else
				return _iconButton.up;
			
		}
	}
}
