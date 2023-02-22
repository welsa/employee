/*************************************************************************************
Class Name - VFC_PrintPartListForBodyshop
Version - 1.0
Created Date -
Function - Controller for page VF_PrintPartListForBodyshop

Modification Log :
-----------------------------------------------------------------------------
* Developer         Date        Description
* ----------        ----------  ---------------------------------------------
* Dourga            06/12/2016  C-001754 : B/S Delivery Note
* Ashutosh          07/02/2017  C-001871: Rework of the class and only made mapping changes on the page
*************************************************************************************/
public with sharing class VFC_PrintPartListForBodyshop
{
    public PrerequisiteOrder__c currentSalesOrder {get; set;}
    public String renderAs {get; set;}
    public Map<Id, OfferWrapper> mapOfferWrapper {get; set;}
    public String currentDate {get; set;}

    public VFC_PrintPartListForBodyshop(ApexPages.StandardController sc)
    {
        currentSalesOrder   = (PrerequisiteOrder__c) sc.getRecord();
        renderAs            = 'pdf';
        mapOfferWrapper		= new Map<Id, OfferWrapper>();
        currentDate         = System.today().format();

        String fileName     = Label.Delivery_note + '_' + currentSalesOrder.Name + '_' + System.now().format('dd-MM-yy') + '.pdf';

        if(ApexPages.currentPage().getParameters().get('force_download') == 'true')
        {
            ApexPages.currentPage().getHeaders().put('content-disposition', 'attachemnt; filename=' + fileName);
        }
        else
        {
            ApexPages.currentPage().getHeaders().put('content-disposition', 'inline; filename=' + fileName);
        }

        for (Offer__c currentOffer :[SELECT	    Id, PartNUmber__c, Description__c, Quantity__c, FinalType__c, CataloguePrice__c,
                                                Discount__c, Price__c, BSTotalPrice__c, CreatedDate, DeliveryStatus__c, ParentOffer__c,
                                                Suppliable__c, Accepted__c, OriginalPartNumber__c, Type__c
                                     FROM		Offer__c
                                     WHERE		Prerequisiteorder__c = :currentSalesOrder.Id and Type__c != 'Invoicing'
                                     ORDER BY	Name ASC])
        {
            // To add wrapper depending on its type
            if (currentOffer.ParentOffer__c != null)
            {
                // is a child offer

                // Checks if a wrapper of that id already exists
                if (mapOfferWrapper.containsKey(currentOffer.ParentOffer__c))
                {
                    // add the child offer to the existing wrapper
                    mapOfferWrapper.get(currentOffer.ParentOffer__c).addChildOffer(currentOffer);
                }
                else
                {
                    // put a new wrapper in the map
                    mapOfferWrapper.put(currentOffer.ParentOffer__c, new OfferWrapper(currentOffer));
                }
            }
            else
            {
                // is the parent offer

                // Checks if a wrapper of that id already exists
                if (mapOfferWrapper.containsKey(currentOffer.Id))
                {
                    // add the parent offer to the existing wrapper
                    mapOfferWrapper.get(currentOffer.Id).setParentOffer(currentOffer);
                }
                else
                {
                    // put a new wrapper in the map
                    mapOfferWrapper.put(currentOffer.Id, new OfferWrapper(currentOffer));
                }
            }
        }

        System.debug('## mapOfferWrapper: ' + mapOfferWrapper);
    }

    public class OfferWrapper
	{
		// The parent offer of the wrapper
		public Offer__c parentOffer { get; set; }

		// List of child offers of the wrapper
		// It is empty if there is no child offers
		public List<BundleItemOffer> childOfferList { get; set; }

		public Boolean isSuppliedByAS
		{
			get
			{
				return (parentOffer != null &&
						parentOffer.Suppliable__c == true &&
						parentOffer.Accepted__c != 'NO');
			}
		}

		// variable to know if the offer is for an alternative order line
		public Boolean isOfferAlternative
		{
			get
			{
				return (parentOffer != null &&
						parentOffer.OriginalPartNumber__c != null &&
						childOfferList.size() != 0);
			}
		}

        public String parentOfferCreatedDate
        {
            get
            {
                return parentOffer.CreatedDate.date().format();
            }
        }

		public OfferWrapper(Offer__c off)
		{
			childOfferList = new List<BundleItemOffer> ();

			if (off.ParentOffer__c != null)
			{
				// the offer is a child offer
				childOfferList.add(new BundleItemOffer(off));
			}
			else
			{
				// the offer is a parent offer
				parentOffer = off;
			}
		}

		public void setParentOffer(Offer__c offer)
		{
			if (parentOffer == null)
			{
				parentOffer = offer;
			}
		}

		public void addChildOffer(Offer__c offer)
		{
			childOfferList.add(new BundleItemOffer(offer));
		}
	}

    public class BundleItemOffer
    {
        public Offer__c bundleItem {get; set;}

        public String bundleItemCreatedDate
        {
            get
            {
                return bundleItem.CreatedDate.date().format();
            }
        }

        public BundleItemOffer(Offer__c currentOffer)
        {
            bundleItem = currentOffer;
        }
    }

    /*
    private final Id SalesOrderId = ApexPages.currentPage().getParameters().get('id');
    public PrerequisiteOrder__c currentSO = [select id, Name, Status__c, BodyShop__r.ShippingCountry from PrerequisiteOrder__c where id =:SalesOrderId];
    public String displayAddress;
    public PrerequisiteOrder__c Assessment = [select Assessment__c from PrerequisiteOrder__c where Id=:SalesOrderId Limit 1];
    public Id AssessmentId = Assessment.Assessment__c;
    public string renderAs{get;set;}
    public VFC_PrintPartListForBodyshop(ApexPages.StandardController controller) {
            if(ApexPages.currentPage().getParameters().get('pdf') != null && ApexPages.currentPage().getParameters().get('pdf') == 'true')
            {
                renderAs = 'pdf';
                if(ApexPages.currentPage().getParameters().get('force_download') != null && ApexPages.currentPage().getParameters().get('force_download') == 'true')
                {
                    Date dateNow = Date.today();
                    String day = String.valueOf(dateNow.day());
                    String month = String.valueOf(dateNow.month());
                    String year= String.valueOf(dateNow.year());
                    string fileName = Label.Delivery_note+'_'+currentSO.Name+'_'+date.today()+'.pdf';

                    if(apexPages.currentPage().getParameters().get('filename') != null)
                    {
                        fileName = Label.Delivery_note+'_'+currentSO.Name+'_'+day+'-'+month+'-'+year+'.pdf';
                    }

                    Apexpages.currentPage().getHeaders().put('content-disposition', 'attachemnt; filename='+fileName);
                }
            }
    }

    public List<PrerequisiteOrder__c> getSalesOrder()    {
        return [select id, Name,ClaimReference__c,PlateNumber__c,ReferenceNumber__c from PrerequisiteOrder__c where id =:SalesOrderId];
    }

    public List<Offer__c> getOfferLines()    {
        if(currentSO.Status__c == 'INACCEPTANCE') {
            return [Select Name, PartNUmber__c,Total__c, Description__c, Quantity__c, Type__c, DeliveryStatus__c, FinalType__c, CataloguePrice__c, Price__c, BSTotalPrice__c, Discount__c, CreatedDate from Offer__c where Type__c='QUICK' and PrerequisiteOrder__c=:SalesOrderId];
        }
        else {
            return [Select Name, PartNUmber__c,Total__c, Description__c, Quantity__c, Type__c, DeliveryStatus__c, FinalType__c, CataloguePrice__c, Price__c, BSTotalPrice__c, Discount__c, CreatedDate from Offer__c where Accepted__c = 'YES' and PrerequisiteOrder__c=:SalesOrderId];
        }
    }

    public String getDateToday() {
        Date dateNow = Date.today();
        String day = String.valueOf(dateNow.day());
        String month = String.valueOf(dateNow.month());
        String year= String.valueOf(dateNow.year());
        return day+'/'+month+'/'+year;
    }*/

    public String getAddress()
    {
        if(currentSalesOrder.BodyShop__r.ShippingCountry == 'Spain')
        {
          return    '\n'+
                    '<div style="float:left;width:45%;text-align:right;">\n'+
                    '<p style="font-weight:bold;">Alpha Scale S.A., Sucursal en España<br/>\n'+
                    'W0010418B<br/>\n'+
                    'C/ Camino Fuente de la Mora, no 1<br/>\n'+
                    '28050 Madrid</p>\n'+
                    '</div>\n';
        }
        else if(currentSalesOrder.BodyShop__r.ShippingCountry == 'France')
        {
          return    '\n'+
                    '<div style="float:left;width:45%;text-align:right;">\n'+
                    '<p style="font-weight:bold;">Alpha Scale France<br/>\n'+
                    '21 Avenue Matignon<br/>\n'+
                    '75008 Paris</p>\n'+
                    '</div>\n';
        }
        else if(currentSalesOrder.BodyShop__r.ShippingCountry == 'Italy'){
            return  '\n'+
                    '<div style="float:left;width:45%;text-align:right;">\n'+
                    '<p style="font-weight:bold;">AXA Assicurazioni<br/>\n'+
                    'Corso Como 17<br/>\n'+
                    '20154 Milano</p>\n'+
                    '</div>\n';
        }
        else if(currentSalesOrder.BodyShop__r.ShippingCountry == 'Germany'){
            return  '\n'+
                    '<div style="float:left;width:45%;text-align:right;">\n'+
                    '<p style="font-weight:bold;">LieferanschriftBrutschin Unfallreparaturen & KFZ-Service<br/>\n'+
                    'Max-Eyth-Str. 9<br/>\n'+
                    '70839 Gerlingen</p>\n'+
                    'GERMANY (DE)</p>\n'+
                    'Mwst.Nummer : DE218907645</p>\n'+
                    '</div>\n';
        }
        else return null;
    }
}