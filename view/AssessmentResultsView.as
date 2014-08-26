package org.nflc.framework.view
{
	import flash.events.Event;
	
	import org.nflc.common.FocusableLabel;
	import org.nflc.common.FocusableRichText;
	import org.nflc.common.IconButtonBitmap;
	import org.nflc.common.KeyboardController;
	import org.nflc.framework.component.*;
	import org.nflc.framework.domain.LessonConfiguration;
	import org.nflc.framework.domain.Screen;
	import org.nflc.framework.event.AssessmentEvent;
	import org.nflc.framework.event.DocumentEvent;
	import org.nflc.framework.view.*;
	import org.nflc.managers.AccessibilityManager;
	import org.nflc.framework.model.AppModel;
	
	import spark.components.Group;
	import spark.components.VGroup;
	import spark.components.supportClasses.SkinnableComponent;
	
	// Using mx:Text control as Rich Text removes font display from loaded swf files
	// See https://bugs.adobe.com/jira/browse/SDK-30590

	[Event(name="open", type="flash.events.Event")] 
	public class AssessmentResultsView extends SkinnableComponent
	{
		[SkinPart(required="true")] 
		public var title:FocusableLabel;
		
		[SkinPart(required="true")] 
		public var scoreText:FocusableRichText;
		
		[SkinPart(required="true")] 
		public var score:FocusableRichText;
		
		[SkinPart(required="true")] 
		public var perfomanceSummary:VGroup;
		
		[SkinPart(required="true")] 
		public var certificate:Group;
		
		[SkinPart(required="true")] 
		public var certificateIcon:IconButtonBitmap;
		
		[SkinPart(required="true")] 
		public var summaryHeader:FocusableLabel;
		
		public var questions:Array;
		public var lessons:Array;
		
		private var _tabbedItems:Array;
		private var _keyboardController:KeyboardController;
		
		[Bindable]
		[Inject("appModel", bind="true")]
		public var appModel:AppModel;
		
		public function AssessmentResultsView()
		{
			setStyle( "styleName", "assessmentResultsView" );
		}
		
		public function openCertificate():void
		{
			var document:String = appModel.lessonId + LessonConfiguration.assessment.certificate;
			dispatchEvent( new DocumentEvent(DocumentEvent.OPEN, document) );
		}
		
		public function displayScore():void
		{
			var numCorrect:int = getNumCorrect();
			var percentage:Number = Math.round( (numCorrect/questions.length) * 100 );
			
			if( percentage >= LessonConfiguration.assessment.passingScore )
			{
				scoreText.text = LessonConfiguration.assessment.correctText;
				if( LessonConfiguration.assessment.showCertificate )
				{
					certificate.visible = true;
					appModel.showCertificate = true;
				}
			}
			else
				scoreText.text = LessonConfiguration.assessment.incorrectText;
			
			dispatchEvent( new AssessmentEvent(AssessmentEvent.SCORE, percentage) );
			score.text = "You answered " + numCorrect + " correctly and your score is " + percentage + "%.";
			
			displayPerformanceSummary();
		}
		
		private function getNumCorrect():int
		{
			var numCorrect:int = 0;
			for each( var question:Screen in questions )
			{
				if( question.activity.sessionData && question.activity.sessionData.isResponseCorrect )
					numCorrect++;
			}
			return numCorrect;
		}
		
		private function displayPerformanceSummary():void
		{
			_tabbedItems =  [ title,
							  score,
							  scoreText,
							  certificateIcon,
							  summaryHeader];
			
			var header:PerfomanceSummaryHeader = new PerfomanceSummaryHeader();
			header.lesson.text = "Lesson";
			header.total.text = "Number Possible";
			header.numCorrect.text = "Number Correct";
			
			_tabbedItems.push( header.lesson, header.total, header.numCorrect );
			
			perfomanceSummary.addElement( header );
			for each( var lesson:Object in lessons )
				perfomanceSummary.addElement( addPerformanceItem(lesson) );
				
			var footer:PerfomanceSummaryFooter = new PerfomanceSummaryFooter();
			footer.lesson.text = "Total";
			
			footer.total.text = String(questions.length);
			footer.total.accessibilityName = "Number possible " + String(questions.length);
			
			footer.numCorrect.text = String( getNumCorrect() );	
			footer.numCorrect.accessibilityName = "Number correct " + String( getNumCorrect() );	
			
			_tabbedItems.push( footer.lesson, footer.total, footer.numCorrect );
			
			perfomanceSummary.addElement( footer );
			
			AccessibilityManager.getInstance().addDisplayObjects( _tabbedItems, AccessibilityManager.CONTENT );
			listenForEnterKey();
		}
		
		// TODO: make lesson a vo
		private function addPerformanceItem( lesson:Object ):PerfomanceSummaryItem
		{
			var item:PerfomanceSummaryItem = new PerfomanceSummaryItem();
			item.lesson.text = lesson.title;
			item.lesson.accessibilityName = "Lesson " + lesson.title;
			
			var total:uint = getTotalQuestionsForLesson( lesson.id );
			item.total.text = String(total);
			item.total.accessibilityName = "Number possible " + String(total);
			
			var numCorrect:uint = getLessonTotalCorrect( lesson.id );
			item.numCorrect.text = String(numCorrect);
			item.numCorrect.accessibilityName = "Number correct " + String(numCorrect);
			
			_tabbedItems.push( item.lesson, item.total, item.numCorrect );
			
			return item;
		}
		
		private function getTotalQuestionsForLesson( loid:String ):int
		{
			var total:int = 0;
			for each( var question:Screen in questions )
			{
				if( question.activity && question.activity.loId == loid )
					total++;
			}
			return total;
		}
		
		private function getLessonTotalCorrect( loid:String ):int
		{
			var numCorrect:int = 0;
			for each( var question:Screen in questions )
			{
				if( question.activity && question.activity.loId == loid )
				{
					if( question.activity.sessionData && question.activity.sessionData.isResponseCorrect )
						numCorrect++;
				}
				
			}
			return numCorrect;
		}
		
		public function dispose():void 
		{
			if( _tabbedItems )
			{
				AccessibilityManager.getInstance().removeDisplayObjects( _tabbedItems, AccessibilityManager.CONTENT );
				_tabbedItems = null;
			}
			
			if( _keyboardController )
			{
				_keyboardController.removeHotKey( certificateIcon );
				_keyboardController = null;
			}
		}
		
		private function listenForEnterKey():void
		{
			_keyboardController = KeyboardController.getInstance();
			_keyboardController.setFocusManager( focusManager );
			_keyboardController.createHotKey( certificateIcon, openCertificate );
		}
	}
}