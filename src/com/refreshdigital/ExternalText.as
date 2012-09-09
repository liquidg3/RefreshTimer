package com.refreshdigital
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	import mx.controls.Text;

	[Bindable]
	public class ExternalText extends Text
	{
		private var _source:String;
		private var _dataLoader:URLLoader;
		private var _dataRequest:URLRequest;
		private var _timer:Timer = null;
		
		
		//how often we refresh the source in miliseconds
		private var _refreshRate:Number = 30000;
		
		public function ExternalText() {
			super();
		}
		
		public function get source():String {
			return _source;
		}
		
		public function set source(url:String):void {
			_source = url;
			loadSource();
			this._timer = new Timer(this._refreshRate,999999999);
			this._timer.addEventListener('timer',loadSource);
		}
		
		private function loadSource():void {
			try {
				_dataLoader 	= new URLLoader()
				_dataRequest 	= new URLRequest(_source);
				
				_dataLoader.addEventListener('success', onDataLoaded);
				_dataLoader.load(_dataRequest);
			} catch (error:Error) {
				
			}
		}
		
		private function onDataLoaded(evt:Event):void {
			htmlText = _dataLoader.data;
		}
	}
}