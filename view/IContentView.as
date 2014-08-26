package org.nflc.framework.view
{
	import org.nflc.framework.domain.Screen;
	
	// NOTE: all views that implement this interface MUST also dispatch an Event.COMPLETE event
	
	public interface IContentView
	{
		function set currentScreen( value:Screen ):void;
		function dispose():void;
	}
}