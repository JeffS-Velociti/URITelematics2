@isTest
public class URITelematics2ComponentControllerTest {
 
    @testSetup static void setup(){ 
        String acRecId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Corporate').getRecordTypeId();
        Id conRcdType = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Xpress Partner').getRecordTypeId();
        Id vehRecId = Schema.SObjectType.Vehicles__c.getRecordTypeInfosByName().get('Health United Rentals').getRecordTypeId();
        String woRecId = DB_Util.getRecordTypeId('PNET', 'SFDC_Work_Orders__c' ); 
        
        Resorces rs = new Resorces();
        List<Account> testAcc = rs.createAccounts(1); 
        testAcc[0].Active__c = true;
        testAcc[0].RecordTypeId = acRecId;
        insert testAcc; 
        system.debug('AccountQuery::'+[SELECT Id, Active__c FROM Account]);
        system.debug('vehRecId:::'+vehRecId);
        
        Contact[] conList = new Contact[]{
            new Contact(firstName = 'test1',LastName='con1',AccountId=testAcc[0].Id,Status__c = 'Active',RecordTypeId = conRcdType,Tech_Type__c = 'Networking', Email='tests@gmail.com'),
            new contact(firstName = 'test2',LastName='con2',AccountId=testAcc[0].Id,Status__c = 'Active',RecordTypeId = conRcdType ,Tech_Type__c = 'Networking', Email='test@gmail.com')
        };
        insert conList ;
        List<Contact> consList = [SELECT RecordTypeId,Name, Status__c,SCMC__Active__c FROM Contact];
        system.debug('contactQuery::'+consList);
        
        Fleet_Maintenance__c FM = new Fleet_Maintenance__c();
        FM.Name = 'TestFleet';
        FM.OwnerId = userinfo.getUserId();
        FM.Kit__c = 'test';
        FM.Vehicle_Type__c = 'tEST';
        insert FM;
        
        List<Opportunity> oppList = new List<Opportunity>( rs.createOpportunities(1,testAcc[0].id) );
        oppList[0].CloseDate = system.today();
        oppList[0].StageName = 'Prospecting';
        oppList[0].Quote_Validity__c = System.today();
        insert oppList;
        
        List<velocitiProject__c> velProjList = new List<velocitiProject__c>(rs.createveloProjects(2,oppList[0].id));
        insert velProjList;
        List<SFDC_Work_Orders__c> woList = new List<SFDC_Work_Orders__c>(rs.createWorkOrder(5,woRecId,velProjList[0].id));
        insert woList;
        
        SCMC__Currency_Master__c [] cur = new SCMC__Currency_Master__c[]{
           new SCMC__Currency_Master__c(Name = 'USD',SCMC__Number_of_decimals__c = 2.0)
        };
        insert cur ;
        
        SCMC__Sales_Order__c[] salesorder = new SCMC__Sales_Order__c[]{
          new SCMC__Sales_Order__c(SCMC__Currency__c = cur[0].Id  ,SCMC__Customer_Account__c = testAcc[0] .Id,SCMC__Sales_Order_Date__c = System.today()+3,Work_Order__c = woList[0].Id,SCMC__Confirm_To__c = consList[0].Name)
        };  
        salesorder[0].SCMC__Drop_Ship_City__c = 'Test';
        salesorder[0].SCMC__Drop_Ship_Line1__c  = 'Test';
        salesorder[0].SCMC__Drop_Ship_State_Province__c  = 'Test';
        salesorder[0].SCMC__Drop_Ship_Zip_Postal_Code__c  = 'Test';
        insert salesorder ;
        
        /*SCMC__Item__c[]  ItemMas = new SCMC__Item__c[]{
           new SCMC__Item__c(Name = 'test1',SCMC__Item_Description__c = 'testing testing testing',SCMC__ABC_Classification__c = 'Other',SCMC__Acquisition__c = 'Purchase' )
        };
        
        insert ItemMas ;
        
        SCMC__Sales_Order_Line_Item__c[] salesLine = new SCMC__Sales_Order_Line_Item__c[]{
            new SCMC__Sales_Order_Line_Item__c(SCMC__Sales_Order__c = salesorder[0].Id,SCMC__Quantity__c = 1,SCMC__Price__c = 500 )//,SCMC__Item_Master__c = ItemMas[0].Id
        };
        
        insert salesLine ;*/
        
        List<Vehicles__c> serviceList = TestDataFactory.createServices(3, true);
        serviceList[0].RecordTypeId = vehRecId;
        serviceList[0].Scheduling_Coordinator__c = 'testee@gmail.com';
        serviceList[1].Scheduling_Coordinator__c = 'testee@gmail.com';
        serviceList[2].Scheduling_Coordinator__c = 'testee@gmail.com';
        serviceList[0].Name = 'TestService1';
        serviceList[0].Service_Type__c = 'Repair';
        serviceList[0].Power_On__c = 'Yes';
        serviceList[0].Ext_Harness__c = 'True';
        serviceList[0].DSNSerial__c = '455890';
        serviceList[0].Technician__c = conList[0].Id;
        serviceList[0].Velociti_Inventory__c = 'Yes';
        serviceList[0].Confirmation_Number__c = '890890';
        //serviceList[0].Device_Type__c = 'Android';
        serviceList[0].Fleet_Maintenance__c = FM.Id;
        
        serviceList[0].Communicated__c = system.now();
        serviceList[1].RecordTypeId = vehRecId;
        serviceList[1].Name = 'TestService2';
        serviceList[1].Service_Type__c = 'Smart Control';
        serviceList[1].Power_On__c = 'Yes';
        serviceList[1].Ext_Harness__c = 'True';
        serviceList[1].DSNSerial__c = '455890';
        serviceList[1].Technician__c = conList[0].Id;
        serviceList[1].Velociti_Inventory__c = 'No';
        serviceList[1].Confirmation_Number__c = '890890';
       // serviceList[1].Device_Type__c = 'Android';
        serviceList[1].Fleet_Maintenance__c = FM.Id;
        serviceList[1].CID__c = '1234';
        serviceList[1].Legacy_Serial_Number__c = '45890';
        serviceList[2].RecordTypeId = vehRecId;
        serviceList[2].Name = 'TestService3';
        serviceList[2].Service_Type__c = 'Telematics Repair';
        serviceList[2].DSNSerial__c = '455890';
        serviceList[2].Technician__c = conList[0].Id;
        serviceList[2].Velociti_Inventory__c = 'Yes';
        //serviceList[2].Device_Type__c = 'Android';
        serviceList[2].Fleet_Maintenance__c = FM.Id;
        serviceList[2].Communicated__c = system.now();
        serviceList[2].Confirmation_Number__c = '890890';
        serviceList[2].Last_Modified_By_Sites_User__c = consList[0].Id;
        serviceList[0].Equip_Category__c = 'M8';
        serviceList[1].Equip_Category__c = 'M8';
        serviceList[2].Equip_Category__c = 'M8';
        serviceList[0].CID__c = '1234';
        serviceList[2].CID__c = '1234';
        serviceList[0].Device_Type__c = 'ZTR';
        serviceList[1].Device_Type__c = 'ZTR';
        serviceList[2].Device_Type__c = 'ZTR';
        Update serviceList;
        Test.startTest();
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c, Make_Formula__c,Fleet_Maintenance__c,RecordTypeId,DSNSerial__c FROM Vehicles__c];
        system.debug('vehList'+vehList);
        Attachment att = new Attachment();
        att.Name = 'Device_Serial_Number';
        att.Body = Blob.valueOf('Test Attachment');
        att.ParentId = vehList[0].Id;
        insert att;
        
        Attachment att2 = new Attachment();
        att2.Name = 'Device_Serial_Number';
        att2.Body = Blob.valueOf('Test Attachment');
        att2.ParentId = vehList[1].Id;
        insert att2;
        
