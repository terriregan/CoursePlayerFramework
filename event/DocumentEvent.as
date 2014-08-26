package org.nflc.framework.event
{
	import flash.events.Event;
	
	public class DocumentEvent extends Event
	{
		public static const OPEN:String = "DocumentEvent.OPEN";
		public var document:String;
		
		public function DocumentEvent( type:String, document:String, bubbles:Boolean=true, cancelable:Boolean=false )
		{
			super( type, bubbles, cancelable );
			this.document = document;
		}
		
		override public function clone():Event
		{
			return new DocumentEvent( type, document, bubbles, cancelable );
		}
	}
}