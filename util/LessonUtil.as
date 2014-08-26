package org.nflc.framework.util
{
	import org.nflc.activities.model.ActivityData;
	import org.nflc.framework.domain.LessonConfiguration;
	import org.nflc.framework.domain.Screen;
	import org.nflc.framework.model.Constants;
	import org.nflc.framework.util.ErrorUtil;
	import org.nflc.managers.AccessibilityManager;
	
	import utils.array.getItemsByKey;
	import utils.array.randomize;
	import utils.array.removeItem;
	
	public class LessonUtil
	{
		public static function getScreensFromXML( xml:XML, id:String ):Array 
		{
			var screens:Array = [];
			
			for each( var data:XML in xml..screen ) 
			{
				var screen:Screen = new Screen();
				screen.title = data.@title;
				screen.screenNumber = data.@number;
				screen.type = data.@type;  // need to verify this as bad xml data could cause problems
				screen.lessonId = id;
				
				switch( screen.type )
				{
					case  Constants.ACTIVITY:
						if( data.hasOwnProperty('@mandatory') && data.@mandatory.length() )
							screen.mandatory =  data.@mandatory;
						
						if( !LessonConfiguration.activityXMLInSeparateFiles )
						{
							screen.file =  data.@file;
							var xmlData:XML =  xml..activity.( @id == (screen.file) )[0];
							LessonUtil.updateActivityXML( xmlData, screen );
						}
						else
						{
							screen.file =  id + data.@file;
						}
						break;
					
					case Constants.ANIMATION:
						screen.file =  id + data.@file;
						break;
					
					case Constants.VIDEO:
						// screen.file =  LessonConfiguration.videoTemplate; fix when have time
						screen.file =  "template_video.swf"; 
						screen.source =  id + data.@source;
						break;
					
					case  Constants.MODULE:
						screen.file =  data.@file;
						
				}
				
				// load an alternative summary if screen reader is active
				if( data.@summary == "true" )
				{
					if( AccessibilityManager.getInstance().usingScreenReader() )
					{
						screen.type = Constants.MODULE;
						screen.file =  "summary";
					}
				}
				screens.push( screen );
			}
			
			return screens;
		}
		
		public static function updateActivityXML( xml:XML, screen:Screen ):void 
		{
			if( xml )
			{
				screen.activity =  new ActivityData();
				screen.activity.content = xml;
				screen.activity.id = xml.@id;
				screen.activity.interactionType = xml.@interactionType;
			
				if( xml.hasOwnProperty('@loId') && xml.@loId.length() )
				{
					screen.activity.loId = xml.@loId;
				}
				// fetch user response from LMS or LSO if available
			}
		}
		
		public static function getDurationFromXML( xml:XML ):String 
		{
			return xml.estimated_duration;
		}
		
		public static function getTitleFromXML( xml:XML ):String 
		{
			return xml.title;
		}
		
		public static function getIntroTitleFromXML( xml:XML ):String 
		{
			return xml.introTitle;
		}
		
		public static function getCourseIdFromXML( xml:XML ):String 
		{
			return xml.@course;
		}
		
		public static function getPrereqsFromXML( xml:XML ):Array 
		{
			
			var prereqs:Array = [];
			for each( var prereq:XML in xml..prereq ) 
			{
				prereqs.push( prereq );
			}
			return prereqs;
		}
		
		
		public static function geLessonsFromXML( xml:XML ):Array 
		{
			var lessons:Array = [];
			var lesson:Object;
			for each( var lo:XML in xml..lo ) 
			{
				lesson = {};
				lesson.id = lo.@id;
				lesson.title = lo;
				lessons.push( lesson );
			}
			
			return lessons;
		}
		
		public static function getResourcesFromXML( xml:XML ):Array 
		{
			var resources:Array = [];
			var obj:Object;
			for each( var xml:XML in xml..resource ) 
			{
				obj = {};
				obj.id = xml.@id;
				obj.filename = xml;
				if( xml.hasComplexContent() )
				{
					obj.data = [];
					for each( var item:XML in xml.resource) 
					{
						obj.data.push( {"title": item.@title, "url": item} );
					}
				}
				resources.push( obj );
			}
			return resources;
		}
		
		
		
		public static function configureAssessment( activities:Array, startIndex:int ):Array 
		{
			// grab mandatory questions from activities
			var mandatory:Array = getItemsByKey( activities, "mandatory", true );
			
			// grab non-mandatory questions from activities
			var nonMandatory:Array = getItemsByKey( activities, "mandatory", false );
			
			if( AccessibilityManager.getInstance().usingScreenReader() )
				nonMandatory = removeActivitiesWithImage( nonMandatory );
			
			// determine how many non mandatory questions we need
			var numberOfRandomQuestions:uint = LessonConfiguration.assessment.numberOfQuestions - LessonConfiguration.assessment.numberOfMandatoryQuestions;
			
			// check to make sure we have the right number of mandatory questions
			if( LessonConfiguration.assessment.numberOfMandatoryQuestions !== mandatory.length )
				trace( "MandatoryQuestions : " + LessonConfiguration.assessment.numberOfMandatoryQuestions +  "\nActual MandatoryQuestions : " + mandatory.length );
		
			//  randomize nonMandatory questions 
			var randomNonMandatory:Array = randomize( nonMandatory )
			
			// extract the right number of non mandatory questions	
			randomNonMandatory.splice(numberOfRandomQuestions);
			
			// combine both arrays and randomize
			var combined:Array = mandatory.concat(randomNonMandatory);
			
			var screens:Array = ( LessonConfiguration.assessment.randomizeQuestions ) ? randomize( combined ) : combined;
			var len:int = screens.length;
			var screen:Screen;
			var i:int;
			var j:int;
			var k:int;
			for( i = 0, j = startIndex, k = 1; i < len; i++, j++, k++ )
			{
				screen = screens[i] as Screen;
				screen.screenNumber = j;
				screen.questionNumber = k;
			}
			
			return screens;
		}
		
		private static function removeActivitiesWithImage( arr:Array ):Array
		{
			var result:Array = arr.slice();
			var len:int = arr.length;
			var xml:XML;
			for( var i:int = 0; i < len; i++ )
			{
				xml = arr[i].activity.content;	
				if( hasImagePromptComponent(xml.question[0]) || hasImageChoices(xml..choice) )
					removeItem( result, arr[i] );
			}
			return result;
		}
		
		private static function hasImagePromptComponent( xml:XML ):Boolean
		{
			if( xml.component && xml.component.@image.length() )
				return true;
			else
				return false;
		}
		
		private static function hasImageChoices( xml:XMLList ):Boolean
		{
			for each( var choice:XML in xml )
			{
				if( choice.@image.length() )
					return true;
			}
			return false;
		}
		
	}
}