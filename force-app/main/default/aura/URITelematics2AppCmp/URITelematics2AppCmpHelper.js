({
    closeModal:function(component,event,helper){
        var modal = component.find('cfmodal');
        $A.util.addClass(modal,'slds-hide');
        $A.util.removeClass(modal, 'slds-show');
        component.set('v.modalContent','');
        component.set('v.confirmMsg','');
    },
    openModal : function(component,event,helper){
        var modal = component.find('cfmodal');
        $A.util.addClass(modal, 'slds-show');
        $A.util.removeClass(modal,'slds-hide');
        helper.setDSNValue(component,event,helper);
    },
    
	saveVehiclehelper : function(component, event, helper,isBack,isCompleted,isImageLevelSave) {
        var vehicle = JSON.parse(JSON.stringify(component.get('v.vehicle')));
        var action = component.get('c.saveVehicle');
        const server = component.find('server');
        var params = {};
        if(isImageLevelSave){
            delete vehicle["Service_Status__c"];
        }
        params.vehicleStr = JSON.stringify(vehicle);
        params.isCompleted = isCompleted;
        server.callServer(
            action,
            params,
            false,
            $A.getCallback(function(response) {
                var result = JSON.parse(response);
                component.set('v.vehicle',result);
                if(isBack){
                    component.find('showToastcmp').showToastAuraMethod('success', 'Service Updated Successfully.', 10000);
                    this.BackToURLnesDeploymentSearch(component,event,helper);
                }
            }),
            $A.getCallback(function(error) { 
                helper.showToast(component,event,helper,'error',error,10000);
                component.set('v.isLoading',false);
            }),
            false, 
            false,
            false,
            false
        );
	},
    
    validateImages : function(component, event, helper,ImageId){
        var imagesCmp = component.find(ImageId);
        var isEmptyImage = true;
        if(imagesCmp){
            if(Array.isArray(imagesCmp)){
                for(var i=0;i<imagesCmp.length;i++){
                   var boo = imagesCmp[i].imageValidation();
                    
                    if(boo){
                        isEmptyImage = false;
                    }
                }
            }else{
                var boo = imagesCmp.imageValidation();
                if(boo){
                    isEmptyImage = false;
                }
            }
        }
        return isEmptyImage;
    },
    validateFields : function(component, event, helper,fieldId){
        var isEmptyFields = true;
        var required = component.find(fieldId);
        if(required){
            if(Array.isArray(required)){
                for(var i=0;i<required.length;i++){
                    var fieldvalue = required[i].get("v.value");
                    required[i].showHelpMessageIfInvalid();
                    //console.log('isValid'+required[i].checkValidity());
                    console.log(required[i].get("v.validity").valid );
                    console.log(fieldvalue);
                    if(! fieldvalue || ! required[i].get("v.validity").valid){
                        console.log(fieldvalue);
                        isEmptyFields = false;
                    }
                }
            }else{
                var fieldvalue = required.get("v.value");
                component.find(fieldId).showHelpMessageIfInvalid();
                console.log(fieldvalue);
                if(! fieldvalue){
                    console.log(fieldvalue);
                    isEmptyFields = false;
                }
            }
        }
        return isEmptyFields;
    },
    validateDeviceSerailNumber : function(component,event,helper,dsnFieldId){
        var vehicle = component.get('v.vehicle');
        var isEmptyFields = true;
        console.log(dsnFieldId);
        var DSN = component.find(dsnFieldId);
        
        console.log(DSN);
        var DeviceSerialNumber = DSN.get("v.value");
        DSN.setCustomValidity("");
        console.log( DeviceSerialNumber);
        if(DeviceSerialNumber){
            
            DeviceSerialNumber = DeviceSerialNumber.toString();
            var isNan = /^([0-9]*)$/.test(DeviceSerialNumber);
            if(isNan){
                if(DeviceSerialNumber.startsWith ('466') || DeviceSerialNumber.startsWith ('467') || DeviceSerialNumber.startsWith ('496')||DeviceSerialNumber.startsWith ('497') || DeviceSerialNumber.startsWith ('701') || DeviceSerialNumber.startsWith ('456') || DeviceSerialNumber.startsWith ('711')){
                    if(DeviceSerialNumber.length != 10){
                        DSN.setCustomValidity("Device Serial Number should be 10 characters long");
                        isEmptyFields = false;
                    }else{
                        vehicle.Device_Type__c = 'ZTR';
                        component.set('v.vehicle',vehicle);
                        DSN.setCustomValidity("");
                    }
                }else if(DeviceSerialNumber.startsWith ('6') || DeviceSerialNumber.startsWith ('5') || DeviceSerialNumber.startsWith ('7')){
                    if(DeviceSerialNumber.length != 6){
                        DSN.setCustomValidity("Device Serial Number should be 6 characters long");
                        isEmptyFields = false;
                    }else{
                        vehicle.Device_Type__c = 'TrackUnit';
                        component.set('v.vehicle',vehicle);
                        DSN.setCustomValidity("");
                    }
                }else{
                    DSN.setCustomValidity("Device Serial Number is not valid");
                    isEmptyFields = false;
                }
            }else{
                DSN.setCustomValidity("Device Serial Number should be Integer");
                isEmptyFields = false;
            }
        }else{
            DSN.setCustomValidity("Device Serial Number is Required");
            isEmptyFields = false;
            
        }
        DSN.reportValidity(); 
        return isEmptyFields;
    },
    checkDSNalign : function(component,event,helper){
        var vehicle = component.get('v.vehicle');
        var action = component.get('c.checkSerialNumber');
        const server = component.find('server');
        var params = {};
        params.vehicleStr = JSON.stringify(vehicle);
        server.callServer(
            action,
            params,
            false,
            $A.getCallback(function(response) {
                var result = JSON.parse(response);
                component.set('v.vehicle',result);
                helper.activateTelematicsFunc(component, event, helper);
            }),
            $A.getCallback(function(error) { 
                helper.showToast(component,event,helper,'error',error,10000);
                component.set('v.isLoading',false);
            }),
            false, 
            false,
            false,
            false
        );
    },
    BackToURLnesDeploymentSearch : function(component,event,helper){
        //window.history.back();
        component.set('v.backStatus','');
        window.setTimeout(
            $A.getCallback(function() {
                var componentEvent = component.getEvent("gobackToSearchView");
                var params = {};
                params.actionType = 'DATA-ENTRY';
                componentEvent.setParams({
                    "params":params
                });
                console.log('params',params);
                componentEvent.fire();
                component.set("v.isLoading",false);
            }), 3000
        );
    },
    activateTelematicsFunc: function(component, event, helper){
        component.set('v.showHelpText',true); 
        
        component.set("v.isLoading",true);
        var vehicle = component.get('v.vehicle');
        var assetMaster = component.get('v.assetMaster');
        var zscpList = component.get('v.zscpList');
        var zscp = component.get('v.zscp');
        console.log('zscpList::',zscpList);
        console.log('zscp::',zscp);
        var controllerType = '';
        for(var i=0;i< zscpList.length;i++){
            
            if(zscpList[i].value == zscp){
                console.log('true');
                controllerType = zscpList[i].label;
                //assetMaster.Controller_Type__c = controllerType;
                break;
            }
        }
        console.log('controllerType::',controllerType);
        console.log('JSON.stringify(assetMaster)::',JSON.stringify(assetMaster));
        var action = component.get('c.activateTelematics');
        const server = component.find('server');
        var params = {};
        params.vechString = JSON.stringify(vehicle);
        params.contactId = component.get('v.conId');
        params.zscpPackageId = component.get('v.zscp');
        params.assetMasterStr = JSON.stringify(assetMaster);
        params.controllerType = controllerType;
        server.callServer(
            action,
            params,
            false,
            $A.getCallback(function(response) {
                var result = JSON.parse(response);
                var vehicle = result.activeVech;
                component.set('v.vehicle',vehicle);
                var confirmMsg = result.confirmMsg;
                //confirmMsg = 'Error';
                if(confirmMsg == 'Activated Successfully'){
                    //component.set("v.vechActivated",true);
                    helper.testDeviceFunc(component, event, helper);
                }else if(confirmMsg == '404 Next Section'){
                    component.set("v.isLoading",false);
                    var modalContent = 'Service Successful';
                    component.set('v.modalContent',modalContent);
                    component.set('v.confirmMsg',confirmMsg);
                    this.openModal(component,event,helper);
                }else{
                    var toastcom = component.find('showToastcmp').showToastAuraMethod('error', confirmMsg, 10000);
                	component.set("v.isLoading",false);
                }
            }),
            $A.getCallback(function(error) { 
                helper.showToast(component,event,helper,'error',error,10000);
                component.set('v.isLoading',false);
            }),
            false, 
            false,
            false,
            false
        );
        
    },
    testDeviceFunc: function(component, event, helper){
        var vehicle = component.get('v.vehicle');
        //component.set("v.isLoading",true);
        var action = component.get('c.testDevice');
        const server = component.find('server');
        var params = {};
        params.vechString = JSON.stringify(vehicle);
        params.contactId = component.get('v.conId');
        server.callServer(
            action,
            params,
            false,
            $A.getCallback(function(response) {
                var result = JSON.parse(response);
                if(result){
                    var vehicle = result.activeVech;
                    console.log('vehicle');
                    component.set('v.vehicle',vehicle);
                    var confirmMsg = result.confirmMsg;
                    
                    if(confirmMsg == 'Communicated False'){
                        component.set("v.isLoading",false);
                        var modalContent = 'The device is not communicating. Please run the Equipment again for 1-5 minutes, power off, and select "Test Again".  If the issue persists, please select "Deinstall Device".';
                        component.set('v.modalContent',modalContent);
                        component.set('v.confirmMsg',confirmMsg);
                        this.openModal(component,event,helper);
                    }else if(confirmMsg == 'Run Hour True'){
                        this.call1537RunHrsTrue(component,event,helper,result.activeVech);
                        
                    }else if(confirmMsg == 'Equip Categaory True'){
                        var modalContent = 'The Device is not returning Run Hours.Please review all wiring and connections , then power on the Equipment, run 1-5 minutes, power off, and Test Device again if issue persists, select Deinstall Device.';
                        component.set('v.modalContent',modalContent);
                        component.set('v.confirmMsg',confirmMsg);
                        this.openModal(component,event,helper);
                        component.set("v.isLoading",false);
                    }else if(confirmMsg == 'Equip Categaory False'){
                        component.set("v.isLoading",false);
                        var modalContent = 'The device is not returning run hours. Please review all wiring and connections then run the Equipment for 1-5 minutes, power off, and select "Test Again".  If the issue persists, please select "Wiring & Connections are Good".';
                        component.set('v.modalContent',modalContent);
                        component.set('v.confirmMsg',confirmMsg);
                        this.openModal(component,event,helper);
                    }
                }
            }),
            $A.getCallback(function(error) { 
                helper.showToast(component,event,helper,'error',error,10000);
                component.set('v.isLoading',false);
            }),
            false, 
            false,
            false,
            false
        );

    },
    call1537RunHrsTrue : function(component,event,helper,Vehicle){
        var action = component.get('c.call1537');
        const server = component.find('server');
        var params = {};
        params.Vehicle = JSON.stringify(Vehicle);
        server.callServer(
            action,
            params,
            false,
            $A.getCallback(function(response) {
                var result= response.getReturnValue();
                if(result){
                    var modalContent = 'The Device is functioning as expected.'
                    component.set('v.modalContent',modalContent);
                    component.set('v.confirmMsg','Run Hour True');
                }else{
                    var modalContent = ''
                    component.set('v.modalContent',modalContent);
                    component.set('v.confirmMsg','show existing location');
                }
                this.openModal(component,event,helper); 
                component.set('v.isLoading',false);
            }),
            $A.getCallback(function(error) { 
                helper.showToast(component,event,helper,'error',error,10000);
                component.set('v.isLoading',false);
            }),
            false, 
            false,
            false,
            false
        );

    },
    DeinstallDeviceFunc :function(component,event,helper){
        var confirmMsg = component.get('v.confirmMsg');
        if(confirmMsg == 'Equip Categaory True'){
            var vehicle = component.get('v.vehicle');
            vehicle.Package_Update__c  = 'No';
        }
        var vehicle = component.get('v.vehicle');
        component.set("v.isLoading",true);
        var action = component.get('c.DeinstallDevice');
        const server = component.find('server');
        var params = {};
        params.vechString = JSON.stringify(vehicle);
        params.contactId = component.get('v.conId');
        server.callServer(
            action,
            params,
            false,
            $A.getCallback(function(response) {
                var result = JSON.parse(response);
                if(result){
                    var vehicle = result.activeVech;
                    console.log('vehicle');
                    component.set('v.vehicle',vehicle);
                    var confirmMsg = result.confirmMsg;
                    /*var gotoDeInstall = result.gotoDeInstall;                     
                    var gotoDeInstallFroRunHr = result.gotoDeInstallFroRunHr;*/
                    component.set("v.isLoading",false);
                    if(confirmMsg == 'New Device Number'){
                        var modalContent = 'Please key the New Device Serial Number';
                        component.set('v.modalContent',modalContent);
                        component.set('v.confirmMsg',confirmMsg);
                        this.openModal(component,event,helper);
                    }
                }
            }),
            $A.getCallback(function(error) { 
                helper.showToast(component,event,helper,'error',error,10000);
                component.set('v.isLoading',false);
            }),
            false, 
            false,
            false,
            false
        );

        
    },
    updateVehicleWithDSN : function(component, event, helper) {
		var vehicle = component.get('v.vehicle');
        var action = component.get('c.replaceDSN');
        const server = component.find('server');
        var params = {};
        params.vehicleStr = JSON.stringify(vehicle);
        params.attachmentName = 'Device Serial Number';
        server.callServer(
            action,
            params,
            false,
            $A.getCallback(function(response) {
                var result = JSON.parse(response);
                component.set('v.vehicle',result);
                helper.activateTelematicsFunc(component, event, helper);
            }),
            $A.getCallback(function(error) { 
                helper.showToast(component,event,helper,'error',error,10000);
                component.set('v.isLoading',false);
            }),
            false, 
            false,
            false,
            false
        );        
	},
    setFuelsFromControllerType : function(component, event, helper){
        var fuelModuleOriginalList = component.get('v.fuelModuleOriginalList');
        var zscp = component.get('v.zscp');
        if(zscp != '' && zscp != null && zscp != undefined){
            var zscpList = component.get('v.zscpList');
            var result = zscpList.filter(function(zscpInst){
                if(zscpInst.value == zscp){
                    return true;
                }
            });
            console.log('result',result);
            console.log('fuelModuleOriginalList',fuelModuleOriginalList)
            var fuelModuleList = [];
            if(result != null && result != undefined && result.length >0){
                for(var i=0;i<fuelModuleOriginalList.length;i++){
                    if(fuelModuleOriginalList[i].Asset_Type_s__c == 'ALL' || fuelModuleOriginalList[i].Asset_Type_s__c.includes(result[0].packageName)){
                        fuelModuleList.push(fuelModuleOriginalList[i].Package_Name__c);
                    }
                }
                
            }
            console.log('fuelModuleList::',fuelModuleList);
            component.set('v.fuelModuleList',fuelModuleList);
        }else{
            component.set('v.fuelModuleList',[]);
        }
    },
    closeoapuModal:function(component,event,helper){
        var modal = component.find('oapumodal');
        $A.util.addClass(modal,'slds-hide');
        $A.util.removeClass(modal, 'slds-show');
        component.set('v.modalContent','');
        component.set('v.confirmMsg','');
    },
    openoapuModal : function(component,event,helper){
        var modal = component.find('oapumodal');
        $A.util.addClass(modal, 'slds-show');
        $A.util.removeClass(modal,'slds-hide');
    },
    
    openURModal : function(component,event,helper){
        var modal = component.find('partsUsedModel');
        $A.util.addClass(modal, 'slds-show');
        $A.util.removeClass(modal,'slds-hide');
    },
    sendEmail : function(component,event,helper){
         var action = component.get('c.overtheAirPackageUpdate');
        var vehicle = component.get('v.vehicle');
        const server = component.find('server');
        var params = {};
        params.vehicle = JSON.stringify(component.get('v.vehicle'));
        params.contactId = component.get('v.conId');
        server.callServer(
            action,
            params,
            false,
            $A.getCallback(function(response) {
                var result = JSON.parse(response);
                component.set('v.vehicle',result);
                component.set('v.packageUpdate',true);
                helper.saveVehiclehelper(component, event, helper,false,false);
                component.set('v.stage','2'); 
                var urPartsBomList  = component.get('v.urPartsList');
                if(urPartsBomList && urPartsBomList.length >0 && !(vehicle.Parts_Used_List__c) ){
                    helper.openURModal(component,event,helper);
                }else if(vehicle.Parts_Used_List__c){
                    helper.EnterPartsUsed(component,event,helper);
                }
                component.set('v.isLoading',false);

            }),
            $A.getCallback(function(error) { 
                helper.showToast(component,event,helper,'error',error,10000);
                component.set('v.isLoading',false);
            }),
            false, 
            false,
            false,
            false
        );
    },
    callTestAgain: function(component,event,helper){
        component.set('v.isLoading',true);
        var action = component.get('c.newTestAgain');
        var vehicle = component.get('v.vehicle');
        const server = component.find('server');
        var params = {};
        params.vehicle = JSON.stringify(vehicle);
        params.contactId = component.get('v.conId');
        server.callServer(
            action,
            params,
            false,
            $A.getCallback(function(response) {
                var result = JSON.parse(response);
                var vehicle = result.activeVech;
                component.set('v.vehicle',vehicle);
                if(vehicle.Run_Hours__c && result.confirmMsg == 'Success'){
                    //alert(state);
                    helper.closeoapuModal(component, event, helper);
                    helper.saveVehiclehelper(component, event, helper,false,false);
                    component.set('v.stage','2');  
                    var urPartsBomList  = component.get('v.urPartsList');
                    if(urPartsBomList && urPartsBomList.length >0 && !(vehicle.Parts_Used_List__c) ){
                        helper.openURModal(component,event,helper);
                    }
                }else{
                    component.set('v.TestAgainError',true);
                }
                component.set('v.isLoading',false);
            }),
            $A.getCallback(function(error) { 
                helper.showToast(component,event,helper,'error',error,10000);
                component.set('v.isLoading',false);
            }),
            false, 
            false,
            false,
            false
        );

    },
    getBOMDetails : function(component,event,helper){
        var action = component.get('c.getBillOfMaterials');
        const server = component.find('server');
        var params = {};
        params.vehicle = JSON.stringify(component.get('v.vehicle'));
        server.callServer(
            action,
            params,
            false,
            $A.getCallback(function(response) {
                var result = JSON.parse(response);
                component.set('v.parentBom',result);
                component.set('v.bomModal',true);
                component.set('v.isLoading',false);
            }),
            $A.getCallback(function(error) { 
                helper.showToast(component,event,helper,'error',error,10000);
                component.set('v.isLoading',false);
            }),
            false, 
            false,
            false,
            false
        );

    },
    saveBOMfunction : function(component,event,helper){
        var action = component.get('c.saveBillOfMaterial');
        const server = component.find('server');
        var params = {};
        params.parentBomStr = JSON.stringify(component.get('v.parentBom'));
        params.vehicle = JSON.stringify(component.get('v.vehicle'));
        server.callServer(
            action,
            params,
            false,
            $A.getCallback(function(response) {
                var result = JSON.parse(response);
                component.set('v.bomModal',false);
                component.set('v.parentBom',result);
                component.set('v.isLoading',false);
            }),
            $A.getCallback(function(error) { 
                helper.showToast(component,event,helper,'error',error,10000);
                component.set('v.isLoading',false);
            }),
            false, 
            false,
            false,
            false
        );
    },
    showToast : function(component,event, helper,type,message,delay) {
        //var toastCmp = component.find('toast');
        //toastCmp.showToast(type,message,delay);
        component.find('server').displayToast(type,message , type, 'sticky');
    },
    EnterPartsUsed: function(component, event, helper){
        component.set('v.isLoading',true);
        window.setTimeout(
            $A.getCallback(function() {
                helper.getBOMDetails(component, event, helper);
            }), 6000
        );
    },
    setDSNValue : function(component, event, helper){
        var vehicle = component.get("v.vehicle");
        if(vehicle.DSNSerial__c){
            var DeviceSerialNumber = component.find("DeviceSerialNumber");
            var NewDeviceSerialNumber = component.find("NewDeviceSerialNumber");
            
            console.log('DeviceSerialNumber:::',DeviceSerialNumber);
            if(DeviceSerialNumber != undefined){
                component.find("DeviceSerialNumber").set('v.value',vehicle.DSNSerial__c);
            }
            if(NewDeviceSerialNumber != undefined){
                component.find("NewDeviceSerialNumber").set('v.value',vehicle.DSNSerial__c);
            }
        }
        if(vehicle.Removed_Device_Serial_Number__c){
            var required = component.find('required');
            if(required){
                if(Array.isArray(required)){
                    for(var i=0;i<required.length;i++){
                        var fieldName = required[i].get("v.name");
                        console.log('required[i]:::',required[i]);
                        if(fieldName == 'RDeviceSerialNumber'){
                            required[i].set("v.value",vehicle.Removed_Device_Serial_Number__c);
                            break;
                        }
                    }
                }else{
                    var fieldName = required.get("v.name");
                    if(fieldName == 'RDeviceSerialNumber'){
                        required.set("v.value",vehicle.Removed_Device_Serial_Number__c);
                    }
                }
            }
        }
        
    },
    changeHandler : function(cmp, event, helper,name){
        if(name == 'NewDeviceSerialNumber'){
            cmp.get('v.vehicle')['DSNSerial__c'] = cmp.find("NewDeviceSerialNumber").get('v.value');
        }else if(name == 'DeviceSerialNumber'){
            cmp.get('v.vehicle')['DSNSerial__c'] = cmp.find("DeviceSerialNumber").get('v.value');
        }else if(name == 'RDeviceSerialNumber'){
            var required = cmp.find('required');
            if(required){
                if(Array.isArray(required)){
                    for(var i=0;i<required.length;i++){
                        var fieldName = required[i].get("v.name");
                        if(fieldName == 'RDeviceSerialNumber'){
                            cmp.get('v.vehicle')['Removed_Device_Serial_Number__c'] = required[i].get("v.value");
                            break;
                        }
                    }
                }else{
                    var fieldName = required.get("v.name");
                    if(fieldName == 'RDeviceSerialNumber'){
                        cmp.get('v.vehicle')['Removed_Device_Serial_Number__c'] = required.get("v.value");
                    }
                }
            }
            //cmp.get('v.vehicle')['Removed_Device_Serial_Number__c'] = cmp.find("DeviceSerialNumber").get('v.value');
        }
        var record = cmp.get('v.vehicle');
        cmp.set('v.vehicle',record);
    }
})