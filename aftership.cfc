component {
	// cfprocessingdirective( preserveCase=true );

	function init(
		required string apiKey
	,	string apiUrl= "https://api.aftership.com/v4"
	,	string userAgent= "aftership-cfml-api-client/1.0"
	,	numeric httpTimeOut= 120
	,	boolean debug
	) {
		arguments.debug = ( arguments.debug ?: request.debug ?: false );
		this.apiKey= arguments.apiKey;
		this.apiUrl= arguments.apiUrl;
		this.userAgent= arguments.userAgent;
		this.httpTimeOut= arguments.httpTimeOut;
		this.debug= arguments.debug;
		this.offSet = getTimeZoneInfo().utcTotalOffset;
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
			var info= ( isSimpleValue( arguments.input ) ? arguments.input : serializeJson( arguments.input ) );
			cftrace(
				var= "info"
			,	category= "aftership"
			,	type= "information"
			);
		}
		return;
	}

	//////////////////////////////////////////////////////////////////////////////
	// COURIERS
	// https://docs.aftership.com/api/4/couriers/get-couriers
	//////////////////////////////////////////////////////////////////////////////

	function getActiveCouriers() {
		return this.apiRequest( "GET /couriers" );
	}

	function getAllCouriers() {
		return this.apiRequest( "GET /couriers/all" );
	}

	function getCourierDetect(
		required string tracking_number
	,	string tracking_postal_code
	,	date tracking_ship_date
	,	string tracking_account_number
	,	string tracking_key
	,	string tracking_destination_country
	,	slug
	) {
		if( structKeyExists( arguments, "tracking_ship_date" ) ) {
			arguments.tracking_ship_date= dateFormat( arguments.tracking_ship_date, "yyyymmdd" );
		}
		var json= { "tracking"= arguments };
		return this.apiRequest( "POST /couriers/detect", json );
	}

	//////////////////////////////////////////////////////////////////////////////
	// TRACKING
	// https://docs.aftership.com/api/4/trackings/post-trackings
	//////////////////////////////////////////////////////////////////////////////

	function getTracking( required string tracking_number, required string slug ) {
		return this.apiRequest( "GET /trackings/#arguments.slug#/#arguments.tracking_number#" );
	}

	function getLastCheckpoint(
		required string tracking_number
	,	required string slug
	,	string fields= "slug,created_at,checkpoint_time,city,coordinates,country_iso3,country_name,message,state,tag,zip"
	,	string lang= ""
	) {
		return this.apiRequest( "GET /trackings/#arguments.slug#/#arguments.tracking_number#" & this.structToQueryString( arguments ) );
	}

	function getLastCheckpointID(
		required string tracking_id
	,	string fields= "slug,created_at,checkpoint_time,city,coordinates,country_iso3,country_name,message,state,tag,zip"
	,	string lang= ""
	) {
		return this.apiRequest( "GET /trackings/#arguments.tracking_id#" & this.structToQueryString( arguments ) );
	}

	function getTrackings(
		numeric page= 1
	,	numeric limit= 100
	,	string keyword
	,	string slug
	,	numeric delivery_time
	,	string origin
	,	string destination
	,	date created_at_min
	,	date created_at_max
	,	string fields= "title,order_id,tag,checkpoints,checkpoint_time,message,country_name"
	,	string lang= ""
	) {
		if( structKeyExists( arguments, "created_at_min" ) ) {
			arguments.created_at_min= this.zDateFormat( arguments.created_at_min );
		}
		if( structKeyExists( arguments, "created_at_max" ) ) {
			arguments.created_at_max= this.zDateFormat( arguments.created_at_max );
		}
		return this.apiRequest( "GET /trackings" & this.structToQueryString( arguments ) );
	}

	function deleteTracking( required string tracking_number, required string slug ) {
		return this.apiRequest( "DELETE /trackings/#arguments.slug#/#arguments.tracking_number#" );
	}

	function deleteTrackingID( required string tracking_id ) {
		return this.apiRequest( "DELETE /trackings/#arguments.tracking_id#" );
	}

	function createRetracking(
		required string tracking_number
	,	required string slug
	) {
		return this.apiRequest( "POST /trackings/#arguments.slug#/#arguments.tracking_number#/retrack" );
	}

	
	function createTracking(
		required string tracking_number
	,	required string slug
	,	string title= ""
	,	emails
	,	smses
	,	string order_id
	,	string order_id_path
	,	string customer_name
	,	struct custom_fields
	,	string note
	,	string language
	,	string delivery_type
	,	string pickup_location
	,	string pickup_note
	,	string tracking_postal_code
	,	string tracking_ship_date
	,	string tracking_account_number
	,	string tracking_key
	,	string tracking_origin_country
	,	string tracking_destination_country
	,	string tracking_state
	,	android
	,	ios
	,	string origin_country_iso3
	,	string destination_country_iso3
	,	date order_promised_delivery_date
	) {
		if( structKeyExists( arguments, "emails" ) && isSimpleValue( arguments.emails ) ) {
			arguments.emails = listToArray( arguments.emails );
		}
		if( structKeyExists( arguments, "smses" ) && isSimpleValue( arguments.smses ) ) {
			arguments.smses = listToArray( arguments.smses );
		}
		if( structKeyExists( arguments, "tracking_ship_date" ) ) {
			arguments.tracking_ship_date= dateFormat( arguments.tracking_ship_date, "yyyymmdd" );
		}
		if( structKeyExists( arguments, "order_promised_delivery_date" ) ) {
			arguments.order_promised_delivery_date= dateFormat( arguments.order_promised_delivery_date, "yyyy-mm-dd" );
		}
		arguments.tracking_ship_date= dateFormat( arguments.tracking_ship_date, "yyyymmdd" );
		var json= { "tracking"= arguments };
		return this.apiRequest( "POST /trackings", json );
	}

	function updateTracking(
		required string tracking_number
	,	required string slug
	,	string title
	,	emails
	,	sms
	,	string order_id
	,	string order_id_path
	,	string customer_name
	,	struct custom_fields
	,	string note
	,	string language
	,	string delivery_type
	,	string pickup_location
	,	string pickup_note
	,	date order_promised_delivery_date
	) {
		if( structKeyExists( arguments, "emails" ) && isSimpleValue( arguments.emails ) ) {
			arguments.emails = listToArray( arguments.emails );
		}
		if( structKeyExists( arguments, "smses" ) && isSimpleValue( arguments.smses ) ) {
			arguments.smses = listToArray( arguments.smses );
		}
		if( structKeyExists( arguments, "order_promised_delivery_date" ) ) {
			arguments.order_promised_delivery_date= dateFormat( arguments.order_promised_delivery_date, "yyyy-mm-dd" );
		}
		var args = duplicate( arguments );
		structDelete( args, "slug" );
		structDelete( args, "tracking_number" );
		var json= { "tracking"= args };
		return this.apiRequest( "PUT /trackings/#arguments.slug#/#arguments.tracking_number#", json );
	}

	function updateTrackingID(
		required string tracking_id
	,	string title
	,	emails
	,	sms
	,	string order_id
	,	string order_id_path
	,	string customer_name
	,	struct custom_fields
	,	string note
	,	string language
	,	string delivery_type
	,	string pickup_location
	,	string pickup_note
	,	date order_promised_delivery_date
	) {
		if( structKeyExists( arguments, "emails" ) && isSimpleValue( arguments.emails ) ) {
			arguments.emails = listToArray( arguments.emails );
		}
		if( structKeyExists( arguments, "smses" ) && isSimpleValue( arguments.smses ) ) {
			arguments.smses = listToArray( arguments.smses );
		}
		if( structKeyExists( arguments, "order_promised_delivery_date" ) ) {
			arguments.order_promised_delivery_date= dateFormat( arguments.order_promised_delivery_date, "yyyy-mm-dd" );
		}
		var args = duplicate( arguments );
		structDelete( args, "tracking_id" );
		var json= { "tracking"= args };
		return this.apiRequest( "PUT /trackings/#arguments.tracking_id#", json );
	}


	//////////////////////////////////////////////////////////////////////////////
	// NOTIFICATIONS
	// https://docs.aftership.com/api/4/notifications/get-notifications
	//////////////////////////////////////////////////////////////////////////////

	function getNotifications( required string tracking_number, required string slug ) {
		return this.apiRequest( "GET /notifications/#arguments.slug#/#arguments.tracking_number#" );
	}

	function getNotificationsID( required string tracking_id ) {
		return this.apiRequest( "GET /notifications/#arguments.tracking_id#" );
	}

	function addNotification(
		required string tracking_number
	,	required string slug
	,	emails= ""
	,	sms= ""
	) {
		if( structKeyExists( arguments, "emails" ) && isSimpleValue( arguments.emails ) ) {
			arguments.emails = listToArray( arguments.emails );
		}
		if( structKeyExists( arguments, "smses" ) && isSimpleValue( arguments.smses ) ) {
			arguments.smses = listToArray( arguments.smses );
		}
		var json= {
			"notification"= {
				emails= arguments.emails
			,	smses= arguments.smses
			}
		};
		return this.apiRequest( "POST /notifications/#arguments.slug#/#arguments.tracking_number#/add", json );
	}

	function addNotificationID(
		required string tracking_id
	,	emails= ""
	,	sms= ""
	) {
		if( structKeyExists( arguments, "emails" ) && isSimpleValue( arguments.emails ) ) {
			arguments.emails = listToArray( arguments.emails );
		}
		if( structKeyExists( arguments, "smses" ) && isSimpleValue( arguments.smses ) ) {
			arguments.smses = listToArray( arguments.smses );
		}
		var json= {
			"notification"= {
				emails= arguments.emails
			,	smses= arguments.smses
			}
		};
		return this.apiRequest( "POST /notifications/#arguments.tracking_id#/add", json );
	}

	function removeNotification(
		required string tracking_number
	,	required string slug
	,	emails= ""
	,	sms= ""
	) {
		if( structKeyExists( arguments, "emails" ) && isSimpleValue( arguments.emails ) ) {
			arguments.emails = listToArray( arguments.emails );
		}
		if( structKeyExists( arguments, "smses" ) && isSimpleValue( arguments.smses ) ) {
			arguments.smses = listToArray( arguments.smses );
		}
		structDelete( args, "tracking_id" );
		var json= {
			"notification"= {
				emails= arguments.emails
			,	smses= arguments.smses
			}
		};
		return this.apiRequest( "POST /notifications/#arguments.slug#/#arguments.tracking_number#/remove", json );
	}

	function removeNotificationID(
		required string tracking_id
	,	emails= ""
	,	sms= ""
	) {
		if( structKeyExists( arguments, "emails" ) && isSimpleValue( arguments.emails ) ) {
			arguments.emails = listToArray( arguments.emails );
		}
		if( structKeyExists( arguments, "smses" ) && isSimpleValue( arguments.smses ) ) {
			arguments.smses = listToArray( arguments.smses );
		}
		var json= {
			"notification"= {
				emails= arguments.emails
			,	smses= arguments.smses
			}
		};
		return this.apiRequest( "POST /notifications/#arguments.tracking_id#/remove", json );
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
		// this.debugLog( out.response );
		out.statusCode = http.responseHeader.Status_Code ?: 500;
		if ( left( out.statusCode, 1 ) == 4 || left( out.statusCode, 1 ) == 5 ) {
			out.success= false;
			out.error= "status code error: #out.statusCode#";
		} else if ( out.response == "Connection Timeout" || out.response == "Connection Failure" ) {
			out.error= out.response;
		} else if ( left( out.statusCode, 1 ) == 2 ) {
			out.success= true;
		}
		// parse response 
		if ( len( out.response ) ) {
			try {
				out.response= deserializeJSON( out.response );
				if ( isStruct( out.response ) && structKeyExists( out.response, "meta" ) && structKeyExists( out.response.meta, "message" ) ) {
					out.success= false;
					out.error= out.response.meta.message;
				}
			} catch (any cfcatch) {
				out.error= "JSON Error: " & (cfcatch.message?:"No catch message") & " " & (cfcatch.detail?:"No catch detail");
			}
		}
		if ( len( out.error ) ) {
			out.success= false;
		}
		this.debugLog( out.statusCode & " " & out.error );
		return out;
	}

	string function zDateFormat( required date date ) {
		arguments.date = dateAdd( "s", this.offSet, arguments.date );
		return dateFormat( arguments.date, "yyyy-mm-dd" ) & "T" & timeFormat( arguments.date, "HH:mm:ss") & "Z";
	}

	string function structToQueryString(required struct stInput, boolean bEncode= true) {
		var sOutput= "";
		var sItem= "";
		var sValue= "";
		var amp= "?";
		for ( sItem in stInput ) {
			if ( !isNull( stInput[ sItem ] ) ) {
				sValue= stInput[ sItem ];
				if ( bEncode ) {
					sOutput &= amp & sItem & "=" & urlEncodedFormat( sValue );
				} else {
					sOutput &= amp & sItem & "=" & sValue;
				}
				amp= "&";
			}
		}
		return sOutput;
	}

}