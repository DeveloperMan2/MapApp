package com.skin
{
	import mx.core.DPIClassification;
	
	import spark.skins.mobile.CalloutSkin;
	
	public class BoxyCalloutSkin extends CalloutSkin
	{
		public function BoxyCalloutSkin()
		{
			super();
			
			// this skin does not implement contentBackgroundAppearance=inset
			contentBackgroundInsetClass = null;
			
			// disable drop shadow
			dropShadowVisible = true;
			
			// disable backgroundColor gradient fill
			useBackgroundGradient = false;
			
			// square up the corners
//			contentCornerRadius = 3;
//			backgroundCornerRadius = 3;
			
			// backgroundColor frame is not visible
			frameThickness = 0;
			
			// add border properties (by default this is NaN, no border)
			borderThickness = 2;
			borderColor = 0x07A0FA;
			
			// new arrow proportions
			switch (applicationDPI)
			{
				case DPIClassification.DPI_480:
				{
					arrowWidth = 90;
					arrowHeight = 45;
					break;
				}
				case DPIClassification.DPI_320:
				{
					arrowWidth = 60;
					arrowHeight = 30;
					break;
				}
				case DPIClassification.DPI_240:
				{
					arrowWidth = 45;
					arrowHeight = 15;
					break;
				}
				default:
				{
					arrowWidth = 30;
					arrowHeight = 10;
					break;
				}
			}
		}
		
		override protected function createChildren():void
		{
			// BoxyCalloutArrow subclasses CalloutArrow
			
			// create arrow first, super will skip default arrow creation
			arrow = new BoxyCalloutArrow();
			arrow.id = "arrow";
			arrow.styleName = this;
			
			// call super
			super.createChildren();
			
			// add arrow above all other children
			addChild(arrow);
		}
	}
}