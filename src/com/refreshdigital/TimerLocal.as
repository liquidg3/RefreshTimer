package com.refreshdigital
{
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import spark.components.Label;
	
	
	
	public class TimerLocal
	{
		private var _startDate:Date;
		private var _genericTimer:Timer;
		private var _previousElapsedTime:Number = 0;
		
		/**
		 *  array of labels that will be updated every intervals
		 */
		private var _labels:Array		= [];
		
		public var nowTime:String;
		public var running:Boolean;
		
		public function TimerLocal()
		{
			this.running = false;
		}
		
		/**
		 * Attach a label that will be updated with elapsed time
		 */
		public function attachLabel(label:Label):void
		{
			this._labels.push(label);
		}
		
		public function start():void
		{
			
			if(_genericTimer != null) {
				_genericTimer.stop();
			}
			_genericTimer = new Timer(1000);
			_genericTimer.addEventListener(TimerEvent.TIMER,_interval);
			_genericTimer.start();
			_startDate = new Date();
			this.running = true;
		}
		
		public function stop():void
		{
			this.running = false;
			if(_genericTimer == null) {
				return;
			}
			_genericTimer.stop();
			
			var nowDate:Date		= new Date();
			_previousElapsedTime 	= nowDate.valueOf() - _startDate.valueOf() + _previousElapsedTime;
			_genericTimer			= null;
		}
		
		public function reset():void {
			_previousElapsedTime 	= 0;
			_startDate 				= null;
			this._setLabels('00:00:00');
		}
		
		private function _interval(event:TimerEvent):void
		{
			if(this._startDate == null) {
				return;
			}
			
			
			var nowDate:Date		= new Date();
			var elapsed:Number 		= (nowDate.valueOf() + _previousElapsedTime) - _startDate.valueOf();
			
			var elapsedTime:Date	= new Date(elapsed);
			var seconds:String		= ("00"+elapsedTime.seconds.toString()).substr(-2);
			var hours:String		= ("00"+elapsedTime.hoursUTC.toString()).substr(-2);
			var minutes:String		= ("00"+elapsedTime.minutes.toString()).substr(-2);
			
			this._setLabels(hours.toString() + ":" + minutes.toString() + ":" + seconds.toString());

			nowTime = String(elapsed);
		}
		

		public function getElapsedTime():Number {
			return _previousElapsedTime;
		}
		
		/**
		 * You can attach labels that are updated every interval with elapsed time.
		 * this function loops through all labels attached to this time and updates
		 * them with a nicely formatted elapsed time HH:MM:SS
		 */
		private function _setLabels(text:String):void {
			for each(var label:Label in this._labels) {
				label.text = text;
			}
		}

	}
}