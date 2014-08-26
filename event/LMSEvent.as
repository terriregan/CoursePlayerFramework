package org.nflc.framework.event
{
	import flash.events.Event;
	
	public class LMSEvent extends Event
	{
		public static const INITIALIZED:String  = "LMSEvent.INITIALIZED";
		public static const NOT_INITIALIZED:String = "LMSEvent.NOT_INITIALIZED";
		public static const CANNOT_CONNECT:String = "LMSEvent.CANNOT_CONNECT";
		public static const DISCONNECT:String = "LMSEvent.DISCONNECT";
		public static const CONNECTION_LOST:String = "LMSEvent.CONNECTION_LOST";
		public static const ERROR:String = "LMSEvent.ERROR";
		public static const SUCCESS:String = "LMSEvent.SUCCESS";
		public static const CANNOT_CLOSE_WINDOW:String = "LMSEvent.CANNOT_CLOSE_WINDOW";
		public static const UPDATE:String = "LMSEvent.UPDATE";
		
		/*public static const COMMIT:String = "LMSEvent.commit";
		public static const SET_SCORE:String	= "LMSEvent.set_score";
		public static const SET_STATUS:String = "LMSEvent.set_status";
		public static const SET_INCOMPLETE:String = "LMSEvent.set_incomplete";
		public static const SET_COMPLETE:String = "LMSEvent.set_complete";
		public static const SET_PASS:String = "LMSEvent.set_pass";
		public static const SET_FAIL:String = "LMSEvent.set_fail";
		public static const SET_LASTLOCATION:String = "LMSEvent.set_lastlocation";
		public static const SET_SUSPENDDATA	:String = "LMSEvent.set_suspenddata";
		public static const EXIT:String = "LMSEvent.exit";*/
		
		private var _data:String;
		
		public function get data():String
		{
			return _data;
		}
		
		public function LMSEvent( type:String, bubbles:Boolean = true, cancelable:Boolean = false, data:String = "")
		{
			super( type, bubbles, cancelable );
			_data = data;
		}
		
		override public function clone():Event
		{
			return new LMSEvent( type, bubbles, cancelable, _data );
		}
	}
}