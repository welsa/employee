/***
* @description Lightning controller to provide details about existing FieldSets.
* @author      P-E GROS
* @date        Oct. 2020
* @see         sfpegGetFieldSet_CTL
*
* Legal Notice
* This code is the property of Salesforce.com and is protected by U.S. and International
* copyright laws. Reproduction, distribution without written permission of Salesforce is
* strictly prohibited. In particular this code has been delivered by Salesforce.com for
* its Client’s internal purposes pursuant to specific terms and conditions, and cannot be
* re-used, reproduced or distributed for any other purposes.
***/

@isTest
public with sharing class sfpegGetFieldSet_CTL_TST {


/***
* @description Initializes the test context.
***/
    @testSetup
    static void testSetup() {
        System.debug('testSetup: START');

        System.debug('testSetup: END');
    }

/***
* @description Tests the "getFieldSetDescs" and implicitly the "getFieldSetDesc" methods.
***/    
    static TestMethod void testGetFieldSetDescs() {
        System.debug('testGetFieldSetDescs: START'); 
        Test.startTest();

        // Standard working case
        try {
            List<String> nameList = new List<String>();
            nameList.add('Task.SFPEG_TSTFS');
            sfpegGetFieldSet_CTL.getFieldSetDescs(nameList);
            //sfpegConfiguration_CTL.getFieldSetDesc('Task.SFPEG_TSTFS');
            System.debug('testGetFieldSetDesc: no exception raised');
            System.assert(true);
        }
        catch (Exception e) {
            System.debug('testGetFieldSetDesc: exception raised (check 1st required SFPEG_TSTFS fieldset on Task object) ' + e.getMessage());
            System.assert(false);
        }

        // Error cases
        try {
            List<String> nameList = new List<String>();
            nameList.add('Task.SFPEG_DUMMY_FIELDSET');
            sfpegGetFieldSet_CTL.getFieldSetDescs(nameList);
            //sfpegConfiguration_CTL.getFieldSetDesc('Task.SFPEG_TSTFS');
            System.debug('testGetFieldSetDesc: no exception raised');
            System.assert(false);
        }
        catch (Exception e) {
            System.debug('testGetFieldSetDesc: exception raised ' + e.getMessage());
            System.assert(true);
        }
        
        try {
            List<String> nameList = new List<String>();
            nameList.add('Test.Test');
            sfpegGetFieldSet_CTL.getFieldSetDescs(nameList);
            System.debug('testGetFieldSetDesc: no exception raised for Test.Test');
            System.assert(false);
        }
        catch (Exception e) {
            System.debug('testGetFieldSetDesc: exception raised for Test.Test' + e.getMessage());
            System.assert(true);
        }

        try {
            List<String> nameList = new List<String>();
            nameList.add('Test');
            sfpegGetFieldSet_CTL.getFieldSetDescs(nameList);
            System.debug('testGetFieldSetDesc: no exception raised for Test');
            System.assert(false);
        }
        catch (Exception e) {
            System.debug('testGetFieldSetDesc: exception raised for Test' + e.getMessage());
            System.assert(true);
        }
        
        Test.stopTest();
        System.debug('testGetFieldSetDesc: END');
    }

}