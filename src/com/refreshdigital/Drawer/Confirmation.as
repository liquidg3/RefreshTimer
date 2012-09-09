package com.refreshdigital.Drawer
{
	
	import com.refreshdigital.Drawer;
	
	import flash.events.MouseEvent;
	
	import mx.core.IUIComponent;
	import mx.core.IVisualElement;
	import mx.core.UIComponent;
	
	import spark.components.Button;
	import spark.components.Group;
	import spark.components.Label;
	import spark.layouts.HorizontalLayout;
	import spark.layouts.VerticalLayout;
	
	public class Confirmation extends Drawer
	{
		
		private var _group:Group 				= null;
		private var _okButton:Button			= null;
		private var _cancelButton:Button		= null;
		private var _closeAutomatically:Boolean = true;
		
		public function Confirmation(params:Object, callback:Function, noCallback:Function)
		{
			//set defults
			params.id = 'confirmation';
			
			//see if a confirm exists
			var oldConfirm:Drawer = Drawer.getFromId(params.id);
			Drawer.destroyDrawer(params.id);
			
			if(oldConfirm != null) {
				oldConfirm.hide(function():void {
					oldConfirm = null;
				});
			}
			
			if(params.closeAutomatically != null) {
				this._closeAutomatically = params.closeAutomatically;
			}
			
			super(params);
			
			//set default arguments
			if(!params.okButtonText) {
				params.okButtonText = 'Ok';
			}
			
			if(!params.cancelButtonText) {
				params.cancelButtonText = 'Cancel';
			}
			
			//drop in confirmation stuff
			_group 				= new Group();
			_group.layout		= new VerticalLayout();
			
			//add label
			var label:Label		= new Label();
			label.text			= params.message;
			
			_group.addElement(label);
			
			//ok  & cancel button
			_okButton 			= new Button();
			_cancelButton		= new Button();
			
			_okButton.width		= _cancelButton.width = 85;
			_okButton.height	= _cancelButton.height = 25;
			_okButton.top		= _cancelButton.top = label.top + label.height + 20;
			_okButton.label		= "Yes";
			_okButton.addEventListener(MouseEvent.CLICK,function():void{callback();});
			
			_cancelButton.label = "No";
			_cancelButton.addEventListener(MouseEvent.CLICK,function():void{noCallback();});
			
			var buttonGroup:Group 	= new Group();
			buttonGroup.layout 		= new HorizontalLayout();
			
			//add buttons to group
			buttonGroup.addElement(_okButton);
			buttonGroup.addElement(_cancelButton);
			
			_group.addElement(buttonGroup);

			//set site of group
			_group.width		= 200;
			_group.height		= _cancelButton.top + _cancelButton.height + 10;
			
			this.setComponent(_group);
			this.place();
			
		}
		
		/**
		 * Override the normal drawer hide because this drawer removes itself
		 * after it is hidden.
		 */
		override public function hide(callback:Function = null):void {
			
			var me:Confirmation = this;
			super.hide(function():void {
				if (callback != null) {
					callback.apply(me);
				}
				var parent:Group = me.parent as Group;
				parent.removeElement(this);
			});
		}
		

	}
}