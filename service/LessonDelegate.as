package org.nflc.framework.service
{
	import mx.rpc.AsyncToken;
	import mx.rpc.http.mxml.HTTPService;
	
	public class LessonDelegate
	{
		public function LessonDelegate() {}
		
		
		public function load( url:String ):AsyncToken
		{
			var lessonService:HTTPService = new HTTPService();
			lessonService.resultFormat = "e4x";
			lessonService.url = url;
			return lessonService.send();	
		}
	}
}