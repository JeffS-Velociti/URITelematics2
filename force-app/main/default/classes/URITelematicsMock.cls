@isTest  
public class URITelematicsMock
{   
    public class URITelematics200Mock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest request){
            HTTpResponse response = new HTTPResponse();
            if(request.getEndpoint().contains('https://velociti-endpoints.herokuapp.com/api/sobjectservice')){
                response.setStatusCode(200);
                response.setStatus('OK');
                InstallationAppDmlUtil.ServiceResponse cls = new InstallationAppDmlUtil.ServiceResponse();
                cls.status = 'Success';
                cls.recordString =request.getBody();
                response.setBody(JSON.serialize(cls));
            }else if(request.getEndpoint().contains('https://api.onei3.com/1537/series?attr[equipment]=')){
                response.setStatus('OK');
                response.setStatusCode(200);
                response.setBody('{"id":"36683823253185679","href":"/1537/series/36683823253185679","key":"equipment:36681234864301193.run_time","title":"Run Time","tags":["run_time","numeric","time"],"attrs":{"equipment":"36681234864301193","uom":"hour"},"createdAt":"2014-10-28T14:44:12Z","last":{"t":"2014-10-28T15:45:59Z","v":101.11}}');
            }else if(request.getEndpoint().contains('https://api.onei3.com/257/devices/')){
                String responseBody = '{"href":"/257/devices/4662168139","serialNumber":"4662168139","network":{"href":"/257/devices/4662168139/network"},"attrs":{"model":"M6H2"},"tags":[],"createdAt":"2015-12-21T04:03:40Z"}';
                response.setStatus('OK');
                response.setStatusCode(200);
                response.setBody(responseBody);
            }else if(request.getEndpoint().contains('https://api.onei3.com/769/installations/?device.serialnumber=')){
                String responseBody = '[{"id":"69516673895458533","account":{"id":"222842659"},"href":"/769/installations/69516673895458533","createdAt":"2014-12-12T21:57:13Z","device":{"href":"/257/devices/4662007381","serialNumber":"4662007381","attrs":{"model":"M6H2"},"tags":[],"createdAt":"2014-11-04T23:14:51Z","communicatedAt":"2014-12-17T09:17:01Z"},"equipment":{"id":"69516673845126884","href":"/513/equipment/69516673845126884","name":"10291939","createdAt":"2014-12-12T21:57:13Z","tags":[],"attrs":{"class":"2000","category":"0300","make":"SKYJACK","model":"SJIII3219","model year":"2014","equipment number":"10291939"}},"packages":[{"id":"20813847120052572","name":"M6H - United Rentals: Basic + Utilization"}],"attrs":{}}]';
                response.setStatusCode(200);
                response.setBody(responseBody);
            }else if(request.getEndpoint().contains('https://api.onei3.com/769/installations/')){
                //String responseBody = '{ "href": "/installations/123454321", "message": "Installation has been queued for processing" }';
                response.setStatus('OK');
                response.setStatusCode(200);
                response.setBody('{ "id": "1000000", "device": { "serialNumber":"123456789", "attrs": { "model": "M6C" },"tags": [],"createdAt": "2014-09-30T05:00Z","communicatedAt": "2014-09-30T05:50Z" }, "equipment": {"id":"987654321","name":"F150 Service Truck #333","attrs":{"make":"Ford","model":"F150","year":"2012"}},"packages":[{"id":"111222333"}],"attrs":{"Installed by":"someuser@somecompany.com","key2":"value2"}}');
            }else if(request.getEndpoint().contains('https://api.onei3.com/769/installations')){
                String responseBody = '{ "href": "/installations/123454321", "message": "Installation has been queued for processing" }';
                response.setStatus('OK');
                response.setStatusCode(200);
                response.setBody(responseBody);
            }else if(request.getEndpoint().contains('https://api.onei3.com/513/equipment?name=')){
                //String responseBody = '{ "id": "469500422025841082", "href": "/513/equipment/469500422025841082", "name": "10501260", "createdAt" : "2016-06-16T18:53:31Z", "communicatedAt": "2018-04-16T13:20:01Z", "tags": [], "attrs": {"make": "MAGNUM PRO","model": "MLT6SM","model year": "2016","vin": "1602959","po": "11402487","onei3:serial": "4662202985","onei3:model": "M6H2","class":"4001","category":"320","equipment number":"10501260"}, "coords": [ -80.65661,40.88523] }';
                response.setBody('[{ "id": "469500422025841082", "href": "/513/equipment/469500422025841082", "name": "10501260", "createdAt" : "2016-06-16T18:53:31Z", "communicatedAt": "2018-04-16T13:20:01Z", "tags": [], "attrs": {"make": "MAGNUM PRO","model": "MLT6SM","model year": "2016","vin": "1602959","po": "11402487","onei3:serial": "4662202985","onei3:model": "M6H2","class":"4001","category":"320","equipment number":"10501260"}, "coords": [ -80.65661,40.88523] }]');
                
                response.setStatus('OK');
                response.setStatusCode(200);
               // response.setBody(responseBody);
            }else if(request.getEndpoint().contains('https://api.onei3.com/513/equipment')){
                String responseBody = '{ "id": "469500422025841082", "href": "/513/equipment/469500422025841082", "name": "10501260", "createdAt" : "2016-06-16T18:53:31Z", "communicatedAt": "2018-04-16T13:20:01Z", "tags": [], "attrs": {"make": "MAGNUM PRO","model": "MLT6SM","model year": "2016","vin": "1602959","po": "11402487","onei3:serial": "4662202985","onei3:model": "M6H2","class":"4001","category":"320","equipment number":"10501260"}, "coords": [ -80.65661,40.88523] }';
                response.setStatus('OK');
                response.setStatusCode(200);
                response.setBody(responseBody);
            }else if(request.getEndpoint().contains('https://api.onei3.com/769/installations/')){
                                String responseBody = '[{"id":"69516673895458533","account":{"id":"222842659"},"href":"/769/installations/69516673895458533","createdAt":"2014-12-12T21:57:13Z","device":{"href":"/257/devices/4662007381","serialNumber":"4662007381","attrs":{"model":"M6H2"},"tags":[],"createdAt":"2014-11-04T23:14:51Z","communicatedAt":"2014-12-17T09:17:01Z"},"equipment":{"id":"69516673845126884","href":"/513/equipment/69516673845126884","name":"10291939","createdAt":"2014-12-12T21:57:13Z","tags":[],"attrs":{"class":"2000","category":"0300","make":"SKYJACK","model":"SJIII3219","model year":"2014","equipment number":"10291939"}},"packages":[{"id":"20813847120052572","name":"M6H - United Rentals: Basic + Utilization"}],"attrs":{}}]';
                response.setBody(responseBody);
                response.setStatusCode(200);
            }else if(request.getEndpoint().contains('https://auth.onei3.com/core/connect/token')){
                String responseBody = '{"access_token": "qwertyui789456"}';
                response.setStatusCode(200);
                response.setBody(responseBody);
            }else{
                String responseBody = '[{"id":"69516673895458533","account":{"id":"222842659"},"href":"/769/installations/69516673895458533","createdAt":"2014-12-12T21:57:13Z","device":{"href":"/257/devices/4662007381","serialNumber":"4662007381","attrs":{"model":"M6H2"},"tags":[],"createdAt":"2014-11-04T23:14:51Z","communicatedAt":"2014-12-17T09:17:01Z"},"equipment":{"id":"69516673845126884","href":"/513/equipment/69516673845126884","name":"10291939","createdAt":"2014-12-12T21:57:13Z","tags":[],"attrs":{"class":"2000","category":"0300","make":"SKYJACK","model":"SJIII3219","model year":"2014","equipment number":"10291939"}},"packages":[{"id":"20813847120052572","name":"M6H - United Rentals: Basic + Utilization"}],"attrs":{}}]';
                response.setStatusCode(200);
                response.setStatusCode(200);
            }
            return response;
        }
        
    }
    
    public class URITelematics200Mocka implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest request){
            HTTpResponse response = new HTTPResponse();
            if(request.getEndpoint().contains('https://velociti-endpoints.herokuapp.com/api/sobjectservice')){
                response.setStatusCode(200);
                response.setStatus('OK');
                InstallationAppDmlUtil.ServiceResponse cls = new InstallationAppDmlUtil.ServiceResponse();
                cls.status = 'Success';
                cls.recordString =request.getBody();
                response.setBody(JSON.serialize(cls));
            }else if(request.getEndpoint().contains('https://api.onei3.com/1537/series?attr[equipment]=')){
                response.setStatus('OK');
                response.setStatusCode(200);
                response.setBody('{"id":"36683823253185679","href":"/1537/series/36683823253185679","key":"equipment:36681234864301193.run_time","title":"Run Time","tags":["run_time","numeric","time"],"attrs":{"equipment":"36681234864301193","uom":"hour"},"createdAt":"2014-10-28T14:44:12Z","last":{"t":"2014-10-28T15:45:59Z","v":101.11}}');
            }else if(request.getEndpoint().contains('https://api.onei3.com/257/devices/')){
                String responseBody = '{"href":"/257/devices/4662168139","serialNumber":"4662168139","network":{"href":"/257/devices/4662168139/network"},"attrs":{"model":"M6H2"},"tags":[],"createdAt":"2015-12-21T04:03:40Z"}';
                response.setStatus('OK');
                response.setStatusCode(200);
                response.setBody(responseBody);
            }else if(request.getEndpoint().contains('https://api.onei3.com/769/installations/?device.serialnumber=')){
                String responseBody = '[{"id":"69516673895458533","account":{"id":"222842659"},"href":"/769/installations/69516673895458533","createdAt":"2014-12-12T21:57:13Z","device":{"href":"/257/devices/4662007381","serialNumber":"4662007381","attrs":{"model":"M6H2"},"tags":[],"createdAt":"2014-11-04T23:14:51Z","communicatedAt":"2014-12-17T09:17:01Z"},"equipment":{"id":"69516673845126884","href":"/513/equipment/69516673845126884","name":"10291939","createdAt":"2014-12-12T21:57:13Z","tags":[],"attrs":{"class":"2000","category":"0300","make":"SKYJACK","model":"SJIII3219","model year":"2014","equipment number":"10291939"}},"packages":[{"id":"20813847120052572","name":"M6H - United Rentals: Basic + Utilization"}],"attrs":{}}]';
                response.setStatusCode(202);
                response.setBody(responseBody);
            }else if(request.getEndpoint().contains('https://api.onei3.com/769/installations/')){
                //String responseBody = '{ "href": "/installations/123454321", "message": "Installation has been queued for processing" }';
                response.setStatus('OK');
                response.setStatusCode(200);
                response.setBody('{ "id": "1000000", "device": { "serialNumber":"123456789", "attrs": { "model": "M6C" },"tags": [],"createdAt": "2014-09-30T05:00Z","communicatedAt": "2014-09-30T05:50Z" }, "equipment": {"id":"987654321","name":"F150 Service Truck #333","attrs":{"make":"Ford","model":"F150","year":"2012"}},"packages":[{"id":"111222333"}],"attrs":{"Installed by":"someuser@somecompany.com","key2":"value2"}}');
            }else if(request.getEndpoint().contains('https://api.onei3.com/769/installations')){
                String responseBody = '{ "href": "/installations/123454321", "message": "Installation has been queued for processing" }';
                response.setStatus('OK');
                response.setStatusCode(200);
                response.setBody(responseBody);
            }else if(request.getEndpoint().contains('https://api.onei3.com/513/equipment?name=')){
                //String responseBody = '{ "id": "469500422025841082", "href": "/513/equipment/469500422025841082", "name": "10501260", "createdAt" : "2016-06-16T18:53:31Z", "communicatedAt": "2018-04-16T13:20:01Z", "tags": [], "attrs": {"make": "MAGNUM PRO","model": "MLT6SM","model year": "2016","vin": "1602959","po": "11402487","onei3:serial": "4662202985","onei3:model": "M6H2","class":"4001","category":"320","equipment number":"10501260"}, "coords": [ -80.65661,40.88523] }';
                response.setBody('[{ "id": "469500422025841082", "href": "/513/equipment/469500422025841082", "name": "10501260", "createdAt" : "2016-06-16T18:53:31Z", "communicatedAt": "2018-04-16T13:20:01Z", "tags": [], "attrs": {"make": "MAGNUM PRO","model": "MLT6SM","model year": "2016","vin": "1602959","po": "11402487","onei3:serial": "4662202985","onei3:model": "M6H2","class":"4001","category":"320","equipment number":"10501260"}, "coords": [ -80.65661,40.88523] }]');
                
                response.setStatus('OK');
                response.setStatusCode(200);
               // response.setBody(responseBody);
            }else if(request.getEndpoint().contains('https://api.onei3.com/513/equipment')){
                String responseBody = '{ "id": "469500422025841082", "href": "/513/equipment/469500422025841082", "name": "10501260", "createdAt" : "2016-06-16T18:53:31Z", "communicatedAt": "2018-04-16T13:20:01Z", "tags": [], "attrs": {"make": "MAGNUM PRO","model": "MLT6SM","model year": "2016","vin": "1602959","po": "11402487","onei3:serial": "4662202985","onei3:model": "M6H2","class":"4001","category":"320","equipment number":"10501260"}, "coords": [ -80.65661,40.88523] }';
                response.setStatus('OK');
                response.setStatusCode(200);
                response.setBody(responseBody);
            }else if(request.getEndpoint().contains('https://api.onei3.com/769/installations/')){
                                String responseBody = '[{"id":"69516673895458533","account":{"id":"222842659"},"href":"/769/installations/69516673895458533","createdAt":"2014-12-12T21:57:13Z","device":{"href":"/257/devices/4662007381","serialNumber":"4662007381","attrs":{"model":"M6H2"},"tags":[],"createdAt":"2014-11-04T23:14:51Z","communicatedAt":"2014-12-17T09:17:01Z"},"equipment":{"id":"69516673845126884","href":"/513/equipment/69516673845126884","name":"10291939","createdAt":"2014-12-12T21:57:13Z","tags":[],"attrs":{"class":"2000","category":"0300","make":"SKYJACK","model":"SJIII3219","model year":"2014","equipment number":"10291939"}},"packages":[{"id":"20813847120052572","name":"M6H - United Rentals: Basic + Utilization"}],"attrs":{}}]';
                response.setBody(responseBody);
                response.setStatusCode(200);
            }else if(request.getEndpoint().contains('https://auth.onei3.com/core/connect/token')){
                String responseBody = '{"access_token": "qwertyui789456"}';
                response.setStatusCode(200);
                response.setBody(responseBody);
            }else{
                String responseBody = '[{"id":"69516673895458533","account":{"id":"222842659"},"href":"/769/installations/69516673895458533","createdAt":"2014-12-12T21:57:13Z","device":{"href":"/257/devices/4662007381","serialNumber":"4662007381","attrs":{"model":"M6H2"},"tags":[],"createdAt":"2014-11-04T23:14:51Z","communicatedAt":"2014-12-17T09:17:01Z"},"equipment":{"id":"69516673845126884","href":"/513/equipment/69516673845126884","name":"10291939","createdAt":"2014-12-12T21:57:13Z","tags":[],"attrs":{"class":"2000","category":"0300","make":"SKYJACK","model":"SJIII3219","model year":"2014","equipment number":"10291939"}},"packages":[{"id":"20813847120052572","name":"M6H - United Rentals: Basic + Utilization"}],"attrs":{}}]';
                response.setStatusCode(200);
                response.setStatusCode(200);
            }
            return response;
        }
        
    }
    public class URITelematics429Mock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest request){
            HTTpResponse response = new HTTPResponse();
            if(request.getEndpoint().contains('https://velociti-endpoints.herokuapp.com/api/sobjectservice')){
                response.setStatusCode(200);
                response.setStatus('OK');
                InstallationAppDmlUtil.ServiceResponse cls = new InstallationAppDmlUtil.ServiceResponse();
                cls.status = 'Success';
                cls.recordString =request.getBody();
                response.setBody(JSON.serialize(cls));
            }else if(request.getEndpoint().contains('https://api.onei3.com/1537/series?attr[equipment]=')){
                response.setStatus('OK');
                response.setStatusCode(429);
                response.setBody('{"id":"36683823253185679","href":"/1537/series/36683823253185679","key":"equipment:36681234864301193.run_time","title":"Run Time","tags":["run_time","numeric","time"],"attrs":{"equipment":"36681234864301193","uom":"hour"},"createdAt":"2014-10-28T14:44:12Z","last":{"t":"2014-10-28T15:45:59Z","v":101.11}}');
            }else if(request.getEndpoint().contains('https://api.onei3.com/257/devices/')){
                String responseBody = '{"href":"/257/devices/4662168139","serialNumber":"4662168139","network":{"href":"/257/devices/4662168139/network"},"attrs":{"model":"M6H2"},"tags":[],"createdAt":"2015-12-21T04:03:40Z"}';
                response.setStatus('OK');
                response.setStatusCode(429);
                response.setBody(responseBody);
            }else if(request.getEndpoint().contains('https://api.onei3.com/769/installations/')){
                //String responseBody = '{ "href": "/installations/123454321", "message": "Installation has been queued for processing" }';
                response.setStatus('OK');
                response.setStatusCode(429);
                response.setBody('{ "id": "1000000", "device": { "serialNumber":"123456789", "attrs": { "model": "M6C" },"tags": [],"createdAt": "2014-09-30T05:00Z","communicatedAt": "2014-09-30T05:50Z" }, "equipment": {"id":"987654321","name":"F150 Service Truck #333","attrs":{"make":"Ford","model":"F150","year":"2012"}},"packages":[{"id":"111222333"}],"attrs":{"Installed by":"someuser@somecompany.com","key2":"value2"}}');
            }else if(request.getEndpoint().contains('https://api.onei3.com/769/installations')){
                String responseBody = '{ "href": "/installations/123454321", "message": "Installation has been queued for processing" }';
                response.setStatus('OK');
                response.setStatusCode(429);
                response.setBody(responseBody);
            }else if(request.getEndpoint().contains('https://api.onei3.com/513/equipment?name=')){
                String responseBody = '[{ "id": "469500422025841082", "href": "/513/equipment/469500422025841082", "name": "10501260", "createdAt" : "2016-06-16T18:53:31Z", "communicatedAt": "2018-04-16T13:20:01Z", "tags": [], "attrs": {"make": "MAGNUM PRO","model": "MLT6SM","model year": "2016","vin": "1602959","po": "11402487","onei3:serial": "4662202985","onei3:model": "M6H2","class":"4001","category":"320","equipment number":"10501260"}, "coords": [ -80.65661,40.88523] }]';
                response.setStatus('OK');
                response.setStatusCode(429);
                response.setBody(responseBody);
            }else if(request.getEndpoint().contains('https://api.onei3.com/769/installations/')){
                response.setStatusCode(429);
            }else if(request.getEndpoint().contains('https://auth.onei3.com/core/connect/token')){
                String responseBody = '{"access_token": "qwertyui789456"}';
                response.setStatusCode(429);
                response.setBody(responseBody);
            }else {
                response.setStatusCode(429);
            }
            return response;
        }
        
    }
    
    public class URITelematics429Mocka implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest request){
            HTTpResponse response = new HTTPResponse();
            if(request.getEndpoint().contains('https://velociti-endpoints.herokuapp.com/api/sobjectservice')){
                response.setStatusCode(200);
                response.setStatus('OK');
                InstallationAppDmlUtil.ServiceResponse cls = new InstallationAppDmlUtil.ServiceResponse();
                cls.status = 'Success';
                cls.recordString =request.getBody();
                response.setBody(JSON.serialize(cls));
            }else if(request.getEndpoint().contains('https://api.onei3.com/1537/series?attr[equipment]=')){
                response.setStatus('OK');
                response.setStatusCode(428);
                response.setBody('{"id":"36683823253185679","href":"/1537/series/36683823253185679","key":"equipment:36681234864301193.run_time","title":"Run Time","tags":["run_time","numeric","time"],"attrs":{"equipment":"36681234864301193","uom":"hour"},"createdAt":"2014-10-28T14:44:12Z","last":{"t":"2014-10-28T15:45:59Z","v":101.11}}');
            }else if(request.getEndpoint().contains('https://api.onei3.com/257/devices/')){
                String responseBody = '{"href":"/257/devices/4662168139","serialNumber":"4662168139","network":{"href":"/257/devices/4662168139/network"},"attrs":{"model":"M6H2"},"tags":[],"createdAt":"2015-12-21T04:03:40Z"}';
                response.setStatus('OK');
                response.setStatusCode(428);
                response.setBody(responseBody);
            }else if(request.getEndpoint().contains('https://api.onei3.com/769/installations/')){
                //String responseBody = '{ "href": "/installations/123454321", "message": "Installation has been queued for processing" }';
                response.setStatus('OK');
                response.setStatusCode(428);
                response.setBody('{ "id": "1000000", "device": { "serialNumber":"123456789", "attrs": { "model": "M6C" },"tags": [],"createdAt": "2014-09-30T05:00Z","communicatedAt": "2014-09-30T05:50Z" }, "equipment": {"id":"987654321","name":"F150 Service Truck #333","attrs":{"make":"Ford","model":"F150","year":"2012"}},"packages":[{"id":"111222333"}],"attrs":{"Installed by":"someuser@somecompany.com","key2":"value2"}}');
            }else if(request.getEndpoint().contains('https://api.onei3.com/769/installations')){
                String responseBody = '{ "href": "/installations/123454321", "message": "Installation has been queued for processing" }';
                response.setStatus('OK');
                response.setStatusCode(428);
                response.setBody(responseBody);
            }else if(request.getEndpoint().contains('https://api.onei3.com/513/equipment?name=')){
                String responseBody = '[{ "id": "469500422025841082", "href": "/513/equipment/469500422025841082", "name": "10501260", "createdAt" : "2016-06-16T18:53:31Z", "communicatedAt": "2018-04-16T13:20:01Z", "tags": [], "attrs": {"make": "MAGNUM PRO","model": "MLT6SM","model year": "2016","vin": "1602959","po": "11402487","onei3:serial": "4662202985","onei3:model": "M6H2","class":"4001","category":"320","equipment number":"10501260"}, "coords": [ -80.65661,40.88523] }]';
                response.setStatus('OK');
                response.setStatusCode(428);
                response.setBody(responseBody);
            }else if(request.getEndpoint().contains('https://api.onei3.com/769/installations/')){
                response.setStatusCode(428);
            }else if(request.getEndpoint().contains('https://auth.onei3.com/core/connect/token')){
                String responseBody = '{"access_token": "qwertyui789456"}';
                response.setStatusCode(428);
                response.setBody(responseBody);
            }else {
                response.setStatusCode(428);
            }
            return response;
        }
        
    }
    
    public class URITelematics202Mock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest request){
            HTTpResponse response = new HTTPResponse();
            if(request.getEndpoint().contains('https://velociti-endpoints.herokuapp.com/api/sobjectservice')){
                response.setStatusCode(200);
                response.setStatus('OK');
                InstallationAppDmlUtil.ServiceResponse cls = new InstallationAppDmlUtil.ServiceResponse();
                cls.status = 'Success';
                cls.recordString =request.getBody();
                response.setBody(JSON.serialize(cls));
            }else if(request.getEndpoint().contains('https://api.onei3.com/1537/series?attr[equipment]=')){
                response.setStatus('OK');
                response.setStatusCode(202);
                response.setBody('{"id":"36683823253185679","href":"/1537/series/36683823253185679","key":"equipment:36681234864301193.run_time","title":"Run Time","tags":["run_time","numeric","time"],"attrs":{"equipment":"36681234864301193","uom":"hour"},"createdAt":"2014-10-28T14:44:12Z","last":{"t":"2014-10-28T15:45:59Z","v":101.11}}');
            }else if(request.getEndpoint().contains('https://api.onei3.com/257/devices/')){
                String responseBody = '{"href":"/257/devices/4662168139","serialNumber":"4662168139","network":{"href":"/257/devices/4662168139/network"},"attrs":{"model":"M6H2"},"tags":[],"createdAt":"2015-12-21T04:03:40Z"}';
                response.setStatus('OK');
                response.setStatusCode(202);
                response.setBody(responseBody);
            }else if(request.getEndpoint().contains('https://api.onei3.com/769/installations')){
                String responseBody = '{ "href": "/installations/123454321", "message": "Installation has been queued for processing" }';
                response.setStatus('OK');
                response.setStatusCode(202);
                response.setBody(responseBody);
            }else if(request.getEndpoint().contains('https://api.onei3.com/513/equipment?name=')){
                String responseBody = '[{ "id": "469500422025841082", "href": "/513/equipment/469500422025841082", "name": "10501260", "createdAt" : "2016-06-16T18:53:31Z", "communicatedAt": "2018-04-16T13:20:01Z", "tags": [], "attrs": {"make": "MAGNUM PRO","model": "MLT6SM","model year": "2016","vin": "1602959","po": "11402487","onei3:serial": "4662202985","onei3:model": "M6H2","class":"4001","category":"320","equipment number":"10501260"}, "coords": [ -80.65661,40.88523] }]';
                response.setStatus('OK');
                response.setStatusCode(202);
                response.setBody(responseBody);
            }else if(request.getEndpoint().contains('https://api.onei3.com/769/installations/')){
                response.setStatusCode(202);
            }else if(request.getEndpoint().contains('https://auth.onei3.com/core/connect/token')){
                String responseBody = '{"access_token": "qwertyui789456"}';
                response.setStatusCode(202);
                response.setBody(responseBody);
            }else {
                response.setStatusCode(202);
            }
            return response;
        }
        
    }
    
    public class URITelematics202Mocka implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest request){
            HTTpResponse response = new HTTPResponse();
            if(request.getEndpoint().contains('https://velociti-endpoints.herokuapp.com/api/sobjectservice')){
                response.setStatusCode(200);
                response.setStatus('OK');
                InstallationAppDmlUtil.ServiceResponse cls = new InstallationAppDmlUtil.ServiceResponse();
                cls.status = 'Success';
                cls.recordString =request.getBody();
                response.setBody(JSON.serialize(cls));
            }else if(request.getEndpoint().contains('https://api.onei3.com/1537/series?attr[equipment]=')){
                response.setStatus('OK');
                response.setStatusCode(202);
                response.setBody('{"id":"36683823253185679","href":"/1537/series/36683823253185679","key":"equipment:36681234864301193.run_time","title":"Run Time","tags":["run_time","numeric","time"],"attrs":{"equipment":"36681234864301193","uom":"hour"},"createdAt":"2014-10-28T14:44:12Z","last":{"t":"2014-10-28T15:45:59Z","v":101.11}}');
            }else if(request.getEndpoint().contains('https://api.onei3.com/257/devices/')){
                String responseBody = '{"href":"/257/devices/4662168139","serialNumber":"4662168139","network":{"href":"/257/devices/4662168139/network"},"attrs":{"model":"M6H2"},"tags":[],"createdAt":"2015-12-21T04:03:40Z"}';
                response.setStatus('OK');
                response.setStatusCode(202);
                response.setBody(responseBody);
            }else if(request.getEndpoint().contains('https://api.onei3.com/769/installations')){
                String responseBody = '{ "href": "/installations/123454321", "message": "Installation has been queued for processing" }';
                response.setStatus('OK');
                response.setStatusCode(202);
                response.setBody(responseBody);
            }else if(request.getEndpoint().contains('https://api.onei3.com/513/equipment?name=')){
                String responseBody = '[{ "id": "469500422025841082", "href": "/513/equipment/469500422025841082", "name": "10501260", "createdAt" : "2016-06-16T18:53:31Z", "communicatedAt": "2018-04-16T13:20:01Z", "tags": [], "attrs": {"make": "MAGNUM PRO","model": "MLT6SM","model year": "2016","vin": "1602959","po": "11402487","onei3:serial": "4662202985","onei3:model": "M6H2","class":"4001","category":"320","equipment number":"10501260"}, "coords": [ -80.65661,40.88523] }]';
                response.setStatus('OK');
                response.setStatusCode(202);
                response.setBody(responseBody);
            }else if(request.getEndpoint().contains('https://api.onei3.com/769/installations/')){
                response.setStatusCode(200);
            }else if(request.getEndpoint().contains('https://auth.onei3.com/core/connect/token')){
                String responseBody = '{"access_token": "qwertyui789456"}';
                response.setStatusCode(202);
                response.setBody(responseBody);
            }else {
                response.setStatusCode(202);
            }
            return response;
        }
        
    }
    public class URITelematics409Mock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest request){
            HTTpResponse response = new HTTPResponse();
            if(request.getEndpoint().contains('https://velociti-endpoints.herokuapp.com/api/sobjectservice')){
                response.setStatusCode(200);
                response.setStatus('OK');
                InstallationAppDmlUtil.ServiceResponse cls = new InstallationAppDmlUtil.ServiceResponse();
                cls.status = 'Success';
                cls.recordString =request.getBody();
                response.setBody(JSON.serialize(cls));
            }else if(request.getEndpoint().contains('https://api.onei3.com/1537/series?attr[equipment]=')){
                response.setStatus('OK');
                response.setStatusCode(409);
                response.setBody('{"id":"36683823253185679","href":"/1537/series/36683823253185679","key":"equipment:36681234864301193.run_time","title":"Run Time","tags":["run_time","numeric","time"],"attrs":{"equipment":"36681234864301193","uom":"hour"},"createdAt":"2014-10-28T14:44:12Z","last":{"t":"2014-10-28T15:45:59Z","v":101.11}}');
            }else if(request.getEndpoint().contains('https://api.onei3.com/257/devices/')){
                String responseBody = '{"href":"/257/devices/4662168139","serialNumber":"4662168139","network":{"href":"/257/devices/4662168139/network"},"attrs":{"model":"M6H2"},"tags":[],"createdAt":"2015-12-21T04:03:40Z"}';
                response.setStatus('OK');
                response.setStatusCode(409);
                response.setBody(responseBody);
            }else if(request.getEndpoint().contains('https://api.onei3.com/769/installations')){
                String responseBody = '{ "href": "/installations/123454321", "message": "Installation has been queued for processing" }';
                response.setStatus('OK');
                response.setStatusCode(409);
                response.setBody(responseBody);
            }else if(request.getEndpoint().contains('https://api.onei3.com/513/equipment?name=')){
                String responseBody = '[{ "id": "469500422025841082", "href": "/513/equipment/469500422025841082", "name": "10501260", "createdAt" : "2016-06-16T18:53:31Z", "communicatedAt": "2018-04-16T13:20:01Z", "tags": [], "attrs": {"make": "MAGNUM PRO","model": "MLT6SM","model year": "2016","vin": "1602959","po": "11402487","onei3:serial": "4662202985","onei3:model": "M6H2","class":"4001","category":"320","equipment number":"10501260"}, "coords": [ -80.65661,40.88523] }]';
                response.setStatus('OK');
                response.setStatusCode(409);
                response.setBody(responseBody);
            }else if(request.getEndpoint().contains('https://api.onei3.com/769/installations/')){
                response.setStatusCode(409);
            }else if(request.getEndpoint().contains('https://auth.onei3.com/core/connect/token')){
                String responseBody = '{"access_token": "qwertyui789456"}';
                response.setStatusCode(409);
                response.setBody(responseBody);
            }else {
                response.setStatusCode(409);
            }
            return response;
        }
        
    }
    public class URITelematics400Mock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest request){
            HTTpResponse response = new HTTPResponse();
            if(request.getEndpoint().contains('https://velociti-endpoints.herokuapp.com/api/sobjectservice')){
                response.setStatusCode(200);
                response.setStatus('OK');
                InstallationAppDmlUtil.ServiceResponse cls = new InstallationAppDmlUtil.ServiceResponse();
                cls.status = 'Success';
                cls.recordString =request.getBody();
                response.setBody(JSON.serialize(cls));
            }else if(request.getEndpoint().contains('https://api.onei3.com/1537/series?attr[equipment]=')){
                response.setStatus('OK');
                response.setStatusCode(400);
                response.setBody('{"id":"36683823253185679","href":"/1537/series/36683823253185679","key":"equipment:36681234864301193.run_time","title":"Run Time","tags":["run_time","numeric","time"],"attrs":{"equipment":"36681234864301193","uom":"hour"},"createdAt":"2014-10-28T14:44:12Z","last":{"t":"2014-10-28T15:45:59Z","v":101.11}}');
            }else if(request.getEndpoint().contains('https://api.onei3.com/257/devices/')){
                String responseBody = '{"href":"/257/devices/4662168139","serialNumber":"4662168139","network":{"href":"/257/devices/4662168139/network"},"attrs":{"model":"M6H2"},"tags":[],"createdAt":"2015-12-21T04:03:40Z"}';
                response.setStatus('OK');
                response.setStatusCode(400);
                response.setBody(responseBody);
            }else if(request.getEndpoint().contains('https://api.onei3.com/769/installations')){
                String responseBody = '{ "href": "/installations/123454321", "message": "Installation has been queued for processing" }';
                response.setStatus('OK');
                response.setStatusCode(400);
                response.setBody(responseBody);
            }else if(request.getEndpoint().contains('https://api.onei3.com/513/equipment?name=')){
                String responseBody = '[{ "id": "469500422025841082", "href": "/513/equipment/469500422025841082", "name": "10501260", "createdAt" : "2016-06-16T18:53:31Z", "communicatedAt": "2018-04-16T13:20:01Z", "tags": [], "attrs": {"make": "MAGNUM PRO","model": "MLT6SM","model year": "2016","vin": "1602959","po": "11402487","onei3:serial": "4662202985","onei3:model": "M6H2","class":"4001","category":"320","equipment number":"10501260"}, "coords": [ -80.65661,40.88523] }]';
                response.setStatus('OK');
                response.setStatusCode(400);
                response.setBody(responseBody);
            }else if(request.getEndpoint().contains('https://api.onei3.com/769/installations/')){
                response.setStatusCode(400);
            }else if(request.getEndpoint().contains('https://auth.onei3.com/core/connect/token')){
                String responseBody = '{"access_token": "qwertyui789456"}';
                response.setStatusCode(400);
                response.setBody(responseBody);
            }else {
                response.setStatusCode(400);
            }
            return response;
        }
        
    }
    public class URITelematics404Mock implements HttpCalloutMock {
        
        public HTTPResponse respond(HTTPRequest request){
            HTTpResponse response = new HTTPResponse();
            if(request.getEndpoint().contains('https://velociti-endpoints.herokuapp.com/api/sobjectservice')){
                response.setStatusCode(200);
                response.setStatus('OK');
                InstallationAppDmlUtil.ServiceResponse cls = new InstallationAppDmlUtil.ServiceResponse();
                cls.status = 'Success';
                cls.recordString =request.getBody();
                response.setBody(JSON.serialize(cls));
            }else if(request.getEndpoint().contains('https://api.onei3.com/1537/series?attr[equipment]=')){
                response.setStatus('OK');
                response.setStatusCode(404);
                response.setBody('{"id":"36683823253185679","href":"/1537/series/36683823253185679","key":"equipment:36681234864301193.run_time","title":"Run Time","tags":["run_time","numeric","time"],"attrs":{"equipment":"36681234864301193","uom":"hour"},"createdAt":"2014-10-28T14:44:12Z","last":{"t":"2014-10-28T15:45:59Z","v":101.11}}');
            }else if(request.getEndpoint().contains('https://api.onei3.com/257/devices/')){
                String responseBody = '{"href":"/257/devices/4662168139","serialNumber":"4662168139","network":{"href":"/257/devices/4662168139/network"},"attrs":{"model":"M6H2"},"tags":[],"createdAt":"2015-12-21T04:03:40Z"}';
                response.setStatus('OK');
                response.setStatusCode(404);
                response.setBody(responseBody);
            }else if(request.getEndpoint().contains('https://api.onei3.com/769/installations')){
                String responseBody = '{ "href": "/installations/123454321", "message": "Installation has been queued for processing" }';
                response.setStatus('OK');
                response.setStatusCode(404);
                response.setBody(responseBody);
            }else if(request.getEndpoint().contains('https://api.onei3.com/513/equipment?name=')){
                String responseBody = '[{ "id": "469500422025841082", "href": "/513/equipment/469500422025841082", "name": "10501260", "createdAt" : "2016-06-16T18:53:31Z", "communicatedAt": "2018-04-16T13:20:01Z", "tags": [], "attrs": {"make": "MAGNUM PRO","model": "MLT6SM","model year": "2016","vin": "1602959","po": "11402487","onei3:serial": "4662202985","onei3:model": "M6H2","class":"4001","category":"320","equipment number":"10501260"}, "coords": [ -80.65661,40.88523] }]';
                response.setStatus('OK');
                response.setStatusCode(404);
                response.setBody(responseBody);
            }else if(request.getEndpoint().contains('https://api.onei3.com/769/installations/')){
                response.setStatusCode(404);
            }else if(request.getEndpoint().contains('https://auth.onei3.com/core/connect/token')){
                String responseBody = '{"access_token": "qwertyui789456"}';
                response.setStatusCode(404);
                response.setBody(responseBody);
            }else {
                response.setStatusCode(404);
            }
            return response;
        }
        
    }
}