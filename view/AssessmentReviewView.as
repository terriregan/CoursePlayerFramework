package org.nflc.framework.view
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayList;
	import mx.controls.Text;
	import mx.events.FlexEvent;
	
	import org.nflc.activities.model.SessionData;
	import org.nflc.common.KeyboardController;
	import org.nflc.framework.domain.LessonConfiguration;
	import org.nflc.framework.domain.Screen;
	import org.nflc.framework.event.AssessmentEvent;
	import org.nflc.framework.event.NavigationEvent;
	import org.nflc.framework.view.*;
	import org.nflc.managers.AccessibilityManager;
	import org.nflc.common.FocusableLabel;
	import org.nflc.common.FocusableRichText;
	
	import spark.components.Button;
	import spark.components.DropDownList;
	import spark.components.Label;
	import spark.components.RichText;
	import spark.components.TileGroup;
	import spark.components.supportClasses.SkinnableComponent;
	
	import utils.array.addItemsAt;
	
	[Event(name="submit", type="org.nflc.framework.event.AssessmentEvent")] 
	public class AssessmentReviewView extends SkinnableComponent
	{
		[SkinPart(required="true")] 
		public var title:FocusableLabel;
		
		[SkinPart(required="true")] 
		public var submitButton:Button;
		
		[SkinPart(required="true")] 
		public var jumpTo:Button;
		
		[SkinPart(required="false")] 
		public var questionList:DropDownList;
		
		[SkinPart(required="false")] 
		public var reviewText:FocusableRichText;
		
		[SkinPart(required="false")] 
		public var notAnsweredText:FocusableRichText;
		
		[SkinPart(required="false")] 
		public var submitText:FocusableRichText;
		
		[SkinPart(required="false")] 
		public var unansweredQuestions:TileGroup;
		
		public var questions:Array;
		
		[Bindable]
		public var hasUnansweredQuestion:Boolean = false;
		
		private var _tabbedItems:Array;
		private var _keyboardController:KeyboardController;
		
		public function AssessmentReviewView()
		{
			setStyle( "styleName", "assessmentReviewView" );
		}
		
		override protected function partAdded( partName:String,instance:Object ):void
		{
			super.partAdded( partName, instance ); 
			
			if( LessonConfiguration.assessment )
			{	
				if( instance == reviewText )
					instance.text = LessonConfiguration.assessment.reviewText;
				
				if( instance == notAnsweredText )
					instance.text = LessonConfiguration.assessment.notAnsweredText;
				
				if( instance == submitText )
					instance.text = LessonConfiguration.assessment.submitText;
				
				if( instance == submitButton )
					submitButton.addEventListener( MouseEvent.CLICK, onSubmit );
			}
		}
		
		public function onSubmit( e:MouseEvent = null ):void
		{
			dispatchEvent( new AssessmentEvent(AssessmentEvent.SUBMIT) );
		}
		
		public function populateQuestonList():void
		{
			if( questionList && !questionList.dataProvider )
					questionList.dataProvider = new ArrayList( questions ); 
				
			updateUnansweredQuestionList();
		}
		
		public function updateUnansweredQuestionList():void
		{
			var buttons:Array = [];
			var linkButton:Button;
			var sd:SessionData;
			unansweredQuestions.removeAllElements();
			for each( var screen:Screen in questions )
			{
				sd = screen.activity.sessionData;
				if( !sd || !sd.isAnswered )
				{
					linkButton = new Button();
					linkButton.setStyle( 'styleName', 'linkButton' );
					linkButton.name = String(screen.questionNumber);
					linkButton.label = "Question " + screen.questionNumber;
					linkButton.addEventListener( MouseEvent.CLICK, gotoQuestion );
					unansweredQuestions.addElement( linkButton );
					hasUnansweredQuestion = true;
					buttons.push( linkButton );
				}
			}
			initializeScreen( buttons );
		}
		
		public function gotoQuestion( e:MouseEvent ):void
		{
			dispatchEvent( new NavigationEvent(NavigationEvent.JUMP, int(e.target.name)) );
		}
		
		public function jumpToQuestion( e:MouseEvent = null ):void
		{
			if( questionList.selectedItem )
			{
				var screenNumber:int = int( questionList.selectedItem.questionNumber );
				dispatchEvent( new NavigationEvent(NavigationEvent.JUMP, screenNumber) );
			}
		}
		
		private function initializeScreen( questions:Array ):void
		{
			_tabbedItems =  [ title,
							 reviewText,
							 questionList,
							 jumpTo,
							 notAnsweredText];
			
			addItemsAt( _tabbedItems, questions, 5 );
			_tabbedItems.push( submitText, submitButton );
			
			AccessibilityManager.getInstance().addDisplayObjects( _tabbedItems, AccessibilityManager.CONTENT );
			
			listenForEnterKey();
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
				_keyboardController.removeHotKey( jumpTo );
				_keyboardController.removeHotKey( submitButton );
				_keyboardController = null;
			}
			
		}
		
		private function listenForEnterKey():void
		{
			_keyboardController = KeyboardController.getInstance();
			_keyboardController.setFocusManager( focusManager );
			_keyboardController.createHotKey(  jumpTo, jumpToQuestion );
			_keyboardController.createHotKey(  submitButton, onSubmit );
		}
	}
}