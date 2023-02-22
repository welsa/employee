@isTest
global class MockHttpResponseGenerator implements HttpCalloutMock {
	
	global HTTPResponse respond(HTTPRequest req) {
		HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody('[{"created_at":"Fri May 30 21:44:46 +0000 2014","id":472493846321201150,"id_str":"472493846321201152","text":"test","user":{"id":50374439,"id_str":"50374439","name":"Tom Hanks","screen_name":"tomhanks","location":"Los Angeles","description":"test","entities":{"url":{"urls":[{"display_url":"playtone.com","indices":[0,22]}]},"description":{"urls":[]}},"profile_sidebar_border_color":"BDDCAD","profile_sidebar_fill_color":"DDFFCC","profile_text_color":"000000","profile_use_background_image":false,"default_profile":false,"default_profile_image":false,"following":null,"follow_request_sent":null,"notifications":null},"geo":null,"coordinates":null,"place":null,"contributors":null,"retweet_count":159,"favorite_count":537,"entities":{"hashtags":[],"symbols":[],"user_mentions":[]},"favorited":false,"retweeted":false,"possibly_sensitive":false,"lang":"en"}]');
        
        res.setStatusCode(200);
        res.setStatus('OK');
        return res;
	}

}