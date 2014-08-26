package org.nflc.framework.event
{
	import flash.events.Event;
	import org.nflc.framework.model.Constants;
	
	public class CourseModeEvent extends Event
	{
		public static const MODE_CHANGED:String = "CourseModeEvent.MODE_CHANGED";
		
		public var mode:String;
		
		// Had to change parameter from Constants.STANDARD_MODE to  mode:String= 'standardMode' --not sure why
		public function CourseModeEvent(type:String, mode:String= 'standardMode', bubbles:Boolean=true, cancelable:Boolean=false )
		{
			super(type, bubbles, cancelable);
			this.mode = mode;
		}
		
		
		override public function clone():Event
		{
			return new CourseModeEvent( type, mode, bubbles, cancelable );
		}
	}
}