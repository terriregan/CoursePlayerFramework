package org.nflc.framework.view
{
	import flash.events.Event;
	
	import mx.core.IVisualElement;

	public interface IModuleView extends IVisualElement
	{
		function dispose( e:Event = null ):void;
	}
}