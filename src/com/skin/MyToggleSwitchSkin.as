package com.skin
{
	import spark.skins.mobile.ToggleSwitchSkin;
	
	public class MyToggleSwitchSkin extends ToggleSwitchSkin
	{
		public function MyToggleSwitchSkin()
		{
			super();
			// Set properties to define the labels 
			// for the selected and unselected positions.
			selectedLabel="";
			unselectedLabel=""; 
		}
	}
}