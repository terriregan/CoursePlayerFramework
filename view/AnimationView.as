package org.nflc.framework.view
{
	import flash.events.Event;
	import flash.events.FocusEvent;
	
	import mx.controls.SWFLoader;
	import mx.managers.IFocusManagerComponent;
	import flash.display.Shape;
	
	import org.nflc.framework.domain.Screen;
	import org.nflc.framework.event.LoadEvent;
	import org.nflc.framework.event.LogEvent;
	import org.nflc.framework.model.Constants;
	import org.nflc.framework.util.ErrorUtil;
	
	public class AnimationView extends SWFLoader implements IContentView
	{
		public function set currentScreen( value:Screen ):void
		{
			dispose();
			if( value )
			{
				if( value.type == Constants.ANIMATION || 
					value.type == Constants.VIDEO )
				{
					dispatchEvent( new LogEvent(LogEvent.LOG, this + " AnimationView - _file " + value.file, true) );
					this.source =  value.file;
				}
			}
			else
			{
				// do clean up?
			}
		}
		
		public function dispose():void
		{
			dispatchEvent( new LogEvent(LogEvent.LOG, "AnimationView - unloading " + this.source, true) );
			this.unloadAndStop();
			this.source = null;
		}
		
		public function AnimationView()
		{
			super();
			//addEventListener( FocusEvent.KEY_FOCUS_CHANGE, onFocusChange );
		}	
		
		// Add mask to ensure that the animaiton does not "bleed over" into main content
		// The -3 on the width accounts for the 3 pixl border around main content area
		// The border is in the MainContentView skin file in the applicable course
		// NOT SURE IF THIS NEEDS TO BE ADDED
		/*private function init():void 
		{
			var s:Shape = new Shape();
			s.graphics.beginFill( 0xFFFFFF );
			s.graphics.drawRect(0, 0, 761, 498 );
			s.graphics.endFill();
			addChild(s);
			s.visible = true;
			this.mask = s;
		}*/
		
		private function onFocusChange( e:FocusEvent ):void
		{
			trace("change");
		}
	}
}