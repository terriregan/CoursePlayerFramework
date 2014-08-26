package org.nflc.framework.event
{
	import flash.events.Event;
	
	public class NavigationEvent extends Event
	{
		public static const GO_NEXT:String = "NavigationEvent.GO_NEXT";
		public static const GO_PREVIOUS:String = "NavigationEvent.GO_PREVIOUS";
		public static const JUMP:String = "NavigationEvent.JUMP";
		public static const DISABLE_PREVIOUS:String = "NavigationEvent.DISABLE_PREVIOUS";
		public static const DISABLE_NEXT:String = "NavigationEvent.DISABLE_NEXT";
		public static const DISABLE_BOTH:String = "NavigationEvent.DISABLE_BOTH";
		
		public var screen:*;
		
		public function NavigationEvent( type:String, screen:* = null, bubbles:Boolean = true, cancelable:Boolean = false )
		{
			super( type, bubbles, cancelable );
			this.screen = screen;
		}
		
		override public function clone():Event
		{
			return new NavigationEvent( type, screen,  bubbles, cancelable );
		}
	}
}