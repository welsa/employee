/*
  ----------------------------------------------------------------------
  -- - Name          : APCreateAttachments
  -- - Author        : ABT
  -- - Description   : Class to create and insert attachments
  --
  -- Maintenance History:
  --
  -- Date         Name  Version  Remarks
  -- -----------  ----  -------  ---------------------------------------
  -- 20-SEP-2016  ABT    1.0     Corrected the way attachments were created
  ----------------------------------------------------------------------
 **********************************************************************
*/
public class APCreateAttachments
{
	// ABT - 22-SEP-2016 - Commented - C-001728
	//public static void createAttachment (String body, sObject sObj){
	//
	//	Attachment attachment = new Attachment();
	//	attachment.Body = Blob.valueOf(body);
	//	attachment.Name = String.valueOf('Request.txt');
	//	attachment.ParentId = (Id)sObj.get('Id');
	//	insert attachment;
	//}

	public static void createAttachment(String fileName, String body, sObject sObj)
	{

		Attachment attachment	= new Attachment(
													Body		= Blob.valueOf(body),
													Name		= (fileName != null && fileName.contains('.')) ? fileName : fileName + '.txt',
													ParentId	= (Id) sObj.get('Id')
												);
		insert attachment;
	}
}