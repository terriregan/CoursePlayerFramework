package org.nflc.framework.view
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	
	import mx.controls.SWFLoader;
	import mx.managers.IFocusManagerComponent;
	
	import org.nflc.framework.domain.Screen;
	import org.nflc.framework.event.LoadEvent;
	import org.nflc.framework.model.Constants;
	
	public class VideoView extends SWFLoader implements IContentView
	{
		public function set currentScreen( value:Screen ):void
		{
			dispose();
			if( value )
			{
				if( value.type == Constants.VIDEO )
				{
					this.source = value.file;
				}
			}
			else
			{
				// do clean up?
			}
		}
		
		public function dispose():void
		{
			this.unloadAndStop();
		}
		
		public function VideoView()
		{
			super();
		}	
		
	}
}