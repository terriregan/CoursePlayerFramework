package org.nflc.framework.view
{
	import flash.events.Event;
	
	import org.nflc.activities.factory.*;
	import org.nflc.activities.model.ActivityConstants;
	import org.nflc.activities.model.ConfigurationManager;
	import org.nflc.activities.view.Activity;
	import org.nflc.framework.domain.LessonConfiguration;
	import org.nflc.framework.domain.Screen;
	import org.nflc.framework.model.Constants;
	import org.nflc.managers.AccessibilityManager;
	
	import spark.components.Group;
	
	import utils.array.contains;
	
	[Event(name="complete", type="flash.events.Event")]
	public class ActivityView extends Group implements IContentView
	{
		private var _activityFactory:ActivityFactory;
		private var activity:Activity = null;
		
		public function set currentScreen( value:Screen ):void
		{
			if( value )
			{
				// clean up any previous activity
				dispose();
				if( value.type == Constants.ACTIVITY )
				{
					var interactionType:String = value.activity.interactionType;
				
					if( AccessibilityManager.getInstance().usingScreenReader() )
					{
						if( utils.array.contains(ActivityConstants.ACESSIBLE_ACTIVITIES, interactionType) )
						{
							_activityFactory = fetchAccessibileFactory( interactionType );
						}
						else
						{
							_activityFactory = fetchFactory( interactionType );
						}
					}
					else
					{
						_activityFactory = fetchFactory( interactionType );
					}
					
					if( _activityFactory )
					{
						activity = _activityFactory.display( this, value.activity );
					}
					
					if( activity )
						ready();
				}
			}
			else
			{
				// do clean up?
			}
		}
		
		public function ActivityView()
		{
			super();
		}	
		
		public function dispose():void
		{
			if( activity )
			{
				activity.dispose();
				removeElement( activity );
				activity = null;
			}
		}
		
		private function fetchFactory( interactionType:String ):ActivityFactory
		{
			if( utils.array.contains(ActivityConstants.SELECTABLE_ACTIVITIES, interactionType) )
				return new SelectableActivityFactory();
				
			if( utils.array.contains(ActivityConstants.DRAGGABLE_ACTIVITIES, interactionType) ) 
				return new MatchingActivityFactory();
			
			if( utils.array.contains(ActivityConstants.ORDERING_ACTIVITIES, interactionType) ) 
				return new OrderingActivityFactory();
			
			if( utils.array.contains(ActivityConstants.CLICKABLE_ACTIVITIES, interactionType) ) 
				return new ClickableActivityFactory();
			
			if( interactionType == ActivityConstants.CATEGORIZING )
				return new CategorizationActivityFactory();
			
			return null;
		}
		
		private function fetchAccessibileFactory( interactionType:String ):ActivityFactory
		{
			if( interactionType == ActivityConstants.CATEGORIZING )
				return new AccessibleActivityCategorizationFactory();
			
			else
				return new AccessibleActivityFactory();
		}
		
		private function ready():void
		{
			dispatchEvent( new Event(Event.COMPLETE) );
		}
	}
}