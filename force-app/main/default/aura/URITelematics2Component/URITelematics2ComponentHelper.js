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
    },
    getParameterByName: function(cmp, event, name) {
        
        name = name.replace(/[\[\]]/g, "\\$&");
        var url = window.location.href;
        var regex = new RegExp("[?&]" + name + "(=([^&#]*)|&|#|$)");
        var results = regex.exec(url);
        if (!results) return null;
        if (!results[2]) return '';
        return decodeURIComponent(results[2].replace(/\+/g, " "));
    },
	saveVehiclehelper : function(component, event, helper,isBack,isCompleted) {
        var vehicle = component.get('v.vehicle');
        var action = component.get('c.saveVehicle');
        action.setParams({
            "vehicleStr":JSON.stringify(vehicle),
            "isCompleted":isCompleted
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log(state);
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                console.log(result);
                component.set('v.vehicle',JSON.parse(result));
                if(isBack){
                    component.find('showToastcmp').showToastAuraMethod('success', 'Service Updated Successfully.', 10000);
                    this.BackToURLnesDeploymentSearch(component,event,helper);
                }
            }
        });
        $A.enqueueAction(action);
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
                }else if(DeviceSerialNumber.startsWith ('3') ){
                    if(DeviceSerialNumber.length != 7){
                        DSN.setCustomValidity("Device Serial Number should be 7 characters long");
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
        action.setParams({
            "vehicleStr":JSON.stringify(vehicle)
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log(state);
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                console.log(':::re::',result);
                component.set('v.vehicle',JSON.parse(result));
                //component.set('v.stage','2');
                helper.activateTelematicsFunc(component, event, helper);
                //component.set('v.isLoading',false);
            }
        });
        $A.enqueueAction(action);
    },
    BackToURLnesDeploymentSearch : function(component,event,helper){
        window.history.back();
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
        action.setParams({
            "vechString":JSON.stringify(vehicle),
            "contactId":component.get('v.conId'),
            "zscpPackageId":component.get('v.zscp'),
            "assetMasterStr":JSON.stringify(assetMaster),
            "controllerType":controllerType
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log(state);
            if(state === 'SUCCESS'){
                
                console.log(response.getReturnValue());
                var result= JSON.parse(response.getReturnValue());
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
                }/*else if(confirmMsg == 'unable to sync' && vehicle.Service_Notes__c && vehicle.Service_Notes__c.toLowerCase().includes('unable to sync')){
                	component.set('v.stage','2'); 
                    component.set("v.isLoading",false);
                }*/else{
                    var toastcom = component.find('showToastcmp').showToastAuraMethod('error', confirmMsg, 10000);
                	component.set("v.isLoading",false);
                }
                
                /*var gotoDeInstall = result.gotoDeInstall; 
                
                var gotoDeInstallForRunHr = result.gotoDeInstallFroRunHr; */
                }
            });
        $A.enqueueAction(action);
        
        
    },
    testDeviceFunc: function(component, event, helper){
        var vehicle = component.get('v.vehicle');
        //component.set("v.isLoading",true);
        var action = component.get('c.testDevice');
        
        action.setParams({
            "vechString":JSON.stringify(vehicle),
            "contactId":component.get('v.conId')
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log(state);
            if(state === 'SUCCESS'){
                console.log(response.getReturnValue());
                var result= JSON.parse(response.getReturnValue());
                if(result){
                    var vehicle = result.activeVech;
                    console.log('vehicle');
                    component.set('v.vehicle',vehicle);
                    var confirmMsg = result.confirmMsg;
                    //confirmMsg = 'Run Hour True';
                    /*var gotoDeInstall = result.gotoDeInstall;                     
                    var gotoDeInstallFroRunHr = result.gotoDeInstallFroRunHr;*/
                    
                    if(confirmMsg == 'Communicated False'){
                        component.set("v.isLoading",false);
                        var modalContent = 'The device is not communicating. Please run the Equipment again for 1-5 minutes, power off, and select "Test Again".  If the issue persists, please select "Deinstall Device".';
                        component.set('v.modalContent',modalContent);
                        component.set('v.confirmMsg',confirmMsg);
                        this.openModal(component,event,helper);
                    }else if(confirmMsg == 'Run Hour True'){
                        this.call1537RunHrsTrue(component,event,helper,result.activeVech);
                        /*var modalContent = 'The Device is functioning as expected.'
                        component.set('v.modalContent',modalContent);
                        component.set('v.confirmMsg',confirmMsg);
                        this.openModal(component,event,helper);*/
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
                
            }
        });
        $A.enqueueAction(action);
    },
    call1537RunHrsTrue : function(component,event,helper,Vehicle){
        var action = component.get('c.call1537');
        action.setParams({
            "Vehicle":JSON.stringify(Vehicle)
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log(state);
            if(state === 'SUCCESS'){
                console.log('call1537',response.getReturnValue());
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
            }
        });
        $A.enqueueAction(action);
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
        
        action.setParams({
            "vechString":JSON.stringify(vehicle),
            "contactId":component.get('v.conId')
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log(state);
            if(state === 'SUCCESS'){
                console.log(response.getReturnValue());
                var result= JSON.parse(response.getReturnValue());
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
                
            }
        });
        $A.enqueueAction(action);
    },
    updateVehicleWithDSN : function(component, event, helper) {
		var vehicle = component.get('v.vehicle');
        var action = component.get('c.replaceDSN');
        action.setParams({
            "vehicleStr":JSON.stringify(vehicle),
            "attachmentName":'Device Serial Number'
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log(state);
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                console.log(result);
                component.set('v.vehicle',JSON.parse(result));
                helper.activateTelematicsFunc(component, event, helper);
            }
        });
        $A.enqueueAction(action);
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
        action.setParams({
            "vehicle":JSON.stringify(component.get('v.vehicle')),
            "contactId":component.get('v.conId')
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            console.log(state);
            if(state === 'SUCCESS'){
                var result = response.getReturnValue();
                component.set('v.vehicle',JSON.parse(result));
                //---helper.closeoapuModal(component,event,helper);
                component.set('v.packageUpdate',true);
                helper.saveVehiclehelper(component, event, helper,false,false);
                
                component.set('v.stage','2'); 
                var urPartsBomList  = component.get('v.urPartsList');
                if(urPartsBomList && urPartsBomList.length >0 && !(vehicle.Parts_Used_List__c) ){
                    helper.openURModal(component,event,helper);
                }else if(vehicle.Parts_Used_List__c){
                    helper.EnterPartsUsed(component,event,helper);
                }
            }else{
                var msg = response.getError()[0].message;
                component.find('showToastcmp').showToastAuraMethod('error',msg , 10000);
            }
            component.set('v.isLoading',false);
        });
        $A.enqueueAction(action);
    },
    callTestAgain: function(component,event,helper){
        component.set('v.isLoading',true);
        var action = component.get('c.newTestAgain');
        var vehicle = component.get('v.vehicle');
        console.log('vehicle::::',JSON.stringify(vehicle));
        console.log(vehicle.Id);
        action.setParams({
            "vehicle":JSON.stringify(vehicle),
            "contactId":component.get('v.conId')
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            
            if(state === 'SUCCESS'){
                var result = JSON.parse(response.getReturnValue());
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
                    //alert('"Over-the-Air Package Update" is NOT complete, please continue to run the Equipment and "Test" again later. ');
                }
            }else{
                
                var msg = response.getError()[0].message;
                component.find('showToastcmp').showToastAuraMethod('error',msg , 10000);
            }
            component.set('v.isLoading',false);
        });
        $A.enqueueAction(action);
    },
    getBOMDetails : function(component,event,helper){
       // setTimeout(function() {
            console.log('hai');
            var action = component.get('c.getBillOfMaterials');
            action.setParams({
                vehicle: JSON.stringify(component.get('v.vehicle'))
            });
            action.setCallback(this,function(response){
                var state = response.getState();
                console.log(state);
                if(state == 'SUCCESS'){
                    var result = JSON.parse(response.getReturnValue());
                    console.log('result',result);
                    component.set('v.parentBom',result);
                    component.set('v.bomModal',true);
                }else{
                    var error = response.getError();
                    var message = '';
                    if(Array.isArray(error) && error.length>0){
                        message = error[0].message;
                    }else{
                        message = error.message;
                    }
                    helper.showToast(component,event,helper,'error',message,10000);
                }
                component.set('v.isLoading',false);
            });
            $A.enqueueAction(action);            
        //}, 4000);
        
    },
    saveBOMfunction : function(component,event,helper){
        var action = component.get('c.saveBillOfMaterial');
        action.setParams({
            parentBomStr: JSON.stringify(component.get('v.parentBom')),
            vehicle : JSON.stringify(component.get('v.vehicle'))
        });
        action.setCallback(this,function(response){
            var state = response.getState();
            if(state == 'SUCCESS'){
                var result = JSON.parse(response.getReturnValue());
                component.set('v.bomModal',false);
                component.set('v.parentBom',result);
            }else{
                var error = response.getError();
                var message = '';
                if(Array.isArray(error) && error.length>0){
                    message = error[0].message;
                }else{
                    message = error.message;
                }
                helper.showToast(component,event,helper,'error',message,10000);
            }
            component.set('v.isLoading',false);
        });
        $A.enqueueAction(action);
    },
    showToast : function(component,event, helper,type,message,delay) {
        var toastCmp = component.find('toast');
        toastCmp.showToast(type,message,delay);
    },
    EnterPartsUsed: function(component, event, helper){
        component.set('v.isLoading',true);
        window.setTimeout(
            $A.getCallback(function() {
                helper.getBOMDetails(component, event, helper);
            }), 6000
        );
    },
})