package org.nflc.framework.model
{
	import org.nflc.managers.KeyCodes;
	import flash.ui.Keyboard;
	
	final public class Constants
	{
		// course modes
		public static const STANDARD_MODE:String = "standardMode";	
		public static const TEST_MODE:String = "testMode";	
		
		// screen views
		public static const ACTIVITY:String = "activity";	
		public static const ANIMATION:String = "animation";	
		public static const ASSESSMENT:String = "assessment";
		public static const VIDEO:String = "video";
		public static const MODULE:String = "module";	
		public static const LOADING:String = "loading";	
		
		// nav to top of page
		public static const GOTO_TOP:String = "gotoTop";
				
		// hot keys (modifier is added to each)
		public static const KEY_GLOSSARY:uint = KeyCodes.NUM_1;
		public static const KEY_ACRONYMS:uint = KeyCodes.NUM_2;
		public static const KEY_HELP:uint = KeyCodes.NUM_3;
		public static const KEY_RESOURCES:uint = KeyCodes.NUM_4;
		public static const KEY_TRANSCRIPT:uint = KeyCodes.NUM_5;
		public static const KEY_EQUATIONS:uint = KeyCodes.NUM_6;
		public static const KEY_CERTIFICATE:uint = KeyCodes.NUM_7;
		
		public static const KEY_NEXT:uint = KeyCodes.PERIOD;
		public static const KEY_PREVIOUS:uint = KeyCodes.COMMA;
		public static const KEY_REVIEW:uint = KeyCodes.BACKSLASH;
		public static const KEY_SUBMIT:uint = Keyboard.ENTER;  // THIS MIGHT BE "SPACE"
		public static const KEY_CLOSE_WINDOW:uint = Keyboard.ESCAPE;
		public static const KEY_TOGGLE_MENU:uint = KeyCodes.SLASH;
						
		// window types
		public static const GLOSSARY_WIN:String = "GLOSSARY";
		public static const RESOURCE_WIN:String = "RESOURCES";
		public static const EQUATIONS_WIN:String = "EQUATIONS";
		public static const ACRONYMS_WIN:String = "ACRONYMS";
		public static const HELP_WIN:String = "HELP";
		public static const TRANSCRIPT_WIN:String = "TRANSCRIPT";
		public static const LESSON_MENU_BUTTON:String = "LESSON_MENU_BUTTON";
		public static const LESSON_MENU:String = "LESSON_MENU";
		
			
		public static const RESOURCE_DOCK_WINDOWS:Array = [ GLOSSARY_WIN, 
													   		RESOURCE_WIN, 
													   		EQUATIONS_WIN, 
													  		ACRONYMS_WIN, 
													   		HELP_WIN, 
													   		TRANSCRIPT_WIN ];
		
				
	}
}