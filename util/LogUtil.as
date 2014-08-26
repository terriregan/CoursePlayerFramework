package org.nflc.framework.util
{
	import flash.events.IEventDispatcher;
	import mx.controls.Alert;
	import flash.events.KeyboardEvent;
	import mx.core.FlexGlobals;
	import org.nflc.managers.KeyCodes;

	public final class LogUtil 
	{
		private static var _instance:LogUtil;
		private static var _log:Array = new Array();
		
		
		public function LogUtil( enforcer:SingletonEnforcer ) 
		{
			FlexGlobals.topLevelApplication.stage.addEventListener( KeyboardEvent.KEY_UP, keyHandler );
		}
		
		private function keyHandler( e:KeyboardEvent ):void
		{
			if( e.keyCode == 49 && e.shiftKey && e.ctrlKey )
				show();
		}
		
		public static function getInstance():LogUtil 
		{
			if( _instance == null ) 
			{
				_instance = new LogUtil( new SingletonEnforcer() );
			}
			return _instance;
		}
		
		
		public function show():void
		{		
			Alert.show( _log.join('\n'), "LOG" );
		}	
		
		public function add( msg:String ):void
		{		
			_log.push( msg );
		}	
	}
}
class SingletonEnforcer {}