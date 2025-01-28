@isTest
global class NSATestMock implements HttpCalloutMock{
    global HTTPResponse respond(HTTPRequest req) {
			HttpResponse res = new HttpResponse();
			if (req.getEndpoint().contains('http://35.80.161.201/v1/api/')) {
				res.setHeader('Content-Type', 'application/json');
				res.setBody('[{"networks":["CG"],"names_of_networks":["Cigna Health Life Insurance Company"],"tin_type":"ein","tin":"010535132","include_shoppable_items":true,"provider_type":null}]');
				res.setStatusCode(200);
			}else if (req.getEndpoint().contains('http://35.80.161.201/fhtest/api/FH/GetByFilter')) {
				res.setHeader('Content-Type', 'application/json');
				res.setBody('{"success":true,"Data":[{"ScrubID":"ea6bbed2","Results":[{"ProcedureCode":"93015","LineNumber":1,"Allowed":76.08}]}]}');
				res.setStatusCode(200);
			}else if (req.getEndpoint().contains('https://pricer.zebuservices.com')) {
				res.setHeader('Content-Type', 'application/json');
				res.setBody('{"success":true,"Data":[{"ScrubID":"ea6bbed2","Results":[{"ProcedureCode":"93015","LineNumber":1,"Allowed":76.08}]}]}');
				res.setStatusCode(200);
			}else if (req.getEndpoint().contains('http://35.80.161.201/v1/api/statistic/GetByTPAAcronym')) {
				res.setHeader('Content-Type', 'application/json');
				res.setBody('{"files":[{"reporting_entity_name":"MEDCOST","reporting_entity_type":"Payer","last_updated_on":"2022-06-23","version":"1.0.0","created_date":"2022-12-15","billing_code_count":"484"},{"reporting_entity_name":"Cigna Health Life Insurance Company","reporting_entity_type":"Health Insurance Issuer","last_updated_on":"2022-12-01","version":"1.0.0","created_date":"2022-12-14","billing_code_count":"512"},{"reporting_entity_name":"First Choice Health network","reporting_entity_type":"PPO","last_updated_on":"2022-11-05","version":"1.0.0","created_date":"2022-12-13","billing_code_count":"494"},{"reporting_entity_name":"Merative on behalf of HealthPartners","reporting_entity_type":"Third-Party Administrator","last_updated_on":"2022-12-01","version":"1.2.0","created_date":"2022-12-22","billing_code_count":"488"},{"reporting_entity_name":"Sagamore Health Network","reporting_entity_type":"Third Party","last_updated_on":"2022-11-14","version":"1.0.0","created_date":"2022-12-22","billing_code_count":"490"},{"reporting_entity_name":"NHBC PHX WEST PRIMARY ACCESS","reporting_entity_type":"TP","last_updated_on":"2023-01-16","version":"1.0.0","created_date":"2023-01-16","billing_code_count":"498"},{"reporting_entity_name":"NHBC PHX WEST PRIMARY OOA ACCESS","reporting_entity_type":"TP","last_updated_on":"2023-01-16","version":"1.0.0","created_date":"2023-01-16","billing_code_count":"498"}],"provider_count":"2160911"}');
				res.setStatusCode(200);
			}
			return res;
    }
}