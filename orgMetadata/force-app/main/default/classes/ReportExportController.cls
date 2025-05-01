public with sharing class ReportExportController {
    public static Blob createSimpleZip(Blob fileData, String fileName) {
    // Create header using String.fromCharArray() for special characters
    List<Integer> headerChars = new List<Integer>{
        80, 75, 3, 4,          // PK\x03\x04
        20, 0,                  // Version needed to extract
        0, 0,                   // General purpose bit flag
        8, 0,                   // Compression method
        0, 0, 0, 0,             // Last mod time/date
        0, 0, 0, 0,             // CRC-32
        0, 0, 0, 0,             // Compressed size (placeholder)
        0, 0, 0, 0,             // Uncompressed size (placeholder)
        fileName.length(), 0,    // File name length
        0, 0                    // Extra field length
    };
    
    // Convert header to String
    String header = String.fromCharArray(headerChars);
    header += fileName;  // Add filename
    
    // Add file data
    String fileContent = fileData.toString();
    
    // Create footer
    List<Integer> footerChars = new List<Integer>{
        80, 75, 1, 2, 0, 0,    // Minimal central directory
        80, 75, 5, 6, 0, 0      // Minimal end record
    };
    String footer = String.fromCharArray(footerChars);
    
    //eturn Blob.valueOf(header + fileContent + footer);
    return Blob.valueOf(header + fileContent + footer);
    }
    
    @AuraEnabled(cacheable=false)
    public static String generateReportExcel(String reportId) {
		//Get Instance URL
        String instanceUrl = URL.getOrgDomainUrl().toExternalForm();        
        // Build the PrintableViewDownloadServlet URL
        //https://fullnsa-dev-ed.develop.my.salesforce.com/00OQy00000DtTZ3MAN?isdtp=p1&csv=1
        String reportUrl = instanceUrl + '/servlet/PrintableViewDownloadServlet?isdtp=p1&reportId=' + reportId;
        
        //String reportUrl = instanceUrl + '/' + reportId + '?isdtp=p1&csv=1';
        //System.Debug('URL='+reportUrl);
        
        // Fetch report content as a Blob
        PageReference reportPage = new PageReference(reportUrl);
        Blob reportBlob;
        try {
          reportBlob = reportPage.getContent();
        } catch (Exception e) {
          throw new AuraHandledException('Error generating report: ' + e.getMessage());
        }
        System.Debug('Returning Results');
        
        Blob zipBlob = createSimpleZip(reportBlob, 'Report.xlsx');
            
        // Return Base64-encoded content for LWC
        return EncodingUtil.base64Encode(reportBlob);
    }

    @AuraEnabled(cacheable=false)
		public static String generateReportCSV(String reportId) {
    	return new ReportService().generateReport(reportId);
	}
    
 /*   
    @AuraEnabled(cacheable=false)
    public static String generateReportCSV(String reportId) {
		//Get Instance URL
        String instanceUrl = URL.getOrgDomainUrl().toExternalForm();        
        // Build the PrintableViewDownloadServlet URL
        //https://fullnsa-dev-ed.develop.my.salesforce.com/00OQy00000DtTZ3MAN?isdtp=p1&csv=1
        
        //String reportUrl = instanceUrl + '/servlet/PrintableViewDownloadServlet?isdtp=p1&csv=1&reportId=' + reportId;
        String reportUrl = instanceUrl + '/' + reportId +'?isdtp=p1&csv=1';
        //String reportUrl = 'https://fullnsa-dev-ed.develop.my.salesforce.com/servlet/PrintableViewDownloadServlet?isdtp=p1&reportId=' + reportId;
        
        System.Debug('Report Url >>' + reportUrl);   
        
        // Fetch report content as a Blob
        PageReference reportPage = new PageReference(reportUrl);
        Blob reportBlob;
        try {
          reportBlob = reportPage.getContent();
          System.Debug('Report Page  >>' + reportPage.getContent());    
          System.Debug('Report BLOB  >>' + reportBlob.size());   
        } catch (Exception e) {
          throw new AuraHandledException('Error generating report: ' + e.getMessage());
        }
        System.Debug('Returning Results >>' + reportBlob.toString());
        return reportBlob.toString();
    }

///------------------------------------------------------------------------------------------------------------------    
private static String processReportJson(String reportJson) {
    // Parse the JSON response
    Map<String, Object> reportData = (Map<String, Object>) JSON.deserializeUntyped(reportJson);
    
    // Get the report metadata
    Map<String, Object> reportMetadata = (Map<String, Object>) reportData.get('reportMetadata');
    Map<String, Object> reportExtendedMetadata = (Map<String, Object>) reportData.get('reportExtendedMetadata');
    Map<String, Object> factMap = (Map<String, Object>) reportData.get('factMap');
    
    // Create a list to hold CSV rows
    List<String> csvRows = new List<String>();
    
    // 1. Add column headers
    List<String> headers = new List<String>();
    if (reportExtendedMetadata != null) {
        Map<String, Object> detailColumnInfo = (Map<String, Object>) reportExtendedMetadata.get('detailColumnInfo');
        if (detailColumnInfo != null) {
            for (String fieldName : detailColumnInfo.keySet()) {
                Map<String, Object> columnInfo = (Map<String, Object>) detailColumnInfo.get(fieldName);
                headers.add((String) columnInfo.get('label'));
            }
        }
    }
    csvRows.add(String.join(headers, ','));
    
    // 2. Add data rows
    if (factMap != null) {
        // Typically there's a 'T!T' key for tabular reports
        Map<String, Object> mainFact = (Map<String, Object>) factMap.get('T!T');
        if (mainFact != null) {
            List<Object> rows = (List<Object>) mainFact.get('rows');
            if (rows != null) {
                for (Object rowObj : rows) {
                    Map<String, Object> row = (Map<String, Object>) rowObj;
                    List<Object> dataCells = (List<Object>) row.get('dataCells');
                    
                    List<String> rowValues = new List<String>();
                    if (dataCells != null) {
                        for (Object cellObj : dataCells) {
                            Map<String, Object> cell = (Map<String, Object>) cellObj;
                            Object value = cell.get('label');
                            // Handle null values and escape CSV special characters
                            String stringValue = value != null ? String.valueOf(value).escapeCsv() : '';
                            rowValues.add(stringValue);
                        }
                        csvRows.add(String.join(rowValues, ','));
                    }
                }
            }
        }
    }
    
    return String.join(csvRows, '\n');
}
    
@AuraEnabled(cacheable=false)
public static String generateReportCSV1(String reportId) {
    String instanceUrl = URL.getOrgDomainUrl().toExternalForm();
    String endpoint = instanceUrl + '/services/data/v56.0/analytics/reports/' + reportId;
    
    HttpRequest req = new HttpRequest();
    req.setEndpoint(endpoint);
    req.setMethod('GET');
    req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionId());
    
    Http http = new Http();
    HttpResponse res = http.send(req);
    
    if (res.getStatusCode() != 200) {
        throw new AuraHandledException('Error fetching report: ' + res.getStatus());
    }
    
    // Parse the JSON response and construct CSV manually
    // This requires additional processing based on the report structure
    String T = processReportJson(res.getBody());
    System.debug('T=>>>'+T);
    return processReportJson(res.getBody());
}
*/    
/*    
public with sharing class ReportExportController {
    
    // Helper method to combine multiple blobs
    private static Blob combineBlobs(Blob part1, Blob part2) {
        String part1Hex = EncodingUtil.convertToHex(part1);
        String part2Hex = EncodingUtil.convertToHex(part2);
        return EncodingUtil.convertFromHex(part1Hex + part2Hex);
    }
    
    // Create a simple ZIP file with one file entry
    public static Blob createSimpleZip(Blob fileData, String fileName) {
        // 1. Create local file header
        Blob header = Blob.valueOf(
            'PK' + (char)3 + (char)4 +  // Local file header signature
            (char)20 + (char)0 +        // Version needed to extract (2.0)
            (char)0 + (char)0 +         // General purpose bit flag
            (char)0 + (char)0 +         // Compression method (store)
            getDosTime() +              // Last mod file time (2 bytes)
            getDosDate() +              // Last mod file date (2 bytes)
            calculateCrc32(fileData) +  // CRC-32 (4 bytes)
            intToLittleEndian(fileData.size()) +  // Compressed size (4 bytes)
            intToLittleEndian(fileData.size()) +  // Uncompressed size (4 bytes)
            shortToLittleEndian(fileName.length()) +  // File name length (2 bytes)
            (char)0 + (char)0           // Extra field length (2 bytes)
        );
        
        // Add file name
        header = combineBlobs(header, Blob.valueOf(fileName));
        
        // 2. Add file data
        Blob zipContent = combineBlobs(header, fileData);
        
        // 3. Create central directory header
        Blob centralDir = Blob.valueOf(
            'PK' + (char)1 + (char)2 +  // Central directory file header signature
            (char)20 + (char)0 +        // Version made by
            (char)20 + (char)0 +        // Version needed to extract
            (char)0 + (char)0 +         // General purpose bit flag
            (char)0 + (char)0 +         // Compression method
            getDosTime() +              // Last mod file time
            getDosDate() +              // Last mod file date
            calculateCrc32(fileData) +  // CRC-32
            intToLittleEndian(fileData.size()) +  // Compressed size
            intToLittleEndian(fileData.size()) +  // Uncompressed size
            shortToLittleEndian(fileName.length()) +  // File name length
            (char)0 + (char)0 +        // Extra field length
            (char)0 + (char)0 +        // File comment length
            (char)0 + (char)0 +        // Disk number start
            (char)0 + (char)0 +        // Internal file attributes
            intToLittleEndian(0) +      // External file attributes
            intToLittleEndian(0)        // Relative offset of local header
        );
        
        // Add file name to central directory
        centralDir = combineBlobs(centralDir, Blob.valueOf(fileName));
        
        // 4. Create end of central directory record
        Blob endRecord = Blob.valueOf(
            'PK' + (char)5 + (char)6 +  // End of central directory signature
            (char)0 + (char)0 +         // Number of this disk
            (char)0 + (char)0 +         // Disk where central directory starts
            shortToLittleEndian(1) +    // Number of central directory records on this disk
            shortToLittleEndian(1) +    // Total number of central directory records
            intToLittleEndian(centralDir.size()) +  // Size of central directory
            intToLittleEndian(zipContent.size()) +   // Offset of start of central directory
            (char)0 + (char)0           // ZIP file comment length
        );
        
        // Combine all parts
        zipContent = combineBlobs(zipContent, centralDir);
        zipContent = combineBlobs(zipContent, endRecord);
        
        return zipContent;
    }
    
    // Helper methods for ZIP format
    private static String getDosTime() {
        DateTime now = DateTime.now();
        Integer hour = now.hour();
        Integer minute = now.minute();
        Integer second = now.second() / 2;
        Integer dosTime = (hour << 11) | (minute << 5) | second;
        return (char)(dosTime & 0xFF) + (char)((dosTime >> 8) & 0xFF);
    }
    
    private static String getDosDate() {
        DateTime now = DateTime.now();
        Integer year = now.year() - 1980;
        Integer month = now.month();
        Integer day = now.day();
        Integer dosDate = (year << 9) | (month << 5) | day;
        return (char)(dosDate & 0xFF) + (char)((dosDate >> 8) & 0xFF);
    }
    
    private static String calculateCrc32(Blob data) {
        // Simplified CRC32 calculation (for actual use, implement proper CRC32)
        return (char)0 + (char)0 + (char)0 + (char)0;
    }
    
    private static String intToLittleEndian(Integer value) {
        return (char)(value & 0xFF) + 
               (char)((value >> 8) & 0xFF) + 
               (char)((value >> 16) & 0xFF) + 
               (char)((value >> 24) & 0xFF);
    }
    
    private static String shortToLittleEndian(Integer value) {
        return (char)(value & 0xFF) + (char)((value >> 8) & 0xFF);
    }
    
    @AuraEnabled(cacheable=false)
    public static String generateReportExcel(String reportId) {
        try {
            // Get Instance URL
            String instanceUrl = URL.getOrgDomainUrl().toExternalForm();
            
            // Build the report URL for Excel format
            String reportUrl = instanceUrl + '/servlet/PrintableViewDownloadServlet?isdtp=p1&export=1&xf=xls&reportId=' + reportId;
            
            // Fetch report content as a Blob
            PageReference reportPage = new PageReference(reportUrl);
            Blob reportBlob = reportPage.getContent();
            
            // Validate report content
            if (reportBlob == null || reportBlob.size() == 0) {
                throw new AuraHandledException('Report generation returned empty content');
            }
            
            if (reportBlob.size() > 5000000) { // 5MB
                throw new AuraHandledException('Report is too large to process');
            }
            
            // Create ZIP file containing the Excel report
            Blob zipBlob = createSimpleZip(reportBlob, 'Report.xlsx');
            
            // Return Base64-encoded ZIP file
            return EncodingUtil.base64Encode(zipBlob);
            
        } catch (Exception e) {
            throw new AuraHandledException('Error generating report: ' + e.getMessage());
        }
    }
}
*/
}