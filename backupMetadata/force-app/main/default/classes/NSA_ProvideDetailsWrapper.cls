/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 10-25-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
public with sharing class NSA_ProvideDetailsWrapper {
    public List<String> networks;
	public String tin_type;
	public String tin;
	public String provider_type;
	public Error error;
	public String status;
	public String message;
	public String code;
	public String description;

	public class Error {
		public String status;
		public String message;
		public String code;
		public String description;
	}

	
	public static List<NSA_ProvideDetailsWrapper> parse(String json) {
		return (List<NSA_ProvideDetailsWrapper>) System.JSON.deserialize(json, List<NSA_ProvideDetailsWrapper>.class);
	}
}