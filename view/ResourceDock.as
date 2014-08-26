package org.nflc.framework.view
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.controls.SWFLoader;
	import mx.core.FlexGlobals;
	import mx.core.UIComponent;
	import mx.events.FlexEvent;
	
	import org.nflc.common.IconButtonBitmap;
	import org.nflc.common.KeyboardController;
	import org.nflc.common.ResizableTitleWindow;
	import org.nflc.common.WindowManager;
	import org.nflc.framework.component.ListItem;
	import org.nflc.framework.domain.LessonConfiguration;
	import org.nflc.framework.event.AccessibilityEvent;
	import org.nflc.framework.event.DocumentEvent;
	import org.nflc.framework.event.LoadEvent;
	import org.nflc.framework.event.WindowEvent;
	import org.nflc.framework.model.AppModel;
	import org.nflc.framework.model.Constants;
	import org.osmf.elements.AudioElement;
	import org.osmf.media.MediaPlayer;
	import org.osmf.media.URLResource;
	
	import spark.components.Group;
	import spark.components.Label;
	import spark.components.VGroup;
	import spark.components.supportClasses.SkinnableComponent;
	
	import utils.array.getItemByKey;

	[SkinState("normal")]
	[SkinState("assessment")]
	public class ResourceDock extends SkinnableComponent
	{
		private var _keyboardController:KeyboardController
		private var _glossaryView:SearchableListView;
		private var _acronymView:SearchableListView;
		private var _resourceView:ListView;
		private var _helpView:HelpView;
		private var _glossary:XML;
		private var _acronyms:XML;
		private var _glossaryTimer:Timer;
		private var _aronymnTimer:Timer;
		private var _helpTimer:Timer;
		private var _player:MediaPlayer;
		private var _element:AudioElement;
		
		[SkinPart(required="false")] 
		public var glossaryBtn:IconButtonBitmap;
		
		[SkinPart(required="false")] 
		public var acronymsBtn:IconButtonBitmap;
		
		[SkinPart(required="false")] 
		public var helpBtn:IconButtonBitmap;
		
		[SkinPart(required="false")] 
		public var resourcesBtn:IconButtonBitmap;
		
		[SkinPart(required="false")] 
		public var transcriptBtn:IconButtonBitmap;
		
		[SkinPart(required="false")] 
		public var equationsBtn:IconButtonBitmap;
			
		[Inject("appModel", bind="true")]
		public var appModel:AppModel;
		
		// TO DO - consolidate window timer/ handlers
		
		[Inject("appModel.glossary", bind="true")]
		public function set glosssary( value:XML ):void
		{
			if( value )
			{
				_glossaryView.courseId = appModel.courseId;
				_glossaryView.xml = value;
				_glossaryView.currentState = "content";
			}
		}		
		
		[Inject("appModel.acronyms", bind="true")]
		public function set acronyms( value:XML ):void
		{
			if( value )
			{
				_acronymView.courseId = appModel.courseId;
				_acronymView.xml = value;
				_acronymView.currentState = "content";
			}
		}	
		
		[Inject("appModel.shortcuts", bind="true")]
		public function set shortcuts( value:XML ):void
		{
			if( value )
				_helpView.xml = value;
		}	
		
		public function ResourceDock() 
		{
			this.addEventListener( FlexEvent.CREATION_COMPLETE, init );
		}
		
		private function init( e:FlexEvent ):void
		{
			this.removeEventListener( FlexEvent.CREATION_COMPLETE, init );
			
			// 508 - create keys that will respond to "SPACE" or "ENTER" when focused on
			_keyboardController = KeyboardController.getInstance();
			_keyboardController.setFocusManager( focusManager );
			
			if( LessonConfiguration.assessment == null )
			{
				_keyboardController.createHotKey(  glossaryBtn, openResource, [Constants.GLOSSARY_WIN] );
				_keyboardController.createHotKey(  acronymsBtn, openResource, [Constants.ACRONYMS_WIN] );
				_keyboardController.createHotKey(  helpBtn, openResource, [Constants.HELP_WIN] );
				_keyboardController.createHotKey(  resourcesBtn, openResource, [Constants.RESOURCE_WIN] );
				_keyboardController.createHotKey(  transcriptBtn, openResource, [Constants.TRANSCRIPT_WIN] );
				
				if( appModel.courseId == 'wf' ) // move this to lesson config file
					_keyboardController.createHotKey(  equationsBtn, openResource, [Constants.EQUATIONS_WIN] );
				
			}
			else
			{
				_keyboardController.createHotKey(  helpBtn, openResource, [Constants.HELP_WIN] );
			}
		}
				
		private function loadResource(resource:String, title:String ):void
		{
			var swf:SWFLoader = new SWFLoader();
			swf.source = resource;
			WindowManager.getInstance().createPopUp( swf, title, 520, 400, 150, 80, false );
		}
				
		private function timerHandler( e:TimerEvent ):void
		{
			_glossaryTimer.removeEventListener( TimerEvent.TIMER, timerHandler );
			_glossaryTimer = null;
			var document:Object = getItemByKey( appModel.resources, "id", "glossary" );
			
			if( document )
				dispatchEvent( new LoadEvent(LoadEvent.LOAD, document.filename) );
		}
		
		private function helpHandler( e:TimerEvent ):void
		{
			_helpTimer.removeEventListener( TimerEvent.TIMER, helpHandler );
			_helpTimer = null;
			dispatchEvent( new LoadEvent(LoadEvent.LOAD, "shortcuts.xml") );
		}
		
		private function acronTimerHandler( e:TimerEvent ):void
		{
			_aronymnTimer.removeEventListener( TimerEvent.TIMER, acronTimerHandler );
			_aronymnTimer = null;
			var document:Object = getItemByKey( appModel.resources, "id", "acronymns" );
			if( document )
				dispatchEvent( new LoadEvent(LoadEvent.LOAD, document.filename) );
		}
		
		override protected function getCurrentSkinState():String 
		{ 
			var state:String = "normal";
			if(  LessonConfiguration.assessment != null )
			{
				state = "assessment";
			}
			return state;
		}
		
		[EventHandler(event="WindowEvent.OPEN", properties="window")]
		public function openResource( window:String ):void
		{
			var document:Object;
			var win:ResizableTitleWindow;
			switch ( window )
			{
				case Constants.TRANSCRIPT_WIN:
					document = getItemByKey( appModel.resources, "id", "transcript" );
					if( document )
						dispatchEvent( new DocumentEvent(DocumentEvent.OPEN, appModel.lessonId + document.filename) );
					break;
				
				case Constants.EQUATIONS_WIN:
					document = getItemByKey( appModel.resources, "id", "equations" );
					if( document )
						dispatchEvent( new DocumentEvent(DocumentEvent.OPEN, document.filename) );
					break;
				
				case Constants.HELP_WIN:
					if( !_helpView )
					{
						// delay data loading to give window time to display
						_helpView = new HelpView();
						_helpView.printableDocument = appModel.courseId + ".help.print.pdf";
						document = getItemByKey( appModel.resources, "id", "help" );	
						if( document )
							_helpView.items = document.data;
						_helpTimer = new Timer( 500 );
						_helpTimer.addEventListener( TimerEvent.TIMER, helpHandler );
						_helpTimer.start();
					}
					
					win = WindowManager.getInstance().createPopUp( _helpView, Constants.HELP_WIN, 500, 400, 150, 30, false );
					_keyboardController.createHotKey(  win.closeButton, WindowManager.getInstance().close, [win] );
					win.addEventListener( "show", _helpView.activate );
					win.addEventListener( "hide", _helpView.dispose );
					
					break;
				
				case Constants.GLOSSARY_WIN:
					if( !_glossaryView )
					{
						// delay data loading to give window time to display
						_glossaryView = new SearchableListView();
						_glossaryView.printableDocument = appModel.courseId + ".glossary.pdf";
						_glossaryTimer = new Timer( 500 );
						_glossaryTimer.addEventListener( TimerEvent.TIMER, timerHandler );
						_glossaryTimer.start();
					}	
					
					win = WindowManager.getInstance().createPopUp( _glossaryView, Constants.GLOSSARY_WIN, 620, 500, 100, 30, false );
					_keyboardController.createHotKey(  win.closeButton, WindowManager.getInstance().close, [win] );
					win.addEventListener( "show", _glossaryView.activate );
					win.addEventListener( "hide", _glossaryView.dispose );
				
					break;
				
				case Constants.RESOURCE_WIN:
					document = getItemByKey( appModel.resources, "id", "resources" );
					if( !_resourceView )
					{
						_resourceView = new ListView();
						if( document )
						{
							_resourceView.items = document.data;
						}
					}
					
					win = WindowManager.getInstance().createPopUp( _resourceView, Constants.RESOURCE_WIN, 400, 300, 180, 50, false );
					_keyboardController.createHotKey(  win.closeButton, WindowManager.getInstance().close, [win] );
					win.addEventListener( "show", _resourceView.activate );
					win.addEventListener( "hide", _resourceView.dispose );
					break;
				
				case Constants.ACRONYMS_WIN:
					if( !_acronymView )
					{
						// delay data loading to give window time to display
						_acronymView = new SearchableListView();
						_acronymView.isExportable = false;
						_acronymView.printableDocument = appModel.courseId + ".acronyms.pdf";
						_aronymnTimer = new Timer( 500 );
						_aronymnTimer.addEventListener( TimerEvent.TIMER, acronTimerHandler );
						_aronymnTimer.start();
					}	
					win = WindowManager.getInstance().createPopUp( _acronymView, Constants.ACRONYMS_WIN, 620, 500, 100, 30, false );
					_keyboardController.createHotKey(  win.closeButton, WindowManager.getInstance().close, [win] );
					win.addEventListener( "show", _acronymView.activate );
					win.addEventListener( "hide", _acronymView.dispose );
					break;
			}
		}	
		
	}
}