package org.nflc.framework.presentation
{
	import flash.accessibility.Accessibility;
	import flash.accessibility.AccessibilityProperties;
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.system.Capabilities;
	
	import mx.containers.ViewStack;
	import mx.controls.SWFLoader;
	
	import org.nflc.framework.domain.LessonConfiguration;
	import org.nflc.framework.domain.Screen;
	import org.nflc.framework.event.AccessibilityEvent;
	import org.nflc.framework.event.LoadEvent;
	import org.nflc.framework.event.LogEvent;
	import org.nflc.framework.event.ScreenEvent;
	import org.nflc.framework.model.AppModel;
	import org.nflc.framework.model.Constants;
	import org.nflc.framework.util.ErrorUtil;
	import org.nflc.framework.view.MainContentView;
	import org.nflc.managers.AccessibilityManager;
	
	import spark.components.NavigatorContent;
	
	public class MainContentViewPresentationModel
	{
		private var _screenVolume:Number = 1;
		private var _screenCaptionsDisplay:Boolean = false;
		private var _timeline:*;
		private var _currentScreen:Screen;
		
		[Dispatcher]
		public var dispatcher:IEventDispatcher;
		
		[Bindable]
		public var isLoading:Boolean = true;
		
		[Bindable]
		public var selectedIndex:uint;
		
		public var selectedView:String;
		
		public var view:MainContentView;
		
		[Bindable]
		public var currentScreen:Screen;
	
				
		[EventHandler(event="ScreenEvent.CHANGE", properties="screen")]
		public function handleScreenChange( screen:Screen ):void
		{
			// trace('MainContentViewPresentationModel ' + screen.screenNumber)
			isLoading = true;
			
			// get/save the current props before load next screen
			saveScreenProperties();
			
			dispatcher.dispatchEvent( new LogEvent(LogEvent.LOG, "MainContentViewPresentationModel - set currentScreen: " + screen.source + "  " + screen.file) );
			
			// set new screen
			currentScreen = screen;
		}
						
			
		public function displayReadyState( e:Event ):void
		{
			
			if( e.target is SWFLoader )
			{
				_timeline = SWFLoader(e.target).content;
				_timeline.addEventListener( Event.REMOVED_FROM_STAGE, onRemoveFromStage );
				initializeScreenProperties();
			}
			
			if( currentScreen )
			{
				setSelecteIndex();
				isLoading = false;
				dispatcher.dispatchEvent( new AccessibilityEvent(AccessibilityEvent.UPDATE_SCREEN_INFO, currentScreen ) );
			}
			dispatcher.dispatchEvent( new LogEvent(LogEvent.LOG, "MainContentViewPresentationModel - COMPLETE displayReadyState:  " + currentScreen.file + "\n\n") );
			
		}
		
		private function onRemoveFromStage( e:Event ):void
		{
			dispatcher.dispatchEvent( new LogEvent(LogEvent.LOG, "Animation remove from stage") );
		}
		
		private function initializeScreenProperties():void  // should this be in controller or model (no deals with view)
		{
			if( _timeline != null )
			{
				if( _timeline.hasOwnProperty('setMediaVolume') )
				{
					_timeline.setMediaVolume( _screenVolume );
					_timeline.setCaptionsOn( _screenCaptionsDisplay );
				}
				
				if( currentScreen.type == Constants.VIDEO && 
					_timeline.hasOwnProperty('setMediaSource') ) 
				{
					_timeline.setMediaSource( currentScreen.source );
				}
			}
		}
		
		public function saveScreenProperties():void
		{
			if( _timeline != null &&  _timeline.hasOwnProperty('getMediaVolume') )
			{
				var vol:Number = _timeline.getMediaVolume();  // only save volume if it is a valid number
				if( vol >= 0 )
				{
					_screenVolume = vol;
				}
				
				if( _timeline.hasOwnProperty('checkForControlBar') ) // in some loaded screens, there is no control bar or media (i.e. intro, explore it need to handle that)
				{
					if( _timeline.checkForControlBar() && 
						_timeline.hasOwnProperty('getCaptionsOn'))
					{
						_screenCaptionsDisplay = _timeline.getCaptionsOn();  
					}
				}
				_timeline = null;
			}
		}
		
		private function setSelecteIndex():void
		{
			switch( currentScreen.type )
			{
				case Constants.ANIMATION:
				case Constants.VIDEO:
					selectedIndex = 0;
					break;
				
				case Constants.ACTIVITY:
					selectedIndex = 1;
					break;
				
				case Constants.ASSESSMENT:
					selectedIndex = 2;
					break;
				
				case Constants.MODULE:
					selectedIndex = 3;
					break;
				
			}	
		}
		
	}
}