({
	doInit : function(component, event, helper) {
		component.set('v.isLoading',true);
        var recordId = helper.getParameterByName(component , event, 'vecID');
        component.set('v.recordId',recordId);
        
        var woId = helper.getParameterByName(component , event, 'WoId');
        component.set('v.woId',woId);
        
        console.log(recordId);
        //console.log(component.get('v.conId'));
        
        var action = component.get('c.getVehicle');
        action.setParams({
            "vehicleId":recordId
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log(state);
            if(state === 'SUCCESS'){
                //console.log(response.getReturnValue());
                var result = JSON.parse(response.getReturnValue());
                console.log(result);
                component.set('v.ServiceType',result.serviceType);
                if(result.serviceType && result.serviceType.includes('3G Replacement')){
                    component.set('v.replacement3G',true);
                }
                component.set('v.picklistWrapper',result.vehiclePickListWrapper);
                component.set('v.zscpList',result.optionList);
                //component.set('v.controllerTypeList',result.controllerTypeList);fuelModuleList
                component.set('v.fuelModuleOriginalList',result.fuelModuleList);
                component.set('v.assetMaster',result.assetMaster);
                if(result.urPartsBomList && result.urPartsBomList.length >0 && !(result.vehicle.Parts_Used_List__c)){
                    component.set('v.urPartsList',result.urPartsBomList);
                   // helper.openURModal(component,event,helper);
                }
                
                /*component.set('v.typesOfPartsUsed',result.typesOfPartsUsed);
                component.set('v.searchSOLIList',result.searchSOLIList);*/
                if(result.assetMaster.Fuel_Module__c != null && result.assetMaster.Fuel_Module__c != ''){
                    var fuelModuleList = [];
                    fuelModuleList.push(result.assetMaster.Fuel_Module__c);
                    component.set('v.fuelModuleList',fuelModuleList);
                }
                if(result.assetMaster != undefined && result.assetMaster != ''){
                    if(result.assetMaster.Controller_Type__c != undefined && result.assetMaster.Controller_Type__c != ''){
                        for(var i=0;i< result.optionList.length;i++){
                            
                            if(result.optionList[i].label == result.assetMaster.Controller_Type__c){
                                console.log('true');
                                component.set('v.zscp',result.optionList[i].value);
                                helper.setFuelsFromControllerType(component, event, helper);
                                break;
                            }
                        }
                    }
                }
                console.log(component.get('v.zscpList'));
                var vehicle = result.vehicle;
                 
                if(vehicle.Email_Send__c){
                    console.log('email send:'+vehicle.Email_Send__c);
                    component.set('v.packageUpdate',true);
                }
                var contactId = component.get('v.conId');
                vehicle.Technician__c = contactId;
                vehicle.Work_Order__c = woId;
                //barcode
                var barcodeString = result.barcodeField;
                if(barcodeString != '' && barcodeString != null){
                    if(barcodeString.includes('DSNSerial__c')){
                        vehicle.DSNSerialHasBarcode = true;
                    }else{
                        vehicle.DSNSerialHasBarcode = false;
                    }
                    if(barcodeString.includes('Removed_Device_Serial_Number__c')){
                        vehicle.RDSNSerialHasBarcode = true;
                    }else{
                        vehicle.RDSNSerialHasBarcode = false;
                    }
                }
                component.set('v.vehicle',vehicle);
                component.set('v.stage','1');
                console.log('requiredIds'+result.requiredIds);
                component.set('v.requiredIds',result.requiredIds);
                component.set('v.optionalIds',result.optionalIds);
                component.set('v.showDynamicImages',result.showDynamicImages);
                var totalTime = 0;
                var Equipment_Service_Time_In_Minutes = vehicle.Equipment_Service_Time_In_Minutes__c;
                var Telematics_Device_Activation_In_Minutes = vehicle.Telematics_Device_Activation_In_Minutes__c;
                if(Equipment_Service_Time_In_Minutes){
                    totalTime += parseInt(Equipment_Service_Time_In_Minutes);
                }
                if(Telematics_Device_Activation_In_Minutes){
                    totalTime += parseInt(Telematics_Device_Activation_In_Minutes);
                }
                component.set('v.TotalTime',totalTime);
                setTimeout(function() {
                    var URIcmp = component.find('URIcmp');
                    $A.util.removeClass(URIcmp,'slds-hide');
                    component.set('v.isLoading',false);
                    /*if(result.vehicle.Parts_Used_List__c){
                        helper.EnterPartsUsed(component,event,helper);
                    }*/
                },5000);
            }
        });
        $A.enqueueAction(action);
	},
    saveVehicles : function(component, event, helper) {
        helper.saveVehiclehelper(component, event, helper,true,false);
    },
    validateVehicle : function(component, event, helper) {
        var isEmptyImages = helper.validateImages(component, event, helper,'ImageCmp');
        var isEmptyFields = helper.validateFields(component, event, helper,'required');
        console.log('calling',isEmptyImages,isEmptyFields);
        var isEmptySN = helper.validateDeviceSerailNumber(component,event,helper,'DeviceSerialNumber');
        console.log('isEmptySN::'+isEmptySN);
        if(isEmptyFields && isEmptyImages && isEmptySN){
            var DSN = component.find('DeviceSerialNumber');
            var DeviceSerialNumber = DSN.get("v.value");
            component.set('v.isLoading',true);
            if(DeviceSerialNumber.startsWith ('6') || DeviceSerialNumber.startsWith ('5')){
                var vehicle = component.get('v.vehicle');
                vehicle.Velociti_Inventory__c = 'No';
                component.set('v.vehicle',vehicle);
                //--component.set('v.stage','2');
                helper.activateTelematicsFunc(component, event, helper);
                //component.set('v.isLoading',false);
            }else{
                helper.checkDSNalign(component, event, helper);
            }
        }
        
    },
    
    goNextStage : function(component, event, helper){
        helper.closeModal(component,event,helper);
        var URIcmp = component.find('URIcmp');
        $A.util.addClass(URIcmp,'slds-hide');
        component.set('v.isLoading',true);
        component.set('v.stage','2'); 
        var vehicle = component.get('v.vehicle');
        var urPartsBomList  = component.get('v.urPartsList');
        if(urPartsBomList && urPartsBomList.length >0 && !(vehicle.Parts_Used_List__c) ){
            helper.openURModal(component,event,helper);
        }else if(vehicle.Parts_Used_List__c){
            helper.EnterPartsUsed(component,event,helper);
        }
        setTimeout(function() {
            $A.util.removeClass(URIcmp,'slds-hide');
            component.set('v.isLoading',false);
        },5000);
    },
    goBack : function(component,event,helper){
        helper.BackToURLnesDeploymentSearch(component,event,helper);
    },
    logout : function(component,event,helper){
        var myEvent = $A.get("e.c:logoutEvent");
        myEvent.fire();
    },
    closeModal:function(component,event,helper){
        helper.closeModal(component,event,helper);
    },
    closeModalTestAgain:function(component,event,helper){
        helper.closeModal(component,event,helper);
        helper.activateTelematicsFunc(component, event, helper);
    },
    closeModalTestAgainForM6AndM8:function(component,event,helper){
        helper.closeModal(component,event,helper);
        helper.testDeviceFunc(component, event, helper);
    },
    newTest:function(component,event,helper){
        //helper.closeoapuModal(component,event,helper);
        helper.callTestAgain(component, event, helper);
    },
    callTestDevice: function(component,event,helper){
        helper.closeModal(component,event,helper);
        //helper.testDeviceFunc(component, event, helper);
    },
    DeinstallDeviceFunc : function(component,event,helper){
        
        helper.closeModal(component,event,helper);
        var vehicle = component.get('v.vehicle');
        var confirmMsg = component.get('v.confirmMsg');
        if(confirmMsg == 'Equip Categaory True'){
            vehicle.Package_Update__c  = 'No';
            component.set('v.vehicle',vehicle);
        }
        var one_day=1000*60*60*24;
        
        var difference_ms = (new Date().getTime() - new Date(vehicle.Date_Shipped__c).getTime());
        
        if(Math.round(difference_ms/one_day) <= 365){
            var modalContent = 'Device Serial Number '+ vehicle.DSNSerial__c+' is under WARRANTY. Return the device to your Branch Contact and have them contact warranty@ur.com to begin the RMA process.';
            component.set('v.modalContent',modalContent);
            confirmMsg = 'Device Serial Number Condition True';
            component.set('v.confirmMsg',confirmMsg);
            helper.openModal(component,event,helper);
        }else{
            var modalContent = 'Device Serial Number '+ vehicle.DSNSerial__c+' is NOT under Warranty. Return the device to the Branch Contact to dispose of in accordance with state laws.';
            confirmMsg = 'Device Serial Number Condition False';
            component.set('v.confirmMsg',confirmMsg);
            component.set('v.modalContent',modalContent);
            helper.openModal(component,event,helper);
        }
         //helper.DeinstallDeviceFunc(component, event, helper);
    },
    acceptAndContinue : function(component,event,helper){
        helper.closeModal(component,event,helper);
        helper.DeinstallDeviceFunc(component, event, helper);
    },
    ECFalseClose : function(component,event,helper){
        helper.closeModal(component,event,helper);
        var vehicle = component.get('v.vehicle');
        vehicle.Package_Update__c  = 'Yes';
        component.set('v.vehicle',vehicle);
        /*helper.saveVehiclehelper(component, event, helper,false,false);
        component.set('v.stage','2'); */ //case number 00316163
        helper.openoapuModal(component,event,helper);
    },
    previousPage : function(component,event,helper){
        var isEmptyImages = helper.validateImages(component, event, helper,'SNImage');
        var isEmptyFields = helper.validateDeviceSerailNumber(component,event,helper,'NewDeviceSerialNumber');
        
        if(isEmptyFields && isEmptyImages){
            component.set("v.isLoading",true);
            helper.closeModal(component,event,helper);
            
            helper.updateVehicleWithDSN(component, event, helper);
            
        }
    },
    CompleteService: function(component,event,helper){
        var isEmptyImages = helper.validateImages(component, event, helper,'stage2ImageCmp');
        var dynamicImages = false;
        if(component.get('v.showDynamicImages')){
            dynamicImages = component.find('uriGenericImages').imageValidation();
        }
        //var isEmptyFields = helper.validateFields(component, event, helper,'ServiceNotes');
        var isEmptyFields = helper.validateFields(component, event, helper,'required');
        //alert(dynamicImages);
        if(!dynamicImages && isEmptyImages && isEmptyFields){
            var today = new Date();
            let mon = today.getMonth() + 1;
            let day = today.getDate();
            var vehicle = component.get('v.vehicle');
            vehicle.Service_Date__c  = today.getFullYear()+'-'+ (mon.length == 1 ? '0' : '') + mon +'-'+ (day.length == 1 ? '0' : '') + day ;
            component.set('v.vehicle',vehicle);
            helper.saveVehiclehelper(component, event, helper,true,true);
        }
    },
    saveVehicleOnImageLoad : function(component, event, helper) {
        console.log('calling');
        helper.saveVehiclehelper(component, event, helper,false,false);
    },
    setFuels: function(component, event, helper){
        helper.setFuelsFromControllerType(component, event, helper);
    },
    barcodeScan : function(component, event, helper){
        
        var field = event.currentTarget.dataset.att;
        console.log('barcode Scan',field);
        var fieldName;
        if(field == 'RDSN'){
            fieldName = 'Removed_Device_Serial_Number__c';
        }else{
            fieldName = 'DSNSerial__c';
        }
        var myEvent = $A.get("e.c:barcodeEvent1");
        myEvent.setParams({"fieldName" : fieldName});
        myEvent.fire();
        
        window.addEventListener("message", $A.getCallback(function(event) {
            var eventData = (event.data).split(',');
            var vehicle1 = component.get("v.vehicle");
            if(eventData[1] == "DSNSerial__c"){
                vehicle1.DSNSerial__c = eventData[0];
            }else if(eventData[1] == "Removed_Device_Serial_Number__c"){
                vehicle1.Removed_Device_Serial_Number__c = eventData[0];
            }
            component.set("v.vehicle",vehicle1);
        }), false);
    },
    //case number 00316163
    packageUpdate: function(component, event, helper){
        component.set('v.isLoading',true);
        helper.sendEmail(component,event,helper);
    },
    revokeToPrevious : function(component, event, helper){
        component.set('v.TestAgainError',false);
    },
    call1537Again : function(component, event, helper){
        component.set('v.isLoading',true);
        helper.closeModal(component,event,helper);
        var vehicle = component.get('v.vehicle');
        helper.call1537RunHrsTrue(component,event,helper,vehicle);
    },
    useExistingLocation : function(component, event, helper){
        var vehicle = component.get('v.vehicle');
        console.log('vehicle:',vehicle.Use_existing_location__c);
        var inputCmp = component.find('existinglocation');
        var value = inputCmp.get('v.value');
        if(!value){
            inputCmp.showHelpMessageIfInvalid();
        }else{
            console.log(value);
            vehicle.Use_existing_location__c = value;
            if( value == 'Inside Structure'){
                var modalContent = 'The Device is functioning as expected.'
                component.set('v.modalContent',modalContent);
                component.set('v.confirmMsg','Run Hour True');
            }else if(value == 'Outside'){
                vehicle.Package_Update__c = 'No';
                var modalContent = 'The device is not returning GPS Location, run 1-5 minutes, power off, and test device again. If issues persist select "deinstall device".';
                component.set('v.modalContent',modalContent);
                component.set('v.confirmMsg','Inside Structure');
            }
            component.set('v.vehicle',vehicle);
            helper.openModal(component,event,helper);
        }
        
    },
    deinstall : function(component,event,helper){
        component.set('v.isLoading',true);
        var vehicle = component.get('v.vehicle');
        vehicle.Package_Update__c  = 'No';
        component.set('v.vehicle',vehicle);
        helper.closeModal(component,event,helper);
        helper.DeinstallDeviceFunc(component, event, helper);
    },
    closeURModal:function(component,event,helper){
        var urParts = component.find('urParts');
        var isEmptyFields = helper.validateFields(component,event,helper,'urParts');
        if(isEmptyFields){
            var modal = component.find('partsUsedModel');
            $A.util.addClass(modal,'slds-hide');
            $A.util.removeClass(modal, 'slds-show');
            /*var vehicle = component.get('v.vehicle');
            vehicle.Display_Parts_Used_Component__c  = true;
            component.set('v.vehicle',vehicle);*/
            helper.EnterPartsUsed(component,event,helper);
        }
        console.log(component.get('v.vehicle'));
        console.log(isEmptyFields);
    },
    saveBOM : function(component, event, helper){
        component.set('v.isLoading',true);
        helper.saveBOMfunction(component, event, helper);
    },
    Cancel : function(component, event, helper){
        component.set('v.bomModal',false);
    },
    EnterPartsUsedCall: function(component, event, helper){
        component.set('v.isLoading',true);
        window.setTimeout(
            $A.getCallback(function() {
                helper.getBOMDetails(component, event, helper);
            }), 6000
        );
    },
    calculateTotalTime : function(component, event, helper){
        var totalTime = 0;
        var vehicle = component.get('v.vehicle');
        //--var Locating_Equipment_In_Minutes = vehicle.Locating_Equipment_In_Minutes__c;
        var Equipment_Service_Time_In_Minutes = vehicle.Equipment_Service_Time_In_Minutes__c;
        var Telematics_Device_Activation_In_Minutes = vehicle.Telematics_Device_Activation_In_Minutes__c;

       /* if(Locating_Equipment_In_Minutes){
            totalTime += parseInt(Locating_Equipment_In_Minutes);
        }*/
        if(Equipment_Service_Time_In_Minutes){
            totalTime += parseInt(Equipment_Service_Time_In_Minutes);
        }
        if(Telematics_Device_Activation_In_Minutes){
            totalTime += parseInt(Telematics_Device_Activation_In_Minutes);
        }
        component.set('v.TotalTime',totalTime);
    }
    
})