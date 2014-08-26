package org.nflc.framework.presentation
{
	import flash.events.Event;
	
	import mx.events.IndexChangedEvent;
	
	import org.nflc.activities.events.ActivityStatusEvent;
	import org.nflc.framework.domain.LessonConfiguration;
	import org.nflc.framework.domain.Screen;
	import org.nflc.framework.event.AccessibilityEvent;
	import org.nflc.framework.event.NavigationEvent;
	import org.nflc.framework.event.ScreenEvent;
	import org.nflc.framework.event.WindowEvent;
	import org.nflc.framework.model.AppModel;
	import org.nflc.framework.model.Constants;
	import org.nflc.managers.AccessibilityManager;
	import org.swizframework.reflection.Constant;
	
	import spark.events.IndexChangeEvent;

	public class LessonNavigationPresentationModel
	{
		public static const STATE_DISABLE_PREV:String = "disablePrev";
		public static const STATE_DISABLE_NEXT:String = "disableNext";
		public static const STATE_ENABLE_BOTH:String = "enableBoth";
		public static const STATE_DISABLE_BOTH:String = "disableBoth";
		public static const STATE_ASSESSMENT:String = "assessment";
		
		[Dispatcher]
		public var dispatcher:IEventDispatcher;
		
		[Bindable]
		public var lessonMenuVisible:Boolean = false;
		
		[Bindable]
		[Inject("appModel", bind="true")]
		public var model:AppModel;
		
		[Bindable]
		[Inject("appModel.currentScreen", bind="true")]
		public var currentScreen:Screen;
				
		[Inject("appModel.totalScreens", bind="true")]
		public var totalScreens:int;
		
		[Bindable]
		[Inject("appModel.screens", bind="true")]
		public var screens:Array;
				
		[Bindable]
		public var currentState:String = STATE_DISABLE_PREV;
		
		[Bindable]
		public var hasReviewScreenBeenViewed:Boolean = false;
		
		[EventHandler(event="WindowEvent.OPEN", properties="window")]
		public function showWindow( window:String ):void
		{
			if( window == Constants.LESSON_MENU )
			{
				lessonMenuVisible = true;
			}
				
		}
		
		[EventHandler(event="WindowEvent.CLOSE")]
		public function hideWindow():void
		{
			lessonMenuVisible = false;
		}
		
		[EventHandler(event="ScreenEvent.CHANGE", properties="screen")]
		public function updateCurrentState( screen:Screen ):void
		{
			if( screen.screenNumber < 2 )
			{
				currentState = STATE_DISABLE_PREV;
			}
			else if ( screen.screenNumber > totalScreens - 1 )
			{
				currentState = STATE_DISABLE_NEXT;
			}
			else
			{
				if( screen.type == Constants.ACTIVITY && 
								   LessonConfiguration.forceActivityCompleteBeforeContinue )
				{
					currentState = ( screen.activity.sessionData.isComplete ) ? STATE_ENABLE_BOTH : 
																			    STATE_DISABLE_NEXT;
				}
				else
				{
					currentState = STATE_ENABLE_BOTH;
				}
			}
			if( screen.type == Constants.ASSESSMENT )
				hasReviewScreenBeenViewed = true;
		}
		
		[EventHandler(event="NavigationEvent.DISABLE_PREVIOUS")]
		public function disablePrevious():void
		{
			currentState = STATE_DISABLE_PREV;
		}
		
		[EventHandler(event="NavigationEvent.DISABLE_NEXT")]
		public function disableNext():void
		{
			currentState = STATE_DISABLE_NEXT;
		}
		
		[EventHandler(event="NavigationEvent.DISABLE_BOTH")]
		public function disableBoth():void
		{
			currentState = STATE_DISABLE_BOTH;
		}
		
		[EventHandler(event="activityComplete")]
		public function handleActivityStatus():void
		{
			updateCurrentState( currentScreen );
		}
		
		
		//--------------------------------------------------------------------------
		//
		// public methods called by its view
		//
		//--------------------------------------------------------------------------
		
		public function goNext():void
		{
			dispatcher.dispatchEvent( new NavigationEvent( NavigationEvent.GO_NEXT ) );
		}
		
		public function goPrev():void
		{
			dispatcher.dispatchEvent( new NavigationEvent( NavigationEvent.GO_PREVIOUS ) );
		}
		
		public function toggleMenu( e:Event=null ):void
		{
			model.lessonMenuVisible = !model.lessonMenuVisible;	
			if( model.lessonMenuVisible )
			{
				model.focusedButton = Constants.LESSON_MENU_BUTTON;			
				dispatcher.dispatchEvent( new AccessibilityEvent(AccessibilityEvent.SET_FOCUS, Constants.LESSON_MENU) );
			}
			else
				dispatcher.dispatchEvent( new AccessibilityEvent(AccessibilityEvent.SET_FOCUS, Constants.LESSON_MENU_BUTTON) );
		}
		
		public function closeMenu( e:Event=null ):void
		{
			model.lessonMenuVisible = false;
			dispatcher.dispatchEvent( new AccessibilityEvent(AccessibilityEvent.SET_FOCUS, Constants.LESSON_MENU_BUTTON) );
		}
		
		public function jump( index:uint ):void
		{
			dispatcher.dispatchEvent( new NavigationEvent(NavigationEvent.JUMP, index) );
		}
		
		public function returnToReview():void
		{
			dispatcher.dispatchEvent( new NavigationEvent(NavigationEvent.JUMP, Constants.ASSESSMENT) );
		}
	}
}