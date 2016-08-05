package  com.mapping
{
	import com.supermap.web.core.*;
	import com.supermap.web.mapping.*;
	import com.supermap.web.sm_internal;
	import com.supermap.web.utils.CoordinateReferenceSystem;
	import com.supermap.web.utils.Unit;
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	
	import mx.events.*;

	use namespace sm_internal;
	
	
	public class BaiduMapLayer extends TiledCachedLayer
	{	
		private var  offsetXY:Array;
		
		public function BaiduMapLayer()
		{	
			/*
			offsetXY = new Array();	
			
			offsetXY.push({x:-3,y:1});//3
			offsetXY.push({x:-6,y:3});//4
			offsetXY.push({x:-12,y:7});//5
			offsetXY.push({x:-24,y:15});//6
			offsetXY.push({x:-48,y:31});//7
			offsetXY.push({x:-96,y:63});//8
			offsetXY.push({x:-192,y:127});//9
			offsetXY.push({x:-384,y:255});//10
			offsetXY.push({x:-768,y:511});//11
			offsetXY.push({x:-1536,y:1023});//12
			offsetXY.push({x:-3072,y:2047});//13
			offsetXY.push({x:-6144,y:4095});//14
			offsetXY.push({x:-12288,y:8191});//15
			offsetXY.push({x:-24576,y:16383});//16
			offsetXY.push({x:-49152,y:32767});//17
			offsetXY.push({x:-98304,y:65535});//18
			offsetXY.push({x:-196608,y:131071});//19	
			*/
			this.buildTileInfo();            
		}
		
		private function buildTileInfo():void
		{
			/*
			var minX:Number = 6291456;
			var minY:Number = 0;
			var maxX:Number = minX + Math.pow(2, 14) * 256 * 5;
			var maxY:Number = minY + Math.pow(2, 14) * 256 * 4;
			*/
			
			var minX:Number = -2.0037508342789244E7;
			var minY:Number = -2.003750834278914E7;
			var maxX:Number = 2.0037508342789244E7;
			var maxY:Number = 2.00375083427891E7;
			
//			
//			var minX = -33554432;//-2.0037508342789244E7;
//			var minY = -33554432;//-2.003750834278914E7;
//			var maxX= 33554432;//2.0037508342789244E7;
//			var maxY= 33554432;//2.00375083427891E7;
			this.CRS = new CoordinateReferenceSystem(900913,Unit.METER);
			this.bounds = new Rectangle2D(minX, minY, maxX, maxY);
			//为了修改坐标错误进行的纠偏
			this.origin = new Point2D(-16777169, 16777124);
			this.tileSize = 256;
			
			var res:Number = Math.pow(2,17);
			var resAry:Array = new Array();
			for (var i:int = 0; i < 17; i++)
			{
				resAry[i] = res;
				res *= 0.5;
			}
			this.resolutions = resAry;  
			this.setLoaded(true);
			invalidateLayer();
		}
		
		override protected function addMapListeners():void
		{
			super.addMapListeners();
			if (map != null) {
//				this.resolutions = map.resolutions;
			}
		}
		
		protected override function getTileURL(row:int, col:int, level:int):URLRequest
		{
			
			var strUrl:String;	
			/*
			var x:int = col + offsetXY[level].x;
			var y:int = offsetXY[level].y - row;
		
			var z:int = level + 3;			
			var num:int = Math.abs((x + y) % 8);
			num++;
			*/
			var zoom:int = level - 1;
			var offsetX:int = Math.pow(2, zoom) as int;  
			
			var offsetY:int = offsetX - 1;  
			
			var numX:int = col - offsetX;  
			
			var numY:int = (-row) + offsetY;  
			zoom = level + 1;  
			
			var num:int = (col + row) % 8 + 1;   
			strUrl = "http://online" + num + ".map.bdimg.com/onlinelabel/?qt=tile&x="+ numX + "&y=" + numY + "&z=" + zoom + "&styles=pl&udt=20160730&scaler=1&p=0";
			strUrl = strUrl.replace(/-/g,"M");
			return new URLRequest(strUrl);
		}
	}
}