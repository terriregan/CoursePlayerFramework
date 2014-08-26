package org.nflc.framework.presentation
{
	import org.nflc.framework.domain.Screen;
	import org.nflc.framework.event.LoadEvent;
	import org.nflc.framework.event.WindowEvent;
	import org.nflc.framework.model.AppModel;
	import org.nflc.framework.model.Constants;

	public class MainViewPresentationModel
	{
		
		[Dispatcher]
		public var dispatcher:IEventDispatcher;
		
		[Bindable]
		public var lessonMenuVisible:Boolean = false;
		
		[Bindable]
		[Inject("appModel", bind="true")]
		public var model:AppModel;
		
		[Bindable]
		[Inject("appModel.totalScreens", bind="true")]
		public var totalScreens:int;
		
		[Bindable]
		[Inject("appModel.lessonTitle", bind="true")]
		public var lessonTitle:String;
		
		[Bindable]
		[Inject("appModel.currentScreen", bind="true")]
		public var currentScreen:Screen;
		
		[Bindable]
		[Inject("appModel.resources.length", bind="true")]
		public var numResources:int;
		
		
		[EventHandler(event="WindowEvent.OPEN", properties="window")]
		public function showWindow( window:String ):void
		{
			if( window == Constants.LESSON_MENU )
				lessonMenuVisible = true;
		}
		
		[EventHandler(event="WindowEvent.CLOSE")]
		public function hideWindow():void
		{
			lessonMenuVisible = false;
		}
	}
}