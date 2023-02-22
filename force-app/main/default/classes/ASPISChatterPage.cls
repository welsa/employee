public without sharing class ASPISChatterPage {
/*
----------------------------------------------------------------------
-- - Name          : ASPISChatterPage
-- - Author        : AMI
-- - Description   : Display chatter feeds fpr corresponding record
--
-- Maintenance History:
--
-- Date      	Name  Version    Remarks
-- -----------  ----  -------    -------------------------------------
-- 20-DEC-2018  AMI   1.0       Initial version
----------------------------------------------------------------------
**********************************************************************
*/
	public string encodedId {get;set;}
	public string decodedId {get;set;}
	public boolean isHPage 		= false;

	public ASPISChatterPage() {
		system.debug('## Start ASPISChatterPage Constructor');

		//getting id from url
		encodedId 			 	= ApexPages.currentPage().getParameters().get('id');
		system.debug('## encodedId ' + encodedId);

		decodedId			 	= '';

		string tempVariable 	= ApexPages.currentPage().getParameters().get('homepage');

		if(string.isNotBlank(tempVariable)){
			isHPage 			= tempVariable == '0'? false : true;
		}else{
			isHPage 			= false;
		}

		if(string.isNotBlank(encodedId) && !isHPage){
			decodedId			= decryptBase64(encodedId);
		}else if(string.isNotBlank(encodedId) && isHPage){
			decodedId			= encodedId;
		}

		system.debug('## End ASPISChatterPage Constructor');
	}

	public String decryptBase64(String encryptedText){
		system.debug('## Start decryptBase64');
        
        Blob decryptedData      = EncodingUtil.base64Decode(encryptedText);
        String decryptedText    = decryptedData.toString();
        return decryptedText;
    }
}