        Attachment att1 = new Attachment();
        att1.Name = 'Device_Serial_Number';
        att1.Body = Blob.valueOf('Test Attachment');
        att1.ParentId = vehList[2].Id;
        insert att1;
        
        
        Id woRecordtypeId = Schema.SObjectType.SFDC_Work_Orders__c.getRecordTypeInfosByName().get('Transportation').getRecordTypeId();
        List<SFDC_Work_Orders__c> WorkOrdersList = TestDataFactory.createWorkOrder(3,woRecordtypeId,true);
        
        List<Equipment__c> equipmentList = new List<Equipment__c>();
        Equipment__c equ1 = new Equipment__c();
        equ1.Name = 'TestService1';
        equ1.Installed_SN__c = '43456';
        equ1.Part_number__c = 'Test';
        equ1.Work_Order__c = WorkOrdersList[0].Id;
        equipmentList.add(equ1);
        Equipment__c equ2 = new Equipment__c();
        equ2.Name = 'TestService2';
        equ2.Installed_SN__c = '84061';
        equ2.Part_number__c = 'Test0';
        equ2.Work_Order__c = WorkOrdersList[1].Id;
        equipmentList.add(equ2);
        Equipment__c equ3 = new Equipment__c();
        equ3.Name = 'TestService3';
        equ3.Installed_SN__c = '34569';
        equ3.Part_number__c = 'Test1';
        equ3.Work_Order__c = WorkOrdersList[2].Id;
        equipmentList.add(equ3);
        insert equipmentList;
        
        SCMC__Ownership_Code__c ownerCode = new SCMC__Ownership_Code__c();
        ownerCode.Name = 'United Rentals';
        insert ownerCode;
        
        SCMC__Unit_of_Measure__c uom = new SCMC__Unit_of_Measure__c();
        uom.Name = 'Test';
        insert uom;
        
        SCMC__Item__c item = new SCMC__Item__c();
        item.SCMC__Stocking_UOM__c = uom.Id;
        item.Name = 'Test Item';
        item.SCMC__ABC_Classification__c = 'Other';
        item.SCMC__Acquisition__c = 'Make';
        item.SCMC__Item_Description__c = 'Test Descrition';
        insert item;
        
        SCMC__Sales_Order_Line_Item__c salesLine = new SCMC__Sales_Order_Line_Item__c();
        salesLine.SCMC__Sales_Order__c = salesorder[0].Id;
        salesLine.SCMC__Item_Master__c = item.Id;
        salesLine.SCMC__Quantity__c = 10;
        salesLine.SCMC__Customer_Current_Promise_Date__c = System.Today()+3;
        salesLine.SCMC__Price__c = 10;
        insert salesLine;
        
        Velociti_Settings__c veloSetting = new Velociti_Settings__c(R_S_N_Q_S__c='Test,test',LIT__c='test', ZTR_Package_Update_Email__c = 'test1@gmail.com,test2@gmail.com',ZTR__c = NULL, URITelematics_Sender__c = 'test@gmail.com',Salesorder_Customer_Account__c =testAcc[0].Id,Heroku_sobjectservice__c='https://velociti-endpoints.herokuapp.com/api/sobjectservice' );
        insert veloSetting;
        UR_ZTR_Location_Setting__c urSetting = new UR_ZTR_Location_Setting__c(Name='M8', Location_Id__c='234567890123');
        //insert urSetting;
        
       SCMC__Serial_Number__c[]  serial = new SCMC__Serial_Number__c[]{
            new SCMC__Serial_Number__c(Vehicle_Number__c = vehList [2].Id,SCMC__Serial_Number__c = '455890',Status__c = 'Installed')//SCMC__Sales_Order_Line_Item__c = salesLine [0].Id,
                ,new SCMC__Serial_Number__c(Vehicle_Number__c = vehList [0].Id,SCMC__Serial_Number__c = '455890',Status__c = 'Installed',SCMC__Ownership_Code__c = ownerCode.Id, SCMC__Sales_Order_Line_Item__c = salesLine.Id)
       };
       Insert serial;
       List<SCMC__Serial_Number__c> serialNumberList = [SELECT SCMC__Serial_Number__c,Vehicle_Number__c, Status__c, Ownership_Code_Name__c,SCMC__Sales_Order_Line_Item__c FROM SCMC__Serial_Number__c ];
      system.debug('serialNumberList'+serialNumberList);
        SCMC__Item__c[]  ItemMas = new SCMC__Item__c[]{
            new SCMC__Item__c(Name = 'test1',SCMC__Item_Description__c = 'testing testing testing',SCMC__ABC_Classification__c = 'Other',SCMC__Acquisition__c = 'Purchase' ),
            new SCMC__Item__c(Name = 'test2',SCMC__Item_Description__c = 'testing testing testing',SCMC__ABC_Classification__c = 'Other',SCMC__Acquisition__c = 'Purchase') 
        };
        
        insert ItemMas ;
        
        SCMC__Bill_of_Material__c bom = new SCMC__Bill_of_Material__c();
        bom.SCMC__Item__c = ItemMas[1].Id;
        bom.Price__c = 1000;
        insert bom;
        
