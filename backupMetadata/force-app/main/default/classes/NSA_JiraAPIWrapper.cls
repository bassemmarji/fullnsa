/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-25-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

public class NSA_JiraAPIWrapper {

	public String id;
	public String key;
	public String self;

	
	public static NSA_JiraAPIWrapper parse(String json) {
		return (NSA_JiraAPIWrapper) System.JSON.deserialize(json, NSA_JiraAPIWrapper.class);
	}
}