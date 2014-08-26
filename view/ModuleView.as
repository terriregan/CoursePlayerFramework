package org.nflc.framework.view
{
	import flash.events.Event;
	
	import org.nflc.activities.factory.*;
	import org.nflc.framework.domain.Screen;
	import org.nflc.framework.model.Constants;
	import org.nflc.framework.view.IModuleView;
	import org.nflc.framework.view.IntroductionView;
	import org.nflc.framework.view.SummaryView;
	
	import spark.components.Group;
	
	[Event(name="complete", type="flash.events.Event")]
	public class ModuleView extends Group implements IContentView
	{
		public var view:IModuleView;
		
		public function set currentScreen( value:Screen ):void
		{
			dispose();
			if( value.type == Constants.MODULE )
			{
				if( value.file == "intro" )
				{
					view =  new IntroductionView();
					addElement( view );
				}
				
				if( value.file == "summary" )
				{
					view =  new SummaryView();
					addElement( view );
				}
				ready();
			}
		}

		public function ModuleView()
		{
			super();
		}	
		
		public function dispose():void
		{
			if( view )
			{
				view.dispose();
				removeElement( view );
				view = null;
			}
		}
		
		
		private function ready():void
		{
			dispatchEvent( new Event(Event.COMPLETE) );
		}
	}
}