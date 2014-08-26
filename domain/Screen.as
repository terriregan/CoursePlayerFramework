package org.nflc.framework.domain
{
	import org.nflc.activities.model.ActivityData;
	import org.nflc.framework.model.Constants;
	
	[Bindable]
	public class Screen
	{
		// NOTE: screen type constants in org.nflc.framework.model.Contstants class
		public var screenNumber:int;			// position in sequence of screens
		public var questionNumber:int;			// position in sequence of ONLY questions (assessment)
		public var type:String;
		public var activity:ActivityData;
		public var title:String;
		public var file:String;
		public var source:String;				// media source
		public var lessonId:String;
		public var summary:Boolean = false;
		public var mandatory:Boolean = false;
		
		public function get description():String
		{
			if( this.type == Constants.ANIMATION )
				return "Time based media";
			
			else if ( this.type == Constants.ACTIVITY )
				return "Knowledge check";
			
			else
				return "Video";
		}
	}
}