package com.util
{
	import com.supermap.web.core.Rectangle2D;
	import com.supermap.web.core.geometry.GeoPoint;
	import com.supermap.web.core.geometry.Geometry;
	
	import spark.primitives.Rect;

	public class Coordinate
	{
		public static var M_PI:Number=Math.PI;
		//经纬度转墨卡托
		// 经度(lon)，纬度(lat)		
		public static function lon2Mercator(lon:Number):Number
		{
			var x:Number = lon *20037508.342789/180;
			
			return x;
		}
		
		public static function lat2Mercator(lat:Number):Number
		{
			var y:Number = Math.log(Math.tan((90+lat)*M_PI/360))/(M_PI/180);
			y = y *20037508.34789/180;
			
			return y;
		}
		
		//墨卡托转经纬度
		
		public static function Mercator2Lon(mercatorX:Number):Number
		{
			var x:Number = mercatorX/20037508.34*180;
			
			return x;
		}
		
		public static function Mercator2Lat(mercatorY:Number):Number
		{
			var y:Number = mercatorY/20037508.34*180;
			y= 180/M_PI*(2*Math.atan(Math.exp(y*M_PI/180))-M_PI/2);
			
			return y;
		}
		
		public static function  geographicToMercator(geometry:Geometry):Geometry
		{
			if (geometry is GeoPoint)
			{
				var geoPoint:GeoPoint = geometry as GeoPoint;
				return new GeoPoint(lon2Mercator(geoPoint.x), lat2Mercator(geoPoint.y));
			} 
			return null;
		}
		
		public static function  rectangle2DToMercator(rect:Rectangle2D):Rectangle2D
		{
				return new Rectangle2D(lon2Mercator(rect.left), lat2Mercator(rect.bottom), lon2Mercator(rect.right), lat2Mercator(rect.top));
		}
			
	}
}