        List<SCMC__Bill_of_Material__c> bomList = new List<SCMC__Bill_of_Material__c>();
        SCMC__Bill_of_Material__c bom1 = new SCMC__Bill_of_Material__c();
        bom1.SCMC__Parent__c = bom.Id;
        bom1.SCMC__Item__c = ItemMas[1].Id;
        bom1.Price__c = 1000;
        bomList.add(bom1);
        SCMC__Bill_of_Material__c bom2 = new SCMC__Bill_of_Material__c();
        bom2.SCMC__Parent__c = bom.Id;
        bom2.SCMC__Item__c = ItemMas[0].Id;
        bom2.Price__c = 500;
        bomList.add(bom2);
        insert bomList;
       Test.stopTest();
    } 
    
    @isTest static void URITestMethod1(){
        
        Test.setMock(WebServiceMock.class, new MetadataServiceTest.WebServiceMockImpl());       
        List<Contact> conList = [SELECT Id FROM Contact];
        Cookie secretKey = new Cookie('secretKey',conList[0].Id,null,28800,false);
        ApexPages.currentPage().setCookies(new Cookie[]{secretKey});
        system.debug('Cookie Value'+ApexPages.currentPage().getCookies().get('secretKey'));
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c, Make_Formula__c,Fleet_Maintenance__c,RecordTypeId FROM Vehicles__c];
        
       
        URITelematics2ComponentController URIClass = new URITelematics2ComponentController();
        
        try{
            URITelematics2ComponentController.getVehicle(vehList[0].Id);
        }catch(Exception e){
            
        }
            
            //URITelematics2ComponentController.getVehicle(vehList[2].Id);
         
        
         Test.startTest();
        Test.setMock(HttpCalloutMock.class, new InstallationAppDmlUtilMock());
        URITelematics2ComponentController.saveVehicle(JSON.serialize(vehList[0]),true);
        URITelematics2ComponentController.checkSerialNumber(JSON.serialize(vehList[0]));
        vehList[0].Legacy_Serial_Number__c = '455891';
        URITelematics2ComponentController.replaceDSN(JSON.serialize(vehList[0]),'Test Service');
        Test.stopTest();
    }
    
    @isTest static void URITestMethod200MOCK1(){ 
        
        List<Contact> conList = [SELECT Id FROM Contact];
        Cookie secretKey = new Cookie('secretKey',conList[0].Id,null,28800,false);
        ApexPages.currentPage().setCookies(new Cookie[]{secretKey});
        system.debug('Cookie Value'+ApexPages.currentPage().getCookies().get('secretKey'));
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c,Device_Type__c, Make_Formula__c,Fleet_Maintenance__c,RecordTypeId,DSNSerial__c,Name FROM Vehicles__c];
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics200Mock());
        Test.startTest();
        String accessToken = URITelematics2ComponentController.getAccessToken();
        URITelematics2ComponentController URIClass = new URITelematics2ComponentController();
        
        URITelematics2ComponentController.isMarriageMethod();
        URITelematics2ComponentController.DeinstallDevice(JSON.serialize(vehList[0]), conList[0].Id);
        URITelematics2ComponentController.overtheAirPackageUpdate(JSON.serialize(vehList[0]), conList[0].Id);
        
        URIClass.logout();
        Test.stopTest();
    }
    @isTest static void URITestMethod200MOCK2(){
        
        List<Contact> conList = [SELECT Id FROM Contact];
        Cookie secretKey = new Cookie('secretKey',conList[0].Id,null,28800,false);
        ApexPages.currentPage().setCookies(new Cookie[]{secretKey});
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c,Device_Type__c, Make_Formula__c,Fleet_Maintenance__c,RecordTypeId,DSNSerial__c,Name FROM Vehicles__c];
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics200Mock());
        Test.startTest();
        //String accessToken = URITelematics2ComponentController.getAccessToken();
        URITelematics2ComponentController URIClass = new URITelematics2ComponentController();
        vehList[0].CID__c = '1231323';
        vehList[0].Communicated__c = system.Now();
        vehList[0].Run_Hours__c = '2';
        vehList[0].Device_Type__c = 'ZTR';
        vehList[0].Confirmation_Number__c = '12324';
        URITelematics2ComponentController.testDevice(JSON.serialize(vehList[0]), conList[0].Id);
        
        Test.stopTest();
    }
    @isTest static void URITestMethod200MOCK2a(){
        
        List<Contact> conList = [SELECT Id FROM Contact];
        Cookie secretKey = new Cookie('secretKey',conList[0].Id,null,28800,false);
        ApexPages.currentPage().setCookies(new Cookie[]{secretKey});
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Device_Type__c,Model_Formula__c, Make_Formula__c,Fleet_Maintenance__c,RecordTypeId,DSNSerial__c,Name FROM Vehicles__c];
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics200Mock());
        Test.startTest();
        //String accessToken = URITelematics2ComponentController.getAccessToken();
        URITelematics2ComponentController URIClass = new URITelematics2ComponentController();
        vehList[0].Confirmation_Number__c = '1231323';
        vehList[0].CID__c = '1231323';
        vehList[0].Communicated__c = system.Now();
        vehList[0].Run_Hours__c = '2';
        vehList[0].Device_Type__c = 'TrackUnit';
        vehList[0].Confirmation_Number__c = '12324';
        URITelematics2ComponentController.testDevice(JSON.serialize(vehList[0]), conList[0].Id);
        
        Test.stopTest();
    }
    @isTest static void URITestMethod200MOCK3(){
        
        List<Contact> conList = [SELECT Id FROM Contact];
        Fleet_Maintenance__c fleet = [SELECT ID,Controller_Type__c from Fleet_Maintenance__c limit 1];
        Cookie secretKey = new Cookie('secretKey',conList[0].Id,null,28800,false);
        ApexPages.currentPage().setCookies(new Cookie[]{secretKey});
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c,Device_Type__c, Make_Formula__c,Fleet_Maintenance__c,RecordTypeId,DSNSerial__c,Name FROM Vehicles__c];      
        
        //String accessToken = URITelematics2ComponentController.getAccessToken();
        URITelematics2ComponentController URIClass = new URITelematics2ComponentController();
        vehList[0].Device_Type__c = 'ZTR';
        Test.StartTest();
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics200Mock());
        URITelematics2ComponentController.newTestAgain(JSON.serialize(vehList[0]), conList[0].Id);
        Test.StopTest();
        
    }
    @isTest static void URITestMethod200MOCK4(){
        
        List<Contact> conList = [SELECT Id FROM Contact];
        Cookie secretKey = new Cookie('secretKey',conList[0].Id,null,28800,false);
        ApexPages.currentPage().setCookies(new Cookie[]{secretKey});
        system.debug('Cookie Value'+ApexPages.currentPage().getCookies().get('secretKey'));
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c, Make_Formula__c,Fleet_Maintenance__c,RecordTypeId,DSNSerial__c,Service_Notes__c,Name FROM Vehicles__c];
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics200Mock());
        Test.startTest();
        Fleet_Maintenance__c fleet = [SELECT ID,Controller_Type__c from Fleet_Maintenance__c limit 1];
        URITelematics2ComponentController.vechWrapperForActivateTelematics vechWrapper = new URITelematics2ComponentController.vechWrapperForActivateTelematics();
        vechWrapper.activeVech = vehList[0];
        vechWrapper.gotoDeInstall = true;
        vechWrapper.gotoDeInstallFroRunHr = true;
        URITelematics2ComponentController.vech = vehList[0];
        URITelematics2ComponentController.assetmaster = fleet;
        String accessToken = URITelematics2ComponentController.getAccessToken();
        URITelematics2ComponentController.getInstallationIdByName(vehList[0].Name, accessToken, vechWrapper,'');     
        
        Test.stopTest();
    }
    @isTest static void URITestMethod200MOCK4a(){
        
        List<Contact> conList = [SELECT Id FROM Contact];
        Cookie secretKey = new Cookie('secretKey',conList[0].Id,null,28800,false);
        ApexPages.currentPage().setCookies(new Cookie[]{secretKey});
        system.debug('Cookie Value'+ApexPages.currentPage().getCookies().get('secretKey'));
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c, Make_Formula__c,Fleet_Maintenance__c,RecordTypeId,DSNSerial__c,Service_Notes__c,Name FROM Vehicles__c];
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics200Mocka());
        Test.startTest();
        
        URITelematics2ComponentController.vechWrapperForActivateTelematics vechWrapper = new URITelematics2ComponentController.vechWrapperForActivateTelematics();
        vechWrapper.activeVech = vehList[0];
        vechWrapper.gotoDeInstall = true;
        vechWrapper.gotoDeInstallFroRunHr = true;
        URITelematics2ComponentController.vech = vehList[0];
        Fleet_Maintenance__c fleet = [SELECT ID,Controller_Type__c from Fleet_Maintenance__c limit 1];
        URITelematics2ComponentController.assetmaster = fleet;
        String accessToken = URITelematics2ComponentController.getAccessToken();
        URITelematics2ComponentController.getInstallationIdByName(vehList[0].Name, accessToken, vechWrapper,'');
        //URITelematics2ComponentController.installationPostMethod(vehList[0].DSNSerial__c, vechWrapper);
        
        Test.stopTest();
    }
    
    @isTest static void URITestMethod200MOCK5(){
        
        List<Contact> conList = [SELECT Id FROM Contact];
        Cookie secretKey = new Cookie('secretKey',conList[0].Id,null,28800,false);
        ApexPages.currentPage().setCookies(new Cookie[]{secretKey});
        system.debug('Cookie Value'+ApexPages.currentPage().getCookies().get('secretKey'));
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c, Make_Formula__c, Fleet_Maintenance__c,Equip_Category__c,Service_Notes__c,Confirmation_Number__c,RecordTypeId,DSNSerial__c,Name,Fleet_Maintenance__r.Class__c, Fleet_Maintenance__r.Category__c ,Fleet_Maintenance__r.Equip_VIN__c,Service_Type__c,Unit_Number__c,Customer_ID__c FROM Vehicles__c];
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics200Mock());
        Test.startTest();
        
        URITelematics2ComponentController.vechWrapperForActivateTelematics vechWrapper = new URITelematics2ComponentController.vechWrapperForActivateTelematics();
        vechWrapper.activeVech = vehList[0];
        URITelematics2ComponentController.vech = vehList[0];
        vechWrapper.gotoDeInstall = true;
        vechWrapper.gotoDeInstallFroRunHr = true;
        Fleet_Maintenance__c fleet = [SELECT ID,Controller_Type__c,Fuel_Module__c from Fleet_Maintenance__c limit 1];
        URITelematics2ComponentController.assetmaster = fleet;
        //URITelematics2ComponentController.getInstallationIdByName(vehList[0].Name, accessToken, vechWrapper);
        vehList[0].Service_Type__c = 'Smart Control';
        URITelematics2ComponentController.installationPostMethod(vehList[0].DSNSerial__c, vechWrapper,'',false);
        
        Test.stopTest();
    }
    @isTest static void URITestMethod429MOCK1(){
        
        List<Contact> conList = [SELECT Id FROM Contact];
        Cookie secretKey = new Cookie('secretKey',conList[0].Id,null,28800,false);
        ApexPages.currentPage().setCookies(new Cookie[]{secretKey});
        system.debug('Cookie Value'+ApexPages.currentPage().getCookies().get('secretKey'));
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c, Make_Formula__c,Fleet_Maintenance__c,RecordTypeId,DSNSerial__c,Name,Service_Type__c FROM Vehicles__c];
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics429Mock());
        Test.startTest();
        String accessToken = URITelematics2ComponentController.getAccessToken();
        URITelematics2ComponentController URIClass = new URITelematics2ComponentController();
        URITelematics2ComponentController.isMarriageMethod();
        vehList[0].Device_Type__c = 'TrackUnit';
        URITelematics2ComponentController.DeinstallDevice(JSON.serialize(vehList[0]), conList[0].Id);
        URIClass.logout();
        Test.stopTest();
    }
    @isTest static void URITestMethod429MOCK2(){
        
        List<Contact> conList = [SELECT Id FROM Contact];
        Cookie secretKey = new Cookie('secretKey',conList[0].Id,null,28800,false);
        ApexPages.currentPage().setCookies(new Cookie[]{secretKey});
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c,Device_Type__c, Make_Formula__c,Fleet_Maintenance__c,RecordTypeId,DSNSerial__c,Name,Service_Type__c FROM Vehicles__c];
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics429Mock());
        Test.startTest();
        //String accessToken = URITelematics2ComponentController.getAccessToken();
        URITelematics2ComponentController URIClass = new URITelematics2ComponentController();
        //vehList[0].Device_Type__c = 'TrackUnit';
        vehList[0].Confirmation_Number__c = '12324';
        vehList[0].Equip_Category__c = 'm6';
        URITelematics2ComponentController.testDevice(JSON.serialize(vehList[0]), conList[0].Id);
    
        Test.stopTest();
    }
    @isTest static void URITestMethod429MOCK3(){
        
        List<Contact> conList = [SELECT Id FROM Contact];
        Cookie secretKey = new Cookie('secretKey',conList[0].Id,null,28800,false);
        ApexPages.currentPage().setCookies(new Cookie[]{secretKey});
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Device_Type__c,Model_Formula__c, Make_Formula__c, Fleet_Maintenance__c,RecordTypeId,DSNSerial__c,Name FROM Vehicles__c];
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics429Mock());
        Test.startTest();
        //String accessToken = URITelematics2ComponentController.getAccessToken();
        URITelematics2ComponentController URIClass = new URITelematics2ComponentController();
        Fleet_Maintenance__c fleet = [SELECT ID,Controller_Type__c from Fleet_Maintenance__c limit 1];
        URITelematics2ComponentController.assetmaster = fleet;
        vehList[0].Device_Type__c = 'ZTR';
        URITelematics2ComponentController.activateTelematics(JSON.serialize(vehList[0]), conList[0].Id,'',JSON.serialize(fleet));
        Test.stopTest();
    }
    @isTest static void URITestMethod200MOCK3aa(){
        
        List<Contact> conList = [SELECT Id FROM Contact];
        Cookie secretKey = new Cookie('secretKey',conList[0].Id,null,28800,false);
        ApexPages.currentPage().setCookies(new Cookie[]{secretKey});
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Device_Type__c,Model_Formula__c, Make_Formula__c, Fleet_Maintenance__c,RecordTypeId,DSNSerial__c,Name FROM Vehicles__c];
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics200Mock());
        Test.startTest();
        //String accessToken = URITelematics2ComponentController.getAccessToken();
        URITelematics2ComponentController URIClass = new URITelematics2ComponentController();
        Fleet_Maintenance__c fleet = [SELECT ID,Controller_Type__c from Fleet_Maintenance__c limit 1];
        URITelematics2ComponentController.assetmaster = fleet;
        vehList[0].Device_Type__c = 'ZTR';
        URITelematics2ComponentController.activateTelematics(JSON.serialize(vehList[0]), conList[0].Id,'',JSON.serialize(fleet));
        Test.stopTest();
    }
    @isTest static void URITestMethod429MOCK4(){
        
        List<Contact> conList = [SELECT Id FROM Contact];
        Cookie secretKey = new Cookie('secretKey',conList[0].Id,null,28800,false);
        ApexPages.currentPage().setCookies(new Cookie[]{secretKey});
        system.debug('Cookie Value'+ApexPages.currentPage().getCookies().get('secretKey'));
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c, Make_Formula__c,Fleet_Maintenance__c,RecordTypeId,DSNSerial__c,Name FROM Vehicles__c];
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics429Mock());
        Test.startTest();
        
        URITelematics2ComponentController.vechWrapperForActivateTelematics vechWrapper = new URITelematics2ComponentController.vechWrapperForActivateTelematics();
        vechWrapper.activeVech = vehList[0];
        vechWrapper.gotoDeInstall = true;
        vechWrapper.gotoDeInstallFroRunHr = true;
        URITelematics2ComponentController.vech = vehList[0];
        Fleet_Maintenance__c fleet = [SELECT ID,Controller_Type__c from Fleet_Maintenance__c limit 1];
        URITelematics2ComponentController.assetmaster = fleet;
        String accessToken = URITelematics2ComponentController.getAccessToken();
        URITelematics2ComponentController.getInstallationIdByName(vehList[0].Name, accessToken, vechWrapper,'');
        URITelematics2ComponentController.testSync('testing','test');
        //URITelematics2ComponentController.installationPostMethod(vehList[0].DSNSerial__c, vechWrapper);
        
        Test.stopTest();
    }
    @isTest static void URITestMethod429MOCK5(){
        
        List<Contact> conList = [SELECT Id FROM Contact];
        Cookie secretKey = new Cookie('secretKey',conList[0].Id,null,28800,false);
        ApexPages.currentPage().setCookies(new Cookie[]{secretKey});
        system.debug('Cookie Value'+ApexPages.currentPage().getCookies().get('secretKey'));
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c, Make_Formula__c,Fleet_Maintenance__c,Equip_Category__c,Confirmation_Number__c,Service_Notes__c,RecordTypeId,DSNSerial__c,Name, Fleet_Maintenance__r.Class__c, Fleet_Maintenance__r.Category__c ,Fleet_Maintenance__r.Equip_VIN__c,Service_Type__c,Unit_Number__c,Customer_ID__c FROM Vehicles__c];
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics429Mock());
        Test.startTest();
        
        URITelematics2ComponentController.vechWrapperForActivateTelematics vechWrapper = new URITelematics2ComponentController.vechWrapperForActivateTelematics();
        vechWrapper.activeVech = vehList[0];
        URITelematics2ComponentController.vech = vehList[0];
        vechWrapper.gotoDeInstall = true;
        vechWrapper.gotoDeInstallFroRunHr = true;
        Fleet_Maintenance__c fleet = [SELECT ID,Controller_Type__c,Fuel_Module__c from Fleet_Maintenance__c limit 1];
        URITelematics2ComponentController.assetmaster = fleet;
        //URITelematics2ComponentController.getInstallationIdByName(vehList[0].Name, accessToken, vechWrapper);
        vehList[0].Service_Type__c = 'Smart Control';
        URITelematics2ComponentController.installationPostMethod(vehList[0].DSNSerial__c, vechWrapper,'',true);
        
        Test.stopTest();
    }
    @isTest static void URITestMethod429MOCK6(){
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics429Mock());
        
        test.startTest();
        URITelematics2ComponentController.isDeviceCommunicating('2423r35t545vc6y', '435363');
        
        Test.stopTest();
    }
    @isTest static void URITestMethod202MOCK6(){
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics202Mock());
        
        test.startTest();
        URITelematics2ComponentController.isDeviceCommunicating('2423r35t545vc6y', '435363');
        
        Test.stopTest();
    }
    @isTest static void URITestMethod429MOCK7(){
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics429Mock());
        
        test.startTest();
        URITelematics2ComponentController.getGPSLocation('2423r35t545vc6y');
        
        Test.stopTest();
    }
    @isTest static void URITestMethod429MOCK8(){
        //Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics429Mock());
        Contact con = [SELECT Id from Contact LIMIT 1];
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c, Make_Formula__c,Fleet_Maintenance__c,Equip_Category__c,Confirmation_Number__c,Service_Notes__c,RecordTypeId,DSNSerial__c,Name FROM Vehicles__c];
        
        URITelematics2ComponentController.vechWrapperForActivateTelematics wrap = new URITelematics2ComponentController.vechWrapperForActivateTelematics();
        wrap.activeVech = vehList[0];
        
        test.startTest();
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics429Mock());
        URITelematics2ComponentController.checkStatusCode('2423r35t545vc6y',new HttpResponse(),'string',con.Id,new URITelematics2ComponentController.vechWrapperForActivateTelematics());
        URITelematics2ComponentController.getEquipValues('2423r35t545vc6y');
        Test.stopTest();
    }
    
    @isTest static void URITestMethod429MOCK8a(){
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics200Mock());
        Contact con = [SELECT Id from Contact LIMIT 1];
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c, Make_Formula__c,Fleet_Maintenance__c,Equip_Category__c,Confirmation_Number__c,Service_Notes__c,RecordTypeId,DSNSerial__c,Name FROM Vehicles__c];
        test.startTest();
        URITelematics2ComponentController.saveService(JSON.serialize(vehList[0]));
        URITelematics2ComponentController.checkStatusCode('2423r35t545vc6y',new HttpResponse(),'string',con.Id,new URITelematics2ComponentController.vechWrapperForActivateTelematics());
        Test.stopTest();
    }
    @isTest static void URITestMethod429MOCK8aa(){
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics202Mock());
        Contact con = [SELECT Id from Contact LIMIT 1];
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c, Make_Formula__c,Fleet_Maintenance__c,Equip_Category__c,Confirmation_Number__c,Service_Notes__c,RecordTypeId,DSNSerial__c,Name FROM Vehicles__c];
        test.startTest();
        URITelematics2ComponentController.saveService(JSON.serialize(vehList[0]));
        URITelematics2ComponentController.checkStatusCode('2423r35t545vc6y',new HttpResponse(),'string',con.Id,new URITelematics2ComponentController.vechWrapperForActivateTelematics());
        Test.stopTest();
    }
    @isTest static void URITestMethod429MOCK9(){
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics429Mock());
        Contact con = [SELECT Id from Contact LIMIT 1];
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c, Make_Formula__c,Fleet_Maintenance__c,Equip_Category__c,Confirmation_Number__c,Service_Notes__c,RecordTypeId,DSNSerial__c,Name,Fleet_Maintenance__r.Equip_VIN__c,Fleet_Maintenance__r.Class__c,Fleet_Maintenance__r.Category__c FROM Vehicles__c];
        
        test.startTest();
        Fleet_Maintenance__c fleet = [SELECT ID,Controller_Type__c from Fleet_Maintenance__c limit 1];
        URITelematics2ComponentController.assetmaster = fleet;
        URITelematics2ComponentController.vech = vehList[0];
        URITelematics2ComponentController.callOut2('2423r35t545vc6y',new HttpResponse(),con.Id,new URITelematics2ComponentController.vechWrapperForActivateTelematics(),'');
        
        Test.stopTest();
    }
    
    @isTest static void URITestMethod429MOCK9a(){
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics429Mocka());
        Contact con = [SELECT Id from Contact LIMIT 1];
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c, Make_Formula__c,Fleet_Maintenance__c,Equip_Category__c,Confirmation_Number__c,Service_Notes__c,RecordTypeId,DSNSerial__c,Name,Fleet_Maintenance__r.Equip_VIN__c,Fleet_Maintenance__r.Class__c,Fleet_Maintenance__r.Category__c FROM Vehicles__c];
        
        test.startTest();
        URITelematics2ComponentController.vech = vehList[0];
        Fleet_Maintenance__c fleet = [SELECT ID,Controller_Type__c from Fleet_Maintenance__c limit 1];
        URITelematics2ComponentController.assetmaster = fleet;
        URITelematics2ComponentController.callOut2('2423r35t545vc6y',new HttpResponse(),con.Id,new URITelematics2ComponentController.vechWrapperForActivateTelematics(),'');
        
        Test.stopTest();
    }
    
    @isTest static void URITestMethod409MOCK1(){
        
        List<Contact> conList = [SELECT Id FROM Contact];
        Cookie secretKey = new Cookie('secretKey',conList[0].Id,null,28800,false);
        ApexPages.currentPage().setCookies(new Cookie[]{secretKey});
        system.debug('Cookie Value'+ApexPages.currentPage().getCookies().get('secretKey'));
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c,Device_Type__c, Make_Formula__c,Fleet_Maintenance__c,RecordTypeId,DSNSerial__c,Name FROM Vehicles__c];
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics409Mock());
        Test.startTest();
        String accessToken = URITelematics2ComponentController.getAccessToken();
        URITelematics2ComponentController URIClass = new URITelematics2ComponentController();
        URITelematics2ComponentController.isMarriageMethod();
        URITelematics2ComponentController.DeinstallDevice(JSON.serialize(vehList[0]), conList[0].Id);
        URIClass.logout();
        Test.stopTest();
    }
    @isTest static void URITestMethod409MOCK2(){
        
        List<Contact> conList = [SELECT Id FROM Contact];
        Cookie secretKey = new Cookie('secretKey',conList[0].Id,null,28800,false);
        ApexPages.currentPage().setCookies(new Cookie[]{secretKey});
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c, Device_Type__c,Make_Formula__c,Fleet_Maintenance__c,RecordTypeId,DSNSerial__c,Name FROM Vehicles__c];
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics409Mock());
        Test.startTest();
        //String accessToken = URITelematics2ComponentController.getAccessToken();
        URITelematics2ComponentController URIClass = new URITelematics2ComponentController();
        vehList[0].Confirmation_Number__c = '12324';
        vehList[0].Equip_Category__c = 'm6';
        URITelematics2ComponentController.testDevice(JSON.serialize(vehList[0]), conList[0].Id);
    
        Test.stopTest();
    }
    @isTest static void URITestMethod409MOCK3(){
        
        List<Contact> conList = [SELECT Id FROM Contact];
        Cookie secretKey = new Cookie('secretKey',conList[0].Id,null,28800,false);
        ApexPages.currentPage().setCookies(new Cookie[]{secretKey});
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c,Device_Type__c, Make_Formula__c,Fleet_Maintenance__c,RecordTypeId,DSNSerial__c,Name FROM Vehicles__c];
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics409Mock());
        Test.startTest();
        //String accessToken = URITelematics2ComponentController.getAccessToken();
        URITelematics2ComponentController URIClass = new URITelematics2ComponentController();
        Fleet_Maintenance__c fleet = [SELECT ID,Controller_Type__c from Fleet_Maintenance__c limit 1];
        URITelematics2ComponentController.assetmaster = fleet;
        vehList[0].Device_Type__c = 'ZTR';
        URITelematics2ComponentController.activateTelematics(JSON.serialize(vehList[0]), conList[0].Id,'',JSON.serialize(fleet));
        Test.stopTest();
    }
    @isTest static void URITestMethod409MOCK4(){
        
        List<Contact> conList = [SELECT Id FROM Contact];
        Cookie secretKey = new Cookie('secretKey',conList[0].Id,null,28800,false);
        ApexPages.currentPage().setCookies(new Cookie[]{secretKey});
        system.debug('Cookie Value'+ApexPages.currentPage().getCookies().get('secretKey'));
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c, Make_Formula__c,Fleet_Maintenance__c,RecordTypeId,Service_Notes__c,DSNSerial__c,Name FROM Vehicles__c];
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics409Mock());
        Test.startTest();
        
        URITelematics2ComponentController.vechWrapperForActivateTelematics vechWrapper = new URITelematics2ComponentController.vechWrapperForActivateTelematics();
        vechWrapper.activeVech = vehList[0];
        vechWrapper.gotoDeInstall = true;
        vechWrapper.gotoDeInstallFroRunHr = true;
        URITelematics2ComponentController.vech = vehList[0];
        Fleet_Maintenance__c fleet = [SELECT ID,Controller_Type__c from Fleet_Maintenance__c limit 1];
        URITelematics2ComponentController.assetmaster = fleet;
        String accessToken = URITelematics2ComponentController.getAccessToken();
        URITelematics2ComponentController.getInstallationIdByName(vehList[0].Name, accessToken, vechWrapper,'');
        //URITelematics2ComponentController.installationPostMethod(vehList[0].DSNSerial__c, vechWrapper);
        
        Test.stopTest();
    }
    @isTest static void URITestMethod409MOCK5(){
        
        List<Contact> conList = [SELECT Id FROM Contact];
        Cookie secretKey = new Cookie('secretKey',conList[0].Id,null,28800,false);
        ApexPages.currentPage().setCookies(new Cookie[]{secretKey});
        system.debug('Cookie Value'+ApexPages.currentPage().getCookies().get('secretKey'));
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c, Make_Formula__c,Fleet_Maintenance__c,Equip_Category__c,Confirmation_Number__c,Service_Notes__c,RecordTypeId,DSNSerial__c,Name, Fleet_Maintenance__r.Class__c, Fleet_Maintenance__r.Category__c ,Fleet_Maintenance__r.Equip_VIN__c,Service_Type__c,Unit_Number__c,Customer_ID__c FROM Vehicles__c];
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics409Mock());
        Test.startTest();
        
        URITelematics2ComponentController.vechWrapperForActivateTelematics vechWrapper = new URITelematics2ComponentController.vechWrapperForActivateTelematics();
        vechWrapper.activeVech = vehList[0];
        URITelematics2ComponentController.vech = vehList[0];
        vechWrapper.gotoDeInstall = true;
        vechWrapper.gotoDeInstallFroRunHr = true;
        Fleet_Maintenance__c fleet = [SELECT ID,Controller_Type__c,Fuel_Module__c from Fleet_Maintenance__c limit 1];
        URITelematics2ComponentController.assetmaster = fleet;
        //URITelematics2ComponentController.getInstallationIdByName(vehList[0].Name, accessToken, vechWrapper);
        vehList[0].Service_Type__c = 'Smart Control';
        URITelematics2ComponentController.installationPostMethod(vehList[0].DSNSerial__c, vechWrapper,'',false);
        
        Test.stopTest();
    }
    /*@isTest static void URITestMethod3(){
        List<Contact> conList = [SELECT Id FROM Contact];
        Cookie secretKey = new Cookie('secretKey',conList[0].Id,null,28800,false);
        ApexPages.currentPage().setCookies(new Cookie[]{secretKey});
        system.debug('Cookie Value'+ApexPages.currentPage().getCookies().get('secretKey'));
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c, Make_Formula__c,Fleet_Maintenance__c,RecordTypeId,DSNSerial__c,Communicated__c,Name,Confirmation_Number__c,CID__c FROM Vehicles__c];
        String accessToken = URITelematics2ComponentController.getAccessToken();
        URITelematics2ComponentController.testDevice(JSON.serialize(vehList[1]), conList[0].Id);
        URITelematics2ComponentController.testDevice(JSON.serialize(vehList[0]), conList[0].Id);
    }
    
    @isTest static void URITestMethod4(){ 
        Test.setMock(WebServiceMock.class, new MetadataServiceTest.WebServiceMockImpl());   
        List<Contact> conList = [SELECT Id FROM Contact];
        Cookie secretKey = new Cookie('secretKey',conList[0].Id,null,28800,false);
        ApexPages.currentPage().setCookies(new Cookie[]{secretKey});
        system.debug('Cookie Value'+ApexPages.currentPage().getCookies().get('secretKey'));
        List<Vehicles__c> vehList = [SELECT Id,Last_Modified_By_Sites_User__c, Fleet_Maintenance__c,RecordTypeId,DSNSerial__c,Communicated__c,Name,Confirmation_Number__c,CID__c 
                                     FROM Vehicles__c LIMIT 3];
        String accessToken = URITelematics2ComponentController.getAccessToken();
        Test.startTest();
        URITelematics2ComponentController.getVehicle(vehList[1].Id);
        URITelematics2ComponentController.replaceDSN(JSON.serialize(vehList[2]),'Test Service');
        
        URITelematics2ComponentController.isDeviceCommunicating(accessToken,''); 
        URITelematics2ComponentController.activateTelematics(JSON.serialize(vehList[2]), conList[0].Id);
        URITelematics2ComponentController.checkSerialNumber(JSON.serialize(vehList[2]));
        Test.stopTest();
    }*/
    @isTest static void URITestMethod202MOCK1(){
        
        List<Contact> conList = [SELECT Id FROM Contact];
        Cookie secretKey = new Cookie('secretKey',conList[0].Id,null,28800,false);
        ApexPages.currentPage().setCookies(new Cookie[]{secretKey});
        system.debug('Cookie Value'+ApexPages.currentPage().getCookies().get('secretKey'));
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c,Device_Type__c, Make_Formula__c,Fleet_Maintenance__c,RecordTypeId,DSNSerial__c,Name FROM Vehicles__c];
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics202Mock());
        Test.startTest();
        String accessToken = URITelematics2ComponentController.getAccessToken();
        URITelematics2ComponentController URIClass = new URITelematics2ComponentController();
        URITelematics2ComponentController.isMarriageMethod();
        URITelematics2ComponentController.DeinstallDevice(JSON.serialize(vehList[0]), conList[0].Id);
        URIClass.logout();
        Test.stopTest();
    }
    
    @isTest static void URITestMethod202MOCK1a(){
        
        List<Contact> conList = [SELECT Id FROM Contact];
        Cookie secretKey = new Cookie('secretKey',conList[0].Id,null,28800,false);
        ApexPages.currentPage().setCookies(new Cookie[]{secretKey});
        system.debug('Cookie Value'+ApexPages.currentPage().getCookies().get('secretKey'));
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c,Device_Type__c, Make_Formula__c, Fleet_Maintenance__c,RecordTypeId,DSNSerial__c,Name FROM Vehicles__c];
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics202Mocka());
        Test.startTest();
        String accessToken = URITelematics2ComponentController.getAccessToken();
        URITelematics2ComponentController URIClass = new URITelematics2ComponentController();
        URITelematics2ComponentController.isMarriageMethod();
        URITelematics2ComponentController.DeinstallDevice(JSON.serialize(vehList[0]), conList[0].Id);
        URIClass.logout();
        Test.stopTest();
    }
    
    @isTest static void URITestMethod202MOCK2(){
        
        List<Contact> conList = [SELECT Id FROM Contact];
        Cookie secretKey = new Cookie('secretKey',conList[0].Id,null,28800,false);
        ApexPages.currentPage().setCookies(new Cookie[]{secretKey});
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c,Device_Type__c, Make_Formula__c,Fleet_Maintenance__c,RecordTypeId,DSNSerial__c,Name FROM Vehicles__c];
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics202Mock());
        Test.startTest();
        //String accessToken = URITelematics2ComponentController.getAccessToken();
        URITelematics2ComponentController URIClass = new URITelematics2ComponentController();
        vehList[0].Equip_Category__c = 'm6';
        URITelematics2ComponentController.testDevice(JSON.serialize(vehList[0]), conList[0].Id);
    
        Test.stopTest();
    }
    @isTest static void URITestMethod202MOCK3(){
        
        List<Contact> conList = [SELECT Id FROM Contact];
        Cookie secretKey = new Cookie('secretKey',conList[0].Id,null,28800,false);
        ApexPages.currentPage().setCookies(new Cookie[]{secretKey});
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c,Device_Type__c, Make_Formula__c,Fleet_Maintenance__c,RecordTypeId,DSNSerial__c,Name FROM Vehicles__c];
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics202Mock());
        Test.startTest();
        //String accessToken = URITelematics2ComponentController.getAccessToken();
        URITelematics2ComponentController URIClass = new URITelematics2ComponentController();
        Fleet_Maintenance__c fleet = [SELECT ID,Controller_Type__c,Fuel_Module__c from Fleet_Maintenance__c limit 1];
        URITelematics2ComponentController.assetmaster = fleet;
        vehList[0].Device_Type__c = 'TrackUnit';
        URITelematics2ComponentController.activateTelematics(JSON.serialize(vehList[0]), conList[0].Id,'',JSON.serialize(fleet));
        Test.stopTest();
    }
    @isTest static void URITestMethod202MOCK4(){
        
        List<Contact> conList = [SELECT Id FROM Contact];
        Cookie secretKey = new Cookie('secretKey',conList[0].Id,null,28800,false);
        ApexPages.currentPage().setCookies(new Cookie[]{secretKey});
        system.debug('Cookie Value'+ApexPages.currentPage().getCookies().get('secretKey'));
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c,Device_Type__c, Make_Formula__c,Fleet_Maintenance__c,RecordTypeId,Service_Notes__c,DSNSerial__c,Name FROM Vehicles__c];
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics202Mock());
        Test.startTest();
        
        URITelematics2ComponentController.vechWrapperForActivateTelematics vechWrapper = new URITelematics2ComponentController.vechWrapperForActivateTelematics();
        vechWrapper.activeVech = vehList[0];
        vechWrapper.gotoDeInstall = true;
        vechWrapper.gotoDeInstallFroRunHr = true;
        URITelematics2ComponentController.vech = vehList[0];
        Fleet_Maintenance__c fleet = [SELECT ID,Controller_Type__c,Fuel_Module__c from Fleet_Maintenance__c limit 1];
        URITelematics2ComponentController.assetmaster = fleet;
        String accessToken = URITelematics2ComponentController.getAccessToken();
        URITelematics2ComponentController.getInstallationIdByName(vehList[0].Name, accessToken, vechWrapper,'');
        //URITelematics2ComponentController.installationPostMethod(vehList[0].DSNSerial__c, vechWrapper);
        
        Test.stopTest();
    }
    @isTest static void URITestMethod202MOCK5(){
        
        List<Contact> conList = [SELECT Id FROM Contact];
        Cookie secretKey = new Cookie('secretKey',conList[0].Id,null,28800,false);
        ApexPages.currentPage().setCookies(new Cookie[]{secretKey});
        system.debug('Cookie Value'+ApexPages.currentPage().getCookies().get('secretKey'));
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c,Device_Type__c, Make_Formula__c,Fleet_Maintenance__c,Equip_Category__c,Engine_Hours__c,Confirmation_Number__c,Service_Notes__c,RecordTypeId,DSNSerial__c,Name,Fleet_Maintenance__r.Class__c, Fleet_Maintenance__r.Category__c ,Fleet_Maintenance__r.Equip_VIN__c,Service_Type__c,Unit_Number__c,Customer_ID__c FROM Vehicles__c];
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics202Mock());
        Test.startTest();
        
        URITelematics2ComponentController.vechWrapperForActivateTelematics vechWrapper = new URITelematics2ComponentController.vechWrapperForActivateTelematics();
        vechWrapper.activeVech = vehList[0];
        URITelematics2ComponentController.vech = vehList[0];
        vechWrapper.gotoDeInstall = true;
        vechWrapper.gotoDeInstallFroRunHr = true;
        Fleet_Maintenance__c fleet = [SELECT ID,Controller_Type__c,Fuel_Module__c  from Fleet_Maintenance__c limit 1];
        URITelematics2ComponentController.assetmaster = fleet;
        //URITelematics2ComponentController.getInstallationIdByName(vehList[0].Name, accessToken, vechWrapper);
        vehList[0].Service_Type__c = 'Smart Control';
        URITelematics2ComponentController.installationPostMethod(vehList[0].DSNSerial__c, vechWrapper,'',true);
        
        Test.stopTest();
    }
    
    @isTest static void URITestMethod404MOCK1(){
        
        List<Contact> conList = [SELECT Id FROM Contact];
        Cookie secretKey = new Cookie('secretKey',conList[0].Id,null,28800,false);
        ApexPages.currentPage().setCookies(new Cookie[]{secretKey});
        system.debug('Cookie Value'+ApexPages.currentPage().getCookies().get('secretKey'));
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c,Device_Type__c, Make_Formula__c,Fleet_Maintenance__c,RecordTypeId,DSNSerial__c,Name FROM Vehicles__c];
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics404Mock());
        Test.startTest();
        String accessToken = URITelematics2ComponentController.getAccessToken();
        URITelematics2ComponentController URIClass = new URITelematics2ComponentController();
        URITelematics2ComponentController.isMarriageMethod();
        URITelematics2ComponentController.DeinstallDevice(JSON.serialize(vehList[0]), conList[0].Id);
        URIClass.logout();
        Test.stopTest();
    }
    @isTest static void URITestMethod404MOCK2(){
        
        List<Contact> conList = [SELECT Id FROM Contact];
        Cookie secretKey = new Cookie('secretKey',conList[0].Id,null,28800,false);
        ApexPages.currentPage().setCookies(new Cookie[]{secretKey});
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c,Device_Type__c, Make_Formula__c,Fleet_Maintenance__c,RecordTypeId,DSNSerial__c,Name FROM Vehicles__c];
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics404Mock());
        Test.startTest();
        //String accessToken = URITelematics2ComponentController.getAccessToken();
        URITelematics2ComponentController URIClass = new URITelematics2ComponentController();
        vehList[0].Equip_Category__c = 'm6';
        URITelematics2ComponentController.testDevice(JSON.serialize(vehList[0]), conList[0].Id);
    
        Test.stopTest();
    }
    @isTest static void URITestMethod404MOCK3(){
        
        List<Contact> conList = [SELECT Id FROM Contact];
        Cookie secretKey = new Cookie('secretKey',conList[0].Id,null,28800,false);
        ApexPages.currentPage().setCookies(new Cookie[]{secretKey});
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c,Device_Type__c, Make_Formula__c,Fleet_Maintenance__c,RecordTypeId,DSNSerial__c,Name FROM Vehicles__c];
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics404Mock());
        Test.startTest();
        Fleet_Maintenance__c fleet = [SELECT ID,Controller_Type__c,Fuel_Module__c from Fleet_Maintenance__c limit 1];
        URITelematics2ComponentController.assetmaster = fleet;
        //String accessToken = URITelematics2ComponentController.getAccessToken();
        URITelematics2ComponentController URIClass = new URITelematics2ComponentController();
         vehList[0].Device_Type__c = 'ZTR';
        URITelematics2ComponentController.activateTelematics(JSON.serialize(vehList[0]), conList[0].Id,'',JSON.serialize(fleet));
        Test.stopTest();
    }
    @isTest static void URITestMethod404MOCK4(){
        
        List<Contact> conList = [SELECT Id FROM Contact];
        Cookie secretKey = new Cookie('secretKey',conList[0].Id,null,28800,false);
        ApexPages.currentPage().setCookies(new Cookie[]{secretKey});
        system.debug('Cookie Value'+ApexPages.currentPage().getCookies().get('secretKey'));
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c,Device_Type__c, Make_Formula__c,Fleet_Maintenance__c,RecordTypeId,Service_Notes__c,DSNSerial__c,Name FROM Vehicles__c];
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics404Mock());
        Test.startTest();
        
        URITelematics2ComponentController.vechWrapperForActivateTelematics vechWrapper = new URITelematics2ComponentController.vechWrapperForActivateTelematics();
        vechWrapper.activeVech = vehList[0];
        vechWrapper.gotoDeInstall = true;
        vechWrapper.gotoDeInstallFroRunHr = true;
        URITelematics2ComponentController.vech = vehList[0];
        Fleet_Maintenance__c fleet = [SELECT ID,Controller_Type__c,Fuel_Module__c from Fleet_Maintenance__c limit 1];
        URITelematics2ComponentController.assetmaster = fleet;
        String accessToken = URITelematics2ComponentController.getAccessToken();
        URITelematics2ComponentController.getInstallationIdByName(vehList[0].Name, accessToken, vechWrapper,'');
        //URITelematics2ComponentController.installationPostMethod(vehList[0].DSNSerial__c, vechWrapper);
        
        Test.stopTest();
    }
    @isTest static void URITestMethod404MOCK5(){
        
        List<Contact> conList = [SELECT Id FROM Contact];
        Cookie secretKey = new Cookie('secretKey',conList[0].Id,null,28800,false);
        ApexPages.currentPage().setCookies(new Cookie[]{secretKey});
        system.debug('Cookie Value'+ApexPages.currentPage().getCookies().get('secretKey'));
        List<Vehicles__c> vehList = [SELECT Id, Year_Formula__c,Model_Formula__c,Device_Type__c, Make_Formula__c,Fleet_Maintenance__c,Equip_Category__c,Engine_Hours__c,Confirmation_Number__c,Service_Notes__c,RecordTypeId,DSNSerial__c,Name, Fleet_Maintenance__r.Class__c, Fleet_Maintenance__r.Category__c ,Fleet_Maintenance__r.Equip_VIN__c,Service_Type__c,Unit_Number__c,Customer_ID__c FROM Vehicles__c];
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics404Mock());
        Test.startTest();
        
        URITelematics2ComponentController.vechWrapperForActivateTelematics vechWrapper = new URITelematics2ComponentController.vechWrapperForActivateTelematics();
        vechWrapper.activeVech = vehList[0];
        URITelematics2ComponentController.vech = vehList[0];
        vechWrapper.gotoDeInstall = true;
        vechWrapper.gotoDeInstallFroRunHr = true;
        Fleet_Maintenance__c fleet = [SELECT ID,Controller_Type__c,Fuel_Module__c from Fleet_Maintenance__c limit 1];
        URITelematics2ComponentController.assetmaster = fleet;
        //URITelematics2ComponentController.getInstallationIdByName(vehList[0].Name, accessToken, vechWrapper);
        vehList[0].Service_Type__c = 'Smart Control';
        URITelematics2ComponentController.installationPostMethod(vehList[0].DSNSerial__c, vechWrapper,'',false);
        vehList[0].Service_Notes__c = 'test';
        vehList[1].Service_Notes__c = 'test';
        //vehList[3].Service_Notes__c = 'test';
        //update vehList;
        //URITelematics2ComponentController.installationPostMethod(vehList[0].DSNSerial__c, vechWrapper);
        URITelematics2ComponentController.getFuelList();
        URITelematics2ComponentController.getPickListValuesList();
        Test.stopTest();
    }
    @isTest static void URITestMethod200MOCK2abc(){
        
        Test.setMock(HttpCalloutMock.class, new URITelematicsMock.URITelematics200Mock());
        Test.startTest();
        URITelematics2ComponentController.testSync('testing','test');
        TRY{
            URITelematics2ComponentController.getPickListValues(new List<String>{'Ext_Harness__c'});
        }catch(Exception e){
            
        }
        List<Vehicles__c> vehList = [SELECT Id, Name FROM Vehicles__c];
        if( vehList.size() > 0 ){
            try{
                URITelematics2ComponentController.getService(vehList[0].Id);
                URITelematics2ComponentController.saveService(JSON.serialize(vehList[0]));
                URITelematics2ComponentController.call1537(JSON.serialize(vehList[0]));
                
            }catch(Exception e){
            
            }
        }
        List<SCMC__Bill_of_Material__c> bomList1 = [SELECT Id,Name,Price__c FROM SCMC__Bill_of_Material__c WHERE SCMC__Parent__c = null];

        vehList[0].Parts_Used_List__c = bomList1[0].Id;
        URITelematics2ComponentController.getBillOfMaterials(JSON.serialize(vehList[0]));

        Test.stopTest();
    }
    @isTest
    static void testMethod7() {
        Test.setMock(HttpCalloutMock.class, new InstallationAppDmlUtilMock());

        List<Vehicles__c> vehList = [Select Id, Name,Service_Type__c,Vehicle_Type__c,Odometer__c,CABLE_TYPE_INSTALLED__c,Dock_Serial_Number__c,Digi_Serial_Number__c,
                                         Crank_Handle_Hangar__c,Confirmation__c,Work_Order__r.Project_Name__c,Work_Order__r.SIC_TERM__c, Install_Date__c, Work_Order__r.Name, 
                                         Work_Order__r.Project__c,Work_Order__r.Project__r.Name, Install_Scope__c, Make__c, Model__c, Year__c, Equip_VIN__c, Work_Order__c, Cab_Type__c,
                                         WO_Project_Id__c,Installer__c, Installed_VIN__c, Dropdown_Notes__c, RFID_SN__c, Display_SN__c, Driver_UID__c, DVR_SN__c, DSN__c, Camera_SN__c, Technician__r.Name, Serial_Number_Cross_Check_Fields_api_csv__c, Lift_Plate__c, Technician__c,
                                         ESN_IMEI__c,iBox_SN__c, Post_Install_Notes__c, Service_Notes__c, Service_Status__c,RecordTypeName__c, Serial_Number_Cross_Check_Type__c, PTO_Connections__c, Add_Ons__c, Antenna__c, Re_Installed__c, PTO_Hours__c, Required_App_Fields__c,
                                         De_installed_S_N__c, License_Plate__c, License_Plate_State__c, Removed_OBC_SN__c, Removed_Display_SN__c, Removed_Device_Serial_Number__c, PTO_Verified__c, 
                                         PTO_Connection_Required__c, PTO_Required__c, IOPTO__c, Last_Modified_By_Sites_User__c, Cable_Type_Ordered__c,Pre_Check__c, Pre_Check_Change__c, 
                                         Pre_Check_Notes__c, Pre_Check_Change_Notes__c, Pre_Check_Site_Contact_Notified__c, Pre_Check_Change_Site_Contact_Notified__c,Work_Order__r.Account__c
                                         From Vehicles__c ];
        List<SCMC__Bill_of_Material__c> bomList = [SELECT Id,Name FROM SCMC__Bill_of_Material__c];
        List<SCMC__Bill_of_Material__c> bomList1 = [SELECT Id,Name,Price__c FROM SCMC__Bill_of_Material__c WHERE SCMC__Parent__c =: bomList[0].Id];
        List<SCMC__Item__c> itemList = [SELECT Id,Name FROM SCMC__Item__c];
        List<Contact> conList = [SELECT Id,Name FROM Contact];

        List<URITelematics2ComponentController.billofMaterial> bomWrapList = new List<URITelematics2ComponentController.billofMaterial>();
        for(SCMC__Bill_of_Material__c bom:bomList1){
            
            URITelematics2ComponentController.billofMaterial bomWrap = new URITelematics2ComponentController.billofMaterial();
            bomWrap.bom = bom;
            bomWrap.salesorderLineItem = new SCMC__Sales_Order_Line_Item__c();
            bomWrap.quantity = 2;
            bomWrapList.add(bomWrap);
        }
        URITelematics2ComponentController.parentBillofMaterial parentBomWrap = new URITelematics2ComponentController.parentBillofMaterial();
        parentBomWrap.bom = bomList[0];
        parentBomWrap.salesorder = new SCMC__Sales_Order__c();
        parentBomWrap.billofMaterialList = bomWrapList;
        
        Test.startTest();
        try{
            URITelematics2ComponentController.saveBillOfMaterial(JSON.serialize(parentBomWrap),JSON.serialize(VehList[0]));
        }catch(Exception e){
             
        }
        Test.stopTest();
    }
    
}