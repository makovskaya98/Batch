/**
 * @Author : Makovskaya Kristina
 * @Date : 25/11/2021
 * @description : This class contains methods for working with the batch interface.
 * This test class performs testing of the ContactRuleBatch class.
 */
@isTest
public with sharing class ContactRuleBatchTest {
    @testSetup
    public static void setup() {
        List<Account> accounts = new List<Account>();

        for (Integer i = 1; i <= 2; i++) {
            accounts.add(new Account(Name = 'ANNA' + i, mack_pckg__Contacts_Limit__c = 6));
        }

        for (Integer i = 1; i <= 2; i++) {
            accounts.add(new Account(Name = 'GLOREA' + i));
        }

        for (Integer i = 1; i <= 2; i++) {
            accounts.add(new Account(Name = 'MAX' + i, mack_pckg__Contacts_Limit__c = 8));
        }

        for (Integer i = 1; i <= 2; i++) {
            accounts.add(new Account(Name = 'ALPHA' + i, mack_pckg__Contacts_Limit__c = 10));
        }

        insert accounts;

        List<Contact> contacts = new List<Contact>();

        for (Integer i = 0; i < 50; i++) {
            contacts.add(new Contact(FirstName = 'Lara', LastName = 'Lorens'));
        }

        for (Integer i = 51; i < 70; i++) {
            contacts.add(new Contact(FirstName = 'Alex', LastName = 'Brovn'));
        }

        for (Integer i = 71; i < 100; i++) {
            contacts.add(new Contact(FirstName = 'Alan', LastName = 'Got', mack_pckg__Amount__c = 50.0));
        }

        for (Integer i = 101; i < 120; i++) {
            contacts.add(new Contact(FirstName = 'Maya', LastName = 'Roll', mack_pckg__Amount__c = 2000));
        }

        for (Integer i = 121; i < 160; i++) {
            contacts.add(new Contact(FirstName = 'Martin', LastName = 'Roll', Email = 'email@mail.ru'));
        }

        Account accountMax = [SELECT Id, Name, mack_pckg__Contacts_Limit__c FROM Account WHERE Name = 'MAX2'];

        for (Integer i = 161; i < 179; i++) {
            contacts.add(new Contact(FirstName = 'Kleo' + i, LastName = 'Males', MailingCountry = 'Belarus', AccountId = accountMax.Id));
        }

        Account accountGlorea = [SELECT Id, Name, mack_pckg__Contacts_Limit__c FROM Account WHERE Name = 'GLOREA2'];

        for (Integer i = 180; i < 199; i++) {
            contacts.add(new Contact(FirstName = 'Alex' + i, LastName = 'Blown', MailingCity = 'Brest', AccountId = accountGlorea.Id));
        }

        insert contacts;

        List<SObject> contactAssignmentRules = new List<SObject>();

        Account account = [SELECT Id, Name, mack_pckg__Contacts_Limit__c FROM Account WHERE Name = 'ANNA1'];
        Account account2 = [SELECT Id, Name, mack_pckg__Contacts_Limit__c FROM Account WHERE Name = 'GLOREA1'];
        Account account3 = [SELECT Id, Name, mack_pckg__Contacts_Limit__c FROM Account WHERE Name = 'ALPHA1'];
        Account account4 = [SELECT Id, Name, mack_pckg__Contacts_Limit__c FROM Account WHERE Name = 'ALPHA2'];

        mack_pckg__Contact_Assignment_Rule__c contactAssignmentRule = new mack_pckg__Contact_Assignment_Rule__c(
                Name = 'Rule1',
                mack_pckg__Field_API_Name__c = 'FirstName',
                mack_pckg__Operator__c = '=',
                mack_pckg__Field_Value__c = 'Lara',
                mack_pckg__Account__c = account.Id
        );
        contactAssignmentRules.add(contactAssignmentRule);

        mack_pckg__Contact_Assignment_Rule__c contactAssignmentRule2 = new mack_pckg__Contact_Assignment_Rule__c(
                Name = 'Rule2',
                mack_pckg__Field_API_Name__c = 'LastName',
                mack_pckg__Operator__c = '=',
                mack_pckg__Field_Value__c = 'Brovn',
                mack_pckg__Account__c = account2.Id
        );
        contactAssignmentRules.add(contactAssignmentRule2);

        mack_pckg__Contact_Assignment_Rule__c contactAssignmentRule3 = new mack_pckg__Contact_Assignment_Rule__c(
                Name = 'Rule3',
                mack_pckg__Field_API_Name__c = 'mack_pckg__Amount__c',
                mack_pckg__Operator__c = '>',
                mack_pckg__Field_Value__c = '80',
                mack_pckg__Account__c = account3.Id
        );
        contactAssignmentRules.add(contactAssignmentRule3);

        mack_pckg__Contact_Assignment_Rule__c contactAssignmentRule4 = new mack_pckg__Contact_Assignment_Rule__c(
                Name = 'Rule4',
                mack_pckg__Field_API_Name__c = 'Email',
                mack_pckg__Operator__c = '≠',
                mack_pckg__Field_Value__c = 'NULL',
                mack_pckg__Account__c = account4.Id
        );
        contactAssignmentRules.add(contactAssignmentRule4);

        mack_pckg__Contact_Assignment_Rule__c contactAssignmentRule5 = new mack_pckg__Contact_Assignment_Rule__c(
                Name = 'Rule5',
                mack_pckg__Field_API_Name__c = 'MailingCountry',
                mack_pckg__Operator__c = '=',
                mack_pckg__Field_Value__c = 'Belarus',
                mack_pckg__Account__c = accountMax.Id
        );
        contactAssignmentRules.add(contactAssignmentRule5);

        mack_pckg__Contact_Assignment_Rule__c contactAssignmentRule6 = new mack_pckg__Contact_Assignment_Rule__c(
                Name = 'Rule6',
                mack_pckg__Field_API_Name__c = 'MailingCity',
                mack_pckg__Operator__c = '=',
                mack_pckg__Field_Value__c = 'Brest',
                mack_pckg__Account__c = accountGlorea.Id
        );
        contactAssignmentRules.add(contactAssignmentRule6);

        insert contactAssignmentRules;

        List<Contact> contactsWithAcc = new List<Contact>();

        for (Integer i = 0; i < 2; i++) {
            contactsWithAcc.add(new Contact(FirstName = 'Mona' + i, LastName = 'Lorens', AccountId = account.Id));
        }

        insert contactsWithAcc;
    }

    static testMethod void test() {

        Test.startTest();
        ContactRuleBatch contactRuleBatch = new ContactRuleBatch();
        Id batchId = Database.executeBatch(contactRuleBatch);
        Test.stopTest();

        List<Contact> contacts = [SELECT Id, Name, AccountId FROM Contact];

        for (Contact contact : contacts) {
            System.debug(contact);
        }

        System.assertEquals([SELECT Id, (SELECT Id FROM Contacts) FROM Account WHERE Name = 'ANNA1'].Contacts.size(), 4);
        System.assertEquals([SELECT Id, (SELECT Id FROM Contacts) FROM Account WHERE Name = 'GLOREA1'].Contacts.size(), 5);
        System.assertEquals([SELECT Id, (SELECT Id FROM Contacts) FROM Account WHERE Name = 'ALPHA1'].Contacts.size(), 10);
        System.assertEquals([SELECT Id, (SELECT Id FROM Contacts) FROM Account WHERE Name = 'ALPHA2'].Contacts.size(), 10);
        System.assertEquals([SELECT Id, (SELECT Id FROM Contacts) FROM Account WHERE Name = 'MAX2'].Contacts.size(), 8);
        System.assertEquals([SELECT Id, (SELECT Id FROM Contacts) FROM Account WHERE Name = 'GLOREA2'].Contacts.size(), 5);
    }

    public static void getOperatorTest() {

        mack_pckg__Contact_Assignment_Rule__c contactAssignmentRule = [
                SELECT Id, Name, mack_pckg__Field_API_Name__c, mack_pckg__Operator__c, mack_pckg__Field_Value__c, mack_pckg__Account__c
                FROM mack_pckg__Contact_Assignment_Rule__c
                WHERE Name = 'Rule1'
        ];
        mack_pckg__Contact_Assignment_Rule__c contactAssignmentRule3 = [
                SELECT Id, Name, mack_pckg__Field_API_Name__c, mack_pckg__Operator__c, mack_pckg__Field_Value__c, mack_pckg__Account__c
                FROM mack_pckg__Contact_Assignment_Rule__c
                WHERE Name = 'Rule3'
        ];

        System.assertEquals(ContactRuleBatch.checkingRule(
        [SELECT Id, FirstName FROM Contact WHERE FirstName = 'Lara'],
                contactAssignmentRule.mack_pckg__Field_API_Name__c, contactAssignmentRule.mack_pckg__Operator__c, contactAssignmentRule.mack_pckg__Field_Value__c
        ), true);

        System.assertEquals(ContactRuleBatch.checkingRule(
        [SELECT Id, FirstName FROM Contact WHERE FirstName = 'Max'],
                contactAssignmentRule.mack_pckg__Field_API_Name__c, contactAssignmentRule.mack_pckg__Operator__c, contactAssignmentRule.mack_pckg__Field_Value__c
        ), false);

        System.assertEquals(ContactRuleBatch.checkingRule(
        [SELECT Id, FirstName FROM Contact WHERE FirstName = 'Alan'],
                contactAssignmentRule3.mack_pckg__Field_API_Name__c, contactAssignmentRule.mack_pckg__Operator__c, contactAssignmentRule.mack_pckg__Field_Value__c
        ), true);

    }
}