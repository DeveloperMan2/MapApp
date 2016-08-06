package com.skin
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	import flash.events.TextEvent;
	import flash.system.IME;
	
	import spark.components.TextInput;

	public class CustomTextInput extends TextInput
	{
		public function CustomTextInput()
		{			
			super();		
			super.maxChars = null;
			super.imeMode = "CHINESE";
			IME.enabled = true;
		}
		
		[Bindable]
		public  var fontSize:Number = 24;
		
		[Bindable]
		public var fontColor:Number = 0x000000;
		
		[Bindable]
		public var borderColor:Number = 0x000000;
		
		private var origStr:String = "";
		
		
		
		public function addHandle():void
		{
//			this.addEventListener(FocusEvent.FOCUS_IN,focusIn);
//			this.addEventListener(FocusEvent.FOCUS_OUT,focusOut);	
			this.addEventListener(TextEvent.TEXT_INPUT,textInput);
		}
		protected function textInput(ev:TextEvent):void
		{
			super.text = super.text + ev.text;
		}
		protected function focusIn(ev:FocusEvent):void
		{
			origStr = this.text;
			this.text = "";
		}
		protected function focusOut(ev:FocusEvent):void
		{
			if(this.text.length < 1)
			{
				this.text = origStr;
			}
			else
			{
				origStr = this.text;
			}			
		}
		   
		/**
		 *  @private
		 */
		override public function set text(value:String):void
		{	
			super.text = value;
			
			// Trigger bindings to textChanged.
			var z:int = 0;
			if(z > 0)
				dispatchEvent(new Event("textChanged"));
		}
		
		override public function get text():String
		{
			return super.text;
		}
		override protected function commitProperties() : void{  
			super.commitProperties();  
			super.skin.currentState = getCurrentSkinState();  
		}  		
	}
}


