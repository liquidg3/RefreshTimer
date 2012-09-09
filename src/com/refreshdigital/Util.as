package com.refreshdigital
{
	import components.TimerBar;
	
	import flash.geom.Point;
	
	import mx.core.FlexGlobals;
	import mx.core.IVisualElement;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	import mx.rpc.http.HTTPService;
	
	import org.goasap.events.GoEvent;
	import org.goasap.items.LinearGo;
	
	import spark.primitives.Rect;
	
	public class Util
	{
		public static var mainWindow:RefreshTimer;
		public static var timerBar:TimerBar;
		public static const URL:String = "http://localhost";
		
		public function Util() {}
		
		/**
		 * Animate any property of any IVisualElement.
		 * Params is json object in form:
		 * 
		 * 		{ width: 100,
		 * 		  height: {from: 5, to: 10} }
		 */
		
		public static function animateProperties(component:*, params:Object, options:Object = null):LinearGo {
			
			if(!options) {
				options = {
					duration: 1
				};
			}
			
			var duration:Number 			= options.duration;
			var completeCallback:Function 	= options.completeCallback;
			var stepCallback:Function 		= options.stepCallback;
			
			//normalize properties, set each one as an object
			//width a start and finish
			for(var property:String in params) {
				
				//convert integner to an object with "to" set
				if(typeof(params[property]) != 'object') {
					params[property] = { to: params[property] };
				}
				
				//set start value if one is not set
				params[property].from = (params[property].from != null) ? parseInt(params[property].from) : component[property]; 
			}
			
			var tween:LinearGo = new LinearGo(0,duration);
			
			
			//interval callback
			tween.addCallback(function():void {
				for(var property:String in params) {
					component[property] = (params[property].to - params[property].from) * tween.position + params[property].from;
					//trace('setting ' + property + ': ' + component[property]);
				}
			}, GoEvent.UPDATE);
			
			//setup completion callback if one is passed
			if(completeCallback != null) {
				tween.addCallback(completeCallback,GoEvent.COMPLETE);
			}
			
			if(stepCallback != null) {
				tween.addCallback(stepCallback, GoEvent.UPDATE);
			}
			
			tween.start();
			
			return tween;
		}
		
		public static function copyBounds(source:*, destination:*):void {
			destination.x 			= source.x;
			destination.y 			= source.y;
			destination.width 		= source.width;
			destination.height 		= source.height;
		}
		
		public static function getGlobalPosition(element:Object, includeNativeWindow:Boolean = true):Point {
			
			var point:Point = new Point();
			var x:Number	= 0;
			var y:Number	= 0;
			
			do {
				
				
				x += element.x;
				y += element.y;
				
				if(includeNativeWindow && element.hasOwnProperty('nativeWindow') && element.nativeWindow != null) {
					
					x += element.nativeWindow.x;
					y += element.nativeWindow.y;
					
					//if there is a native window, we're at the highest level we need to be
					break;
				}
				
				
			} while(element = element.parent);
			
			point.x = x;
			point.y = y;
			
			return point;
		}
		
		
		public static function getMousePosition():void {
			
			return void;
		}
		
		public static function ucFirst( str:String ):String { 
			return str.substr(0,1).toUpperCase() + str.substr(1);
		}
		
		public static function trim(s:String):String {
			return s.replace(/^\s+|\s+$/gs, '');
		}
		
		/**
		 * Converts date in format of "2010-04-22T06:00:00Z" and turns it into a date object
		 */
		public static function utcDateTimeToDate(dateTime:String):Date {
			
			//remove time first
			var dateParts:Array = dateTime.split("T");
			if(dateParts.length != 2) {
				return null;
			}
			
			//split up yyyy-mm-dd
			dateParts = dateParts[0].split("-");
			
			if(dateParts.length != 3) {
				return null;
			}
			
			var date:Date	= new Date(+dateParts[0], (+dateParts[1]) - 1, +dateParts[2]);
			
			return date;
		}
		
		public static function checkSerialForEmail(email:String, serial:String, callbackFunction:Function):void {
			var service:HTTPService = new HTTPService(Util.URL + "/serial.php");
			service.addEventListener(ResultEvent.RESULT,callbackFunction);
			service.addEventListener(FaultEvent.FAULT, callbackFunction);
			service.send({
				serial: serial,
				email: email
			});
		}
		
	}
}