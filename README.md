ExpressRoute Builder
====================

            

**ExpressRoute Builder README notes.**


**Script written by:** Robert Barnes


**Date written:** 20/03/2017


**Version Number: **V0.2


**Github URL: **https://github.com/robertraybarnes/PowerShell-Scripts/blob/master/ExpressRoute%20Builder%20PowerShell%20Script%20for%20Azure 


This script is designed to deploy the required components to implement ExpressRoute technology for Microsoft Azure Cloud.


Before proceeding to run this script, there are some architectual design decisions you need to make about the ExpressRoute Solution you are designing.



 1. You need to choose an ExpressRoute service provider to provide Cloud Access from your on-premise infrastructure to the Microsoft Azure Cloud.  You can get a list of providers from https://azure.microsoft.com/en-us/services/expressroute/
 or by running the Get-AzureRmExpressRouteServiceProvider cmdlet in PowerShell.



2. You will need to decide what bandwidth you require.  The bandwidths available do differ from supplier to supplier.



3. A Peering location will need to be chosen.  The locations available to you will depend on the service provider you choose to use.



4. ExpressRoute is available in two tiers, Premium ExpressRoute and Standard ExpressRoute. You will need to decide which option you want to use and consider the additional costs vs the benefits for your use case.



5. There are two different billing models for ExpressRoute, Metered Data and Unlimited Data.  Before proceeding, you will need to consider the cost implications against you requirements.



*NB: It's worth noting that this script deploys ExpressRoute in Azure Resource Manager deployment model.  If your Azure infrastructure is deployed using the classic model, you can still use this script to deploy ExpressRoute in ARM as the script is
 designed to deploy ExpressRoute in a way that will allow Classic Operations through ARM.    There really is no need to deploy ExpressRoute in Classic mode as explained above but if you do prefer to deploy in Classic, I do have a script that functions
 in the same way as this one does to deploy in Classic mode.  Just reach out to me on twitter @robraybarnes and i'll be happy to send it to you.*



There are five basic steps to deploying ExpressRoute from an Azure perspective.  It's worth noting that before performing any of the below steps, it is advisable to contact your ExpressRoute service provider to provision the cloud access connectivity from
 the Data Centre side of things as some steps will not work unless this has been done.
 


1. Create your ExpressRoute circuit 


2. Configure the routing for your new provisioned Circuit. 


3. Provision a subnet for your ExpressRoute Gateway 


4. Deploy an ExpressRoute gateway for your circuit 


5. Link your ExpressRoute circuit to your VNet


 


*NB: When provisoning the subnet for the ExpressRoute Gateway, the sub must be named 'GatewaySubnet' and the IP address for the gateway must be a /27 or higher.  One should also be aware that deploying the gateway for ExpressRoute can take anything
 from 20-40 minutes as the gateway is actually a Virtual machine.*


You will need the latest AzureRM PowerShell module for this script to function but I have built in a neat function that will get the module, install it and import it.  This script was written for AzureRM module 3.6.0.



Just hit the run button and provide the details required for provisioning when asked and the script will take care of the rest for you.
Any issues or suggestions to improve the script, send me a tweet to @robraybarnes


 


 

 

        
    
TechNet gallery is retiring! This script was migrated from TechNet script center to GitHub by Microsoft Azure Automation product group. All the Script Center fields like Rating, RatingCount and DownloadCount have been carried over to Github as-is for the migrated scripts only. Note : The Script Center fields will not be applicable for the new repositories created in Github & hence those fields will not show up for new Github repositories.
