package com.refreshdigital.Drawer
{
	import com.refreshdigital.Project;
	
	import components.DrawerList;
	
	import mx.collections.ArrayCollection;
	import mx.events.CollectionEvent;

	public class DrawerListItem
	{
		[Bindable]
		public var heading:String				= '';

		[Bindable]
		public var headingFontSize:Number 		= 16;
		
		[Bindable]
		public var subHeading:String			= '';
		
		[Bindable]
		public var subHeadingFontSize:Number 	= 12;
		
		[Bindable]
		public var isProgressVisible:Boolean 	= false;
		
		[Bindable]
		public var progressLeft:Number			= 6;
		
		[Bindable]
		public var checked:Boolean				= false;
		
		[Bindable]
		public var isMine:Boolean				= true;
	
		
		private var _listItemObject:DrawerListItemObject	 		= null;
		private var _items:ArrayCollection							= null;
		
		
		public function DrawerListItem(listItemObject:DrawerListItemObject, items:ArrayCollection):void
		{
			listItemObject.setListItem(this);
			
			this._listItemObject 	= listItemObject;
			this._items				= items;
		
		}
		
		public function refresh():Boolean {
			if(this._items != null) {
				this._items.refresh();
			}
			
			return false;
		}
		
		public function getListItemObject():DrawerListItemObject {
			return this._listItemObject;
		}
	}
}