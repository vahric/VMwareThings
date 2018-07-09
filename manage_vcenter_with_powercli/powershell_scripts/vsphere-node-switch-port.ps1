# Username and Password to login vCenter

$usernamePASS = Get-Credential -Message "vCenter server or esxi credentials"

#Input vCenter ip address

$vCenter = Read-Host -Prompt 'Input your server  ip(no intelligent control enter ip)’

#Connect to vCenter

Connect-VIServer -Server $vCenter -Credential $usernamePASS 

#Enter cluster name

$clustername = Read-Host -Prompt ’Name of cluster(no intelligent sure about your entry)’

# List all vSphere nodes in cluster

$vspherehosts = get-cluster $clustername | get-vmhost

#Lets start, for each node we will execute related commands step by step

foreach ($vspherehost in $vspherehosts) {

#About Get-View https://blogs.vmware.com/PowerCLI/2015/02/get-view-part-1-introduction.html
#About Get-View https://blogs.vmware.com/PowerCLI/2015/02/get-view-part-2-views-extension-data.html
#Take broad information about vsphere host

$vspherehostview = get-VMHost $vspherehost | get-view

# Take the name of the vSphere Host

$vspherehostname = $vspherehostview.Name 

# Take broad information about network settings

$vspherehostnetworkview = get-view $vspherehostview.ConfigManager.NetworkSystem 

#List physical nics

$vspherephysicalnics = $vspherehostnetworkview.NetworkInfo.Pnic 

# Lets loop again for each physical nic

foreach ($vspherephysicalnic in $vspherephysicalnics) {

# This will turn each pysical nic info, like below 
<#

Device              : vmnic3
Subnet              : {310, 383, 2001, 2...}
Network             : 
ConnectedSwitchPort : 
LldpInfo            : VMware.Vim.LinkLayerDiscoveryProtocolInfo

#>

# https://www.vmware.com/support/developer/converter-sdk/conv55_apireference/vim.host.NetworkSystem.html

$pnicinfos = $vspherehostnetworkview.QueryNetworkHint($vspherephysicalnic.Device)

# What is lldp http://www.orbit-computer-solutions.com/link-layer-discovery-protocol-lldp/
# What is cdp https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/cdp/configuration/15-mt/cdp-15-mt-book/nm-cdp-discover.html

# Lets loop again 

foreach($pnicinfo in $pnicinfos){

#Get Port Description which indicate port of switch
    $lldpinfoportdescription = ($pnicinfo.LldpInfo.Parameter | Where-Object {$_.Key -eq "Port Description"}).value   

#Get System Name which indicate switch name     
    $lldpinfosystemname = ($pnicinfo.LldpInfo.Parameter | Where-Object {$_.Key -eq "System Name"}).value
    
#Lets print out everything

    Write-Host $vspherehostname, $vspherephysicalnic.device , $lldpinfoportdescription , $lldpinfosystemname
    Write-Host "-----------------------------------------------------"

} #Close last one

} #Close middle

} #Close the first
