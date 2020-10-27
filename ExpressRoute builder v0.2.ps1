##########################################################################################################################################################
##########################################################################################################################################################
##########################################################################################################################################################
##########################################################################################################################################################
####                                                                                                                                                  ####
####                                            ExpressRoute Builder Script by Robert Barnes                                                          ####
####                                                                                                                                                  ####
####      I wrote this script to perform the necessary tasks and provision the required components to implement ExpressRoute technology               ####
####             Most architectual options available to you when designing an ExpressRoute solution are catered for in this script                    ####
####                                       For more details please view the ReadMe document                                                           ####
####                                                                                                                                                  ####
####                                                                                                                                                  ####
##########################################################################################################################################################
##########################################################################################################################################################
##########################################################################################################################################################
##########################################################################################################################################################

$AzureRMGroup = @()
$Location = @()
$ExpressRouteCircuit = @()
$ServiceKey = @()



    
        Function Install-AzureRMPowerShellModule
                {
                        Write-Host "Installing AzureRM PowerShell Module..." -ForegroundColor Yellow
                        Install-Module AzureRM -MinimumVersion 3.6.0 -Force -ErrorAction SilentlyContinue -Verbose
                        Write-Host "Importing AzureRM PowerShell Module..." -ForegroundColor Yellow
                        Import-Module AzureRM -Force -ErrorAction SilentlyContinue -Verbose
                        Write-Host "AzureRM PowerShell module installed" -ForegroundColor Yellow
                }

        Function Azure-RMLogin 
                {
                        Write-Host "Logging into Microsoft Azure..." -ForegroundColor Yellow
                        Login-AzureRmAccount
                        $AzureSubscription = Get-AzureRMSubscription | Out-GridView -Title "Select your Azure subscription" -PassThru
                        Select-AzureRMSubscription -SubscriptionId $AzureSubscription.SubscriptionId
                        Write-Host "Login Successful" -ForegroundColor Yellow
                }

        Function Get-RMAzureVariables
                {
                        Write-Host "Loading Variables..." -ForegroundColor Yellow
                        $AzureRMGroup = Get-AzureRmResourceGroup | Out-GridView -PassThru
                        $Global:AzureRMGroup = $AzureRMGroup
                        $Location = @("West US","West US 2","East US","East US 2","Central US","North Central US","South Central US","West Central US","Canada East","Canada Central","Brazil South","North Europe","West Europe","Germany Central","Germany Northeast","UK West","UK South","Southeast Asia","East Asia","Australia East","Australia Southeast","China East","China North","Central India","West India","South India","Japan East","Japan West","Korea Central","Korea South")
                        $Global:Location = $Location  | Out-GridView -Title "Please choose your Azure Region" -PassThru
                        $ExpressRouteCircuit = Get-AzureRmExpressRouteCircuit
                        $Global:ExpressRouteCircuit = $ExpressRouteCircuit | Out-GridView -Title "Select ExpressRoute Circuit" -PassThru
                        Write-Host "Variables loaded successfully" -ForegroundColor Yellow
                }

        Function Create-RMExpressRouteCircuit
                {
                        Write-Host "Creating ExpressRoute Circuit" -ForegroundColor Yellow
                        #$Location = $Global:Location | Out-GridView -Title "Please choose your Azure Region" -PassThru
                        $ServiceProvider = Get-AzureRmExpressRouteServiceProvider | Out-GridView -Title "Please select your Azure ExpressRoute Service Provider" -PassThru
                        $PeeringLocation = $ServiceProvider.PeeringLocationsText
                        $PeeringLocation = $PeeringLocation | ForEach { $_ -replace '"',"" -replace '[][]','' -replace " ",""} | Where { $_ -ne "" } 
                        $PeeringLocation = ($PeeringLocation.split(",")).trim() | Out-GridView -Title "please select Peering Location" -PassThru
                        $BandwithsOffered =$ServiceProvider.BandwidthsOffered | Out-GridView -Title "Please select your bandwidth requirements" -PassThru
                        $CircuitName = Read-Host "Enter Circuit name here"
                        $Tier = @("Standard","Premium")
                        $Tier = $Tier | Out-GridView -Title "Select Standard or Premium tier of ExpressRoute" -PassThru
                        $Billing = @("MeteredData","UnlimitedData")
                        $Billing = $Billing | Out-GridView -Title "Select a Billing model for ExpressRoute" -PassThru
                        New-AzureRmExpressRouteCircuit -Name $CircuitName -ResourceGroupName $Global:AzureRMGroup.ResourceGroupName `
                        -Location $Global:Location -SkuTier $Tier -SkuFamily $Billing -ServiceProviderName $ServiceProvider.Name `
                        -PeeringLocation $PeeringLocation -BandwidthInMbps $BandwithsOffered.ValueInMbps -AllowClassicOperations $True -Verbose
                        Write-Host "ExpressRoute Circuit created successfully" -ForegroundColor Yellow
                }

        Function Verify-RMExpressRouteCircuit
                {
                        Write-Host "Verifying ExpressRoute Circuit..." -ForegroundColor Yellow
                        Get-AzureRmExpressRouteCircuit -Name $Global:ExpressRouteCircuit.Name -ResourceGroupName $Global:AzureRMGroup.ResourceGroupName
                }

        Function Configure-RMExpressRouteRouting
                {
                        Write-Host "Configuring ExpressRoute Routing..." -ForegroundColor Yellow
                        $PeeringName = Read-Host "Enter Peer name"
                        $PrimaryPeerAddress = Read-Host "What is the Primary Peer IP Address and subnet? (eg 0.0.0.0/24)"
                        $SecondaryPeerAddress = Read-Host "What is the Secondary Peer IP Address and subnet? (eg 0.0.0.0/24)"
                        $VlanID = Read-Host "What is the VLAN ID?"
                        $PeerASN = Read-Host "Enter the AS number for the BGP session"
                        $AccessType = @("AzurePrivatePeering","AzurePublicPeering","MicrosoftPeering")
                        $AccessType = $AccessType | Out-GridView -Title "Select the Peering type you would like to use" -PassThru
                        Add-AzureRmExpressRouteCircuitPeeringConfig -Name $PeeringName `
                        -ExpressRouteCircuit $Global:ExpressRouteCircuit -PeeringType $AccessType -PeerASN $PeerASN `
                        -PrimaryPeerAddressPrefix $PrimaryPeerAddress -SecondaryPeerAddressPrefix $SecondaryPeerAddress -VlanId $VlanID -Verbose
                        Write-Host "Routing configuration completed" -ForegroundColor Yellow
                }

        Function Build-ExpressRouteGateway
                
                {
                        Write-Host "ExpressRoute Gateway is being built" -ForegroundColor Yellow
                        #$RG = Read-Host "Enter a name for the gateway to be created"
                        $Location = $Global:Location | Out-GridView -Title "Please choose your Azure Region" -PassThru
                        $GWName = Read-Host "Enter a name for the gateway to be created"
                        $GWIPName = Read-Host "Enter a name for the Gateway IP address"
                        $GWIPconfName = Read-Host "Enter a name for the Gateway configuration"
                        $VNetName = Get-AzureRmVirtualNetwork | Out-GridView -Title "Select your VNet" -PassThru
                        #$vnet = Get-AzureRmVirtualNetwork -Name $VNetName -ResourceGroupName $RG
                        $AddressPrefix = Read-Host "Enter your Gateway subnet IP address and Subnet mask (/27 or larger)"
                        $VPNType = @("PolicyBased","RouteBased")
                        $VPNType = $VPNType | Out-GridView -Title "Select VPN Type" -PassThru
                        Write-Host "creating the Gateway subnet" -ForegroundColor Yellow
                        Add-AzureRmVirtualNetworkSubnetConfig -Name "GatewaySubnet" -VirtualNetwork $VNetName -AddressPrefix $AddressPrefix -Verbose
                        Set-AzureRmVirtualNetwork -VirtualNetwork $VNetName -Verbose
                        $subnet = Get-AzureRmVirtualNetworkSubnetConfig -Name 'GatewaySubnet' -VirtualNetwork $VNetName
                        $pip = New-AzureRmPublicIpAddress -Name $GWIPName  -ResourceGroupName $Global:AzureRMGroup.ResourceGroupName -Location $Global:Location -AllocationMethod Dynamic
                        $ipconf = New-AzureRmVirtualNetworkGatewayIpConfig -Name $GWIPconfName -Subnet $subnet -PublicIpAddress $pip
                        Write-Host "Deploying the Gateway and subnet.  This operation can take between 20-40 minutes" -ForegroundColor Yellow
                        New-AzureRmVirtualNetworkGateway -Name $GWName -ResourceGroupName $Global:AzureRMGroup.ResourceGroupName -Location $Global:Location -GatewayType Expressroute -IpConfigurations $ipconf -GatewaySku Standard -VpnType $VPNType -Verbose

                }

        Function Link-RMExpressRouteCircuitToVnet
                {
                        Write-Host "ExpressRoute to VNet linking currently in progress..." -ForegroundColor Yellow
                        $Location = $Global:Location | Out-GridView -PassThru -Title "Please choose your Azure Region"
                        $circuit = Get-AzureRmExpressRouteCircuit -Name $Global:ExpressRouteCircuit.Name -ResourceGroupName $Global:AzureRMGroup.ResourceGroupName
                        $GatewayConnectionName = Read-Host "Enter a name for the virtual network gateway connection?"
                        $gw = Get-AzureRmVirtualNetworkGateway -ResourceGroupName $Global:AzureRMGroup.ResourceGroupName | Out-GridView -PassThru -Title "Please Select the Azure Virtual Network Gateway"
                        $connection = New-AzureRmVirtualNetworkGatewayConnection -Name $GatewayConnectionName `
                        -ResourceGroupName $Global:AzureRMGroup.ResourceGroupName -Location $Global:Location -VirtualNetworkGateway1 $gw `
                        -PeerId $circuit.Id -ConnectionType ExpressRoute -ErrorAction Stop -Verbose
                        Write-Host "ExpressRoute to VNet linking completed" -ForegroundColor Yellow
                }

        Function Create-RMExpressRouteCircuitAuthorization
                {
                        Write-Host "Creating authorization to share ExpressRoute Circuit accross multiple subscriptions" -ForegroundColor Yellow
                        $AuthorizationName = Read-Host "Enter a name for the authorization"
                        $circuit = Get-AzureRmExpressRouteCircuit -Name $Global:ExpressRouteCircuit.Name -ResourceGroupName $Global:AzureRMGroup.ResourceGroupName
                        $auth1 = Get-AzureRmExpressRouteCircuitAuthorization -ExpressRouteCircuit $circuit -Name $AuthorizationName
                        Add-AzureRmExpressRouteCircuitAuthorization -ExpressRouteCircuit $circuit -Name $AuthorizationName
                        Set-AzureRmExpressRouteCircuit -ExpressRouteCircuit $circuit -Verbose
                        Write-Host "Authorization completed successfully" -ForegroundColor Yellow
                
                }

        Function Get-FollowOnAction
                {
                        $FollowAction = @("Create ExpressRoute Circuit","Configure ExpressRoute Routing","Create an ExpressRoute Gateway and subnet","Verify ExpressRoute Circuit","Link ExpressRouteCircuit to VNet","Create Circuit Authorizations for multiple Subscription use","Exit")
                        $FollowAction = $FollowAction | Out-GridView -Title "Your requested action has now completed.  Please select any required follow-on action" -PassThru

                            Switch ($FollowAction)
                                
                                {
                                    "Create ExpressRoute Circuit"
                
                                        {
                                            Get-RMAzureVariables
                                            Create-RMExpressRouteCircuit
                                            Get-FollowOnAction
                                        }
           
                                    "Verify ExpressRoute Circuit"

                                        {
                                            Get-RMAzureVariables
                                            Verify-RMExpressRouteCircuit
                                            Get-FollowOnAction
                                        }   
           
                                    "Configure ExpressRoute Routing"
                
                                        {
                                            Get-RMAzureVariables
                                            Configure-RMExpressRouteRouting
                                            Get-FollowOnAction
                                        } 
           
                                    "Create an ExpressRoute Gateway and subnet"
                
                                        {
                                            Get-RMAzureVariables
                                            Build-ExpressRouteGateway
                                            Get-FollowOnAction
                                        }

                                    "Link ExpressRouteCircuit to VNet"
           
                                        {
                                            Get-RMAzureVariables
                                            Link-RMExpressRouteCircuitToVnet
                                            Get-FollowOnAction
                                        }
                
                                    "Create Circuit Authorizations for multiple Subscription use"
           
                                        {
                                            Get-RMAzureVariables
                                            Create-RMExpressRouteCircuitAuthorization
                                            Get-FollowOnAction
                                        }
                
                                    "Exit"

                                        {
                                            Write-Host "Goodbye" -ForegroundColor Yellow
                                            Exit
                                        }
                                    
                                    default
                                        {
                                            Write-Host "You have not selected an action" -ForegroundColor Yellow
                                        }
                
                                } 
                }     

        Install-AzureRMPowerShellModule
        Azure-RMLogin
                
