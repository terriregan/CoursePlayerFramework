package org.nflc.framework.event
{
	import flash.events.Event;
	import org.nflc.framework.domain.Screen;
	
	public class LogEvent extends Event
	{
		public static const LOG:String = "LogEvent.LOG";
		public static const TOGGLE:String = "LogEvent.TOGGLE";
		
		public var msg:String;
		
		public function LogEvent( type:String, msg:String="", bubbles:Boolean=false, cancelable:Boolean=false )
		{
			super( type, bubbles, cancelable );
			this.msg = msg;
		}
		
		override public function clone():Event
		{
			return new LogEvent( type, msg, bubbles, cancelable );
		}
	}
}