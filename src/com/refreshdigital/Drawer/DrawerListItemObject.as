package com.refreshdigital.Drawer
{
	public interface DrawerListItemObject
	{
		function setListItem(ListItem:DrawerListItem):void;
	 	function getListItem():DrawerListItem;
		function setListItemText():void;
		function filter(searchString:String = ''):Boolean;
	}
}