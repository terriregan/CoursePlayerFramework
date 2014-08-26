package org.nflc.framework.controller
{
	import com.nudoru.lms.*;
	import com.nudoru.lms.scorm.SCORMFacade;
	import com.nudoru.lms.scorm.SCOStatus;
	
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.core.FlexGlobals;
	import mx.logging.ILogger;
	import mx.logging.Log;
	import mx.resources.ResourceManager;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.FaultEvent;
	import mx.rpc.events.ResultEvent;
	
	import org.nflc.activities.model.ConfigurationManager;
	import org.nflc.common.WindowManager;
	import org.nflc.framework.event.WindowEvent;
	import org.nflc.framework.domain.Assessment;
	import org.nflc.framework.domain.LessonConfiguration;
	import org.nflc.framework.domain.Screen;
	import org.nflc.framework.event.AccessibilityEvent;
	import org.nflc.framework.event.CourseModeEvent;
	import org.nflc.framework.event.DocumentEvent;
	import org.nflc.framework.event.LMSEvent;
	import org.nflc.framework.event.LoadEvent;
	import org.nflc.framework.event.NavigationEvent;
	import org.nflc.framework.model.AppModel;
	import org.nflc.framework.model.Constants;
	import org.nflc.framework.service.LessonDelegate;
	import org.nflc.framework.util.ErrorUtil;
	import org.nflc.framework.util.LessonUtil;
	import org.nflc.framework.util.LogUtil;
	import org.nflc.managers.KeyCodes;
	import org.nflc.util.DocumentOpener;
	import org.swizframework.storage.SharedObjectBean;
	import org.swizframework.utils.services.ServiceHelper;
	import org.nflc.framework.event.LogEvent;
	
	import utils.array.copyArray;
	import utils.array.getItemByKey;
	import utils.array.getItemsByKey;
	
	public class AppController
	{
		// logger
		protected static const LOG:ILogger = Log.getLogger( "AppController" );
		
		[Inject]
		public var model:AppModel;
		
		[Inject]
		public var serviceHelper:ServiceHelper;
		
		[Inject]
		public var soBean:SharedObjectBean;
		
		[Inject]
		public var delegate:LessonDelegate;
		
		[Inject]
		public var lmsProtocol:SCORMFacade;
				
		[Dispatcher]
		public var dispatcher:IEventDispatcher;
		
		private var _filesToLoad:Array;
		private var _activityConfigLoaded:Boolean = false;
		private var _pendingScreen:Screen;
		private var _windowManager:WindowManager = WindowManager.getInstance();
		
		public function AppController()
		{
			XML.ignoreWhitespace = true;
		}
		
		//--------------------------------------------------------------------------
		//
		// Loading/parsing handlers
		//
		//--------------------------------------------------------------------------
		
		
		private function loadConfigurationResultHandler( e:ResultEvent ):void 
		{
			try 
			{
				var xml:XML = e.result as XML;
				parseConfig( xml );
			}
			catch( error: Error )
			{
				ErrorUtil.showError( 'Unable to parse configuration file: ' + error.message );
				return;
			}
			checkForStartStatus();
		}
		
		private function loadGlossaryResultHandler( e:ResultEvent ):void 
		{
			try 
			{
				var xml:XML = e.result as XML;
				model.glossary = xml;
			}
			catch( error: Error )
			{
				ErrorUtil.showError( 'Unable to load glossary: ' + error.message );
				return;
			}
		}
		
		private function loadShortcutResultHandler( e:ResultEvent ):void 
		{
			try 
			{
				var xml:XML = e.result as XML;
				model.shortcuts = xml;
			}
			catch( error: Error )
			{
				ErrorUtil.showError( 'Unable to load shortucts: ' + error.message );
				return;
			}
		}
		
		private function loadAcronymResultHandler( e:ResultEvent ):void 
		{
			try 
			{
				var xml:XML = e.result as XML;
				model.acronyms = xml;
			}
			catch( error: Error )
			{
				ErrorUtil.showError( 'Unable to load glossary: ' + error.message );
				return;
			}
		}
	
		private function loadManifestResultHandler( e:ResultEvent ):void 
		{
			try 
			{
				var xml:XML = e.result as XML;
				parseManifest( xml );
			}
			catch( error: Error )
			{
				ErrorUtil.showError( 'Unable to load parse manifest: ' + error.message );
				return;
			}
			checkForStartStatus();
		}
		
		private function loadActivityResultHandler( e:ResultEvent ):void 
		{
			try 
			{
				var xml:XML = e.result as XML;
				LessonUtil.updateActivityXML( xml, _pendingScreen );
				updateCurrentScreen();
			}
			catch( error: Error )
			{
				ErrorUtil.showError( 'Unable to parse activity xml file: ' + error.message );
				return;
			}
		}
		
		private function onActivityConfigReady( e:Event ):void
		{
			_activityConfigLoaded = true;
			ConfigurationManager.getInstance().removeEventListener( Event.COMPLETE, onActivityConfigReady );
			checkForStartStatus();
		}
		
		private function loadFaultHandler( e:FaultEvent ):void 
		{
			ErrorUtil.showError( e.toString() );
		}
		
		private function parseConfig( xml:XML ):void
		{
			LessonConfiguration.activityXMLInSeparateFiles = ( xml.activityXMLInSeparateFiles == "true" ) ? true : false;
			LessonConfiguration.forceActivityCompleteBeforeContinue = ( xml.forceActivityCompleteBeforeContinue == "true" ) ? true : false;
			LessonConfiguration.activityConfiguration = xml.activityConfiguration[0];
			LessonConfiguration.navigationButtons = xml.LOConfiguration.buttons[0];
			LessonConfiguration.videoTemplate = xml.animationConfiguration.template.@file;
			
			LessonConfiguration.lmsTrackingOn = ( xml.lmsTrackingOn == "true" ) ? true : false;
			LessonConfiguration.enableLMS = ( xml.enableLMS == "true" ) ? true : false;
			LessonConfiguration.lmsType = xml.lmsVersion;	
						
			if( xml.LOConfiguration.hasOwnProperty('assessment') )
			{
				var assessment:Assessment = new Assessment();
				assessment.randomizeQuestions = ( xml.LOConfiguration.assessment.randomizeQuestions == "true" ) ? true : false;
				assessment.numberOfQuestions = xml.LOConfiguration.assessment.numberOfQuestions;
				assessment.numberOfMandatoryQuestions = xml.LOConfiguration.assessment.numberOfMandatoryQuestions;
				assessment.reviewText = xml.LOConfiguration.assessment.reviewText;
				assessment.notAnsweredText = xml.LOConfiguration.assessment.notAnsweredText;
				assessment.submitText = xml.LOConfiguration.assessment.submitText;
				assessment.incorrectText = xml.LOConfiguration.assessment.incorrectText;
				assessment.correctText = xml.LOConfiguration.assessment.correctText;
				assessment.passingScore = Number( xml.LOConfiguration.assessment.passingScore );
				assessment.showCertificate = ( xml.LOConfiguration.assessment.certificate.@show == "true" ) ? true : false;
				assessment.certificate = xml.LOConfiguration.assessment.certificate;
				LessonConfiguration.assessment = assessment;
			}	
			
			model.info = xml.courseConfiguration.info;	
			model.publication = xml.courseConfiguration.publication;	
			model.curriculum = xml.courseConfiguration.curriculum;
		
			initializeActivityConfig();
		}
		
		private function parseManifest( xml:XML ):void
		{
			model.courseId  = LessonUtil.getCourseIdFromXML( xml );
			model.lessonTitle = LessonUtil.getTitleFromXML( xml );
			model.screens = LessonUtil.getScreensFromXML( xml, model.lessonId );
			model.lessons = LessonUtil.geLessonsFromXML( xml );
			model.resources = LessonUtil.getResourcesFromXML( xml );
			model.totalScreens = model.screens.length;
			model.prereqs = LessonUtil.getPrereqsFromXML( xml );
			model.duration = LessonUtil.getDurationFromXML( xml );
			model.introTitle = LessonUtil.getIntroTitleFromXML( xml );			
		}
		
		private function initializeActivityConfig():void
		{
			ConfigurationManager.getInstance().addEventListener( Event.COMPLETE, onActivityConfigReady );
			
			if( LessonConfiguration.assessment )
				ConfigurationManager.getInstance().testMode = true;
			
			// initialize activities - this should be hard coded in acitivies framework? -- path  needs to be dynamically determined
			ConfigurationManager.getInstance().initialize( "activity.xml", 
				LessonConfiguration.activityConfiguration );
		}
		
		
		private function checkForStartStatus():void
		{
			_filesToLoad.pop();
			if( !_filesToLoad.length && _activityConfigLoaded )
			{
				dispatcher.dispatchEvent( new LoadEvent(LoadEvent.READY) );
				checkForAssessment();
				setUpKeyboardSensor();
				
				if( LessonConfiguration.enableLMS && lmsProtocol ) 
				{	
					lmsProtocol.initialize( LessonConfiguration.lmsType );
				}
				else
					gotoScreen(0)  // not in LMS, go to first screen.  TODO: add LSO storage
			}
		}
		
		private function checkForAssessment():void
		{
			if( LessonConfiguration.assessment )
			{
				var firstScreen:Screen = model.screens[0] as Screen;
				var lastScreen:Screen = model.screens[model.screens.length-1] as Screen;
				
				var activities:Array;
				
				// get all screens that are of type "Activity"
				if( model.debug )
					activities = getItemsByKey( model.screens, "type", Constants.ACTIVITY );
				else
					activities = LessonUtil.configureAssessment( getItemsByKey( model.screens, "type", Constants.ACTIVITY ), 2 );
				
				lastScreen.screenNumber = activities.length + 2;
				
				// store just the activity screens for scoring purposes
				model.assessmentQuestions = copyArray( activities );			
				
				// wrap the activities in the first screen (intro) and the last screen (review/results)
				activities.unshift( firstScreen );
				activities.push( lastScreen );
				
				// update the model with the new screens configuration
				model.screens = activities;
				
				// update the total num screens as all are not used due to question pooling
				model.totalScreens = model.screens.length;
			}
		}
		
		private function setUpKeyboardSensor():void
		{
			FlexGlobals.topLevelApplication.stage.addEventListener( KeyboardEvent.KEY_UP, keyHandler );
		}
		
		// Short cut keys
		private function keyHandler( e:KeyboardEvent ):void
		{
			// shortcuts that are always active regardless of lesson type
			if( e.ctrlKey && e.keyCode == Keyboard.HOME )
				dispatcher.dispatchEvent( new AccessibilityEvent(AccessibilityEvent.SET_FOCUS, Constants.GOTO_TOP) );
			
			if( e.ctrlKey && !e.shiftKey && e.keyCode == Constants.KEY_NEXT )
				goNext();
			
			if( e.ctrlKey && !e.shiftKey && e.keyCode == Constants.KEY_PREVIOUS )
				goPrevious();
			
			if( e.keyCode == Keyboard.TAB || (e.shiftKey && e.keyCode == Keyboard.TAB) )
				dispatcher.dispatchEvent( new AccessibilityEvent(AccessibilityEvent.STORE_FOCUS) );
			
			if( e.ctrlKey &&  e.keyCode == Constants.KEY_HELP )
				dispatchWindowEvent( Constants.HELP_WIN );		
			
			if( e.keyCode == Constants.KEY_CLOSE_WINDOW )
			{
				//if( _windowManager.windowOnTop && _windowManager.windowOnTop.focusManager )
				//	_windowManager.windowOnTop.focusManager.deactivate();
				_windowManager.closeWindows( Constants.RESOURCE_DOCK_WINDOWS );
				
				if( model.lessonMenuVisible )
					model.lessonMenuVisible = false;
				
				if( model.focusedButton != "" )
				{
					dispatcher.dispatchEvent( new AccessibilityEvent(AccessibilityEvent.SET_FOCUS, model.focusedButton) );
					model.focusedButton = "";
				}
			}
			
			// shortcuts that are active if we are in a regular lesson type
			if( LessonConfiguration.assessment == null )
			{
				if( e.ctrlKey && e.keyCode == Constants.KEY_TOGGLE_MENU )
					toggleLessonMenu();
				
				if( e.ctrlKey &&  e.keyCode == Constants.KEY_GLOSSARY )
					dispatchWindowEvent( Constants.GLOSSARY_WIN );
				
				if( e.ctrlKey &&  e.keyCode == Constants.KEY_ACRONYMS )
					dispatchWindowEvent( Constants.ACRONYMS_WIN );
				
				if( e.ctrlKey &&  e.keyCode == Constants.KEY_RESOURCES )
					dispatchWindowEvent( Constants.RESOURCE_WIN );
				
				if( e.ctrlKey &&  e.keyCode == Constants.KEY_TRANSCRIPT )
					dispatchWindowEvent( Constants.TRANSCRIPT_WIN );
				
				if( model.courseId == 'wf' ) // move this to lesson config file
				{
					if( e.ctrlKey &&  e.keyCode == Constants.KEY_EQUATIONS )
						dispatchWindowEvent( Constants.EQUATIONS_WIN );
				}
			}
			
			// shortcuts that are active only for the assessment lesson type
			else
			{
				if( e.ctrlKey && !e.shiftKey && e.keyCode == Constants.KEY_REVIEW )
					jump( Constants.ASSESSMENT );
				
				// only allow shortcut to open certificate if it is visible on stage
				if( model.showCertificate )
				{
					if( e.ctrlKey && !e.shiftKey && e.keyCode == Constants.KEY_CERTIFICATE )
					openDocument( model.lessonId + LessonConfiguration.assessment.certificate );
				}
			}
			
			// debugging
			if( e.keyCode == 57 && e.shiftKey && e.ctrlKey )  // shift+ctrl+9
				dispatcher.dispatchEvent( new LogEvent(LogEvent.TOGGLE) );
		}
		
		private function dispatchWindowEvent( window:String ):void
		{
			// put focus on applicable button before window opens so focus will return there upon window close
			model.focusedButton = window;
			dispatcher.dispatchEvent( new AccessibilityEvent(AccessibilityEvent.SET_FOCUS, window) );
			dispatcher.dispatchEvent( new WindowEvent( WindowEvent.OPEN, window) );
		}
		
		private function toggleLessonMenu():void
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
		
		private function gotoScreen( index:int ):void
		{
			dispatcher.dispatchEvent( new LogEvent(LogEvent.LOG, "AppController - go to screen") );
			if( model &&  model.screens )
			{
				_pendingScreen = model.screens[index];
				
				// if screen is an activity, which is in a separate file and
				// has not yet been loaded, load it
				if( _pendingScreen.type == Constants.ACTIVITY && 
					LessonConfiguration.activityXMLInSeparateFiles && 
					_pendingScreen.activity == null )
				{
					var call:AsyncToken = delegate.load( _pendingScreen.file );
					serviceHelper.executeServiceCall( call, loadActivityResultHandler, loadFaultHandler );
				}
				else
				{
					updateCurrentScreen();
				}
			}
		}
		
		private function updateCurrentScreen():void
		{
			dispatcher.dispatchEvent( new LogEvent(LogEvent.LOG, "AppController - updateCurrentScreen") );
			model.currentScreen = _pendingScreen;  // 0 based array index; 1 based screen index - this will set the animation/activity
			_pendingScreen = null;
			
			if( LessonConfiguration.enableLMS && lmsProtocol ) 
			{
				if( LessonConfiguration.assessment == null )
				{
					lmsProtocol.lastLocation = String( model.currentScreen.screenNumber );  // lms bookmark
					if( model.currentScreen.screenNumber == model.totalScreens )
					{
						lmsProtocol.lessonStatus = SCOStatus.COMPLETE;
						lmsProtocol.successStatus = SCOStatus.PASS;
					}
					else
					{
						lmsProtocol.lessonStatus = SCOStatus.INCOMPLETE;
					}
					lmsProtocol.commit();
				}
			}
		}
		
		private function getScreenNumber( screenName:String ):Screen
		{
			return getItemByKey( model.screens, "type", screenName );
		}
		
		//--------------------------------------------------------------------------
		//
		// Event Handlers
		//
		//--------------------------------------------------------------------------
		
		[EventHandler(event="LessonEvent.CHANGE", properties="lessonId")]
		public function loadLessonManifest( lessonId:String ):void
		{
			XML.ignoreWhitespace = false;
			XML.prettyPrinting = false;
			
			_filesToLoad = ["manifest", "config" ];
			
			// load lesson config file (config file needs to be loaded first as manifest uses some of its values
			var configCall:AsyncToken = delegate.load( lessonId +  "config.xml" );
			serviceHelper.executeServiceCall( configCall, loadConfigurationResultHandler, loadFaultHandler );
			
			// load lesson manifest
			var manifestCall:AsyncToken = delegate.load( lessonId +  "manifest.xml" );
			serviceHelper.executeServiceCall( manifestCall, loadManifestResultHandler, loadFaultHandler );
		}
		
		[EventHandler(event="LoadEvent.LOAD", properties="url")]
		public function loadGlossary( url:String ):void
		{
			var call:AsyncToken = delegate.load( url );
			if( url.indexOf('glossary') != -1 )
				serviceHelper.executeServiceCall( call, loadGlossaryResultHandler, loadFaultHandler );
			else if( url.indexOf('acronym') != -1 )
				serviceHelper.executeServiceCall( call, loadAcronymResultHandler, loadFaultHandler );
			else
				serviceHelper.executeServiceCall( call, loadShortcutResultHandler, loadFaultHandler );
		}
		
		[EventHandler(event="DocumentEvent.OPEN", properties="document")]
		public function openDocument( document:String ):void
		{
			DocumentOpener.open( document );
		}
		
		[EventHandler(event="NavigationEvent.GO_NEXT")]
		public function goNext():void
		{
			var nextScreen:int = model.currentScreen.screenNumber + 1;
			if( nextScreen <= model.screens.length )
			{
				gotoScreen( nextScreen - 1 ); 
				dispatcher.dispatchEvent( new AccessibilityEvent(AccessibilityEvent.SET_FOCUS, Constants.KEY_NEXT) );
			}
		}
	
		[EventHandler(event="NavigationEvent.GO_PREVIOUS")]
		public function goPrevious():void
		{
			var prevScreen:int = model.currentScreen.screenNumber - 1; 
			if( prevScreen >= 1 )
			{
				gotoScreen( prevScreen - 1 );
				dispatcher.dispatchEvent( new AccessibilityEvent(AccessibilityEvent.SET_FOCUS, Constants.KEY_PREVIOUS) );
			}
		}
		
		[EventHandler(event="NavigationEvent.JUMP", properties="screen" )]
		public function jump( screen:* ):void
		{
			if( screen is int )
				gotoScreen( screen );
			
			if( screen is String )
			{
				var jumpToScreen:Screen = getScreenNumber( screen );
				if( jumpToScreen )
					gotoScreen( jumpToScreen.screenNumber - 1 );  // screens array is zero-based so subtract 1
			}
			
			//dispatcher.dispatchEvent( new AccessibilityEvent(AccessibilityEvent.SET_FOCUS, Constants.LESSON_MENU) );
		}
		
		[EventHandler(event="AssessmentEvent.SCORE", properties="score")]
		public function recordAssesment( score:Number ):void
		{
			if( LessonConfiguration.enableLMS && lmsProtocol ) 
			{
				lmsProtocol.score = score;
				if( score >= LessonConfiguration.assessment.passingScore )
				{
					lmsProtocol.lessonStatus = SCOStatus.COMPLETE;
					lmsProtocol.successStatus = SCOStatus.PASS;
				}
				else
				{
					lmsProtocol.lessonStatus = SCOStatus.INCOMPLETE;
					lmsProtocol.successStatus = SCOStatus.FAIL;
				}
				lmsProtocol.commit();
			}	
			dispatcher.dispatchEvent( new NavigationEvent(NavigationEvent.DISABLE_BOTH) );
		}
		
		[EventHandler(event="LMSEvent.INITIALIZED")]
		public function onLMSInitialized():void
		{
			/*	if( lmsProtocol.suspendData )  this is getting all the other stuff, caption/volume state
				model.processSuspendData(lmsProtocol.suspendData); */ 
	
			if( lmsProtocol.lastLocation ) 
			{
				LogUtil.getInstance().add( "onLMSInitialized - go to screen " +  lmsProtocol.lastLocation);
				gotoScreen( int(lmsProtocol.lastLocation) - 1 );
			}
			else 
			{
				LogUtil.getInstance().add( "onLMSInitialized - go to FIRST screen " );
				gotoScreen(0);
			}
				
		}
		
		[EventHandler(event="LMSEvent.CANNOT_CONNECT")]
		public function onLMSCannotConnect():void
		{
			LogUtil.getInstance().add( "Can not connect to LMS" );
			dispatcher.dispatchEvent( new LogEvent(LogEvent.LOG, "AppController - onLMSCannotConnect - go to screen") );
			gotoScreen(0);
		}

	}
}