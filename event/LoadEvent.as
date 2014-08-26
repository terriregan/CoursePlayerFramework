package org.nflc.framework.event
{
	import flash.events.Event;
	
	public class LoadEvent extends Event
	{
		public static const READY:String = "LoadEvent.READY";
		public static const LOAD:String = "LoadEvent.LOAD";

		public var url:String;
		
		public function LoadEvent( type:String, url:String = "", bubbles:Boolean=true, cancelable:Boolean=false )
		{
			super( type, bubbles, cancelable );
			this.url = url;
		}
		
		override public function clone():Event
		{
			return new LoadEvent( type, url, bubbles, cancelable );
		}
	}
}