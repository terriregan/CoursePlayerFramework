package org.nflc.framework.event
{
	import flash.events.Event;
	
	public class AccessibilityEvent extends Event
	{
		public static const SET_FOCUS:String = "AccessibilityEvent.SET_FOCUS";
		public static const SET_INITIAL_FOCUS:String = "AccessibilityEvent.SET_INITIAL_FOCUS";
		public static const STORE_FOCUS:String = "AccessibilityEvent.STORE_FOCUS";
		public static const UPDATE_SCREEN_INFO:String = "AccessibilityEvent.UPDATE_SCREEN_INFO";
		
		public var accObj:*;
		
		public function AccessibilityEvent( type:String, accObj:* = null, bubbles:Boolean = true, cancelable:Boolean = false )
		{
			super( type, bubbles, cancelable );
			this.accObj = accObj;
		}
		
		override public function clone():Event
		{
			return new AccessibilityEvent( type, accObj,  bubbles, cancelable );
		}
	}
}