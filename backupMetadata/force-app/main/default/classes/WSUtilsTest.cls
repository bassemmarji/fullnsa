@IsTest
public with sharing class WSUtilsTest {
    @IsTest
    static void test_pingServer() {
        MultiStaticResourceCalloutMock multimock = new MultiStaticResourceCalloutMock();
        multimock.setStaticResource('callout:MRF_API/api/provider/getbyfilter'      , 'NSA_MRFPricesMockResponse' );
        multimock.setStaticResource('callout:NPI_Registry'                          , 'NSA_ProviderWSMockResponse');
		multimock.setStaticResource('callout:Valenz_API/Release/hooks/ips/submit.py', 'NSA_ValenzMockResponse' );
        
        multimock.setStatusCode(200);
        multimock.setHeader( 'Content-Type' , 'application/json' );

        // Set the mock callout mode
        Test.startTest();
        Test.setMock(HttpCalloutMock.class , multimock);
        
        System.debug('Before=');
        
        Boolean result = false;
        
		try 
        {
        	// Call the method for the first endpoint
        	result = WSUtils.pingServer('callout:MRF_API/api/provider/getbyfilter', 'POST', '{"tins":["1164604591"],"TPA_Acronym":"BSi","NTW_Acronym": ["MC"]}', null);
        	// Verify response received
         	System.debug('1='+result);
        }
        catch (Exception e) {
              System.debug('Error='+e);
        }
        
        
        try 
        {    
            result = WSUtils.pingServer('callout:NPI_Registry', 'GET', null, null);
			// Verify response received
        	System.assertEquals( True , result);   
            System.debug('2='+result);
        }
        catch (Exception e) {
              System.debug('Error='+e);
        }
        
        
        try 
        {    
        	// Call the method for the second endpoint
			result = WSUtils.pingServer('callout:Valenz_API/Release/hooks/ips/submit.py', 'POST', 'test', System.Label.NSA_ValenzAuth);        	// Verify response received
        	System.assertEquals( True , result);
            System.debug('3='+result);
        }
        catch (Exception e) {
              System.debug('Error='+e);
        }
        Test.stopTest();
    }
}