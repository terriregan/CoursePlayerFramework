package org.nflc.framework.model
{
	import flash.events.IEventDispatcher;
	
	import org.nflc.activities.model.SessionData;
	import org.nflc.framework.domain.Screen;
	import org.nflc.framework.event.LessonEvent;
	import org.nflc.framework.event.LogEvent;
	import org.nflc.framework.event.ScreenEvent;
	import org.nflc.framework.event.WindowEvent;
	import org.nflc.framework.model.Constants;
	
	
	public class AppModel 
	{
		public var debug:Boolean = false;
		public var showCertificate:Boolean = false;
		
		public var courseId:String;
		public var focusedButton:String = "";
		
		private var _lessonId:String;
		private var _currentScreen:Screen;
		private var _lessonMenuVisible:Boolean = false;
					
		[Dispatcher] public var dispatcher:IEventDispatcher;
		
		[Bindable] public var screens:Array;
		
		[Bindable] public var totalScreens:int;
		
		[Bindable]	public var lessonTitle:String;
		
		[Bindable]	public var introTitle:String;
		
		[Bindable]	public var duration:String;
		
		// from config.properties
		[Bindable]	public var publication:String;
		
		// from config.properties
		[Bindable]	public var info:String;
		
		// from config.properties
		[Bindable]	public var curriculum:String;
		
		[Bindable]	public var assessmentQuestions:Array;
		
		[Bindable]	public var prereqs:Array;
		
		[Bindable]	public var lessons:Array;
		
		[Bindable]	public var resources:Array;
		
		[Bindable]	public var glossary:XML;
		
		[Bindable]	public var acronyms:XML;
		
		[Bindable]	public var shortcuts:XML;
		
		
		[Bindable]	
		public function get currentScreen():Screen
		{
			return _currentScreen;
		}
		
		public function set currentScreen( value:Screen ):void
		{
			if( _currentScreen != value )
			{
				_currentScreen = value;
				dispatcher.dispatchEvent( new LogEvent(LogEvent.LOG, "AppModel - set currentScreen") );
			
				// if activity screen & if a user has not responded, create  a user response object
				if( _currentScreen.type == Constants.ACTIVITY && 
					!_currentScreen.activity.sessionData )
				{
					_currentScreen.activity.sessionData = new SessionData( currentScreen.activity.id ); // this should happen in screen NOT model
				}
				
				dispatcher.dispatchEvent( new ScreenEvent(ScreenEvent.CHANGE, _currentScreen) );
			}
		}
		
		[Bindable(Event="lessonChanged")]	
		public function get lessonId():String
		{
			return _lessonId;
		}

		public function set lessonId( value:String ):void
		{
			if( value != _lessonId )
			{
				_lessonId = value;
				dispatcher.dispatchEvent( new LessonEvent( LessonEvent.CHANGE, _lessonId ) );
			}
		}
		
		public function get lessonMenuVisible():Boolean
		{
			return _lessonMenuVisible;
		}
		
		public function set lessonMenuVisible( value:Boolean ):void
		{
			if( value != _lessonMenuVisible )
			{
				_lessonMenuVisible = value;
				if( _lessonMenuVisible )
					dispatcher.dispatchEvent( new WindowEvent(WindowEvent.OPEN, Constants.LESSON_MENU) );
				else
					dispatcher.dispatchEvent( new WindowEvent(WindowEvent.CLOSE, Constants.LESSON_MENU) );
			}
		}

	}
}