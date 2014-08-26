package org.nflc.framework.event
{
	import flash.events.Event;
	import org.nflc.framework.domain.Screen;
	
	public class ScreenEvent extends Event
	{
		public static const CHANGE:String = "ScreenEvent.CHANGE";
		public static const VIEW:String = "ScreenEvent.VIEW";
		
		public var screen:Screen;
		
		public function ScreenEvent( type:String, screen:Screen = null, bubbles:Boolean=false, cancelable:Boolean=false )
		{
			super( type, bubbles, cancelable );
			this.screen = screen;
		}
		
		override public function clone():Event
		{
			return new ScreenEvent( type, screen, bubbles, cancelable );
		}
	}
}