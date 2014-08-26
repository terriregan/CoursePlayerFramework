package org.nflc.framework.domain
{
	public class Assessment
	{
		public var randomizeQuestions:Boolean;
		public var numberOfQuestions:int;
		public var numberOfMandatoryQuestions:int;
		public var reviewText:String;
		public var notAnsweredText:String;
		public var submitText:String;
		public var passingScore:Number;
		public var correctText:String;
		public var incorrectText:String;
		public var showCertificate:Boolean;
		public var certificate:String;
		
		public function Assessment() {}
		
	}
}