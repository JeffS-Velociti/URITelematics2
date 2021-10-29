public without sharing class URITelematics2ComponentController {
    public static String EquipmentId = NULL;
    public static String InstallationId = NULL;
    public static String packageId = NULL;
    public static String SerialNo = NULL;
    public static Vehicles__c vech =  new Vehicles__c();
    public static String activateSimStatusMsg = '';
    public string contactId{get;set;}
    public static Fleet_Maintenance__c assetMaster = new Fleet_Maintenance__c();
    
    public URITelematics2ComponentController(){
        Cookie secret1 = ApexPages.currentPage().getCookies().get('secretKey');
        String secretKeyCon = String.valueOf(secret1.getValue());
        Cookie secret = new Cookie('secretKey',secretKeyCon,null,28800,false);
        contactId = secret.getValue();
        system.debug('contactId::'+contactId);
        ApexPages.currentPage().setCookies(new Cookie[] {secret});  
    }
    @auraEnabled
    public static string getService(String serviceId){
        Vehicles__c veh = [SELECT ID,Name,Engine_Hours__c ,Scheduling_Coordinator__c,Confirmation_Number__c, Work_Order__c ,Email_Send__c,Unit_Number__c,Customer_ID__c,
                           Device_Type__c,Work_Order__r.Scheduling_Owner__c,CID__c,Communicated__c,Run_Hours__c,GPS_Location__c,DSNSerial__c,Removed_Device_Serial_Number__c,Health_status__c,
                           Approved_by__c,Fleet_Maintenance__c,Fleet_Maintenance__r.Equip_VIN__c,Fleet_Maintenance__r.Category__c,Display_Parts_Used_Component__c,
                           Year_Formula__c ,Model_Formula__c ,Make_Formula__c,Fleet_Maintenance__r.Class__c, Fleet_Maintenance__r.Fuel_Module__c,Rewired__c,
                           Service_Activities__c, Confirmed_Device_LEDs_ON__c, Confirmed_Device_Reporting__c, Symptom_Code__c, Post_Install_Notes__c, Labor_In_Minutes__c,
                           Locating_Equipment_In_Minutes__c, Equipment_Service_Time_In_Minutes__c,Telematics_Device_Activation_In_Minutes__c
                           FROM Vehicles__c where ID = :serviceId];
        return json.serialize(veh);
    }
    @auraEnabled
    public static string saveService(String service){
        try{
            vech = (Vehicles__c)JSON.deserialize(service,Vehicles__c.CLASS);
            
            // vech.device_type__c = 'ZTR';
            vech.work_order__c = Velociti_Settings__c.getOrgDefaults().UR_HEAT_Activation_WO_ID__c;
            system.debug('vech::::'+vech);
            User currentUser = [SELECT Id,Contact_ID__c  FROM User WHERE Id = : UserInfo.getUserId()];
            //Update vech;
            string msg = '';
            if(currentUser.Contact_ID__c != null && currentUser.Contact_ID__c != ''){
                if(!test.isRunningTest()) vech.Technician__c = currentUser.Contact_ID__c;
                assetMaster = new Fleet_Maintenance__c();
                if(vech.Fleet_Maintenance__c != null){
                    assetMaster = [SELECT ID, Controller_Type__c, Fuel_Module__c  FROM Fleet_Maintenance__c WHERE Id = :vech.Fleet_Maintenance__c LIMIT 1];
                }
                msg = activateTelematics(JSON.serialize(vech),currentUser.Contact_ID__c,'',JSON.serialize(assetMaster)/*,''*/);
            }else{
                msg = 'ERROR';
            }
            return msg;
        }catch(Exception e){
            throw new AuraHandledException (e.getMessage());
        }
        
    }
    @auraEnabled
    public static String getVehicle(String vehicleId){
        vehiclesWrapper vehicleWrap = new vehiclesWrapper();
        vehicleWrap.optionList = new List<option>();
        vehicleWrap.controllerTypeList = new List<String>();
        vehicleWrap.showDynamicImages = false;
        Vehicles__c vehicle = new Vehicles__c();
        vehicleWrap.assetMaster = new Fleet_Maintenance__c();
        vehicleWrap.urPartsBomList = new List<UR_Part_BOM__mdt>();
        if(vehicleId != ''){ 
            List<Vehicles__c> vehicleList = [SELECT Id,Name,Work_Order__r.Scheduling_Owner__c,Service_Type__c,Power_On__c,Ext_Harness__c,DSNSerial__c,Removed_Device_Serial_Number__c,Technician__c,Post_Install_Notes__c,Service_Status__c,Parts_Used_List__c,
                                             Date_Shipped__c,Fleet_Maintenance__r.Equip_VIN__c, Run_Hours__c,Velociti_Inventory__c,Engine_Hours__c,Communicated__c,Equip_Category__c,Sales_Order__r.Crash_Kit__c,Unit_Number__c,Customer_ID__c,
                                             Confirmation_Number__c, Device_Type__c, Make_Formula__c,Fleet_Maintenance__r.Kit__c,Fleet_Maintenance__r.Vehicle_Type__c,Display_Parts_Used_Component__c,Sales_Order__c,
                                             Model_Formula__c,Email_Send__c,Legacy_Serial_Number__c,URfailReasonStatus__c , Package__c,Year_Formula__c, Fleet_Maintenance__r.Class__c, Fleet_Maintenance__r.Category__c,
                                             Service_Activities__c, Confirmed_Device_LEDs_ON__c, Confirmed_Device_Reporting__c, Symptom_Code__c, Labor_In_Minutes__c,Sales_Order__r.SCMC__Shipment_Status__c,Parts_Used__c,
                                             Locating_Equipment_In_Minutes__c, Equipment_Service_Time_In_Minutes__c,Telematics_Device_Activation_In_Minutes__c,Rewired__c
                                             FROM Vehicles__c WHERE ID=:vehicleId];
            if(vehicleList != null && vehicleList.size()>0){
                vehicleWrap.vehicle = vehicleList[0];
                if(vehicleList[0].Service_Type__c.toLowerCase().contains('telematics')){
                    vehicleWrap.serviceType = 'Telematics';
                }else{
                    vehicleWrap.serviceType = vehicleList[0].Service_Type__c;
                }
                if(!Test.isRunningTest()){
                    vehicleWrap.vehiclePickListWrapper = getPickListValues(new List<String>{'Power_On__c','Ext_Harness__c','Confirmed_Device_LEDs_ON__c','Confirmed_Device_Reporting__c','Rewired__c','Symptom_Code__c'});
                }
                List<URIphvacSmartControlComponent__mdt> URIsmartControllList = new List<URIphvacSmartControlComponent__mdt>(); 
                if(String.isNotEmpty(vehicleList[0].Fleet_Maintenance__r.Kit__c)){
                    String metaDataLabel = vehicleList[0].Fleet_Maintenance__r.Kit__c;
                    URIsmartControllList = [SELECT Id, Optional_Images__c ,Required_Images__c 
                                            FROM URIphvacSmartControlComponent__mdt 
                                            WHERE Label=:metaDataLabel];
                    if(URIsmartControllList != null && URIsmartControllList.size()>0){
                        vehicleWrap.showDynamicImages = true;
                        vehicleWrap.requiredIds = URIsmartControllList[0].Required_Images__c;
                        vehicleWrap.optionalIds = URIsmartControllList[0].Optional_Images__c;
                    }
                }
                if(String.isNotEmpty(vehicleList[0].Fleet_Maintenance__r.Vehicle_Type__c)){
                    String vechicleType = '%'+vehicleList[0].Fleet_Maintenance__r.Vehicle_Type__c+'%';
                    List<ZTR_Smart_Control_Package__mdt> packageList = [SELECT Id,Label, Package_Name__c,External_Package_ID__c, Asset_Type_s__c  
                                                                        FROM ZTR_Smart_Control_Package__mdt
                                                                        WHERE Asset_Type_s__c Like :vechicleType AND Fuel_Module__c = FALSE];
                    for(ZTR_Smart_Control_Package__mdt zscp:packageList){
                        option op = new option();
                        op.label = zscp.label;
                        op.value = zscp.External_Package_ID__c;
                        op.packageName = zscp.Package_Name__c;
                        vehicleWrap.optionList.add(op);
                    }
                }
                if(vehicleList[0].Fleet_Maintenance__c != null){
                    vehicleWrap.assetMaster = [SELECT ID, Controller_Type__c, Fuel_Module__c   FROM Fleet_Maintenance__c WHERE Id = :vehicleList[0].Fleet_Maintenance__c LIMIT 1];
                    vehicleWrap.fuelModuleList = getFuelList();
                }
            }
            List<Velociti_Custom_Metadata__mdt> mdt = [SELECT Barcode_Scanner_Fields_Service_Object__c FROM Velociti_Custom_Metadata__mdt];
            vehicleWrap.barcodeField = mdt.size() > 0 && String.isNotBlank(mdt[0].Barcode_Scanner_Fields_Service_Object__c) ? mdt[0].Barcode_Scanner_Fields_Service_Object__c : '';
            List<UR_Part_BOM__mdt> URPartsBomList = new List<UR_Part_BOM__mdt>();
            String bomId = '';
            Set<String> uniqueBom = new Set<String>();
            FOR(UR_Part_BOM__mdt URpu:[SELECT Id,DeveloperName,BOM_ID__c,Equip_Category__c,Item_Master_BOM_Name__c FROM UR_Part_BOM__mdt]){
                if(vehicleList[0].Equip_Category__c == URpu.Equip_Category__c){
                    bomId = URpu.BOM_ID__c;
                    //vehicleList[0].Display_Parts_Used_Component__c = true;
                    //break;
                }
                String Key =  URpu.BOM_ID__c +''+ URpu.Item_Master_BOM_Name__c;
                if(!uniqueBom.contains(Key)){
                    URPartsBomList.add(URpu);
                    uniqueBom.add(Key);
                }
            }
            if(bomId != ''){
                vehicleList[0].Parts_Used_List__c = bomId;
                update vehicleList[0];
            }else{
                vehicleWrap.urPartsBomList = URPartsBomList;
            }
            /*vehicleWrap.typesOfPartsUsed = new List<String>{'No Parts Used','Customer Part'};
   
            if(vehicleWrap.vehicle.Sales_Order__c != NULL && vehicleWrap.vehicle.Sales_Order__r.Crash_Kit__c == 'YES'){
                if(vehicleWrap.vehicle.Sales_Order__r.SCMC__Shipment_Status__c == 'Fulfilled' || vehicleWrap.vehicle.Sales_Order__r.SCMC__Shipment_Status__c == 'Partially Shipped') {
                    vehicleWrap.typesOfPartsUsed.add('Velociti Crash Kit');
                }
            }
            vehicleWrap.searchSOLIList = new List<String>();
            for(SCMC__Sales_Order_Line_Item__c soli : [SELECT Id, Name, SCMC__Item_Master__r.Name, SCMC__Item_Description__c,SCMC__Quantity__c, SCMC__Sales_Order__c, SCMC__Sales_Order__r.Crash_Kit__c FROM SCMC__Sales_Order_Line_Item__c WHERE SCMC__Sales_Order__c =:vehicleWrap.Vehicle.Sales_Order__c AND SCMC__Sales_Order__r.Crash_Kit__c = 'Yes']) {
                vehicleWrap.searchSOLIList.add(soli.SCMC__Item_Master__r.Name+' - '+soli.SCMC__Item_Description__c +' - Qty: '+Integer.valueOf(soli.SCMC__Quantity__c)+' - Velociti Crash Kit');
            }*/
        }
        
        return JSON.serialize(vehicleWrap);
    }
    public static List<ZTR_Smart_Control_Package__mdt> getFuelList(){
        List<ZTR_Smart_Control_Package__mdt> packageList = [SELECT Id,Label, Package_Name__c,External_Package_ID__c, Asset_Type_s__c  
                                                            FROM ZTR_Smart_Control_Package__mdt  where Fuel_Module__c = true];
        
        return packageList;
    }
    @auraEnabled
    public static String saveVehicle(String vehicleStr,Boolean isCompleted){
        Vehicles__c vehicle = (Vehicles__c)JSON.deserialize(vehicleStr, Vehicles__c.class);
        
        if(vehicle != null){
            //update vehicle;
            String response = InstallationAppDmlUtil.upsertServices(JSON.serialize(new List<Vehicles__c>{vehicle}));
            InstallationAppDmlUtil.ServiceResponse cls = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response, InstallationAppDmlUtil.ServiceResponse.class);
            if(cls.status != 'Success'){
                throw new DmlException(cls.message);
            }else{
                if(isCompleted){
                    vehicle = [SELECT Id,Name,Work_Order__r.Scheduling_Owner__c,Service_Type__c,Power_On__c,Ext_Harness__c,DSNSerial__c,Removed_Device_Serial_Number__c,Technician__c,Post_Install_Notes__c,Service_Status__c,Parts_Used_List__c,
                               Date_Shipped__c,Fleet_Maintenance__r.Equip_VIN__c, Run_Hours__c,Velociti_Inventory__c,Engine_Hours__c,Communicated__c,Equip_Category__c,Sales_Order__r.Crash_Kit__c,Unit_Number__c,Customer_ID__c,
                               Confirmation_Number__c, Device_Type__c, Make_Formula__c,Fleet_Maintenance__r.Kit__c,Fleet_Maintenance__r.Vehicle_Type__c,Display_Parts_Used_Component__c,Sales_Order__c,
                               Model_Formula__c,Email_Send__c,Legacy_Serial_Number__c,URfailReasonStatus__c , Package__c,Year_Formula__c, Fleet_Maintenance__r.Class__c, Fleet_Maintenance__r.Category__c,
                               Service_Activities__c, Confirmed_Device_LEDs_ON__c, Confirmed_Device_Reporting__c, Symptom_Code__c, Labor_In_Minutes__c,Sales_Order__r.SCMC__Shipment_Status__c,Parts_Used__c
                               FROM Vehicles__c WHERE ID=:vehicle.Id];
                    List<UnitedRentalsTelematicsFailReasonStatus__mdt> cmList = new List<UnitedRentalsTelematicsFailReasonStatus__mdt>();
                    cmList  = [SELECT Id,Ext_Harness__c,Symptom_Code__c  ,Is_Marriage__c ,Velociti_Inventory__c,X404__c,DeveloperName,
                               Legacy_Serial_Number_Not_Null__c ,Package_Update__c ,Service_Status__c 
                               FROM UnitedRentalsTelematicsFailReasonStatus__mdt 
                               WHERE DeveloperName = :vehicle.URfailReasonStatus__c];    
                    if(cmList != null && cmList.size()>0){
                        vehicle.Service_Status__c = cmList[0].Service_Status__c; 
                    }         
                    //update vehicle;
                    response = InstallationAppDmlUtil.upsertServices(JSON.serialize(new List<Vehicles__c>{vehicle}));
                    cls = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response, InstallationAppDmlUtil.ServiceResponse.class);
                    if(cls.status != 'Success'){
                        throw new DmlException(cls.message);
                    }
                }
            }
        }
        return JSON.serialize(vehicle);
    }
    @auraEnabled
    public static String checkSerialNumber(String vehicleStr){
        Vehicles__c vehicle = (Vehicles__c)JSON.deserialize(vehicleStr, Vehicles__c.class);
        List<SCMC__Serial_Number__c> serialNumberList = [SELECT SCMC__Serial_Number__c,Vehicle_Number__c, Status__c FROM SCMC__Serial_Number__c 
                                                         WHERE ( Ownership_Code_Name__c = 'United Rentals' OR Ownership_Code_Name__c = 'UR – PHVAC' ) 
                                                         AND SCMC__Sales_Order_Line_Item__c !='' 
                                                         AND SCMC__Serial_Number__c = :vehicle.DSNSerial__c 
                                                         AND ((Vehicle_Number__c = : vehicle.Id AND Status__c = 'Installed') 
                                                              OR ( Vehicle_Number__c = null AND Status__c = 'In Transit')) 
                                                         LIMIT 1]; 
        if(serialNumberList != null && serialNumberList.size()>0){
            vehicle.Velociti_Inventory__c = 'Yes';
            serialNumberList[0].Vehicle_Number__c = vehicle.Id;
            //update serialNumberList;
            String response = InstallationAppDmlUtil.upsertSerialNumbers(JSON.serialize(serialNumberList));
            InstallationAppDmlUtil.ServiceResponse cls = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response, InstallationAppDmlUtil.ServiceResponse.class);
            if(cls.status != 'Success'){
                throw new DmlException(cls.message);
            }
        }else{
            vehicle.Velociti_Inventory__c = 'No';
        }
        //update vehicle;
        String response = InstallationAppDmlUtil.upsertServices(JSON.serialize(new List<Vehicles__c>{vehicle}));
        InstallationAppDmlUtil.ServiceResponse cls = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response, InstallationAppDmlUtil.ServiceResponse.class);
        if(cls.status != 'Success'){
            throw new DmlException(cls.message);
        }else{
            return json.serialize(vehicle);
        }
    }
    public static List<String> getPickListValuesList(){
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Fleet_Maintenance__c.Fuel_Module__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry pickListVal : ple){
            pickListValuesList.add(pickListVal.getLabel());
        }     
        return pickListValuesList;
    }
    public static List<vehiclePickListWrapper> getPickListValues(List<String> fieldApiList){
        try{
            
            List<vehiclePickListWrapper> newvehiclePickListWrapperList = new List<vehiclePickListWrapper>();
            
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get('Vehicles__c');//From the Object Api name retrieving the SObject
            Sobject Object_name = targetType.newSObject();
            Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
            Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
            Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap();
            
            MetadataService.MetadataPort service = createService();
            MetadataService.RecordType recordType = (MetadataService.RecordType) service.readMetadata(
                'RecordType', new String[] { 'Vehicles__c.'+'Health_United_Rentals'}
            ).getRecords()[0];
            for(String fieldAPI : fieldApiList){
                String dataType = String.valueOf(field_map.get(fieldAPI).getDescribe().getType());
                String fieldLabel = field_map.get(fieldAPI).getDescribe().getLabel();
                vehiclePickListWrapper newWrapper = new vehiclePickListWrapper();
                
                if(dataType == 'PICKLIST' || dataType == 'MULTIPICKLIST'){
                    
                    for ( MetadataService.RecordTypePicklistValue recordTypePickList : recordType.picklistValues ) { 
                        if(fieldAPI == recordTypePickList.picklist ) {
                            
                            List<String> pickListValues = new List<String>();
                            for( MetadataService.PicklistValue pk : recordTypePickList.values ) {
                                
                                pk.fullName = EncodingUtil.urlDecode(pk.fullName,'UTF-8');
                                pickListValues.add(pk.fullName);
                                
                            }
                            newWrapper.fieldLabel = fieldLabel;
                            newWrapper.fieldName = fieldAPI;
                            newWrapper.pickListValues = pickListValues;
                        } 
                    }
                } 
                
                newvehiclePickListWrapperList.add(newWrapper);
            }
            
            return newvehiclePickListWrapperList;
        } catch (Exception e){
            throw new AuraHandledException(e.getMessage());
        }
        
    }
    public static MetadataService.MetadataPort createService() {
        
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = PicklistBasedOnRecordTypeUtil.getAdminSessionId();
        return service;
    }
    
    @auraEnabled
    public static String activateTelematics( String vechString, String contactId ,String zscpPackageId,String assetMasterStr/*,String controllerType*/){   
        vechWrapperForActivateTelematics teleVech = new vechWrapperForActivateTelematics();
        vech = (Vehicles__c )JSON.deserialize(vechString, Vehicles__c.class);
        assetMaster = (Fleet_Maintenance__c )JSON.deserialize(assetMasterStr, Fleet_Maintenance__c.class);
        //assetMaster.Controller_Type__c = controllerType;
        teleVech.activeVech = vech;    
        SerialNo = vech.DSNSerial__c;
        vech.Equip_Category__c = NULL;
        String accessToken = getAccessToken();
        if( vech.Device_Type__c == 'ZTR' ) {     
            JSONParser parser;
            Http h;
            HttpResponse res;
            HttpRequest req;
            h = new Http();
            req = new HttpRequest();
            
            String resModel = '';
            req.setTimeOut(60000);   
            req.setEndpoint('https://api.onei3.com/257/devices/'+SerialNo);
            req.setMethod('GET');       
            req.setHeader('Content-Type','application/x-www-form-urlencoded');
            req.setHeader('Authorization','Bearer '+accessToken);
            req.setHeader('Accept', '*/*');
            
            //if( ! Test.isRunningtest() ) {
            res = h.send(req);
            
            /*} else {
res = new HttpResponse();
res.setStatusCode(200);
res.setBody('{"href":"/257/devices/4662168139","serialNumber":"4662168139","network":{"href":"/257/devices/4662168139/network"},"attrs":{"model":"M6H2"},"tags":[],"createdAt":"2015-12-21T04:03:40Z"}');
} */
            
            if(res.getStatusCode() == 404){
                vech.X404__c = 'Yes'; 
                activateSimStatusMsg = '404 Next Section';
                vech.Last_Modified_By_Sites_User__c = contactId;
                //update vech;
                String response = InstallationAppDmlUtil.upsertServices(JSON.serialize(new List<Vehicles__c>{vech}));
                InstallationAppDmlUtil.ServiceResponse cls = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response, InstallationAppDmlUtil.ServiceResponse.class);
                if(cls.status != 'Success'){
                    throw new DmlException(cls.message);
                }else{
                    //update assetMaster;// Added as separate Method
                    teleVech.activeVech = vech; 
                    teleVech.confirmMsg = activateSimStatusMsg;
                    return json.serialize(teleVech);
                }
                
            } else if( res.getStatusCode() == 200 ) {
                
                parser = JSON.createParser(res.getBody());
                
                while( parser.nextToken() != null ) {
                    
                    if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) ) {
                        
                        String fieldName = parser.getText();
                        
                        if( fieldName == 'model' ) {
                            parser.nextToken();
                            resModel = parser.getText();
                            vech.Equip_Category__c = resModel;
                        }      
                        
                        if(fieldName == 'createdAt') {
                            parser.nextToken();
                            vech.Date_Shipped__c = parser.getDatetimeValue() != NULL ? parser.getDatetimeValue():NULL;
                        }
                    }
                }
            }else if( res.getStatusCode() == 429 ) {
                system.debug('error::::429');
                if(!Test.isRunningTest()){
                    String returnVal = activateTelematics(vechString,contactId ,zscpPackageId,assetMasterStr/*,controllerType*/);
                    return returnVal;
                }else{
                    return null;
                }
                
            }else {    
                vech.Last_Modified_By_Sites_User__c = contactId;
                if(vech.Service_Notes__c != NULL && vech.Service_Notes__c != ''){
                    vech.Service_Notes__c += req.getEndpoint()+':'+res.getStatusCode()+':'+res.getBody()+':'+res.getStatus()+';';
                }else {
                    vech.Service_Notes__c = req.getEndpoint()+':'+res.getStatusCode()+':'+res.getBody()+':'+res.getStatus()+';';
                }
                //update vech;
                String response = InstallationAppDmlUtil.upsertServices(JSON.serialize(new List<Vehicles__c>{vech}));
                InstallationAppDmlUtil.ServiceResponse cls = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response, InstallationAppDmlUtil.ServiceResponse.class);
                if(cls.status != 'Success'){
                    throw new DmlException(cls.message);
                }else{
                    //update assetMaster;// Added as separate Method
                    activateSimStatusMsg = 'GET 257/device: Unknow Error Step 1';
                    teleVech.activeVech = vech; 
                    teleVech.confirmMsg = activateSimStatusMsg;
                    return json.serialize(teleVech);
                }
            } 
            return callOut2(accessToken,res, contactId,teleVech ,zscpPackageId);
        }else if(vech.Device_Type__c == 'TrackUnit' ){
            
            vech.Unit_Number__c = NULL;
            
            if( SerialNo != '' ) {
                
                String urlVal = 'https://api.trackunit.com/public/GetUnit?token='+Velociti_Settings__c.getOrgDefaults().LIT__c+'&format=json&SerialNumber='+SerialNo;
                Http h = new Http();
                JSONParser parser;
                HttpRequest req = new HttpRequest();
                req.setTimeOut(60000);   
                req.setEndpoint(urlVal);
                req.setMethod('GET');
                HttpResponse res;
                if( ! Test.isRunningtest() ) {
                    res = h.send(req);
                } else {
                    res = new HttpResponse();
                    res.setBody('{"Id":"Test123"}');
                    res.setStatusCode(200);
                }
                
                System.debug(':::res:::'+res);
                
                if( res.getStatusCode() == 200 ) { 
                    
                    parser = JSON.createParser(res.getBody());
                    System.debug(':::parser:::'+parser);
                    
                    while ( parser.nextToken() != null ) {
                        
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) {
                            
                            String fieldName = parser.getText();
                            
                            parser.nextToken();
                            
                            if(fieldName == 'id' && vech.Confirmation_Number__c == NULL ) {
                                vech.Confirmation_Number__c = parser.getText();
                                break;
                            }
                        }
                    }
                    
                } else {
                    activateSimStatusMsg = 'Please contact your Project Coordinator with Error Code '+String.valueOf(res.getStatusCode())+'.';
                    vech.Last_Modified_By_Sites_User__c = contactId;
                    //update vech;
                    String response = InstallationAppDmlUtil.upsertServices(JSON.serialize(new List<Vehicles__c>{vech}));
                    InstallationAppDmlUtil.ServiceResponse cls = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response, InstallationAppDmlUtil.ServiceResponse.class);
                    if(cls.status != 'Success'){
                        throw new DmlException(cls.message);
                    }else{
                        teleVech.confirmMsg = activateSimStatusMsg;
                        teleVech.activeVech = vech; 
                        return json.serialize(teleVech);
                        //return null;
                    }
                }
                
                if( vech.Confirmation_Number__c != NULL ) {
                    
                    urlVal = 'https://api.trackunit.com/public/UpdateUnit?token='+Velociti_Settings__c.getOrgDefaults().LIT__c+'&format=json&Id='+EncodingUtil.urlEncode(vech.Confirmation_Number__c, 'UTF-8');
                    String urlValNew = '&input1Name=Hours';
                    urlValNew += '&name='+EncodingUtil.urlEncode(vech.Name, 'UTF-8')+'&referenceNumber='+EncodingUtil.urlEncode(vech.Name, 'UTF-8');
                    if( vech.Engine_Hours__c != NULL ) {
                        urlValNew += '&preRun1='+EncodingUtil.urlEncode(String.valueOf(vech.Engine_Hours__c*3600), 'UTF-8');
                    }
                    String noteValue = vech.Name;
                    if( !String.isBlank(vech.Year_Formula__c) ) noteValue += ', '+vech.Year_Formula__c;
                    if( !String.isBlank(vech.Make_Formula__c) ) noteValue += ', '+vech.Make_Formula__c;
                    if( !String.isBlank(vech.Model_Formula__c) ) noteValue += ', '+vech.Model_Formula__c;
                    if( !String.isBlank(vech.Equip_Vin_Formula__c) ) noteValue += ', '+vech.Equip_Vin_Formula__c;
                    urlValNew += '&note='+ EncodingUtil.urlEncode(noteValue, 'UTF-8');
                    System.debug(':::::::::::: urlValNew :::::::::::::::'+urlValNew);
                    //if( urlValNew != NULL ) urlVal += EncodingUtil.urlEncode(urlValNew, 'UTF-8');
                    urlVal += urlValNew;
                    System.debug(':::::::::::: urlVal - After Encode:::::::::::::::'+urlVal);
                    
                    h = new Http();
                    req = new HttpRequest();
                    req.setTimeOut(60000);   
                    req.setEndpoint(urlVal);
                    req.setMethod('GET');
                    if( ! Test.isRunningtest() ) {
                        res = h.send(req);
                    } else {
                        res = new HttpResponse();
                        res.setStatusCode(200);
                    }            
                    if( res.getStatusCode() == 200 ) {
                        vech.Approved_by__c  = 'Activated Successfully';
                        activateSimStatusMsg = 'Activated Successfully';
                        teleVech.confirmMsg = activateSimStatusMsg;
                        teleVech.activeVech = vech; 
                        //return json.serialize(teleVech);
                    } else {
                        vech.Approved_by__c  = 'Activation Failed';
                        vech.Last_Modified_By_Sites_User__c = contactId;
                        //update vech;
                        String response = InstallationAppDmlUtil.upsertServices(JSON.serialize(new List<Vehicles__c>{vech}));
                        InstallationAppDmlUtil.ServiceResponse cls = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response, InstallationAppDmlUtil.ServiceResponse.class);
                        if(cls.status != 'Success'){
                            throw new DmlException(cls.message);
                        }else{
                            activateSimStatusMsg = 'Activation Failed';
                            teleVech.confirmMsg = activateSimStatusMsg;
                            teleVech.activeVech = vech; 
                            return json.serialize(teleVech);
                        }
                        //return null;
                    }
                    
                    //New Call out added on 15th July 2015 ( Case - 98909 )
                    
                    String urlVal1 = 'https://api.trackunit.com/public/UpdateGroup?token='+Velociti_Settings__c.getOrgDefaults().LIT__c+'&format=json&Id=15264&addUnits='+EncodingUtil.urlEncode(vech.Confirmation_Number__c, 'UTF-8');
                    Http h1 = new Http();
                    HttpRequest req1 = new HttpRequest();
                    req1.setTimeOut(60000);   
                    req1.setEndpoint(urlVal1);
                    req1.setMethod('GET');
                    HttpResponse res1;
                    if( ! Test.isRunningtest() ) {
                        res1 = h.send(req1);
                    } 
                    System.debug(':::::::::: Res1 ::::::::'+res1);
                    
                }
            }
            
            System.debug(':::::::::: Activate SIM - for TrackUnit ::::::::'+ Vech);
            vech.Last_Modified_By_Sites_User__c = contactId;
            //update vech;
            String response1 = InstallationAppDmlUtil.upsertServices(JSON.serialize(new List<Vehicles__c>{vech}));
            InstallationAppDmlUtil.ServiceResponse cls1 = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response1, InstallationAppDmlUtil.ServiceResponse.class);
            if(cls1.status != 'Success'){
                throw new DmlException(cls1.message);
            }else{
                teleVech.activeVech = vech; 
                return json.serialize(teleVech);
            }
        }
        system.debug(':::::accessToken Activate Sim:::::'+accessToken );
        return null;
    }
    PUBLIC static string callOut2(String accessToken,HttpResponse res,string contactId,vechWrapperForActivateTelematics teleVech  ,String zscpPackageId){
        JSONParser parser;
        Http h1 = new Http();
        HttpRequest req1 = new HttpRequest();
        HttpResponse res1 = new HttpResponse();
        req1.setTimeOut(60000);   
        req1.setEndpoint('https://api.onei3.com/769/installations/?device.serialnumber='+SerialNo);
        req1.setMethod('GET');       
        req1.setHeader('Content-Type','application/x-www-form-urlencoded');
        req1.setHeader('Authorization','Bearer '+accessToken);
        req1.setHeader('Accept', '*/*');
        
        
        if( ! Test.isRunningtest() ) {
            res1 = h1.send(req1);
        } else {
            res1 = new HttpResponse();                    
            res1.setBody('[{ "id": "469500422025841082", "equipment" : {"make": "MAGNUM PRO","model": "MLT6SM","year": "2016","vin": "1602959","po": "11402487","serial": "4662202985","class":"4001","category":"320","equipment number":"10501260"}, "packages": {"make": "MAGNUM PRO","model": "MLT6SM","model year": "2016","vin": "1602959","po": "11402487","serial": "4662202985","class":"4001","category":"320","equipment number":"10501260","id": "469500422025841082"}, "href": "/513/equipment/469500422025841082", "name": "10501260", "createdAt" : "2016-06-16T18:53:31Z", "communicatedAt": "2018-04-16T13:20:01Z", "tags": [], "attrs": {"make": "MAGNUM PRO","model": "MLT6SM","model year": "2016","vin": "1602959","po": "11402487","onei3:serial": "4662202985","onei3:model": "M6H2","class":"4001","category":"320","equipment number":"10501260"}, "coords": [ -80.65661,40.88523] }]');
            //String responseBody = '[{"id":"69516673895458533","account":{"id":"222842659"},"href":"/769/installations/69516673895458533","createdAt":"2014-12-12T21:57:13Z","device":{"href":"/257/devices/4662007381","serialNumber":"4662007381","attrs":{"model":"M6H2"},"tags":[],"createdAt":"2014-11-04T23:14:51Z","communicatedAt":"2014-12-17T09:17:01Z"},"equipment":{"id":"69516673845126884","href":"/513/equipment/69516673845126884","name":"10291939","createdAt":"2014-12-12T21:57:13Z","tags":[],"attrs":{"class":"2000","category":"0300","make":"SKYJACK","model":"SJIII3219","model year":"2014","equipment number":"10291939"}},"packages":[{"id":"20813847120052572","name":"M6H - United Rentals: Basic + Utilization"}],"attrs":{}}]';
            //res1.setBody(responseBody);
            res1.setStatusCode(200);
        }           
        
        if( res1.getStatusCode() == 200 ) {  
            
            if( res1.getBody() != '[]'){ 
                
                parser = JSON.createParser(res1.getBody());
                while ( parser.nextToken() != null ) {
                    
                    if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) ) {
                        
                        String fieldName = parser.getText();
                        
                        parser.nextToken();
                        
                        if(fieldName == 'createdAt') {
                            
                            Date dt = parser.getText() != NULL ? Date.valueOf(parser.getText().substring(0, 10)) : NULL;
                            
                            if(dt != NULL &&  dt != System.today() ) {
                                isMarriageMethod();
                            } else if(dt != NULL &&  dt == System.today()){
                                vech.Is_Marriage__c = 'No';   
                            }
                            
                        } else if( fieldName == 'id' && InstallationId  == NULL ) { 
                            vech.Confirmation_Number__c = parser.getText();
                            InstallationId = vech.Confirmation_Number__c;
                            
                        } else if( fieldName == 'equipment' ) {  
                            
                            while ( parser.nextToken() != null ) {
                                
                                if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) ) {
                                    
                                    fieldName = parser.getText();
                                    
                                    parser.nextToken(); 
                                    if( fieldName == 'id') {
                                        vech.CID__c = parser.getText();
                                        EquipmentId = vech.CID__c;
                                        break;
                                    }                 
                                }
                            }
                        } else if( fieldName == 'packages'){
                            
                            while ( parser.nextToken() != null ) {
                                
                                if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) ) {
                                    
                                    fieldName = parser.getText();
                                    
                                    parser.nextToken();  
                                    
                                    if( fieldName == 'id' ) {
                                        packageId = parser.getText();
                                        vech.Package__c = packageId;
                                        break;
                                    }       
                                    
                                }
                            }
                        }
                    }
                }
                
                if(String.isNotBlank(EquipmentId)){
                    JsonParserForEquipmentDetails equipValues = (JsonParserForEquipmentDetails)JSON.deserialize(getEquipValues(accessToken), JsonParserForEquipmentDetails.class);                    
                    if( equipValues != NULL ){                    
                        equipValues.name = vech.Name;
                        for( String attr : (equipValues.attrs).keySet()){
                            if( attr == 'make'){
                                (equipValues.attrs).put(attr, vech.Make_Formula__c);    
                            } else if( attr == 'model'){
                                (equipValues.attrs).put(attr, vech.Model_Formula__c);    
                            } else if( attr == 'vin'){
                                (equipValues.attrs).put(attr, vech.Fleet_Maintenance__r.Equip_VIN__c);    
                            } else if( attr == 'model year'){
                                (equipValues.attrs).put(attr, vech.Year_Formula__c);    
                            } else if( attr == 'class'){
                                (equipValues.attrs).put(attr, vech.Fleet_Maintenance__r.Class__c);    
                            } else if( attr == 'category'){
                                (equipValues.attrs).put(attr, vech.Fleet_Maintenance__r.Category__c);    
                            } else if( attr == 'equipment number'){
                                (equipValues.attrs).put(attr, vech.Name);    
                            } 
                        }
                        
                        if( (equipValues.attrs).get('vin') == null){
                            (equipValues.attrs).put('vin', vech.Fleet_Maintenance__r.Equip_VIN__c);    
                        } 
                        
                        if( (equipValues.attrs).get('class') == null ){
                            (equipValues.attrs).put('class', vech.Fleet_Maintenance__r.Class__c);    
                        }
                        if( (equipValues.attrs).get('category') == null ){
                            (equipValues.attrs).put('category', vech.Fleet_Maintenance__r.Category__c);    
                        } 
                        if( (equipValues.attrs).get('equipment number') == null ){
                            (equipValues.attrs).put('equipment number', vech.Name);    
                        }
                    }
                    return checkStatusCode(accessToken,res,JSON.serialize(equipValues),contactId,teleVech);
                }
            } else {
                teleVech = installationPostMethod(SerialNo, teleVech,zscpPackageId,true); 
                vech.Last_Modified_By_Sites_User__c = contactId;
                //update vech;
                String response = InstallationAppDmlUtil.upsertServices(JSON.serialize(new List<Vehicles__c>{vech}));
                InstallationAppDmlUtil.ServiceResponse cls = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response, InstallationAppDmlUtil.ServiceResponse.class);
                system.debug('status:::'+cls.status);
                if(cls.status != 'Success'){
                    throw new DmlException(cls.message);
                }else{
                    //update assetMaster;// Added as separate Method
                    teleVech.activeVech = vech; 
                    return json.serialize(teleVech);  
                }   
            }
        }else if( res1.getStatusCode() == 429 ) {
            system.debug('error::::429');
            
            if(!Test.isRunningTest()){
                String accessTokenNew = getAccessToken();
                String returnVal = callOut2( accessTokenNew,res,contactId,teleVech ,zscpPackageId);
                return returnVal;
            }else{
                return null;
            }
            
        } else {
            activateSimStatusMsg = 'GET 769/installation Unknow Error Step 2';
            if(vech.Service_Notes__c != NULL && vech.Service_Notes__c != ''){
                vech.Service_Notes__c += req1.getEndpoint()+':'+res1.getStatusCode()+':'+res1.getBody()+':'+res1.getStatus()+';';
            }else {
                vech.Service_Notes__c = req1.getEndpoint()+':'+res1.getStatusCode()+':'+res1.getBody()+':'+res1.getStatus()+';';
            }
            vech.Last_Modified_By_Sites_User__c = contactId;
            //update vech;
            String response = InstallationAppDmlUtil.upsertServices(JSON.serialize(new List<Vehicles__c>{vech}));
            InstallationAppDmlUtil.ServiceResponse cls = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response, InstallationAppDmlUtil.ServiceResponse.class);
            if(cls.status != 'Success'){
                throw new DmlException(cls.message);
            }else{
                //update assetMaster;// Added as separate Method
                teleVech.activeVech = vech; 
                teleVech.confirmMsg = activateSimStatusMsg;
                return json.serialize(teleVech);
            }
        }
        
        vech.Last_Modified_By_Sites_User__c = contactId;
        //update vech;
        String response1 = InstallationAppDmlUtil.upsertServices(JSON.serialize(new List<Vehicles__c>{vech}));
        InstallationAppDmlUtil.ServiceResponse cls1 = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response1, InstallationAppDmlUtil.ServiceResponse.class);
        if(cls1.status != 'Success'){
            throw new DmlException(cls1.message);
        }else{
            //update assetMaster;// Added as separate Method
            teleVech.activeVech = vech; 
            teleVech.confirmMsg = activateSimStatusMsg;
            return json.serialize(teleVech);
       }
        
    }
    public static string checkStatusCode(String accessToken,HttpResponse res,String equipValues,String contactId,vechWrapperForActivateTelematics teleVech){
        Http h3 = new Http();            
        HttpRequest req3 = new HttpRequest();
        req3.setTimeOut(60000);   
        req3.setEndpoint('https://api.onei3.com/513/equipment/'+EquipmentId);  
        req3.setMethod('PUT'); 
        req3.setHeader('Content-Type','application/json');
        req3.setHeader('Authorization','Bearer '+accessToken);
        req3.setHeader('Accept', '*/*');            
        req3.setBody(equipValues);
        JSONParser parser;
        system.debug(accessToken+'cccccccccc'+req3.getBody());
        HttpResponse res3 = new HttpResponse();
        
        //if( ! Test.isRunningtest() ) {
        res3 = h3.send(req3);
        /*}  else {
res3 = new HttpResponse();
res3.setStatusCode(200);
res3.setBody('[{ "id": "469500422025841082", "href": "/513/equipment/469500422025841082", "name": "10501260", "createdAt" : "2016-06-16T18:53:31Z", "communicatedAt": "2018-04-16T13:20:01Z", "tags": [], "attrs": {"make": "MAGNUM PRO","model": "MLT6SM","model year": "2016","vin": "1602959","po": "11402487","onei3:serial": "4662202985","onei3:model": "M6H2","class":"4001","category":"320","equipment number":"10501260"}, "coords": [ -80.65661,40.88523] }]');

}*/
        
        if(res3.getStatusCode() == 200 ){
            if(String.isBlank(vech.Confirmation_Number__c)){
                vech.Confirmation_Number__c = InstallationId;
            }
            parser = JSON.createParser(res.getBody());
            
            while( parser.nextToken() != null ) {
                
                if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) ) {
                    
                    String fieldName = parser.getText();
                    
                    parser.nextToken();
                    
                    if( fieldName == 'id' && String.isBlank(vech.CID__c) ) {
                        EquipmentId = parser.getText();
                        vech.CID__c = EquipmentId;
                    } 
                }
            }
            
            Integer statusCode = setEngineHours( vech.Confirmation_Number__c, accessToken, vech.Engine_Hours__c  );
            if( statusCode == 202 ) { 
                vech.Approved_by__c = 'Activated Successfully';
                vech.Last_Modified_By_Sites_User__c = contactId;
                //update vech;
                String response = InstallationAppDmlUtil.upsertServices(JSON.serialize(new List<Vehicles__c>{vech}));
                InstallationAppDmlUtil.ServiceResponse cls = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response, InstallationAppDmlUtil.ServiceResponse.class);
                if(cls.status != 'Success'){
                    throw new DmlException(cls.message);
                }else{
                    //update assetmaster;// Added as separate Method
                    activateSimStatusMsg = 'Activated Successfully';
                    teleVech.confirmMsg = activateSimStatusMsg;
                    teleVech.activeVech = vech; 
                    return json.serialize(teleVech);
               }
            } else{
                if(statusCode == 400){
                    activateSimStatusMsg = 'unable to sync';
                }else{
                    activateSimStatusMsg = 'POST 769/installation/CID__c/action/sync Unknow Error Step 4';  
                }
                                          
                vech.Last_Modified_By_Sites_User__c = contactId;
                //update vech;
                String response = InstallationAppDmlUtil.upsertServices(JSON.serialize(new List<Vehicles__c>{vech}));
                InstallationAppDmlUtil.ServiceResponse cls = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response, InstallationAppDmlUtil.ServiceResponse.class);
                if(cls.status != 'Success'){
                    throw new DmlException(cls.message);
                }else{
                    //update assetmaster;// Added as separate Method
                    teleVech.confirmMsg = activateSimStatusMsg;
                    teleVech.activeVech = vech; 
                    return json.serialize(teleVech);
                }
            }
            
        }else if( res3.getStatusCode() == 429 ) {
            system.debug('error::::429');
            
            if(!Test.isRunningTest()){
                String accessTokenNew = getAccessToken();
                String returnVal = checkStatusCode( accessTokenNew, res, equipValues, contactId, teleVech);
                return returnVal;
            }else{
                return null;
            }
            
        } else {
            activateSimStatusMsg = 'PUT 513/equipment/CID__c Unknow Error Step 3';
            if(vech.Service_Notes__c != NULL && vech.Service_Notes__c != ''){
                vech.Service_Notes__c += req3.getEndpoint()+':'+res3.getStatusCode()+':'+res3.getBody()+':'+res3.getStatus()+';';
            }else {
                vech.Service_Notes__c = req3.getEndpoint()+':'+res3.getStatusCode()+':'+res3.getBody()+':'+res3.getStatus()+';';
            }
            vech.Last_Modified_By_Sites_User__c = contactId;
            //update vech;
            String response = InstallationAppDmlUtil.upsertServices(JSON.serialize(new List<Vehicles__c>{vech}));
            InstallationAppDmlUtil.ServiceResponse cls = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response, InstallationAppDmlUtil.ServiceResponse.class);
            if(cls.status != 'Success'){
                throw new DmlException(cls.message);
            }else{
                //update assetmaster;// Added as separate Method
                teleVech.activeVech = vech; 
                teleVech.confirmMsg = activateSimStatusMsg;
                return json.serialize(teleVech);
            }
        }
        
    }
    public static string getEquipValues(String accessToken){
        Http h = new Http();            
        HttpRequest req2 = new HttpRequest();
        req2.setTimeOut(60000);   
        req2.setEndpoint('https://api.onei3.com/513/equipment/'+EquipmentId);  
        req2.setMethod('GET'); 
        req2.setHeader('Content-Type','application/json');
        req2.setHeader('Authorization','Bearer '+accessToken);
        req2.setHeader('Accept', '*/*');                   
        HttpResponse res2 = new HttpResponse();
        if( ! Test.isRunningtest() ) {
        res2 = h.send(req2);
        }  else {
            res2 = new HttpResponse();
            res2.setStatusCode(200);
            res2.setBody('{ "id": "469500422025841082", "href": "/513/equipment/469500422025841082", "name": "10501260", "createdAt" : "2016-06-16T18:53:31Z", "communicatedAt": "2018-04-16T13:20:01Z", "tags": [], "attrs": {"make": "MAGNUM PRO","model": "MLT6SM","model year": "2016","vin": "1602959","po": "11402487","onei3:serial": "4662202985","onei3:model": "M6H2","class":"4001","category":"320","equipment number":"10501260"}, "coords": [ -80.65661,40.88523] }');
        }
        return res2.getBody();
        
    }
    public static vechWrapperForActivateTelematics installationPostMethod(String SerialNo, vechWrapperForActivateTelematics teleVech,String zscpPackageId,boolean firstCall){
        
        String resModel = vech.Equip_Category__c;
        Http h = new Http();
        JSONParser parser;
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        req.setTimeOut(60000);   
        req.setEndpoint('https://api.onei3.com/769/installations');
        req.setMethod('POST');       
        req.setHeader('Content-Type','application/json');
        req.setHeader('Authorization','Bearer '+getAccessToken());
        req.setHeader('Accept', '*/*'); 
        
        UR_ZTR_Location_Setting__c locationSetting;
        
        if( String.isNotBlank(resModel) ){
            
            locationSetting = new UR_ZTR_Location_Setting__c();
            
            if( resModel.contains('M6') ){
                locationSetting = UR_ZTR_Location_Setting__c.getInstance('M6');
            } else if( resModel.contains('M8') ){
                locationSetting = UR_ZTR_Location_Setting__c.getInstance('M8');
            }  else if( resModel.contains('M7') ){
                locationSetting = UR_ZTR_Location_Setting__c.getInstance('M7');
            }
            if( locationSetting != NULL ) {
                packageId = locationSetting.Location_Id__c;            
            }
        }
        
        String s = '';
        if(vech.Service_Type__c == 'Smart Control'){
            packageId = zscpPackageId;
        }
        if(firstCall && vech.Customer_ID__c != null && vech.Service_Type__c != null && vech.Service_Type__c.tolowerCase().contains('3g replacement')){
            packageId = vech.Customer_ID__c;
        }
        if( String.isNotBlank(packageId) || Test.isRunningTest() ){
            if(vech.Service_Type__c == 'Smart Control'){
                List<ZTR_Smart_Control_Package__mdt> fuelModuleIdList = new List<ZTR_Smart_Control_Package__mdt>();
                string fuelModuleId;
                fuelModuleIdList = [SELECT External_Package_ID__c FROM ZTR_Smart_Control_Package__mdt WHERE Fuel_Module__c = true AND Package_Name__c = :assetmaster.Fuel_Module__c LIMIT 1 ]; 
                if( fuelModuleIdList != NULL && fuelModuleIdList.size() > 0 ) fuelModuleId = fuelModuleIdList[0].External_Package_ID__c;               
                
                if(fuelModuleId != null && fuelModuleId != '' && fuelModuleId != 'None'){
                    s = '{ "device": { "serialNumber": "'+ (String.isBlank(SerialNo)?null:SerialNo.replaceAll('"','\\\\"')) +'" },"equipment": { "name": "' + (String.isBlank(vech.Name)?null:vech.Name.replaceAll('"','\\\\"')) +'", "attrs": { "class": "'+ (String.isBlank(vech.Fleet_Maintenance__r.Class__c)?null:vech.Fleet_Maintenance__r.Class__c.replaceAll('"','\\\\"')) +'", "category": "'+(String.isBlank(vech.Fleet_Maintenance__r.Category__c)?null:vech.Fleet_Maintenance__r.Category__c.replaceAll('"','\\\\"')) +'", "make": "'+ (String.isBlank(vech.Make_Formula__c)?null:vech.Make_Formula__c.replaceAll('"','\\\\"')) +'", "Smart Control Enabled": "Y", "model": "'+ (String.isBlank(vech.Model_Formula__c)?null:vech.Model_Formula__c.replaceAll('"','\\\\"')) +'", "vin": "'+ (String.isBlank(vech.Fleet_Maintenance__r.Equip_VIN__c)?null:vech.Fleet_Maintenance__r.Equip_VIN__c.replaceAll('"','\\\\"')) +'", "model year":"'+(String.isBlank(vech.Year_Formula__c)?null:vech.Year_Formula__c.replaceAll('"','\\\\"'))+'", "equipment number": "'+ (String.isBlank(vech.Name)?null:vech.Name.replaceAll('"','\\\\"')) +'" } }, "packages": [ { "id": "'+packageId+'"},{"id":"'+fuelModuleId+'" } ] }';
                }else{
                    s = '{ "device": { "serialNumber": "'+ (String.isBlank(SerialNo)?null:SerialNo.replaceAll('"','\\\\"')) +'" },"equipment": { "name": "' + (String.isBlank(vech.Name)?null:vech.Name.replaceAll('"','\\\\"')) +'", "attrs": { "class": "'+ (String.isBlank(vech.Fleet_Maintenance__r.Class__c)?null:vech.Fleet_Maintenance__r.Class__c.replaceAll('"','\\\\"')) +'", "category": "'+(String.isBlank(vech.Fleet_Maintenance__r.Category__c)?null:vech.Fleet_Maintenance__r.Category__c.replaceAll('"','\\\\"')) +'", "make": "'+ (String.isBlank(vech.Make_Formula__c)?null:vech.Make_Formula__c.replaceAll('"','\\\\"')) +'", "Smart Control Enabled": "Y", "model": "'+ (String.isBlank(vech.Model_Formula__c)?null:vech.Model_Formula__c.replaceAll('"','\\\\"')) +'", "vin": "'+ (String.isBlank(vech.Fleet_Maintenance__r.Equip_VIN__c)?null:vech.Fleet_Maintenance__r.Equip_VIN__c.replaceAll('"','\\\\"')) +'", "model year":"'+(String.isBlank(vech.Year_Formula__c)?null:vech.Year_Formula__c.replaceAll('"','\\\\"'))+'", "equipment number": "'+ (String.isBlank(vech.Name)?null:vech.Name.replaceAll('"','\\\\"')) +'" } }, "packages": [ { "id": "'+packageId+'" } ] }';
                }
            }else if(vech.Service_Type__c != null && vech.Service_Type__c.tolowerCase().contains('3g replacement') && vech.Unit_Number__c != null && firstCall){
                String fuelModuleId = vech.Unit_Number__c;
                s = '{ "device": { "serialNumber": "'+ (String.isBlank(SerialNo)?null:SerialNo.replaceAll('"','\\\\"')) +'" },"equipment": { "name": "' + (String.isBlank(vech.Name)?null:vech.Name.replaceAll('"','\\\\"')) +'", "attrs": { "class": "'+ (String.isBlank(vech.Fleet_Maintenance__r.Class__c)?null:vech.Fleet_Maintenance__r.Class__c.replaceAll('"','\\\\"')) +'", "category": "'+(String.isBlank(vech.Fleet_Maintenance__r.Category__c)?null:vech.Fleet_Maintenance__r.Category__c.replaceAll('"','\\\\"')) +'", "make": "'+ (String.isBlank(vech.Make_Formula__c)?null:vech.Make_Formula__c.replaceAll('"','\\\\"')) +'", "Smart Control Enabled": "Y", "model": "'+ (String.isBlank(vech.Model_Formula__c)?null:vech.Model_Formula__c.replaceAll('"','\\\\"')) +'", "vin": "'+ (String.isBlank(vech.Fleet_Maintenance__r.Equip_VIN__c)?null:vech.Fleet_Maintenance__r.Equip_VIN__c.replaceAll('"','\\\\"')) +'", "model year":"'+(String.isBlank(vech.Year_Formula__c)?null:vech.Year_Formula__c.replaceAll('"','\\\\"'))+'", "equipment number": "'+ (String.isBlank(vech.Name)?null:vech.Name.replaceAll('"','\\\\"')) +'" } }, "packages": [ { "id": "'+packageId+'"},{"id":"'+fuelModuleId+'" } ] }';
            }else{
                s = '{ "device": { "serialNumber": "'+ (String.isBlank(SerialNo)?null:SerialNo.replaceAll('"','\\\\"')) +'" },"equipment": { "name": "' + (String.isBlank(vech.Name)?null:vech.Name.replaceAll('"','\\\\"')) +'", "attrs": { "class": "'+ (String.isBlank(vech.Fleet_Maintenance__r.Class__c)?null:vech.Fleet_Maintenance__r.Class__c.replaceAll('"','\\\\"')) +'", "category": "'+(String.isBlank(vech.Fleet_Maintenance__r.Category__c)?null:vech.Fleet_Maintenance__r.Category__c.replaceAll('"','\\\\"')) +'", "make": "'+ (String.isBlank(vech.Make_Formula__c)?null:vech.Make_Formula__c.replaceAll('"','\\\\"')) +'","model": "'+ (String.isBlank(vech.Model_Formula__c)?null:vech.Model_Formula__c.replaceAll('"','\\\\"')) +'", "vin": "'+ (String.isBlank(vech.Fleet_Maintenance__r.Equip_VIN__c)?null:vech.Fleet_Maintenance__r.Equip_VIN__c.replaceAll('"','\\\\"')) +'", "model year":"'+(String.isBlank(vech.Year_Formula__c)?null:vech.Year_Formula__c.replaceAll('"','\\\\"'))+'", "equipment number": "'+ (String.isBlank(vech.Name)?null:vech.Name.replaceAll('"','\\\\"')) +'" } }, "packages": [ { "id": "'+packageId+'" } ] }';
                
            }
            
        }
        system.debug(getAccessToken()+'Error'+req.getBody());
        System.debug('::::s For 769:::;'+s);
        
        req.setBody(s);            
        
        res = h.send(req);
        
        
        if( res.getStatusCode() == 409 ){  
            teleVech = getInstallationIdByName( vech.Name, getAccessToken(), teleVech,zscpPackageId); 
            return teleVech;
        }else if( res.getStatusCode() == 202 ) {
            
            parser = JSON.createParser(res.getBody());
            while( parser.nextToken() != null ) {
                
                if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) ) {
                    
                    String fieldName = parser.getText();
                    
                    parser.nextToken();                    
                    
                    if(fieldName == 'createdAt') {
                        
                        Date dt = parser.getText() != NULL ? Date.valueOf(parser.getText().substring(0, 10)) : NULL;
                        
                        if(dt != NULL &&  dt != System.today() ) {
                            isMarriageMethod();
                        } else if(dt != NULL &&  dt == System.today()){
                            vech.Is_Marriage__c = 'No';   
                        }
                        
                    } else if( fieldName == 'id' && String.isBlank(vech.Confirmation_Number__c) ) {
                        
                        vech.Confirmation_Number__c = parser.getText();
                        InstallationId = vech.Confirmation_Number__c;
                        
                    }
                    
                    if( fieldName == 'equipment' ) {
                        
                        while ( parser.nextToken() != null ) {
                            
                            if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) ) {
                                
                                String fieldName1 = parser.getText();
                                
                                parser.nextToken();                               
                                
                                if( fieldName1 == 'id' ) {
                                    EquipmentId = parser.getText();
                                    vech.CID__c = EquipmentId;
                                    break;
                                }
                            }
                        }
                    } else if( fieldName == 'packages'){
                        
                        while ( parser.nextToken() != null ) {
                            
                            if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) ) {
                                
                                fieldName = parser.getText();
                                
                                parser.nextToken();  
                                
                                if( fieldName == 'id' ) {
                                    packageId = parser.getText();
                                    vech.Package__c = packageId;
                                }
                                
                                if( packageId != NULL ){
                                    break;
                                }                  
                            }
                        }
                    }
                }
            }
            
            Integer statusCode = setEngineHours( vech.Confirmation_Number__c, getAccessToken(), vech.Engine_Hours__c  );
            if( statusCode == 202 ) { 
                vech.Approved_by__c = 'Activated Successfully';
                // Need to display "Test Device" button
                //update vech;
                String response = InstallationAppDmlUtil.upsertServices(JSON.serialize(new List<Vehicles__c>{vech}));
                InstallationAppDmlUtil.ServiceResponse cls = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response, InstallationAppDmlUtil.ServiceResponse.class);
                if(cls.status != 'Success'){
                    throw new DmlException(cls.message);
                }else{
                    //update assetmaster;// Added as separate Method
                    activateSimStatusMsg = 'Activated Successfully';
                    teleVech.confirmMsg = activateSimStatusMsg;
                    teleVech.activeVech = vech; 
                    return teleVech;
                }
            } else {
                activateSimStatusMsg = 'POST 769/installation/CID__c/action/sync Unknow Error Step 4';
                //update vech;
                String response = InstallationAppDmlUtil.upsertServices(JSON.serialize(new List<Vehicles__c>{vech}));
                InstallationAppDmlUtil.ServiceResponse cls = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response, InstallationAppDmlUtil.ServiceResponse.class);
                if(cls.status != 'Success'){
                    throw new DmlException(cls.message);
                }else{
                    //update assetmaster;// Added as separate Method
                    teleVech.confirmMsg = activateSimStatusMsg;
                    teleVech.activeVech = vech; 
                    return teleVech;
                }
            }
        }else if( res.getStatusCode() == 429 ) {
            system.debug('error::::429');
            
            if(!Test.isRunningTest()){
                vechWrapperForActivateTelematics returnVal = installationPostMethod( SerialNo, teleVech,zscpPackageId,true);
                return returnVal;
            }else{
                return null;
            }
            
        } else {
            if(res.getStatusCode() == 400 && res.getBody().contains('Invalid package Id') && firstCall){
                teleVech = installationPostMethod( SerialNo,  teleVech, zscpPackageId,false);
                return teleVech;
            }else{
                activateSimStatusMsg = 'POST 769/installation Unknow Error Step 5';
                if(vech.Service_Notes__c != NULL && vech.Service_Notes__c != ''){
                    vech.Service_Notes__c += req.getEndpoint()+':'+res.getStatusCode()+':'+res.getBody()+':'+res.getStatus()+';';
                }else {
                    vech.Service_Notes__c = req.getEndpoint()+':'+res.getStatusCode()+':'+res.getBody()+':'+res.getStatus()+';';
                }
                //update vech;
                String response = InstallationAppDmlUtil.upsertServices(JSON.serialize(new List<Vehicles__c>{vech}));
                InstallationAppDmlUtil.ServiceResponse cls = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response, InstallationAppDmlUtil.ServiceResponse.class);
                if(cls.status != 'Success'){
                    throw new DmlException(cls.message);
                }else{
                    //update assetmaster;// Added as separate Method
                    teleVech.confirmMsg = activateSimStatusMsg;
                    teleVech.activeVech = vech; 
                    return teleVech;
                }   
            }
            
        }  
    }
    public static vechWrapperForActivateTelematics getInstallationIdByName( String vechName, String accessToken, vechWrapperForActivateTelematics teleVech,String zscpPackageId ) {
        vechName = vechName.replaceAll(' ', '%20');
        String InstallationIdNew = '';
        String serialNumber = '';
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        HttpResponse res;
        JSONParser parser;
        req.setTimeOut(60000);   
        req.setEndpoint('https://api.onei3.com/513/equipment?name='+vechName);
        req.setMethod('GET');       
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setHeader('Authorization','Bearer '+accessToken);
        req.setHeader('Accept', '*/*');
        
        
        //if( ! Test.isRunningtest() ) {
        res = h.send(req);
        /*} else {
res = new HttpResponse();
res.setStatusCode(200);
res.setBody('[{ "id": "469500422025841082", "href": "/513/equipment/469500422025841082", "name": "10501260", "createdAt" : "2016-06-16T18:53:31Z", "communicatedAt": "2018-04-16T13:20:01Z", "tags": [], "attrs": {"make": "MAGNUM PRO","model": "MLT6SM","model year": "2016","vin": "1602959","po": "11402487","onei3:serial": "4662202985","onei3:model": "M6H2","class":"4001","category":"320","equipment number":"10501260"}, "coords": [ -80.65661,40.88523] }]');
}*/
        
        if( res.getStatusCode() == 200 ) {            
            List<JsonParserForEquipmentDetails> equipValuesList = (List<JsonParserForEquipmentDetails>)JSON.deserialize(res.getBody(), List<JsonParserForEquipmentDetails>.class); 
            JsonParserForEquipmentDetails equipValues = equipValuesList[0];
            if( equipValues != NULL ){       
                String equipmentId = equipValues.id;             
                equipValues.name = vech.Name;
                for( String attr : (equipValues.attrs).keySet()){
                    if( attr == 'onei3:serial'){
                        serialNumber = (equipValues.attrs).get(attr);   
                        break; 
                    }                     
                }
                
                if(String.isBlank(serialNumber)){
                    
                    List<Equipment__c> equipList =  new List<Equipment__c>();
                    equipList = [ Select Id, Name, Installed_SN__c FROM Equipment__c Where Name =: vech.Name And Installed_SN__c != NULL And Record_Type_Name__c = 'United_Rentals' ];
                    
                    if( equipList != NULL && equipList.size() > 0 ){
                        serialNumber = equipList[0].Installed_SN__c;
                    }
                }
                
                
                if(String.isNotBlank(serialNumber)){
                    
                    Http h1 = new Http();
                    HttpRequest req1 = new HttpRequest();
                    HttpResponse res1 = new HttpResponse();
                    req1.setTimeOut(60000);   
                    req1.setEndpoint('https://api.onei3.com/769/installations/?device.serialnumber='+serialNumber);
                    req1.setMethod('GET');       
                    req1.setHeader('Content-Type','application/x-www-form-urlencoded');
                    req1.setHeader('Authorization','Bearer '+accessToken);
                    req1.setHeader('Accept', '*/*');
                    
                    
                    if( ! Test.isRunningtest() ) {
                        res1 = h1.send(req1);
                    } else {
                        res1 = new HttpResponse();                    
                        String json = '[{"id":"69516673895458533","account":{"id":"222842659"},"href":"/769/installations/69516673895458533","createdAt":"2014-12-12T21:57:13Z","device":{"href":"/257/devices/4662007381","serialNumber":"4662007381","attrs":{"model":"M6H2"},"tags":[],"createdAt":"2014-11-04T23:14:51Z","communicatedAt":"2014-12-17T09:17:01Z"},"equipment":{"id":"69516673845126884","href":"/513/equipment/69516673845126884","name":"10291939","createdAt":"2014-12-12T21:57:13Z","tags":[],"attrs":{"class":"2000","category":"0300","make":"SKYJACK","model":"SJIII3219","model year":"2014","equipment number":"10291939"}},"packages":[{"id":"20813847120052572","name":"M6H - United Rentals: Basic + Utilization"}],"attrs":{}}]';
                        res1.setBody(json);
                        res1.setStatusCode(200);
                    }          
                    
                    if( res1.getStatusCode() == 200 ) { 
                        
                        if( res1.getBody() != NULL && res1.getBody() != ''){
                            
                            parser = JSON.createParser(res1.getBody());
                            while ( parser.nextToken() != null ) {
                                
                                if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) ) {
                                    String fieldName = parser.getText();
                                    
                                    parser.nextToken();
                                    
                                    if( fieldName == 'id') {                                           
                                        InstallationIdNew  = parser.getText();
                                        break;
                                        
                                    }
                                }
                            }
                            if(String.isNotBlank(InstallationIdNew)){
                                Integer statusCode = deleteZTREquipCallout(InstallationIdNew, getAccessToken());
                                if( statusCode == 202 ){
                                    vech.Confirmation_Number__c = NULL;
                                    vech.CID__c = NULL;
                                    EquipmentId = NULL;
                                    InstallationId = NULL;
                                    //vech.Communicated__c = NULL;
                                    teleVech = installationPostMethod(SerialNo, teleVech,zscpPackageId,true); 
                                    teleVech.activeVech = vech; 
                                    return teleVech; 
                                } else{
                                    //update vech;
                                    String response = InstallationAppDmlUtil.upsertServices(JSON.serialize(new List<Vehicles__c>{vech}));
                                    InstallationAppDmlUtil.ServiceResponse cls = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response, InstallationAppDmlUtil.ServiceResponse.class);
                                    if(cls.status != 'Success'){
                                        throw new DmlException(cls.message);
                                    }else{
                                        //update assetmaster;// Added as separate Method
                                        activateSimStatusMsg = 'DELETE 769/Installation Unknow Error Step 8';
                                        teleVech.confirmMsg = activateSimStatusMsg;
                                        teleVech.activeVech = vech; 
                                        return teleVech;
                                    }
                                }
                            }
                            
                            
                        }
                    } else {
                        activateSimStatusMsg = 'GET 769/Installation?device.serialnumber Unknow Error Step 7';
                        if(vech.Service_Notes__c != NULL && vech.Service_Notes__c != ''){
                            vech.Service_Notes__c += req1.getEndpoint()+':'+res1.getStatusCode()+':'+res1.getBody()+':'+res1.getStatus()+';';
                        }else {
                            vech.Service_Notes__c = req1.getEndpoint()+':'+res1.getStatusCode()+':'+res1.getBody()+':'+res1.getStatus()+';';
                        }
                        //update vech;
                        String response = InstallationAppDmlUtil.upsertServices(JSON.serialize(new List<Vehicles__c>{vech}));
                        InstallationAppDmlUtil.ServiceResponse cls = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response, InstallationAppDmlUtil.ServiceResponse.class);
                        if(cls.status != 'Success'){
                            throw new DmlException(cls.message);
                        }else{
                            //update assetmaster;// Added as separate Method
                            teleVech.activeVech = vech; 
                            teleVech.confirmMsg = activateSimStatusMsg;
                            return teleVech;
                        }
                    }
                }
            }
            
        }else if( res.getStatusCode() == 429 ) {
            system.debug('error::::429');
            if(!Test.isRunningTest()){
                accessToken = getAccessToken ();
                vechWrapperForActivateTelematics  returnVal = getInstallationIdByName( vechName, accessToken, teleVech ,zscpPackageId);
                return returnVal;
            }else{
                return null;
            }
            
        } else {
            if(vech.Service_Notes__c != NULL && vech.Service_Notes__c != ''){
                vech.Service_Notes__c += req.getEndpoint()+':'+res.getStatusCode()+':'+res.getBody()+':'+res.getStatus()+';';
            }else {
                vech.Service_Notes__c = req.getEndpoint()+':'+res.getStatusCode()+':'+res.getBody()+':'+res.getStatus()+';';
            }
            //update vech;
            String response = InstallationAppDmlUtil.upsertServices(JSON.serialize(new List<Vehicles__c>{vech}));
            InstallationAppDmlUtil.ServiceResponse cls = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response, InstallationAppDmlUtil.ServiceResponse.class);
            if(cls.status != 'Success'){
                throw new DmlException(cls.message);
            }else{
                //update assetmaster;// Added as separate Method
                activateSimStatusMsg = 'GET 513/equipment?name=vech.Name Unknow Error Step 6';
                teleVech.confirmMsg = activateSimStatusMsg;
                teleVech.activeVech = vech; 
                return teleVech;
            }
        } 
        
        return teleVech;      
    }
    public Static Integer deleteZTREquipCallout( String InstallationId, String accesstoken ){
        
        Http h = new Http();
        
        HttpRequest req = new HttpRequest();
        req.setTimeOut(60000);   
        req.setEndpoint('https://api.onei3.com/769/installations/'+InstallationId);
        req.setMethod('DELETE');       
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setHeader('Authorization','Bearer '+accessToken);
        req.setHeader('Accept', '*/*');
        
        
        HttpResponse res = new HttpResponse();
        
        //if( ! Test.isRunningtest() ) {
        res = h.send(req);
        /*}  else {
res = new HttpResponse();
res.setStatusCode(202);
}*/
        if( res.getStatusCode() == 429 ) {
            if(!Test.isRunningTest()){
                accessToken = getAccessToken ();
                Integer  code = deleteZTREquipCallout(InstallationId, accessToken );
                return code;
            }else{
                return null;
            }
        }else if( res.getStatusCode() != 202 ){
            if(vech.Service_Notes__c != NULL && vech.Service_Notes__c != ''){
                vech.Service_Notes__c += req.getEndpoint()+':'+res.getStatusCode()+':'+res.getBody()+':'+res.getStatus()+';';
            }else {
                vech.Service_Notes__c = req.getEndpoint()+':'+res.getStatusCode()+':'+res.getBody()+':'+res.getStatus()+';';
            }
        }
        return res.getStatusCode();
    }
    public static Integer setEngineHours( String InstallationId, String accessToken, Decimal enginHours ) {
        JSONParser parser;        
        Http h;
        HttpResponse res;
        HttpRequest req;        
        
        if( String.isNotBlank(InstallationId)) {
            
            h = new Http();
            req = new HttpRequest();
            req.setTimeOut(60000);   
            req.setEndpoint('https://api.onei3.com/769/installations/'+InstallationId+'/actions/sync');
            req.setMethod('POST');       
            req.setHeader('Content-Type','application/json');
            req.setHeader('Authorization','Bearer '+accessToken);
            req.setHeader('Accept', '*/*');
            String s2 = '[{"baseTag":"run_time","value":'+enginHours+',"uom":"hours"}]';
            
            
            req.setBody(s2);
            
            //if( ! Test.isRunningtest() ) {
            res = h.send(req);
            /*} else {
res = new HttpResponse();
res.setStatusCode(202);
}*/
            if( res.getStatusCode() == 429 ) {
                if( ! Test.isRunningtest() ){
                    accessToken = getAccessToken ();
                    Integer code = setEngineHours( InstallationId, accessToken, enginHours );
                    return code;
                } else{
                    return null;
                }
            }else if( res.getStatusCode() != 202 ){
                if(vech.Service_Notes__c != NULL && vech.Service_Notes__c != ''){
                    vech.Service_Notes__c += req.getEndpoint()+':'+res.getStatusCode()+':'+res.getBody()+':'+res.getStatus()+';';
                }else {
                    vech.Service_Notes__c = req.getEndpoint()+':'+res.getStatusCode()+':'+res.getBody()+':'+res.getStatus()+';';
                }
            }
            
            return res.getStatusCode();
        }
        
        return null;
        
    }
    public static void isMarriageMethod(){
        if(vech != null && vech.Fleet_Maintenance__c != null ){
            List<Device_Master__c> deviceMasterList = new List<Device_Master__c>();
            deviceMasterList = [SELECT Id,Asset_Number__c,Name from Device_Master__c 
                                WHERE Asset_Number__c = :vech.Fleet_Maintenance__c AND Name = :vech.DSNSerial__c];
            vech.Is_Marriage__c = deviceMasterList.size() > 0 ? 'No' : 'Yes';
        }
    }
    public static String getAccessToken(){
        
        String accessToken;
        
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setTimeOut(60000);   
        req.setEndpoint('https://auth.onei3.com/core/connect/token');
        req.setMethod('POST'); 
        String encodedVal = '';
        if( Velociti_Settings__c.getOrgDefaults().UR_ZTR_API_Client_Id_Secret_Key__c != NULL ) encodedVal  = EncodingUtil.base64Encode(Blob.valueOf(Velociti_Settings__c.getOrgDefaults().UR_ZTR_API_Client_Id_Secret_Key__c));
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setHeader('Authorization','Basic '+encodedVal);
        req.setHeader('Accept', '*/*');
        req.setBody('grant_type=client_credentials&scope=any');
        HttpResponse res;
        
        
        //if( ! Test.isRunningtest() ) {
        res = h.send(req);
        /*} else {
res = new HttpResponse();
res.setBody('{"access_token": "qwertyui789456"}');
}*/
        JSONParser parser = JSON.createParser(res.getBody());
        
        while ( parser.nextToken() != null ) {
            
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) {
                
                String fieldName = parser.getText();
                
                parser.nextToken();
                
                if(fieldName == 'access_token') {
                    accessToken = parser.getText();
                }
            }
        }
        return accessToken;
    }
    @auraEnabled    
    Public static String testDevice(String vechString, String contactId ){
        vechWrapperForActivateTelematics teleVech = new vechWrapperForActivateTelematics();
        vech = (Vehicles__c )JSON.deserialize(vechString, Vehicles__c.class); 
        if( vech.Device_Type__c == 'ZTR' ) {
            
            String accessToken = getAccessToken();
            
            teleVech.activeVech = vech;
            String StatusMsg = NULL;
            vech.Communicated__c = NULL;
            vech.Run_Hours__c = NULL;
            
            if( vech.Confirmation_Number__c != NULL ){
                teleVech.confirmMsg = isDeviceCommunicating( accessToken, vech.Confirmation_Number__c);
            }
            
            if( vech.CID__c != NULL && teleVech.confirmMsg == NULL ){
                teleVech.confirmMsg = testSync( accessToken, vech.CID__c);
            }
            
            
            if( (vech.Communicated__c != NULL && vech.Communicated__c.date() == System.Today()) || Test.isRunningTest() ){
                if(vech.Run_Hours__c != null && vech.Run_Hours__c != ''){
                    // Need to dispaly alert with "The Device is functioning as expected
                    // Go to the Next Section
                    teleVech.confirmMsg = 'Run Hour True'; 
                    vech.Last_Modified_By_Sites_User__c = contactId; 
                    //update vech;
                    String response = InstallationAppDmlUtil.upsertServices(JSON.serialize(new List<Vehicles__c>{vech}));
                    InstallationAppDmlUtil.ServiceResponse cls = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response, InstallationAppDmlUtil.ServiceResponse.class);
                    if(cls.status != 'Success'){
                        throw new DmlException(cls.message);
                    }else{
                        teleVech.activeVech = vech; 
                        return json.serialize(teleVech);
                    }
                } else {
                    if(vech.Equip_Category__c.startsWithIgnoreCase('m6')){
                        // Need to work on Page Level
                        teleVech.confirmMsg = 'Equip Categaory True'; 
                        vech.Last_Modified_By_Sites_User__c = contactId; 
                        //update vech;
                        String response = InstallationAppDmlUtil.upsertServices(JSON.serialize(new List<Vehicles__c>{vech}));
                        InstallationAppDmlUtil.ServiceResponse cls = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response, InstallationAppDmlUtil.ServiceResponse.class);
                        if(cls.status != 'Success'){
                            throw new DmlException(cls.message);
                        }else{
                            teleVech.activeVech = vech; 
                            return json.serialize(teleVech);
                        }
                    } else{
                        // Need to work on Page Level
                        teleVech.confirmMsg = 'Equip Categaory False';  
                        vech.Last_Modified_By_Sites_User__c = contactId;
                        //update vech;
                        String response = InstallationAppDmlUtil.upsertServices(JSON.serialize(new List<Vehicles__c>{vech}));
                        InstallationAppDmlUtil.ServiceResponse cls = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response, InstallationAppDmlUtil.ServiceResponse.class);
                        if(cls.status != 'Success'){
                            throw new DmlException(cls.message);
                        }else{
                            teleVech.activeVech = vech; 
                            return json.serialize(teleVech);
                        }
                    }
                }
            } else {
                // Need to handle in Page Level
                teleVech.confirmMsg = 'Communicated False';  
                vech.Last_Modified_By_Sites_User__c = contactId;
                //update vech;
                String response = InstallationAppDmlUtil.upsertServices(JSON.serialize(new List<Vehicles__c>{vech}));
                InstallationAppDmlUtil.ServiceResponse cls = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response, InstallationAppDmlUtil.ServiceResponse.class);
                if(cls.status != 'Success'){
                    throw new DmlException(cls.message);
                }else{
                    teleVech.activeVech = vech; 
                    return json.serialize(teleVech);
                }
            }
        }else if( vech.Device_Type__c == 'TrackUnit' ) {
            
            String SerialNo = vech.DSNSerial__c;
            
            /*if( legacySNStatus ) {            
if( (vech.Wiring_Harness_Test__c == '3 Lights' || vech.Wiring_Harness_Test__c == '2 Lights')  && vech.Legacy_Serial_Number__c != Null ){
SerialNo = vech.Legacy_Serial_Number__c;
}
} else {
SerialNo = vech.DSNSerial__c;
}*/
            
            if( String.isNotBlank(SerialNo)) {
                
                String urlVal = 'https://api.trackunit.com/public/GetUnit?token='+Velociti_Settings__c.getOrgDefaults().LIT__c+'&format=json&SerialNumber='+SerialNo;
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setTimeOut(60000);   
                req.setEndpoint(urlVal);
                req.setMethod('GET');
                HttpResponse res;
                if( ! Test.isRunningtest() ) {
                    res = h.send(req);
                }  else {
                    res = new HttpResponse();
                    res.setBody('{"messageTime":"2015-05-14T16:24:49.0000000Z","batteryLevel":"1","externalPower":"Good","GsmSignalQuality":"Good","GpsSignalQuality":"Good","PhoneNumber":"8393839483","serialNumber":"Test123"}');
                    res.setStatusCode(200);
                }           
                
                System.debug(':::::::: res - TrackUnit Test Device :::::::::'+res);
                System.debug(':::::::: res Body- TrackUnit Test Device :::::::::'+res.getBody());
                
                if( res.getStatusCode() == 200 ) {
                    JSONParser parser = JSON.createParser(res.getBody());
                    System.debug(':::parser:::'+parser);
                    Integer batteryLevel;
                    while ( parser.nextToken() != null ) {
                        
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) {
                            
                            String fieldName = parser.getText();
                            
                            parser.nextToken();
                            
                            if( fieldName == 'messageTime' ) {
                                String dateStr = '';
                                if( ! String.isBlank(parser.getText()) && parser.getText().contains('.') ) {
                                    dateStr = parser.getText().subString(0,parser.getText().lastIndexof('.'));
                                    dateStr = dateStr.replace('T',' ');
                                    System.debug('::::::::: dateStr ::::::::::::'+dateStr);
                                    Vech.Communicated__c = DateTime.valueOf(dateStr);
                                }
                            } else if( fieldName == 'batteryLevel' ) {
                                //vech.Unit_Number__c = parser.getText();
                                if(parser.getText() != null && parser.getText() != ''){
                                    batteryLevel = Integer.valueOf(parser.getText());
                                }
                                
                            } else if( fieldName == 'externalPower' ) {
                                vech.Approved_By__c = parser.getText();
                            } else if( fieldName == 'GsmSignalQuality' ) {
                                vech.Run_Hours__c = parser.getText();
                            } else if( fieldName == 'GpsSignalQuality' ) {
                                vech.GPS_Location__c = parser.getText();
                            } else if( fieldName == 'phoneNumber' ) {
                                vech.CID__c = parser.getText();
                            }
                        }
                    }
                    if( vech.Communicated__c.date() == System.Today() && vech.Run_Hours__c == 'Good' && batteryLevel != null && batteryLevel >=  12.0) {
                        //teleVech.gotoDeInstall = False;
                        //teleVech.confirmMsg = 'Communicated True';
                        teleVech.confirmMsg = 'Run Hour True'; 
                        /*if(vech.Run_Hours__c != null && vech.Run_Hours__c != ''){
teleVech.confirmMsg = 'Run Hour True'; 
}else{
teleVech.confirmMsg = 'Run Hour False'; 
}*/
                    } else {
                        //teleVech.gotoDeInstall = TRUE;
                        teleVech.confirmMsg = 'Communicated False'; 
                    }
                    vech.Last_Modified_By_Sites_User__c = contactId;
                    //update vech;
                    String response = InstallationAppDmlUtil.upsertServices(JSON.serialize(new List<Vehicles__c>{vech}));
                    InstallationAppDmlUtil.ServiceResponse cls = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response, InstallationAppDmlUtil.ServiceResponse.class);
                    if(cls.status != 'Success'){
                        throw new DmlException(cls.message);
                    }
                } else {
                    teleVech.confirmMsg = 'Please contact your Project Coordinator with Error Code '+String.valueOf(res.getStatusCode())+'.';
                    vech.Last_Modified_By_Sites_User__c = contactId;
                    //update vech;
                    String response = InstallationAppDmlUtil.upsertServices(JSON.serialize(new List<Vehicles__c>{vech}));
                    InstallationAppDmlUtil.ServiceResponse cls = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response, InstallationAppDmlUtil.ServiceResponse.class);
                    if(cls.status != 'Success'){
                        throw new DmlException(cls.message);
                    }
                }
            } 
            
            teleVech.activeVech = vech;
            return JSON.serialize(teleVech);
        }
        return null;
    }
    @auraEnabled
    public static boolean call1537(String Vehicle){
        Vehicles__c teleVech = (vehicles__c)JSON.deserialize(Vehicle,vehicles__c.class);
        String accessToken = getAccessToken();
        Http h;
        HttpResponse res;
        HttpRequest req;
        h = new Http();
        req = new HttpRequest();
        req.setTimeOut(60000);   
        req.setEndpoint('https://api.onei3.com/1537/series?attr[equipment]='+teleVech.CID__c+'&tag=gps');
        req.setMethod('GET');       
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setHeader('Authorization','Bearer '+accessToken);
        req.setHeader('Accept', '*/*');
        system.debug(':::::request::::;'+req);
        //if( ! Test.isRunningtest() ) {
        res = h.send(req);
        if(res.getStatusCode() == 200 && res.getStatus() == 'OK'){
            system.debug('res.getBody()::'+res.getBody());
            List<body> bodyWrapper = (List<body>)JSON.deserialize(res.getBody(),List<body>.class);
            if(bodyWrapper != null && bodyWrapper.size()>0 && bodyWrapper[0].last != null && String.isNotBlank(bodyWrapper[0].last.t)){
                Date tDate = Date.valueOf(bodyWrapper[0].last.t.replace('T',' '));
                if(tDate == system.today()){
                    if(bodyWrapper[0].last.v != null){
                        teleVech.GPS_Location__c = string.join(bodyWrapper[0].last.v,',');
                    }
                    //update teleVech;
                    String response = InstallationAppDmlUtil.upsertServices(JSON.serialize(new List<Vehicles__c>{teleVech}));
                    InstallationAppDmlUtil.ServiceResponse cls = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response, InstallationAppDmlUtil.ServiceResponse.class);
                    if(cls.status != 'Success'){
                        throw new DmlException(cls.message);
                    }else{
                        return true;
                    }
                }else{
                    return false;
                }
            }
        }
        return false;
    }
    public class body{
        public string id;
        public string href;
        public string key;
        public string title;
        public List<string> tags;
        public string createdAt; 
        public last last;
        public attrs attrs;
    }
    public class last{
        public string t;
        public List<double> v;
        public attrs attrs;
    }
    public class attrs{
        public string fix_quality;
        public string equipment;
        public string heading;
        public string speed;
    }
    public static string isDeviceCommunicating( String accessToken, String InstallationId) {
        
        
        JSONParser parser;        
        Http h;
        HttpResponse res;
        HttpRequest req;
        String isDeviceCommStatusMsg = NULL;
        
        if( String.isNotBlank(InstallationId)) {
            
            h = new Http();
            req = new HttpRequest();
            req.setTimeOut(60000);   
            req.setEndpoint('https://api.onei3.com/769/installations/'+InstallationId);
            req.setMethod('GET');       
            req.setHeader('Content-Type','application/x-www-form-urlencoded');
            req.setHeader('Authorization','Bearer '+accessToken);
            req.setHeader('Accept', '*/*');
            system.debug(':::::request::::;'+req);
            //if( ! Test.isRunningtest() ) {
            res = h.send(req);
            /*} else {
res = new HttpResponse();
res.setStatusCode(200);
res.setBody('{ "id": "1000000", "device": { "serialNumber":"123456789", "attrs": { "model": "M6C" },"tags": [],"createdAt": "2014-09-30T05:00Z","communicatedAt": "2014-09-30T05:50Z" }, "equipment": {"id":"987654321","name":"F150 Service Truck #333","attrs":{"make":"Ford","model":"F150","year":"2012"}},"packages":[{"id":"111222333"}],"attrs":{"Installed by":"someuser@somecompany.com","key2":"value2"}}');
}*/
            
            if( res.getStatusCode() == 200 ) {
                
                parser = JSON.createParser(res.getBody());
                
                while ( parser.nextToken() != null ) {
                    
                    if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) ) {
                        
                        String fieldName = parser.getText();
                        
                        parser.nextToken();
                        
                        if( fieldName == 'device' ) {
                            
                            while ( parser.nextToken() != null ) {
                                
                                if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) ) {
                                    
                                    String fieldName1 = parser.getText();
                                    
                                    parser.nextToken();
                                    
                                    if( fieldName1 == 'communicatedAt' ) {
                                        vech.Communicated__c = parser.getDatetimeValue();
                                        
                                        break;
                                    }
                                }
                            }
                            
                        }
                    }
                }
            }else if( res.getStatusCode() == 429 ) {
                system.debug('error::::429');
                if(!Test.isRunningTest()){
                    accessToken = getAccessToken ();
                    isDeviceCommStatusMsg = isDeviceCommunicating( accessToken, InstallationId);
                    return isDeviceCommStatusMsg;
                }else{
                    return null;
                }
            } else {
                vech.Communicated__c = NULL;
                isDeviceCommStatusMsg = ' - Please contact your Project Coordinator with Error Code '+String.valueOf(res.getStatusCode())+'.';
                return null;
            }
        } else {
            vech.Communicated__c = NULL;
            isDeviceCommStatusMsg =  ' - You must first \'Activate SIM\' successfully before you can click \'Is Device Communicating?\' button.';
            return null;
        }
        return isDeviceCommStatusMsg;
    }
    public static string testSync( String accessToken, String EquipmentId ) {
        
        String testSyncStatusMsg = NULL;
        JSONParser parser;    
        Http h;
        HttpResponse res;
        HttpRequest req;
        
        if( String.isNotBlank(EquipmentId) ) {           
            
            
            // To Access Engine Hours
            h = new Http();
            req = new HttpRequest();
            req.setTimeOut(60000);   
            req.setEndPoint('https://api.onei3.com/1537/series?attr[equipment]='+EquipmentId+'&tag=run_time');
            req.setMethod('GET');       
            req.setHeader('Content-Type','application/x-www-form-urlencoded');
            req.setHeader('Authorization','Bearer '+accessToken);
            req.setHeader('Accept', '*/*');
            
            
            // if( ! Test.isRunningtest() ) {
            res = h.send(req);
            /*} else {
res = new HttpResponse();
res.setStatusCode(200);
res.setBody('{"id":"36683823253185679","href":"/1537/series/36683823253185679","key":"equipment:36681234864301193.run_time","title":"Run Time","tags":["run_time","numeric","time"],"attrs":{"equipment":"36681234864301193","uom":"hour"},"createdAt":"2014-10-28T14:44:12Z","last":{"t":"2014-10-28T15:45:59Z","v":101.11}}');
}*/
            
            if( res.getStatusCode() == 200 ) {
                
                parser = JSON.createParser(res.getBody());
                
                while ( parser.nextToken() != null ) {
                    
                    if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) ) {
                        
                        String fieldName = parser.getText();
                        
                        parser.nextToken();
                        
                        if( fieldName == 'last' ) {
                            
                            while ( parser.nextToken() != null ) {
                                
                                if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) ) {
                                    
                                    String fieldName1 = parser.getText();
                                    
                                    parser.nextToken();                               
                                    
                                    if( fieldName1 == 'v' ) {
                                        vech.Run_Hours__c  = parser.getText();
                                        break;
                                    }
                                }
                            }
                        }   
                    }
                }
            }else if( res.getStatusCode() == 429 ) {
                if(!Test.isRunningTest()){
                    accessToken = getAccessToken ();
                    testSyncStatusMsg = testSync( accessToken, EquipmentId ); 
                    return testSyncStatusMsg;
                }else{
                    return null;
                }
            } else {
                testSyncStatusMsg = ' - Please contact your Project Coordinator with Error Code '+String.valueOf(res.getStatusCode())+'.';
                //return null;
            }
            
            // Gps Location
            testSyncStatusMsg = getGPSLocation(accessToken);     
        }
        
        return testSyncStatusMsg;
    }
    public static string getGPSLocation(String accessToken){
        String testSyncStatusMsg='';
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setTimeOut(60000);   
        req.setEndPoint('https://api.onei3.com/1537/series?attr[equipment]='+EquipmentId+'&tag=gps');
        req.setMethod('GET');       
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setHeader('Authorization','Bearer '+accessToken);
        req.setHeader('Accept', '*/*');
        HttpResponse res;
        
        //if( ! Test.isRunningtest() ) {
        res = h.send(req);
        /*} else {
res = new HttpResponse();
res.setStatusCode(200);
res.setBody('{"id":"36683822615651467","href":"/1537/series/36683822615651467","key":"equipment:36681234864301193.gps","title":"Location","tags":["gps"],"attrs":{"equipment":"36681234864301193"},"createdAt":"2014-10-28T14:44:12Z","last":{"t":"2014-10-28T16:00:59Z","v":[-81.19893,42.920948,231.45]}}');
}*/
        JSONParser parser;
        
        String locationValues = '';
        
        if( res.getStatusCode() == 200 ) {
            
            parser = JSON.createParser(res.getBody());
            
            while ( parser.nextToken() != null ) {
                
                if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) ) {
                    
                    String fieldName = parser.getText();
                    
                    parser.nextToken();
                    
                    if( fieldName == 'last' ) {
                        
                        while ( parser.nextToken() != null ) {
                            
                            if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) ) {
                                
                                String fieldName1 = parser.getText();
                                
                                parser.nextToken();                               
                                
                                if( fieldName1 == 'v' ) {
                                    while ( parser.nextValue() != null ) {
                                        if( parser.getText() == ']') break;
                                        if(parser.getText() != '[' && parser.getText() != ']' && parser.getText() != '{' && parser.getText() != '}') {
                                            locationValues += parser.getText() + ',';
                                        }
                                    }
                                    break;
                                }
                            }
                        }
                    }   
                }
            }
        }else if( res.getStatusCode() == 429 ) {
            if(!Test.isRunningTest()){
                accessToken = getAccessToken ();
                testSyncStatusMsg = getGPSLocation( accessToken); 
                return testSyncStatusMsg;
            }else{
                return null;
            }
        } else {
            testSyncStatusMsg = 'Please contact your Project Coordinator with Error Code '+String.valueOf(res.getStatusCode())+'.';
        }
        
        if( String.isNotBlank(locationValues)) {
            if( locationValues.endsWith(',')) locationValues = locationValues.subString(0,locationValues.length()-1);
            vech.GPS_Location__c = locationValues;
        } 
        return testSyncStatusMsg;  
    }
    @auraEnabled  
    public static String  DeinstallDevice( String vechString, String contactId ){
        vechWrapperForActivateTelematics teleVech = new vechWrapperForActivateTelematics();
        vech = (Vehicles__c )JSON.deserialize(vechString, Vehicles__c.class);
        if(vech.Device_type__c == 'ZTR'){
            Integer statusCode = deleteZTREquipCallout(vech.Confirmation_Number__c, getAccessToken());         
            if( statusCode == 202 ){
                vech.Confirmation_Number__c = NULL;
                vech.CID__c = NULL;
                EquipmentId = NULL;
                InstallationId = NULL;
                //vech.Communicated__c = NULL;
            }        
            vech.Legacy_Serial_Number__c = vech.DSNSerial__c;
            vech.DSNSerial__c = '';
            teleVech.confirmMsg = 'New Device Number';  
            vech.Last_Modified_By_Sites_User__c = contactId;
            //update vech;
            String response = InstallationAppDmlUtil.upsertServices(JSON.serialize(new List<Vehicles__c>{vech}));
            InstallationAppDmlUtil.ServiceResponse cls = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response, InstallationAppDmlUtil.ServiceResponse.class);
            if(cls.status != 'Success'){
                throw new DmlException(cls.message);
            }else{
                teleVech.activeVech = vech;
                return json.serialize(teleVech);
            }
        }else if( vech.Device_type__c == 'TrackUnit' ) {
            
            if( SerialNo != '' ) {
                
                vech.Confirmation_Number__c = NULL;
                
                String urlVal = 'https://api.trackunit.com/public/GetUnit?token='+Velociti_Settings__c.getOrgDefaults().LIT__c+'&format=json&SerialNumber='+SerialNo;
                Http h = new Http();
                JSONParser parser;
                HttpRequest req = new HttpRequest();
                req.setTimeOut(60000);   
                req.setEndpoint(urlVal);
                req.setMethod('GET');
                HttpResponse res;
                if( ! Test.isRunningtest() ) {
                    res = h.send(req);
                } else {
                    res = new HttpResponse();
                    res.setBody('{"Id":"Test123"}');
                    res.setStatusCode(200);
                }
                
                System.debug(':::res:::'+res);
                
                if( res.getStatusCode() == 200 ) { 
                    
                    parser = JSON.createParser(res.getBody());
                    System.debug(':::parser:::'+parser);
                    
                    while ( parser.nextToken() != null ) {
                        
                        if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)) {
                            
                            String fieldName = parser.getText();
                            
                            parser.nextToken();
                            
                            if(fieldName == 'id' && vech.Confirmation_Number__c == NULL ) {
                                vech.Confirmation_Number__c = parser.getText();
                                break;
                            }
                        }
                    }
                    
                }
            }
            
            System.debug(':::::::::::::: vech.Confirmation_Number__c ::::::::::::::::'+vech.Confirmation_Number__c);
            
            if( vech.Confirmation_Number__c != NULL ) {
                
                //String data = '{"id":"'+vech.Confirmation_Number__c+'","input1Name":"","preRun1":0,"note":"","name":"'+equipRec.Lojack_SN__c+'","referenceNumber":"'+equipRec.Lojack_SN__c+'"}';
                String data = '{"id":"'+vech.Confirmation_Number__c+'","input1Name":"","preRun1":0,"note":"","name":"'+SerialNo+'","referenceNumber":""}';
                Http h = new Http();
                HttpRequest req = new HttpRequest();
                req.setTimeOut(60000);   
                req.setEndpoint('callout:LoJack_Authentication/public/UpdateUnit?Id='+EncodingUtil.urlEncode(vech.Confirmation_Number__c, 'UTF-8'));
                req.setMethod('POST');
                req.setHeader('Content-Type','application/json');
                req.setHeader('token',Velociti_Settings__c.getOrgDefaults().LIT__c);
                System.debug('::: data :::'+data);
                req.setBody(data);
                System.debug('::: req :::'+req);
                HttpResponse res;
                if( ! Test.isRunningtest() ) {
                    res = h.send(req);
                } else {
                    res = new HttpResponse();
                    res.setStatusCode(200);
                }           
                System.debug('::: res :::'+res);
                if( res.getStatusCode() == 200 ) { 
                    teleVech.confirmMsg = 'The delete operation has succeeded.';
                    //isDeletedStatus = TRUE;
                    vech.Confirmation_Number__c = NULL;
                    vech.CID__c = NULL;
                    vech.GPS_Location__c = NULL;
                    vech.Run_Hours__c = NULL;
                    vech.Communicated__c = NULL;
                    vech.Approved_by__c = NULL;
                    vech.Unit_Number__c = NULL;
                    vech.Equip_Category__c = NULL;
                    vech.Last_Modified_By_Sites_User__c = contactId;
                    //update vech;
                    String response = InstallationAppDmlUtil.upsertServices(JSON.serialize(new List<Vehicles__c>{vech}));
                    InstallationAppDmlUtil.ServiceResponse cls = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response, InstallationAppDmlUtil.ServiceResponse.class);
                    if(cls.status != 'Success'){
                        throw new DmlException(cls.message);
                    }
                } else {
                    teleVech.confirmMsg = ' Please contact your Project Coordinator with Error Code '+String.valueOf(res.getStatusCode())+'.';
                }
            } else {
                teleVech.confirmMsg = 'TrackUnit Installation Id is required for Delete';
            }
            teleVech.activeVech = vech;
            return json.serialize(teleVech);
        }
        return NULL;
        
    }
    @auraEnabled
    public static String replaceDSN(String vehicleStr,String attachmentName){
        Vehicles__c vehicle = (Vehicles__c)JSON.deserialize(vehicleStr, Vehicles__c.class);
        if(vehicle != null){
            if(vehicle.DSNSerial__c == vehicle.Legacy_Serial_Number__c){
                vehicle.Legacy_Serial_Number__c = '';
            }else{
                List<SCMC__Serial_Number__c> serialNumberList = [SELECT SCMC__Serial_Number__c,Vehicle_Number__c, Status__c FROM SCMC__Serial_Number__c 
                                                                 WHERE ( Ownership_Code_Name__c = 'United Rentals' OR Ownership_Code_Name__c = 'UR – PHVAC' )  
                                                                 AND SCMC__Sales_Order_Line_Item__c !='' 
                                                                 AND (SCMC__Serial_Number__c = :vehicle.DSNSerial__c 
                                                                      OR SCMC__Serial_Number__c = :vehicle.Legacy_Serial_Number__c)
                                                                 AND ((Vehicle_Number__c = : vehicle.Id AND Status__c = 'Installed') 
                                                                      OR ( Vehicle_Number__c = null AND Status__c = 'In Transit')) 
                                                                ]; 
                boolean align = false;
                if(serialNumberList != null && serialNumberList.size()>0){
                    for(SCMC__Serial_Number__c sn:serialNumberList){
                        if(sn.SCMC__Serial_Number__c == vehicle.DSNSerial__c 
                           &&(! String.valueOf(vehicle.DSNSerial__c).startsWith('6') &&  !String.valueOf(vehicle.DSNSerial__c).startsWith('5'))){
                               sn.Vehicle_Number__c = vehicle.Id;
                               vehicle.Velociti_Inventory__c = 'Yes';
                               align = true;
                           }else if(sn.SCMC__Serial_Number__c == vehicle.Legacy_Serial_Number__c){
                               sn.Vehicle_Number__c = null;
                           }
                    }
                    //update serialNumberList;
                    String response = InstallationAppDmlUtil.upsertSerialNumbers(JSON.serialize(serialNumberList));
                    InstallationAppDmlUtil.ServiceResponse cls = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response, InstallationAppDmlUtil.ServiceResponse.class);
                    if(cls.status != 'Success'){
                        throw new DmlException(cls.message);
                    }
                    if(!align)vehicle.Velociti_Inventory__c = 'No';
                }else{
                    vehicle.Velociti_Inventory__c = 'No';
                }
            }
            //update vehicle;
            String response = InstallationAppDmlUtil.upsertServices(JSON.serialize(new List<Vehicles__c>{vehicle}));
            InstallationAppDmlUtil.ServiceResponse cls = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response, InstallationAppDmlUtil.ServiceResponse.class);
            if(cls.status != 'Success'){
                throw new DmlException(cls.message);
            }else{
                String attchName = attachmentName.replace(' ','_');
                attchName = attchName+'_'+vehicle.Name;
                List<Attachment> dsnAttachment = [SELECT Id FROM Attachment WHERE ParentId = :vehicle.Id AND Name = :attchName];
                if(dsnAttachment != null && dsnAttachment.size()>0){
                    dsnAttachment[0].Name = 'Replaced_'+attchName;
                    update dsnAttachment;
                }
            }
        }
        return JSON.serialize(vehicle);
    }
    public pagereference logout(){
        
        pagereference pg;  
        Cookie secret = new Cookie('secretKey',null,null,1,false);       
        pg = new pagereference('/FieldAppLogin');
        ApexPages.currentPage().setCookies(new Cookie[] {secret});              
        pg.setredirect(true); 
        return pg;    
    }
    @AuraEnabled
    public static String overtheAirPackageUpdate(String vehicle,String contactId){
        Vehicles__c vech = (Vehicles__c)JSON.deserialize(vehicle,Vehicles__c.class);
        Velociti_Settings__c vs = Velociti_Settings__c.getOrgDefaults();
        List<Attachment> files = [SELECT Name, Body, ContentType FROM Attachment WHERE ParentId = :vech.Id AND (Name Like 'Positive_Wiring_Harness_Test%' OR Name Like 'Device_Serial_Number%')];
        OrgWideEmailAddress[] owea = [select Id,Address from OrgWideEmailAddress where Address = :vs.URITelematics_Sender__c];
        
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();
        for (Attachment file: files) {
            Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
            efa.setFileName(file.Name+'.png');
            efa.setBody(file.Body);
            efa.setContentType('image/png');//file.ContentType
            attachments.add(efa);
        }
        
        
        system.debug('attachments::'+attachments);
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTemplateId(vs.ZTR__c);
        mail.settargetobjectid(contactId);
        if(Test.isRunningTest()){
            mail.setPlainTextBody('Test');
        }
        /*if(vech.Work_Order__r.Scheduling_Owner__c != null){
mail.settargetobjectid(vech.Work_Order__r.Scheduling_Owner__c);
}*/
        if ( owea.size() > 0 ) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        mail.setFileAttachments(attachments);
        mail.setWhatId(vech.Id);
        List<String> toAddresses = vs.ZTR_Package_Update_Email__c.split(',');
        if(vech.Scheduling_Coordinator__c != null){
            mail.setCCAddresses(new List<String>{vech.Scheduling_Coordinator__c});
        }
        mail.setToAddresses(toAddresses);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail }); 
        vech.Email_Send__c = system.now();
        return JSON.serialize(vech);
    }
    @AuraEnabled
    PUBLIC static string newTestAgain(String vehicle,String contactId){
        system.debug('vehicle:::'+vehicle);
        vechWrapperForActivateTelematics teleVech = new vechWrapperForActivateTelematics();
        Vehicles__c vech = (Vehicles__c)JSON.deserialize(vehicle,Vehicles__c.class);
        system.debug('vech:::'+vech);
        String accessToken = getAccessToken();
        JSONParser parser;
        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setTimeOut(60000);   
        req.setEndpoint('https://api.onei3.com/769/installations/?device.serialnumber='+vech.DSNSerial__c);
        req.setMethod('GET');       
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setHeader('Authorization','Bearer '+accessToken);
        req.setHeader('Accept', '*/*');
        HttpResponse res = h.send(req);
        
        system.debug('status code'+res.getStatusCode() );   
        system.debug('res.getBody():::'+res.getBody());
        if( res.getStatusCode() == 200 ) {  
            
            if( res.getBody() != '[]'){ 
                
                parser = JSON.createParser(res.getBody());
                while ( parser.nextToken() != null ) {
                    
                    if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) ) {
                        
                        String fieldName = parser.getText();
                        
                        parser.nextToken();
                        
                        if(fieldName == 'createdAt') {
                            
                            
                        } else if( fieldName == 'id' && InstallationId  == NULL ) { 
                            vech.Confirmation_Number__c = parser.getText();
                            InstallationId = vech.Confirmation_Number__c;
                            
                        } else if( fieldName == 'equipment' ) {  
                            
                            while ( parser.nextToken() != null ) {
                                
                                if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) ) {
                                    
                                    fieldName = parser.getText();
                                    
                                    parser.nextToken(); 
                                    if( fieldName == 'id') {
                                        vech.CID__c = parser.getText();
                                        EquipmentId = vech.CID__c;
                                        break;
                                    }                 
                                }
                            }
                        } else if( fieldName == 'packages'){
                            
                            while ( parser.nextToken() != null ) {
                                
                                if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) ) {
                                    
                                    fieldName = parser.getText();
                                    
                                    parser.nextToken();  
                                    
                                    if( fieldName == 'id' ) {
                                        vech.Package__c = parser.getText();
                                        break;
                                    }       
                                    
                                }
                            }
                        }
                    }
                }
                
                if(String.isNotBlank(vech.CID__c)){
                    h = new Http();
                    req = new HttpRequest();
                    req.setTimeOut(60000);   
                    req.setEndPoint('https://api.onei3.com/1537/series?attr[equipment]='+EquipmentId+'&tag=run_time');
                    req.setMethod('GET');       
                    req.setHeader('Content-Type','application/x-www-form-urlencoded');
                    req.setHeader('Authorization','Bearer '+accessToken);
                    req.setHeader('Accept', '*/*');
                    
                    res = h.send(req);
                    system.debug('second response code:::'+res.getStatusCode() );
                    system.debug('second response:::'+res.getBody());
                    if( res.getStatusCode() == 200 ) {
                        
                        parser = JSON.createParser(res.getBody());
                        
                        while ( parser.nextToken() != null ) {
                            
                            if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) ) {
                                
                                String fieldName = parser.getText();
                                
                                parser.nextToken();
                                
                                if( fieldName == 'last' ) {
                                    
                                    while ( parser.nextToken() != null ) {
                                        
                                        if ( (parser.getCurrentToken() == JSONToken.FIELD_NAME) ) {
                                            
                                            String fieldName1 = parser.getText();
                                            
                                            parser.nextToken();                               
                                            
                                            if( fieldName1 == 'v' ) {
                                                vech.Run_Hours__c  = parser.getText();
                                                teleVech.confirmMsg = 'Success';
                                                break;
                                            }
                                        }
                                    }
                                }   
                            }
                        }
                    }
                }
            }
        }else if( res.getStatusCode() == 429 ) {
            system.debug('error::::429');
            if(!Test.isRunningTest()){
                String returnVal = newTestAgain(Json.serialize(vech) ,contactId);
                return returnVal;
            }else{
                return null;
            }
            
        } 
        vech.Last_Modified_By_Sites_User__c = contactId;
        system.debug('this is id'+vech);
        
        //update vech;
        system.debug('this is msh'+teleVech.confirmMsg);
        String response = InstallationAppDmlUtil.upsertServices(JSON.serialize(new List<Vehicles__c>{vech}));
        InstallationAppDmlUtil.ServiceResponse cls = (InstallationAppDmlUtil.ServiceResponse) JSON.deserialize(response, InstallationAppDmlUtil.ServiceResponse.class);
        if(cls.status != 'Success'){
            throw new DmlException(cls.message);
        }else{
            teleVech.activeVech = vech; 
            
            return json.serialize(teleVech);
        }
        
    }
    @auraEnabled
    public static String getBillOfMaterials(String vehicle){
        parentBillofMaterial parentBom = new parentBillofMaterial();
        parentBom.billofMaterialList = new List<billofMaterial>();
        try{
            Vehicles__c vech = (Vehicles__c)JSON.deserialize(vehicle, Vehicles__c.class);
            update vech;
            if(vech.Parts_Used_List__c != NULL){
                Map<Id,SCMC__Sales_Order_Line_Item__c> soliMap = new Map<Id,SCMC__Sales_Order_Line_Item__c>();
                List<SCMC__Sales_Order__c> salesorderList = [SELECT Id,Asset_Number__c,BOM__c,Name FROM SCMC__Sales_Order__c WHERE Asset_Number__c=:Vech.Id AND BOM__c= :vech.Parts_Used_List__r.Name];
                IF(salesorderList != NULL && salesorderList.size()>0){
                    parentBom.salesorder = salesorderList[0];
                    for(SCMC__Sales_Order_Line_Item__c soli:[SELECT Id,Name,SCMC__Quantity__c,SCMC__Item_Master__c FROM SCMC__Sales_Order_Line_Item__c WHERE SCMC__Sales_Order__c = :salesorderList[0].Id]){
                        soliMap.put(soli.SCMC__Item_Master__c,soli);
                    }
                }
                system.debug('soliMap:::'+soliMap);
                List<SCMC__Bill_of_Material__c> childBoms = [SELECT Id,Price__c,Name,SCMC__Item_Description__c,SCMC__Item__c,SCMC__Item__r.Name,SCMC__Parent__c,SCMC__QPA_Use__c FROM SCMC__Bill_of_Material__c WHERE Id =:vech.Parts_Used_List__c OR SCMC__Parent__c=:vech.Parts_Used_List__c];
                 system.debug('soliMap:::'+soliMap);
                if(childBoms != null && childBoms.size()>0){
                    for(integer i=0;i<childBoms.size() ;i++){
                        if(childBoms[i].Id == vech.Parts_Used_List__c){
                            parentBom.bom = childBoms[i];
                        }else{
                            billofMaterial child = new billofMaterial();
                            child.bom = childBoms[i];
                            system.debug('::'+childBoms[i].SCMC__Item__c);
                            if(soliMap.containsKey(childBoms[i].SCMC__Item__c)){
                                child.salesorderLineItem = soliMap.get(childBoms[i].SCMC__Item__c);
                                if(child.salesorderLineItem.SCMC__Quantity__c != null){
                                    child.quantity = child.salesorderLineItem.SCMC__Quantity__c.intValue();
                                }else{
                                    child.quantity = 0;
                                }
                                
                            }else{
                                child.salesorderLineItem = new SCMC__Sales_Order_Line_Item__c();
                                child.quantity = 0;
                            }
                            parentBom.billofMaterialList.add(child);
                        }
                    }
                }
                
            }
            if(parentBom.billofMaterialList != null && parentBom.billofMaterialList.SIZE()>0){
                for(Integer i=0; i<parentBom.billofMaterialList.size();i++){
                    
                    for(Integer j=i+1; j<parentBom.billofMaterialList.size();j++){
                        
                        if(parentBom.billofMaterialList[i].bom.Name > parentBom.billofMaterialList[j].bom.Name){
                            billofMaterial  temp = parentBom.billofMaterialList[i];
                            parentBom.billofMaterialList[i] = parentBom.billofMaterialList[j];
                            parentBom.billofMaterialList[j] = temp;
                        }    
                    }
                }
            }
            system.debug('parentBom::'+parentBom);
            return JSON.serialize(parentBom);
        }catch(Exception e){
            throw new auraException(e.getMessage());
        }
    }
    
    @auraEnabled
     public static String saveBillOfMaterial(String parentBomStr,String vehicle){
        try{
            parentBillofMaterial parentBom = (parentBillofMaterial)JSON.deserialize(parentBomStr, parentBillofMaterial.class);
            Vehicles__c vech = (Vehicles__c)JSON.deserialize(vehicle, Vehicles__c.class);
            if(parentBom != null && parentBom.billofMaterialList.size()>0){
                Id sortId = Schema.SObjectType.SCMC__Sales_Order__c.getRecordTypeInfosByName().get('Parts Used').getRecordTypeId();
                Id solirtId = Schema.SObjectType.SCMC__Sales_Order_Line_Item__c.getRecordTypeInfosByName().get('Item').getRecordTypeId();
                if(!(parentBom.salesorder != null && parentBom.salesorder.Id != null)){
                    parentBom.salesorder = new SCMC__Sales_Order__c(Asset_Number__c  = Vech.Id,Bom__c = vech.Parts_Used_List__r.Name);
                }
                Velociti_Settings__c vs = Velociti_Settings__c.getOrgDefaults();
                parentBom.salesorder.RecordTypeId = sortId;
                parentBom.salesorder.SCMC__Drop_Ship_Line1__c = 'Parts Used';
                parentBom.salesorder.SCMC__Drop_Ship_City__c = 'Parts Used';
                parentBom.salesorder.SCMC__Drop_Ship_State_Province__c = 'Parts Used';
                parentBom.salesorder.SCMC__Drop_Ship_Zip_Postal_Code__c = 'Parts Used';
                parentBom.salesorder.SCMC__Drop_Ship_Country__c = 'Parts Used';
                parentBom.salesorder.SCMC__Currency__c =  'a1j70000000HdGdAAK';
                parentBom.salesorder.SCMC__Customer_Account__c = vs.Salesorder_Customer_Account__c;
                parentBom.salesorder.SCMC__Primary_Sales_Rep__c = vs.Default_Primary_Sales_Rep__c;
                if(parentBom.salesorder.Id == null){
                    parentBom.salesorder.SCMC__Shipment_Status__c = 'Allocated';
                    parentBom.salesorder.SCMC__Status__c = 'Closed';
                }
                system.debug('parentBom.salesorder:::'+parentBom.salesorder);
                //upsert parentBom.salesorder;
                Boolean doForSo = false;
                system.debug(parentBom.salesorder.Id);
                if(parentBom.salesorder.Id != null){
                    doForSo = true;
                }else{
                    insert parentBom.salesorder;
                }
                vech.Parts_Used__c = '';
                system.debug('doForSo'+doForSo);
                List<SCMC__Sales_Order_Line_Item__c> soliList = new List<SCMC__Sales_Order_Line_Item__c>();
                List<SCMC__Sales_Order_Line_Item__c> soliListToDelete = new List<SCMC__Sales_Order_Line_Item__c>();
                for(billofMaterial billofMaterial: parentBom.billofMaterialList){
                    system.debug('billofMaterial:::'+billofMaterial);
                   // if(billofMaterial.quantity >0){
                    if(billofMaterial.quantity < 99){
                        if(billofMaterial.quantity >0){
                            vech.Parts_Used__c += ' '+billofMaterial.bom.SCMC__Item__r.Name+' - '+billofMaterial.bom.SCMC__Item_Description__c+ ' - Qty:'+billofMaterial.quantity+'\n';
                        }
                        if(!(billofMaterial.salesorderLineItem != null && billofMaterial.salesorderLineItem.Id != null)){
                            billofMaterial.salesorderLineItem = new SCMC__Sales_Order_Line_Item__c(SCMC__Sales_Order__c = parentBom.salesorder.Id);
                        }
                        billofMaterial.salesorderLineItem.RecordTypeId = solirtId;
                        billofMaterial.salesorderLineItem.SCMC__Item_Master__c = billofMaterial.bom.SCMC__Item__c;
                        billofMaterial.salesorderLineItem.SCMC__Quantity__c = billofMaterial.quantity;
                        billofMaterial.salesorderLineItem.SCMC__Customer_Current_Promise_Date__c = system.today();
                        billofMaterial.salesorderLineItem.SCMC__Price__c = billofMaterial.bom.Price__c;
                        soliList.add(billofMaterial.salesorderLineItem );
                    }
                    
                    /*}else if(billofMaterial.salesorderLineItem != null && billofMaterial.salesorderLineItem.Id != null){
                        soliListToDelete.add(billofMaterial.salesorderLineItem);
                    }*///commented for W-000141 WI
                }
                Update vech;
                String soliToDelete = null;
                if(soliListToDelete != null && soliListToDelete.size()>0){
                    soliToDelete = JSON.serialize(soliListToDelete);
                    //delete soliListToDelete;
                }
                String soliToupsert = null;
                if(soliList != null && soliList.size()>0){
                    soliToupsert = JSON.serialize(soliList);
                    //delete soliListToDelete;
                }
                system.debug('soliList::'+soliList);
                if((soliList != null && soliList.size()>0) || (soliListToDelete != null && soliListToDelete.size()>0)){
                    if(doForSo){
                        InstallationAppDmlUtil.upsertSalesorderWithSOLI(JSON.serialize(parentBom.salesorder),soliToupsert,soliToDelete);
                    }else{
                        InstallationAppDmlUtil.upsertSalesorderWithSOLI('',JSON.serialize(soliList),soliToDelete);
                    } 
                    //upsert soliList;
                }
            }
            return JSON.serialize(parentBom);
        }catch(Exception e){
            throw new auraException(e.getMessage());
        }
    }
    @auraEnabled
    public static void updateAM(String assetMasterStr,String controllerType){
        try{
            Fleet_Maintenance__c assetMaster = (Fleet_Maintenance__c )JSON.deserialize(assetMasterStr, Fleet_Maintenance__c.class);
            assetMaster.Controller_Type__c = controllerType;
            update assetMaster;
        }catch(Exception e){
            throw new auraHandledException(e.getMessage());
        }
    
    }
    public class parentBillofMaterial{
        @AuraEnabled
        public SCMC__Bill_of_Material__c bom;
        @AuraEnabled
        public SCMC__Sales_Order__c salesorder;
        @AuraEnabled
        public List<billofMaterial> billofMaterialList;
    }
    public class billofMaterial{
        @AuraEnabled
        public SCMC__Bill_of_Material__c bom;
        @AuraEnabled
        public SCMC__Sales_Order_Line_Item__c salesorderLineItem;
        @AuraEnabled
        public Integer quantity;
    }
    public class vehiclePickListWrapper{
        @AuraEnabled
        public String fieldLabel;
        
        @AuraEnabled
        public String fieldName;
        
        @AuraEnabled
        public List<String> pickListValues;
        
    }
    public class vehiclesWrapper{
        @AuraEnabled
        public String serviceType;
        
        @AuraEnabled
        public List<vehiclePickListWrapper> vehiclePickListWrapper;
        
        @AuraEnabled
        public Vehicles__c vehicle;
        
        @AuraEnabled
        public boolean showDynamicImages;
        
        @AuraEnabled
        public string requiredIds;
        
        @AuraEnabled
        public string optionalIds;
        
        @AuraEnabled
        public List<option> optionList;
        @AuraEnabled
        public List<String> controllerTypeList;
        @AuraEnabled
        public List<ZTR_Smart_Control_Package__mdt> fuelModuleList;
        @AuraEnabled
        public List<UR_Part_BOM__mdt> urPartsBomList;
        
        @AuraEnabled
        public Fleet_Maintenance__c assetMaster;
        
        @AuraEnabled
        public String barcodeField;
        /*@AuraEnabled
        public List<String> typesOfPartsUsed;
        @AuraEnabled
        public List<String> searchSOLIList;*/
    }
    public class option{
        @AuraEnabled 
        public string label;
        @AuraEnabled 
        public string value;
        @AuraEnabled 
        public string packageName;
    }
    public class vechWrapperForActivateTelematics{
        @AuraEnabled
        public Vehicles__c activeVech;
        
        @AuraEnabled
        public String confirmMsg;
        
        @AuraEnabled
        public Boolean gotoDeInstall; 
        
        @AuraEnabled
        public Boolean gotoDeInstallFroRunHr; 
        
    }
}