$Action = @("Create ExpressRoute Circuit","Configure ExpressRoute Routing","Create an ExpressRoute Gateway and subnet","Verify ExpressRoute Circuit","Link ExpressRouteCircuit to VNet","Create Circuit Authorizations for multiple Subscription use")
$Action = $Action | Out-GridView -Title "Please select the action you would like to perform" -PassThru

    Switch ($Action)
        {
           "Create ExpressRoute Circuit"
                
                {
                    Get-RMAzureVariables
                    Create-RMExpressRouteCircuit
                    Get-FollowOnAction
                }
           
           "Verify ExpressRoute Circuit"

                {
                    Get-RMAzureVariables
                    Verify-RMExpressRouteCircuit
                    Get-FollowOnAction
                }   
           
           "Configure ExpressRoute Routing"
                
                {
                    Get-RMAzureVariables
                    Configure-RMExpressRouteRouting
                    Get-FollowOnAction
                } 
           
           "Create an ExpressRoute Gateway and subnet"
                
                {
                    Get-RMAzureVariables
                    Build-ExpressRouteGateway
                    Get-FollowOnAction
                }

           "Link ExpressRouteCircuit to VNet"
           
                {
                    Get-RMAzureVariables
                    Link-RMExpressRouteCircuitToVnet
                    Get-FollowOnAction
                }
                
           "Create Circuit Authorizations for multiple Subscription use"
           
                {
                    Get-RMAzureVariables
                    Create-RMExpressRouteCircuitAuthorization
                    Get-FollowOnAction
                }
                
            default
                {
                    Write-Host "You have not selected an action" -ForegroundColor Yellow
                }
                
        }      


    
    
