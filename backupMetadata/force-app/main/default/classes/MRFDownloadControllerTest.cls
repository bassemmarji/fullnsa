@isTest
private class MRFDownloadControllerTest {

	@testSetup
	private static void createTestData() {
		ContentWorkspace testWorkspace = new ContentWorkspace(Name='Machine Readable Files2', DeveloperName='TEST_CLASS');
		insert testWorkspace;
	}
	
	@isTest
	private static void testGetFilesList(){
		ContentWorkspace ws = [Select Id,RootContentFolderId from ContentWorkspace where Name = 'Machine Readable Files2'];
	
		ContentFolder testFolderRecord = new ContentFolder(Name='DRUG', ParentContentFolderId=ws.RootContentFolderId);
		insert testFolderRecord;
	
		
		ContentVersion cv = new ContentVersion();
		cv.VersionData = Blob.valueOf('Pika');
		cv.Title = 'filename';
		cv.PathOnClient = 'myfile.xml';
		insert cv;
		
		cv = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1];
		
		ContentDocumentLink cdl = new ContentDocumentLink();
		cdl.ContentDocumentId = cv.ContentDocumentId;
		cdl.LinkedEntityId = ws.Id;
		cdl.ShareType = 'I';
		cdl.Visibility = 'AllUsers';
		insert cdl;
	
		ContentFolderMember cfm = [SELECT Id, ChildRecordId, ParentContentFolderId
								  FROM ContentFolderMember
								  WHERE ChildRecordId = :cv.ContentDocumentId
								  LIMIT 1];
		cfm.ParentContentFolderId = testFolderRecord.Id;
		update cfm;
		MRFDownloadController mrf = new MRFDownloadController();
		mrf.publicLogoUrl = 'test';
		mrf.selectedOption = 'DRUG';
		mrf.libraryName ='Machine Readable Files2';
		Test.startTest();
		mrf.pageLoad();
		mrf.getDocuments('DRUG');
		mrf.getDocuments('DRUG||DRUG');
		mrf.folderChanged();
		mrf.fileSizeToString(1048570);
		mrf.fileSizeToString(1048578);
		mrf.fileSizeToString(1073741830);
		Test.stopTest();
	}
}