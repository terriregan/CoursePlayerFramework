package org.nflc.framework.domain
{
	import org.nflc.framework.domain.Assessment;
	
	public class LessonConfiguration
	{
		//--------------------------------------------------------------------------------------
		//  Make sure the first line of your embedded XML file does not have a XML header e.g:
		// <?xml version="1.0" encoding="UTF-8" standalone="no" ?>
		// or it will not compile correctly and trhow errors
		//--------------------------------------------------------------------------------------	
		[Embed(source="assets/data/accessibility.xml")]
		public static var accessibilityPrompts:Class;
		
		public static var lmsTrackingOn:Boolean;
		public static var lmsType:String;
		public static var enableLMS:Boolean;
		public static var activityXMLInSeparateFiles:Boolean;
		public static var forceActivityCompleteBeforeContinue:Boolean;			// should the "NEXT" button on the main UI be disabled until the user attempts to answer
		public static var activityConfiguration:XML;
		public static var navigationButtons:XML;
		[Bindable] public static var assessment:Assessment;
		public static var videoTemplate:String;
	}
}