component {
	cfprocessingdirective( preserveCase=true );

	function init(required string apiKey, required string apiUrl= "https://api.aftership.com/v4", numeric timeout= 120, boolean debug= false ) {
		this.apiKey= arguments.apiKey;
		this.apiUrl= arguments.apiUrl;
		this.httpTimeOut= arguments.timeout;
		this.debug= arguments.debug;
		this.userAgent= "aftership-cfml-api-client/1.0";
		if ( structKeyExists( request, "debug" ) && request.debug == true ) {
			this.debug = request.debug;
		}
		return this;
	}

	function debugLog( required input ) {
		if ( structKeyExists( request, "log" ) && isCustomFunction( request.log ) ) {
			if ( isSimpleValue( arguments.input ) ) {
				request.log( "aftership: " & arguments.input );
			} else {
				request.log( "aftership: (complex type)" );
				request.log( arguments.input );
			}
		} else if ( this.debug ) {
			cftrace( text=( isSimpleValue( arguments.input ) ? arguments.input : "" ), var=arguments.input, category="aftership", type="information" );
		}
		return;
	}

	function getTracking( required string tracking_number, required string slug ) {
		return this.apiRequest( "GET /trackings/#arguments.slug#/#arguments.tracking_number#" );
	}

	function deleteTracking( required string tracking_number, required string slug ) {
		return this.apiRequest( "DELETE /trackings/#arguments.slug#/#arguments.tracking_number#" );
	}

	function deleteTrackingID( required string id ) {
		return this.apiRequest( "DELETE /trackings/#arguments.id#" );
	}

	function createTracking(
		required string tracking_number
	,	required string slug
	,	string title= ""
	,	string emails= ""
	,	string smses= ""
	,	string order_id= ""
	,	string order_id_path= ""
	,	string customer_name= ""
	,	struct custom_fields= {}
	) {
		var json= {
			"tracking"= {
			"tracking_number"= arguments.tracking_number
		,	"slug"= arguments.slug
		,	"title"= arguments.title
		,	"emails"= listToArray( arguments.emails )
		,	"smses"= listToArray( arguments.smses )
		,	"order_id"= arguments.order_id
		,	"order_id_path"= arguments.order_id_path
		,	"customer_name"= arguments.customer_name
		,	"custom_fields"= arguments.custom_fields
		} };
		return this.apiRequest( "POST /trackings", json );
	}

	function updateTracking(
		required string tracking_number
	,	required string slug
	,	string title= ""
	,	string emails= ""
	,	string sms= ""
	,	string order_id= ""
	,	string order_id_path= ""
	,	string customer_name= ""
	,	string custom_fields= ""
	) {
		var json= {
			"tracking"= {
			"title"= arguments.title
		,	"emails"= listToArray( arguments.emails )
		,	"smses"= listToArray( arguments.smses )
		,	"order_id"= arguments.order_id
		,	"order_id_path"= arguments.order_id_path
		,	"customer_name"= arguments.customer_name
		,	"custom_fields"= arguments.custom_fields
		} };
		return this.apiRequest( "PUT /trackings/#arguments.slug#/#arguments.tracking_number#", json );
	}

	struct function apiRequest(required string api, json= "") {
		var http= 0;
		var dataKeys= 0;
		var item= "";
		var out= {
			success= false
		,	error= ""
		,	status= ""
		,	json= ""
		,	statusCode= 0
		,	response= ""
		,	verb= listFirst( arguments.api, " " )
		,	requestUrl= this.apiUrl & listRest( arguments.api, " " )
		};
		if ( isStruct( arguments.json ) ) {
			out.json= serializeJSON( arguments.json );
			out.json= reReplace( out.json, "[#chr(1)#-#chr(7)#|#chr(11)#|#chr(14)#-#chr(31)#]", "", "all" );
		} else if ( isSimpleValue( arguments.json ) && len( arguments.json ) ) {
			out.json= arguments.json;
		}
		if ( this.debug ) {
			this.debugLog( out );
		}
		cftimer( type="debug", label="aftership request" ) {
			cfhttp( result="http", method=out.verb, url=out.requestUrl, throwOnError=false, userAgent=this.userAgent, timeOut=this.httpTimeOut, charset="UTF-8" ) {
				cfhttpparam( name="aftership-api-key", type="header", value=this.apiKey );
				if ( out.verb == "POST" || out.verb == "PUT" ) {
					cfhttpparam( name="Content-Type", type="header", value="application/json" );
					cfhttpparam( type="body", value=out.json );
				}
			}
		}
		out.response= toString( http.fileContent );
		if ( this.debug ) {
			this.debugLog( out.response );
		}
		//  RESPONSE CODE ERRORS 
		if ( !structKeyExists( http, "responseHeader" ) || !structKeyExists( http.responseHeader, "Status_Code" ) || http.responseHeader.Status_Code == "" ) {
			out.statusCode= 500;
		} else {
			out.statusCode= http.responseHeader.Status_Code;
		}
		this.debugLog( out.statusCode );
		if ( left( out.statusCode, 1 ) == 4 || left( out.statusCode, 1 ) == 5 ) {
			out.success= false;
			out.error= "status code error: #out.statusCode#";
		} else if ( out.response == "Connection Timeout" || out.response == "Connection Failure" ) {
			out.error= out.response;
		} else if ( listFind( "200,201", http.responseHeader.Status_Code ) ) {
			out.success= true;
		}
		//  parse response 
		if ( len( out.response ) ) {
			try {
				out.response= deserializeJSON( out.response );
				if ( isStruct( out.response ) && structKeyExists( out.response, "meta" ) && structKeyExists( out.response.meta, "message" ) ) {
					out.success= false;
					out.error= out.response.meta.message;
				}
			} catch (any cfcatch) {
				out.error= "JSON Error: " & cfcatch.message;
			}
		}
		if ( len( out.error ) ) {
			out.success= false;
		}
		return out;
	}

}