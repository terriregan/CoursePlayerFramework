package org.nflc.framework.event
{
	import flash.events.Event;
	
	public class WindowEvent extends Event
	{
		public static const OPEN:String = "WindowEvent.OPEN";
		public static const CLOSE:String = "WindowEvent.CLOSE";
	
		public var window:String;
		
		public function WindowEvent( type:String, window:String="", bubbles:Boolean=false, cancelable:Boolean=false )
		{
			super( type, bubbles, cancelable );
			this.window = window;
		}
		
		override public function clone():Event
		{
			return new WindowEvent( type, window, bubbles, cancelable );
		}
	}
}