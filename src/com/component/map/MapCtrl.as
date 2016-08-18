package com.component.map
{
	import com.supermap.web.mapping.ImageLayer;
	import com.supermap.web.mapping.Layer;
	import com.supermap.web.mapping.Map;
	import com.util.ArrayCollectionUtils;
	
	import mx.collections.ArrayCollection;
	
	public class MapCtrl extends Map
	{
		public function MapCtrl()
		{
			super();
		}
		
		/**对图层进行排序，只通过movelaye进行图层位置调节，避免图层刷新
		 * @param fields 排序字段，可以使多字段，第一个字段为主字段
		 * @param fields 是否降序
		 * */
		public function sortLayers(fields:Array,descendings:Array = null,isnums:Array = null):void
		{
			var layers:ArrayCollection = this.layers as ArrayCollection;
			var tempLayers:ArrayCollection = new ArrayCollection(layers.toArray());
			//针对drawaction往map中添加的临时featureslayers，此处先移到最上层，然后从排序数组中移除
			var layer:Layer;
			var sortLayers:ArrayCollection = new ArrayCollection();
			for each(layer in tempLayers)
			{
				if((!(layer  is ImageLayer)) && (!("layerType" in layer) || !("layerIndex") in layer))
				{
					moveLayer(layer.id,layers.length-1);
				}else{
					sortLayers.addItem(layer);
				}
			}
			
			ArrayCollectionUtils.FieldSort(sortLayers,fields,descendings,isnums);
			
			for (var layerIndex:int = 0 ; layerIndex < sortLayers.length ; layerIndex++)
			{
				var sortLayer:Layer = sortLayers.getItemAt(layerIndex) as Layer;
				for each (layer in layers)
				{
					if(sortLayer == layer)
					{
						moveLayer(layer.id,layerIndex);
						break;
					}
				}
			}
		}
	}
}