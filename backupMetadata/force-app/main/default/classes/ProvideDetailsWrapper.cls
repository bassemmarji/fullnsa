public with sharing class ProvideDetailsWrapper {
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

	
	public static List<ProvideDetailsWrapper> parse(String json) {
		return (List<ProvideDetailsWrapper>) System.JSON.deserialize(json, List<ProvideDetailsWrapper>.class);
	}
}