package org.nflc.framework.event
{
	import flash.events.Event;
	
	public class LessonEvent extends Event
	{
		public static const CHANGE:String = "lessonChanged";
		
		private var _lessonId:String;
		
		public function get lessonId():String
		{
			return _lessonId;
		}
		
		public function LessonEvent( type:String, lessonId:String, bubbles:Boolean=false, cancelable:Boolean=false )
		{
			super( type, bubbles, cancelable );
			_lessonId = lessonId;
		}
		
		override public function clone():Event
		{
			return new LessonEvent( type, lessonId, bubbles, cancelable );
		}
	}
}