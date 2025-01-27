/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 01-24-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

public class JiraAPIWrapper {

	public String id;
	public String key;
	public String self;

	
	public static JiraAPIWrapper parse(String json) {
		return (JiraAPIWrapper) System.JSON.deserialize(json, JiraAPIWrapper.class);
	}
}