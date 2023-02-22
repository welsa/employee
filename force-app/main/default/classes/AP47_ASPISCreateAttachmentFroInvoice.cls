global without sharing class AP47_ASPISCreateAttachmentFroInvoice {
    public static Attachment createAttachment(id invId, String invoiceTechNo, string Name){
		system.debug('start createAttachment');
		string blobAttachmentInvoice = RESTPostInvoice.retrievePdfBody(invoiceTechNo, invId);
		Attachment attach = new Attachment();
		attach.Body = Blob.valueOf(blobAttachmentInvoice);
		attach.Name = Name+'.pdf';
		attach.ParentId = invId;
		system.debug('stop createAttachment');
		return attach;
	}
}