/**
 * @Author : Makovskaya Kristina
 * @Date : 25/11/2021
 * @description : This class contains methods for working with the batch interface.
 * These methods allow you to work with a large number of contacts, process them according to the specified rules.
 */
public with sharing class ContactRuleBatch implements Database.Batchable<sObject> {
    /**
     * This method passes packets of records to the execute method.
     * Returns the records of the contacts object.
     * @param dBatchableContext
     * @return Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext dBatchableContext) {
        Map<String, Schema.SObjectField> fields = Schema.getGlobalDescribe().get('Contact').getDescribe().fields.getMap();
        String strFields = '';
        for (Schema.SObjectField field : fields.values()) {
            strFields += field + ', ';
        }
        return Database.getQueryLocator('SELECT ' + strFields.substring(0, strFields.length() - 2) + ' FROM Contact LIMIT 110000');
    }
    /**
     * This method performs processing of each packet.
     * It processes contacts. There are rules that are contained in the mac_pkg__Contract_Assignment_Rules__c object.
     * If the rules are met, the contact is updated according to the corresponding requirements.
     * @param dBatchableContext
     * @param contacts
     */
    public void execute(Database.BatchableContext dBatchableContext, List<Contact> contacts) {
        List<mack_pckg__Contact_Assignment_Rule__c> contactAssignmentRules = [
                SELECT Id, mack_pckg__Field_API_Name__c, mack_pckg__Operator__c, mack_pckg__Field_Value__c, mack_pckg__Account__c
                FROM mack_pckg__Contact_Assignment_Rule__c
        ];
        Map<Id, Decimal> numberOfContacts = new Map<Id, Decimal>();
        Map<Id, Decimal> mapLimitContacts = new Map<Id, Decimal>();
        List<Contact> preUpdateContacts = new List<Contact>();
        Set<Contact> updateContacts = new Set<Contact>();
        List<Account> accounts = [SELECT Id, (SELECT Id FROM Contacts), mack_pckg__Contacts_Limit__c FROM Account];

        for (Account account : accounts) {
            numberOfContacts.put(account.Id, account.Contacts.size());
        }

        for (Account account : accounts) {
            mapLimitContacts.put(account.Id, account.mack_pckg__Contacts_Limit__c);
        }

        for (mack_pckg__Contact_Assignment_Rule__c contactAssignmentRule : contactAssignmentRules) {
            for (Contact contact : contacts) {
                if (contact.AccountId == null) {
                    if (checkingRule(contact, contactAssignmentRule.mack_pckg__Field_API_Name__c, contactAssignmentRule.mack_pckg__Operator__c, contactAssignmentRule.mack_pckg__Field_Value__c)) {
                        contact.AccountId = contactAssignmentRule.mack_pckg__Account__c;
                        preUpdateContacts.add(contact);
                    }
                } else {
                    if (contact.AccountId == contactAssignmentRule.mack_pckg__Account__c) {
                        if (!checkingRule(contact, contactAssignmentRule.mack_pckg__Field_API_Name__c, contactAssignmentRule.mack_pckg__Operator__c, contactAssignmentRule.mack_pckg__Field_Value__c)) {
                            contact.AccountId = null;
                            preUpdateContacts.add(contact);
                        } else {
                            if (mapLimitContacts.get(contact.AccountId) != null) {
                                if (numberOfContacts.get(contact.AccountId) > mapLimitContacts.get(contact.AccountId)) {
                                    numberOfContacts.put(contact.AccountId, numberOfContacts.get(contact.AccountId) - 1);
                                    contact.AccountId = null;
                                    preUpdateContacts.add(contact);
                                }
                            } else {
                                if (numberOfContacts.get(contact.AccountId) > 5) {
                                    numberOfContacts.put(contact.AccountId, numberOfContacts.get(contact.AccountId) - 1);
                                    contact.AccountId = null;
                                    preUpdateContacts.add(contact);
                                }
                            }
                        }
                    }
                }
            }
        }

        for (Contact contact : preUpdateContacts) {
            if (contact.AccountId != null) {
                if (mapLimitContacts.get(contact.AccountId) != null) {
                    if (numberOfContacts.get(contact.AccountId) < mapLimitContacts.get(contact.AccountId)) {
                        updateContacts.add(contact);
                        numberOfContacts.put(contact.AccountId, numberOfContacts.get(contact.AccountId) + 1);
                    }
                } else {
                    if (numberOfContacts.get(contact.AccountId) < 5) {
                        updateContacts.add(contact);
                        numberOfContacts.put(contact.AccountId, numberOfContacts.get(contact.AccountId) + 1);
                    }
                }
            } else {
                updateContacts.add(contact);
            }
        }

        update new List<Contact>(updateContacts);
    }

    /**
     * This method checks each contact for compliance with a specific rule of the mac_pkg__Contract_Assignment_Rule__c object.
     * @param contact recording a contact
     * @param fieldApiName api field name
     * @param operator
     * @param value
     * @return Boolean
     */
    public static Boolean checkingRule(Contact contact, String fieldApiName, String operator, String value) {
        Boolean result = false;
        switch on operator {
            when '=' {
                if (contact.get(fieldApiName) == value) {
                    result = true;
                }
            }
            when '≠' {
                if (contact.get(fieldApiName) != value) {
                    result = true;
                }
            }
            when '>' {
                if (Integer.valueOf(contact.get(fieldApiName)) > Integer.valueOf(value)) {
                    result = true;
                }
            }
            when '≥' {
                if (Integer.valueOf(contact.get(fieldApiName)) >= Integer.valueOf(value)) {
                    result = true;
                }
            }
            when '<' {
                if (Integer.valueOf(contact.get(fieldApiName)) < Integer.valueOf(value)) {
                    result = true;
                }
            }
            when '≤' {
                if (Integer.valueOf(contact.get(fieldApiName)) <= Integer.valueOf(value)) {
                    result = true;
                }
            }
        }
        return result;
    }
    public void finish(Database.BatchableContext dBatchableContext) {

    }
}
