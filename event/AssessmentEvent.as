package org.nflc.framework.event
{
	import flash.events.Event;
	
	public class AssessmentEvent extends Event
	{
		public static const SUBMIT:String = "submit";
		public static const SCORE:String = "score";
		
		public var score:Number;
		
		public function AssessmentEvent(type:String, score:Number = 0, bubbles:Boolean=true, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.score = score;
		}
		
		override public function clone():Event
		{
			return new AssessmentEvent( type, score, bubbles, cancelable );
		}
	}
}