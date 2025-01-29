public with sharing class MRFDownloadController {

    public String publicLogoUrl {
        get;
        set;
    }
    public Folder folder {
        get;
        set;
    }
    public String folderJSON {
        get;
        set;
    }
    public String selectedOption { //selected folder option
        get;
        set;
    }
    public String selectedFile { //for getting file name from url
        get;
        set;
    }
    public String selectedFileExtension {
        get;
        set;
    } // to use extension if file name includes it.
    public String libraryName {
        get;
        set;
    }
    public Map < Id, List < Folder > > folderMap = new Map < Id, List < Folder > > ();
    public Map < Id, List < File > > fileMap = new Map < Id, List < File > > ();
    public Boolean requestHasParameter {
        get;
        set;
    }
    public MRFDownloadController() {
        libraryName = 'Machine Readable Files';
        publicLogoUrl = '';
        requestHasParameter = false;
    }
    public String redirectFileUrl {
        get;
        set;
    }
    public Boolean redirectFileSet {
        get;
        set;
    }
    public void pageLoad() {
        redirectFileSet = false;
        this.folderJSON = '{\n' +
            '  "parentId" : null,\n' +
            '  "name" : "",\n' +
            '  "id" : "",\n' +
            '  "folders" : [],\n' +
            '  "files" : []\n' +
            '}';
        Map < String, String > parameters = ApexPages.currentPage().getParameters();
        if (parameters.containsKey('folder')) {
            requestHasParameter = true;
        }
        System.debug('parameters=>' + parameters);
        System.debug('requestHasParameter=>' + requestHasParameter);
        folderChanged();
        System.debug('publicLogoUrl=>' + publicLogoUrl);
    }

    public void folderChanged() {
        this.folderJSON = '{\n' +
            '  "parentId" : null,\n' +
            '  "name" : "",\n' +
            '  "id" : "",\n' +
            '  "folders" : [],\n' +
            '  "files" : []\n' +
            '}';
        if (String.isNotBlank(selectedOption)) {
            System.debug('SELECTED OPTION==>' + selectedOption);
            if (requestHasParameter) {
                getLogoURL(selectedOption);
            }
            getDocuments(selectedOption);
        }
        this.selectedOption = '';
    }

    public void getDocuments(String folderName) {
        List < String > folderNames;
        if (folderName.contains('||')) {
            folderNames = folderName.split('\\|\\|');
            System.debug('folderNames===>' + folderNames);
            folderName = folderNames[0];
        }
        System.debug('folderName===>' + folderName);

        folderMap = new Map < Id, List < Folder > > ();
        fileMap = new Map < Id, List < File > > ();

        //get document Ids from your library
        String libraryId = [SELECT Id FROM ContentWorkspace WHERE Name =: libraryName].Id;
        list < id > lstConDocs = new list < id > ();
        for (ContentWorkspaceDoc cvd: [SELECT Id, ContentWorkspaceId, ContentDocumentId FROM ContentWorkspaceDoc WHERE ContentWorkspace.Id =: libraryId]) {
            lstConDocs.add(cvd.ContentDocumentId);
        }
        if (lstConDocs.isEmpty()) {
            return;
        }

        List < ContentFolderLink > cfl = [SELECT ParentEntityId, Id, ContentFolderId FROM ContentFolderLink WHERE ParentEntityId =: libraryId];
        Set < Id > foldersUnderLibrary = new Set < Id > ();
        for (ContentFolderLink contentlink: cfl) {
            foldersUnderLibrary.add(contentlink.ContentFolderId);
        }
        ContentFolder mainFolder;
        List < ContentFolder > contentFolderList = [SELECT Id, Name FROM ContentFolder WHERE Name =: folderName AND ParentContentFolderId IN: foldersUnderLibrary];
        if (!contentFolderList.isEmpty()) {
            System.debug('contentFolderList==>' + contentFolderList);
            mainFolder = contentFolderList.get(0);
        }
        if (mainFolder == null) {
            return;
        }
        Folder selectedFolder = new Folder();
        selectedFolder.name = mainFolder.Name;
        selectedFolder.id = mainFolder.Id;
        folder = selectedFolder; // Our selected folder will be set as global for class.
        List < ContentFolder > contentFolders = [SELECT Id, Name, ParentContentFolderId FROM ContentFolder];
        System.debug('contentFolders before adding=' + JSON.serializePretty(contentFolders));
        for (ContentFolder cf: contentFolders) {
            List < Folder > allFolders = new List < Folder > ();
            Folder f = new Folder();
            f.id = cf.Id;
            f.name = cf.Name;
            f.parentId = cf.ParentContentFolderId;
            if (folderMap.containsKey(f.parentId)) {
                allFolders = folderMap.get(f.parentId);
            }
            if (f.parentId != null) {
                allFolders.add(f);
                folderMap.put(f.parentId, allFolders);
            }
        }
        System.debug('mainFolder before adding=' + JSON.serializePretty(this.folder));
        System.debug('folderMap before adding=' + JSON.serializePretty(this.folderMap));
        //addAllFolders(this.folder);

        Map < Id, ContentFolderMember > condIdToCnfMap = new Map < Id, ContentFolderMember > ();
        for (ContentFolderMember cfm: [Select Id, ChildRecordId, ParentContentFolder.Name, ParentContentFolderId FROM ContentFolderMember WHERE ChildRecordId IN: lstConDocs]) {
            condIdToCnfMap.put(cfm.ChildRecordId, cfm);
        }
        System.debug('childRecordTocontentFolderMemberMap=' + condIdToCnfMap);

        List < String > folderContentDocumentIds = new List < String > ();
        for (ContentFolderMember folderMember: condIdToCnfMap.values()) {
            folderContentDocumentIds.add(folderMember.ChildRecordId);
        }

        Map < Id, ContentDocument > files = new Map < Id, ContentDocument > ([SELECT Id, ParentId, Title, FileExtension, ContentSize, LastModifiedDate FROM ContentDocument WHERE Id IN: folderContentDocumentIds]);

        System.debug('files before adding=' + JSON.serializePretty(files));

        for (ContentDocument cd: files.values()) {
            String fileDownloadUrl = Url.getSalesforceBaseUrl().toExternalForm() +
                '/sfc/servlet.shepherd/document/download/' +
                cd.Id;
            File file = new File();
            file.downloadUrl = fileDownloadUrl;
            file.size = fileSizeToString(cd.ContentSize);
            file.name = cd.Title;
            file.extension = cd.FileExtension;
            file.id = cd.Id;
            file.lastModifiedDate = cd.LastModifiedDate.format('MM/dd/yyyy h:mm a');
            if (condIdToCnfMap.containsKey(file.id)) {
                file.parentId = condIdToCnfMap.get(file.id).ParentContentFolderId;
            }
            List < File > tempFiles = new List < File > ();
            if (fileMap.containsKey(file.parentId)) {
                tempFiles = fileMap.get(file.parentId);
            }
            System.debug('fileBeforeAdd=' + file);
            if (file.parentId != null) {
                tempFiles.add(file);
                fileMap.put(file.parentId, tempFiles);
            }
        }

        System.debug('fileMap before adding=' + JSON.serializePretty(this.fileMap));
        addAllFolders(this.folder);
        if (folderNames != null) {
            folderNames.remove(0); //remove root folder
            for (String fName: folderNames) {
                this.folder = this.folder.getFolder(fName);
            }
        }
        if (String.isNotBlank(selectedFile)) {
            if (selectedFile.contains('.')) {
                List < String > splittedFileName = selectedFile.split('\\.');
                System.debug('splittedFileName' + splittedFileName);
                selectedFileExtension = splittedFileName.get(1);
                selectedFile = splittedFileName.get(0);
            }
            String fileUrl = this.folder.getFileURL(selectedFile, selectedFileExtension);
            if (String.isNotBlank(fileUrl)) {
                redirectFileUrl = fileUrl;
                redirectFileSet = true;
            }
            System.debug('redirectFileUrl===>' + redirectFileUrl);
        }
        System.debug(JSON.serializePretty(this.folder));
        this.folderJSON = JSON.serializePretty(this.folder);
        return;
    }

    /* UTIL Method */
    public String fileSizeToString(Long Value) {
        /* string representation if a file's size, such as 2 KB, 4.1 MB, etc */
        if (Value < 1024)
            return string.valueOf(Value) + ' Bytes';
        else
        if (Value >= 1024 && Value < (1024 * 1024)) {
            //KB
            Decimal kb = Decimal.valueOf(Value);
            kb = kb.divide(1024, 2);
            return string.valueOf(kb) + ' KB';
        } else
        if (Value >= (1024 * 1024) && Value < (1024 * 1024 * 1024)) {
            //MB
            Decimal mb = Decimal.valueOf(Value);
            mb = mb.divide((1024 * 1024), 2);
            return string.valueOf(mb) + ' MB';
        } else {
            //GB
            Decimal gb = Decimal.valueOf(Value);
            gb = gb.divide((1024 * 1024 * 1024), 2);

            return string.valueOf(gb) + ' GB';
        }
    }

    public void addAllFolders(Folder newFolder) {
        if (newFolder == null) {
            return;
        }
        if (folderMap.containsKey(newFolder.id)) {
            for (Folder child: folderMap.get(newFolder.id)) {
                newFolder.folders.add(child);
            }
            folderMap.remove(newFolder.id);
        }
        if (fileMap.containsKey(newFolder.id)) {
            for (File childFile: fileMap.get(newFolder.id)) {
                newFolder.addFile(childFile);
            }
            fileMap.remove(newFolder.id);
        }
        for (Folder parent: newFolder.folders) {
            addAllFolders(parent);
        }

    }

    public void getLogoURL(String name) {
        name += '_logo';
        List < StaticResource > staticResources = [SELECT Id, Name, SystemModStamp FROM StaticResource WHERE Name =: name];
        System.debug('staticResources=>' + staticResources);
        if (!staticResources.isEmpty()) {
            this.publicLogoUrl = '/resource/' + staticResources[0].SystemModStamp.getTime() + '/' + staticResources[0].Name;
        }
    }


    /**
     * WRAPPER CLASSES
     */

    public class File {
        public String parentId;
        public String id;
        public String line {
            get;
            set;
        }
        public String downloadUrl {
            get;
            set;
        }
        public String name {
            get;
            set;
        }
        public String size {
            get;
            set;
        }
        public String lastModifiedDate;
        public String extension;
    }

    public class Folder {
        public String parentId;
        public String id;
        public String name;
        public List < Folder > folders;
        public List < File > files;
        public Folder() {
            this.folders = new List < Folder > ();
            this.files = new List < File > ();
        }
        public void addFile(File file) {
            file.line = String.valueOf(this.files.size() + 1);
            this.files.add(file);
        }
        public String getFileURL(String fileName, String fileExtension) {
            String fileUrl;
            if (String.isNotBlank(fileExtension)) {
                for (File f: files) {
                    if (f.name == fileName && f.extension == fileExtension) {
                        fileUrl = f.downloadUrl;
                        break;
                    }
                }
            } else {
                for (File f: files) {
                    if (f.name == fileName) {
                        fileUrl = f.downloadUrl;
                        break;
                    }
                }
            }
            return fileUrl;
        }
        public Folder getFolder(String folderName) {
            Folder foundFolder;
            for (Folder f: folders) {
                if (f.name == folderName) {
                    foundFolder = f;
                    foundFolder.parentId = null; // set parentId to null to hide accordion on html
                    break;
                }
            }
            return foundFolder;
        }
    }

}