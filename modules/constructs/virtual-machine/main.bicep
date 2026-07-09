metadata owner = 'Gullapalli-R'
metadata name = 'Virtual Machines'
metadata description = 'This module deploys a Virtual Machine.'

@description('Required. The name of the virtual machine to be created. You should use a unique prefix to reduce name collisions in Active Directory.')
param name string

@description('Optional. Can be used if the computer name needs to be different from the Azure VM resource name. If not used, the resource name will be used as computer name.')
param computerName string = name

@description('Required. Specifies the size for the VMs.')
@allowed([
  'Standard_B2als_v2'
  'Standard_B4als_v2'
  'Standard_B8als_v2'
  'Standard_B16als_v2'
  'Standard_D2als_v6'
  'Standard_D4als_v6'
  'Standard_D8als_v6'
  'Standard_D16als_v6'
  'Standard_L8s_v3'
  'Standard_L16s_v3'
  'Standard_L8s_v4'
  'Standard_L16s_v4'
  'Standard_D2ds_v5'
  'Standard_D4ds_v5'
  'Standard_D2ads_v7'
])
param vmSize string = 'Standard_B2als_v2'

@description('Optional. This property can be used by user in the request to enable or disable the Host Encryption for the virtual machine. This will enable the encryption for all the disks including Resource/Temp disk at host itself. For security reasons, it is recommended to set encryptionAtHost to True. Restrictions: Cannot be enabled if Azure Disk Encryption (guest-VM encryption using bitlocker/DM-Crypt) is enabled on your VMs.')
param encryptionAtHost bool = false

@description('Optional. Specifies the SecurityType of the virtual machine. It has to be set to any specified value to enable UefiSettings. The default behavior is: UefiSettings will not be enabled unless this property is set.')
@allowed([
  ''
  'ConfidentialVM'
  'TrustedLaunch'
  'Standard'
])
param securityType string = 'TrustedLaunch'

@description('Optional. Specifies whether secure boot should be enabled on the virtual machine. This parameter is part of the UefiSettings. SecurityType should be set to TrustedLaunch to enable UefiSettings.')
param secureBootEnabled bool = true

@description('Optional. Specifies whether vTPM should be enabled on the virtual machine. This parameter is part of the UefiSettings.  SecurityType should be set to TrustedLaunch to enable UefiSettings.')
param vTpmEnabled bool = true

@description('Required. OS image reference. In case of marketplace images, it\'s the combination of the publisher, offer, sku, version attributes. In case of custom images it\'s the resource ID of the custom image.')
param imageReference imageReferenceType

@description('Optional. Specifies information about the marketplace image used to create the virtual machine. This element is only used for marketplace images. Before you can use a marketplace image from an API, you must enable the image for programmatic use.')
param plan planType?

@description('Required. Specifies the OS disk. For security reasons, it is recommended to specify DiskEncryptionSet into the osDisk object.  Restrictions: DiskEncryptionSet cannot be enabled if Azure Disk Encryption (guest-VM encryption using bitlocker/DM-Crypt) is enabled on your VMs.')
param osDisk osDiskType

@description('Optional. Specifies the data disks. For security reasons, it is recommended to specify DiskEncryptionSet into the dataDisk object. Restrictions: DiskEncryptionSet cannot be enabled if Azure Disk Encryption (guest-VM encryption using bitlocker/DM-Crypt) is enabled on your VMs.')
param dataDisks dataDiskType[]?

@description('Optional. The flag that enables or disables hibernation capability on the VM.')
param hibernationEnabled bool = false

@description('Required. Administrator username.')
@secure()
param adminUsername string

@description('Optional. When specifying a Windows Virtual Machine, this value should be passed.')
@secure()
param adminPassword string

@description('Optional. UserData for the VM, which must be base-64 encoded. Customer should not pass any secrets in here.')
param userData string = ''

@description('Optional. Custom data associated to the VM, this value will be automatically converted into base64 to account for the expected VM format.')
param customData string = ''

@description('Optional. Specifies set of certificates that should be installed onto the virtual machine.')
param certificatesToBeInstalled vaultSecretGroupType[]?

@description('Optional. Specifies the priority for the virtual machine.')
@allowed([
  'Regular'
  'Low'
  'Spot'
])
param priority string?

@description('Optional. Specifies the eviction policy for the low priority virtual machine.')
@allowed([
  'Deallocate'
  'Delete'
])
param evictionPolicy string = 'Deallocate'

@description('Optional. Specifies the maximum price you are willing to pay for a low priority VM/VMSS. This price is in US Dollars.')
param maxPriceForLowPriorityVm string = ''

@description('Optional. Specifies resource ID about the dedicated host that the virtual machine resides in.')
param dedicatedHostResourceId string = ''

@description('Optional. Specifies that the image or disk that is being used was licensed on-premises.')
@allowed([
  'RHEL_BYOS'
  'SLES_BYOS'
  'Windows_Client'
  'Windows_Server'
])
param licenseType string?

@description('Optional. The list of SSH public keys used to authenticate with linux based VMs.')
param publicKeys publicKeyType[] = []

@description('Optional. The managed identity definition for this resource.')
param managedIdentities managedIdentitiesType

@description('Optional. Whether boot diagnostics should be enabled on the Virtual Machine. Boot diagnostics will be enabled with a managed storage account if no bootDiagnosticsStorageAccountName value is provided. If bootDiagnostics and bootDiagnosticsStorageAccountName values are not provided, boot diagnostics will be disabled.')
param bootDiagnostics bool = false

@description('Optional. Custom storage account used to store boot diagnostic information. Boot diagnostics will be enabled with a custom storage account if a value is provided.')
param bootDiagnosticStorageAccountName string = ''

@description('Optional. Storage account boot diagnostic base URI.')
param bootDiagnosticStorageAccountUri string = '.blob.${environment().suffixes.storage}/'

@description('Optional. Resource ID of a proximity placement group.')
param proximityPlacementGroupResourceId string = ''

@description('Optional. Resource ID of a virtual machine scale set, where the VM should be added.')
param virtualMachineScaleSetResourceId string = ''

@description('Optional. Resource ID of an availability set. Cannot be used in combination with availability zone nor scale set.')
param availabilitySetResourceId string = ''

@description('Optional. Specifies the gallery applications that should be made available to the VM/VMSS.')
param galleryApplications vmGalleryApplicationType[]?

@description('Required. If set to 1, 2 or 3, the availability zone is hardcoded to that value. If set to -1, no zone is defined. Note that the availability zone numbers here are the logical availability zone in your Azure subscription. Different subscriptions might have a different mapping of the physical zone and logical zone. To understand more, please refer to [Physical and logical availability zones](https://learn.microsoft.com/en-us/azure/reliability/availability-zones-overview?tabs=azure-cli#physical-and-logical-availability-zones).')
@allowed([
  -1
  1
  2
  3
])
param availabilityZone int = -1

// External resources

@description('Optional. Recovery service vault name to add VMs to backup.')
param backupVaultName string = ''

@description('Optional. Resource group of the backup recovery service vault. If not provided the current resource group name is considered by default.')
param backupVaultResourceGroup string = resourceGroup().name

@description('Optional. Backup policy the VMs should be using for backup. If not provided, it will use the DefaultPolicy from the backup recovery service vault.')
param backupPolicyName string = 'DefaultPolicy'

@description('Optional. The configuration for auto-shutdown.')
param autoShutdownConfig autoShutDownConfigType = {}

// Child resources
@description('Optional. Specifies whether extension operations should be allowed on the virtual machine. This may only be set to False when no extensions are present on the virtual machine.')
param allowExtensionOperations bool = true

@description('Optional. The configuration for the [AAD Join] extension. Must at least contain the ["enabled": true] property to be executed. To enroll in Intune, add the setting mdmId: "0000000a-0000-0000-c000-000000000000".')
param extensionAadJoinConfig object = {
  enabled: true
}

@description('Optional. The configuration for the [Anti Malware] extension. Must at least contain the ["enabled": true] property to be executed.')
param extensionAntiMalwareConfig object = osType == 'Windows'
  ? {
      enabled: false
    }
  : { enabled: false }

@description('Optional. The configuration for the [Monitoring Agent] extension. Must at least contain the ["enabled": true] property to be executed.')
param extensionMonitoringAgentConfig object = {
  enabled: false
  dataCollectionRuleAssociations: []
}

@description('Optional. The configuration for the [Guest Configuration] extension. Must at least contain the ["enabled": true] property to be executed. Needs a managed identity.')
param extensionGuestConfigurationExtension object = {
  enabled: false
}

@description('Optional. The configuration for the [Dependency Agent] extension. Must at least contain the ["enabled": true] property to be executed.')
param extensionDependencyAgentConfig object = {
  enabled: false
}

@description('Optional. The configuration for the [Network Watcher Agent] extension. Must at least contain the ["enabled": true] property to be executed.')
param extensionNetworkWatcherAgentConfig object = {
  enabled: false
}

@description('Optional. The configuration for the [Custom Script] extension.')
param extensionCustomScriptConfig extensionCustomScriptConfigType?

// Shared parameters
@description('Optional. Location for all resources.')
param location string = resourceGroup().location

@description('Gets or sets a list of key value pairs that describe the resource. These tags can be used for viewing and grouping this resource (across resource groups). A maximum of 15 tags can be provided for a resource. Each tag must have a key with a length no greater than 128 characters and a value with a length no greater than 256 characters.')
param tags object = {}

@description('Required. The chosen OS type.')
@allowed([
  'Windows'
  'Linux'
])
param osType string

@description('Optional. Specifies whether password authentication should be disabled.')
#disable-next-line secure-secrets-in-params // Not a secret
param disablePasswordAuthentication bool = false

@description('Optional. Indicates whether virtual machine agent should be provisioned on the virtual machine. When this property is not specified in the request body, default behavior is to set it to true. This will ensure that VM Agent is installed on the VM so that extensions can be added to the VM later.')
param provisionVMAgent bool = true

@description('Optional. Indicates whether Automatic Updates is enabled for the Windows virtual machine. Default value is true. When patchMode is set to Manual, this parameter must be set to false. For virtual machine scale sets, this property can be updated and updates will take effect on OS reprovisioning.')
param enableAutomaticUpdates bool = true //default true

@description('Optional. VM guest patching orchestration mode. \'AutomaticByOS\' & \'Manual\' are for Windows only, \'ImageDefault\' for Linux only. Refer to \'https://learn.microsoft.com/en-us/azure/virtual-machines/automatic-vm-guest-patching\'.')
@allowed([
  'AutomaticByPlatform'
  'AutomaticByOS'
  'Manual'
  'ImageDefault'
  ''
])
param patchMode string = ''

@description('Optional. Enables customer to schedule patching without accidental upgrades.')
param bypassPlatformSafetyChecksOnUserSchedule bool = true

@description('Optional. Specifies the reboot setting for all AutomaticByPlatform patch installation operations.')
@allowed([
  'Always'
  'IfRequired'
  'Never'
  'Unknown'
])
param rebootSetting string = 'IfRequired'

@description('Optional. VM guest patching assessment mode. Set it to \'AutomaticByPlatform\' to enable automatically check for updates every 24 hours.')
@allowed([
  'AutomaticByPlatform'
  'ImageDefault'
])
param patchAssessmentMode string = 'AutomaticByPlatform'

@description('Optional. Enables customers to patch their Azure VMs without requiring a reboot. For enableHotpatching, the \'provisionVMAgent\' must be set to true and \'patchMode\' must be set to \'AutomaticByPlatform\'.')
param enableHotpatching bool = true

@description('Optional. Specifies the time zone of the virtual machine. e.g. \'Pacific Standard Time\'. Possible values can be `TimeZoneInfo.id` value from time zones returned by `TimeZoneInfo.GetSystemTimeZones`.')
param timeZone string = ''

@description('Optional. Specifies additional XML formatted information that can be included in the Unattend.xml file, which is used by Windows Setup. Contents are defined by setting name, component name, and the pass in which the content is applied.')
param additionalUnattendContent additionalUnattendContentType[]?

@description('Optional. Specifies the Windows Remote Management listeners. This enables remote Windows PowerShell.')
param winRMListeners winRMListenerType[]?

@description('Optional. Capacity reservation group resource id that should be used for allocating the virtual machine vm instances provided enough capacity has been reserved.')
param capacityReservationGroupResourceId string = ''

@allowed([
  'AllowAll'
  'AllowPrivate'
  'DenyAll'
])
@description('Optional. Policy for accessing the disk via network.')
param networkAccessPolicy string = 'DenyAll'

@allowed([
  'Disabled'
  'Enabled'
])
@description('Optional. Policy for controlling export on the disk.')
param publicNetworkAccess string = 'Disabled'

var publicKeysFormatted = [
  for publicKey in publicKeys: {
    path: publicKey.path
    keyData: publicKey.keyData
  }
]

var linuxConfiguration = {
  disablePasswordAuthentication: disablePasswordAuthentication
  ssh: {
    publicKeys: publicKeysFormatted
  }
  provisionVMAgent: provisionVMAgent
  patchSettings: (provisionVMAgent && (patchMode =~ 'AutomaticByPlatform' || patchMode =~ 'ImageDefault'))
    ? {
        patchMode: patchMode
        assessmentMode: patchAssessmentMode
        automaticByPlatformSettings: (patchMode =~ 'AutomaticByPlatform')
          ? {
              bypassPlatformSafetyChecksOnUserSchedule: bypassPlatformSafetyChecksOnUserSchedule
              rebootSetting: rebootSetting
            }
          : null
      }
    : null
}

var additionalUnattendContentFormatted = [
  for (unattendContent, index) in additionalUnattendContent ?? []: {
    settingName: unattendContent.settingName
    content: unattendContent.content
    componentName: 'Microsoft-Windows-Shell-Setup'
    passName: 'OobeSystem'
  }
]

var windowsConfiguration = {
  provisionVMAgent: provisionVMAgent
  enableAutomaticUpdates: enableAutomaticUpdates
  patchSettings: (provisionVMAgent && (patchMode =~ 'AutomaticByPlatform' || patchMode =~ 'AutomaticByOS' || patchMode =~ 'Manual'))
    ? {
        patchMode: patchMode
        assessmentMode: patchAssessmentMode
        enableHotpatching: (patchMode =~ 'AutomaticByPlatform') ? enableHotpatching : false
        automaticByPlatformSettings: (patchMode =~ 'AutomaticByPlatform')
          ? {
              bypassPlatformSafetyChecksOnUserSchedule: bypassPlatformSafetyChecksOnUserSchedule
              rebootSetting: rebootSetting
            }
          : null
      }
    : null
  timeZone: empty(timeZone) ? null : timeZone
  additionalUnattendContent: empty(additionalUnattendContent) ? null : additionalUnattendContentFormatted
  winRM: !empty(winRMListeners)
    ? {
        listeners: winRMListeners
      }
    : null
}

var formattedUserAssignedIdentities = reduce(
  map((managedIdentities.?userAssignedResourceIds ?? []), (id) => { '${id}': {} }),
  {},
  (cur, next) => union(cur, next)
) // Converts the flat array to an object like { '${id1}': {}, '${id2}': {} }

//If AADJoin Extension is enabled then we automatically enable SystemAssigned (required by AADJoin), otherwise we follow the usual logic.
var identity = !empty(managedIdentities)
  ? {
      type: (extensionAadJoinConfig.enabled ? true : (managedIdentities.?systemAssigned ?? true))
        ? (!empty(managedIdentities.?userAssignedResourceIds ?? {}) ? 'SystemAssigned, UserAssigned' : 'SystemAssigned')
        : (!empty(managedIdentities.?userAssignedResourceIds ?? {}) ? 'UserAssigned' : null)
      userAssignedIdentities: !empty(formattedUserAssignedIdentities) ? formattedUserAssignedIdentities : null
    }
  : null

@description('Private IP Allocation Method')
@allowed([
  'Static'
  'Dynamic'
])
param ipallocation string = 'Dynamic'

@description('The ID of the subnet from which the private IP will be allocated.')
param subnetId string

@description('VM IP Array')
param vmip array = []

resource static_nic_array 'Microsoft.Network/networkInterfaces@2024-05-01' = if (ipallocation == 'Static') {
  name: 'NIC-${name}s-01'
  location: location
  properties: {
    ipConfigurations: [
      for (item, i) in vmip: {
        name: 'ipcnfg${name}0${i+1}'
        properties: {
          privateIPAllocationMethod: ipallocation
          privateIPAddress: vmip[i]
          primary: (i == 0) ? true : false
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

resource dynamic_nic 'Microsoft.Network/networkInterfaces@2024-05-01' = if (ipallocation == 'Dynamic') {
  name: 'NIC-${name}d-01'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipcnfg${name}01'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}

resource managedDataDisks 'Microsoft.Compute/disks@2024-03-02' = [
  for (dataDisk, index) in dataDisks ?? []: if (empty(dataDisk.managedDisk.?id)) {
    location: location
    name: dataDisk.?name ?? '${name}-disk-data-${padLeft((index + 1), 2, '0')}'
    sku: {
      name: dataDisk.managedDisk.?storageAccountType
    }
    properties: {
      diskSizeGB: dataDisk.diskSizeGB
      creationData: {
        createOption: dataDisk.?createoption ?? 'Empty'
      }
      diskIOPSReadWrite: dataDisk.?diskIOPSReadWrite
      diskMBpsReadWrite: dataDisk.?diskMBpsReadWrite
      publicNetworkAccess: publicNetworkAccess
      networkAccessPolicy: networkAccessPolicy
    }
    zones: availabilityZone != -1 && !contains(dataDisk.managedDisk.?storageAccountType, 'ZRS')
      ? array(string(availabilityZone))
      : null
  }
]

resource vm 'Microsoft.Compute/virtualMachines@2025-04-01' = {
  name: name
  location: location
  identity: identity
  tags: tags
  zones: availabilityZone != -1 ? array(string(availabilityZone)) : null
  plan: plan
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    securityProfile: {
      ...(encryptionAtHost ? { encryptionAtHost: encryptionAtHost } : {}) // Using shallow merge as even providing the property with `false` requires the feature to be registered
      securityType: securityType
      uefiSettings: securityType == 'TrustedLaunch'
        ? {
            secureBootEnabled: secureBootEnabled
            vTpmEnabled: vTpmEnabled
          }
        : null
    }
    storageProfile: {
      imageReference: imageReference
      osDisk: {
        name: osDisk.?name ?? '${name}-disk-os-01'
        createOption: osDisk.?createOption ?? 'FromImage'
        deleteOption: osDisk.?deleteOption ?? 'Delete'
        diffDiskSettings: empty(osDisk.?diffDiskSettings ?? {})
          ? null
          : {
              option: 'Local'
              placement: osDisk.diffDiskSettings!.placement
            }
        diskSizeGB: osDisk.?diskSizeGB ?? 128
        caching: osDisk.?caching ?? 'ReadWrite'
        managedDisk: {
          storageAccountType: osDisk.managedDisk.?storageAccountType ?? 'StandardSSD_LRS'
          diskEncryptionSet: {
            id: osDisk.managedDisk.?diskEncryptionSetResourceId
          }
        }
      }
      dataDisks: [
        for (dataDisk, index) in dataDisks ?? []: {
          lun: dataDisk.?lun ?? index
          name: !empty(dataDisk.managedDisk.?id)
            ? last(split(dataDisk.managedDisk.id ?? '', '/'))
            : dataDisk.?name ?? '${name}-disk-data-${padLeft((index + 1), 2, '0')}'
          createOption: (managedDataDisks[index].?id != null || !empty(dataDisk.managedDisk.?id))
            ? 'Attach'
            : dataDisk.?createoption ?? 'Empty'
          deleteOption: !empty(dataDisk.managedDisk.?id) ? 'Detach' : dataDisk.?deleteOption ?? 'Delete'
          caching: !empty(dataDisk.managedDisk.?id) ? 'None' : dataDisk.?caching ?? 'ReadOnly'
          managedDisk: {
            id: dataDisk.managedDisk.?id ?? managedDataDisks[index].?id
            diskEncryptionSet: contains(dataDisk.managedDisk, 'diskEncryptionSet')
              ? {
                  id: dataDisk.managedDisk.diskEncryptionSet.id
                }
              : null
          }
        }
      ]
    }
    additionalCapabilities: {
      hibernationEnabled: hibernationEnabled
    }
    osProfile: {
      computerName: computerName
      adminUsername: adminUsername
      adminPassword: adminPassword
      customData: !empty(customData) ? base64(customData) : null
      windowsConfiguration: osType == 'Windows' ? windowsConfiguration : null
      linuxConfiguration: osType == 'Linux' ? linuxConfiguration : null
      secrets: certificatesToBeInstalled
      allowExtensionOperations: allowExtensionOperations
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: (ipallocation == 'Static') ? (static_nic_array.id) : (dynamic_nic.id)
        }
      ]
    }
    capacityReservation: !empty(capacityReservationGroupResourceId)
      ? {
          capacityReservationGroup: {
            id: capacityReservationGroupResourceId
          }
        }
      : null
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: !empty(bootDiagnosticStorageAccountName) ? true : bootDiagnostics
        storageUri: !empty(bootDiagnosticStorageAccountName)
          ? 'https://${bootDiagnosticStorageAccountName}${bootDiagnosticStorageAccountUri}'
          : null
      }
    }
    applicationProfile: !empty(galleryApplications)
      ? {
          galleryApplications: galleryApplications
        }
      : null
    availabilitySet: !empty(availabilitySetResourceId)
      ? {
          id: availabilitySetResourceId
        }
      : null
    proximityPlacementGroup: !empty(proximityPlacementGroupResourceId)
      ? {
          id: proximityPlacementGroupResourceId
        }
      : null
    virtualMachineScaleSet: !empty(virtualMachineScaleSetResourceId)
      ? {
          id: virtualMachineScaleSetResourceId
        }
      : null
    priority: priority
    evictionPolicy: !empty(priority) && priority != 'Regular' ? evictionPolicy : null
    #disable-next-line BCP036
    billingProfile: !empty(priority) && !empty(maxPriceForLowPriorityVm)
      ? {
          maxPrice: json(maxPriceForLowPriorityVm)
        }
      : null
    host: !empty(dedicatedHostResourceId)
      ? {
          id: dedicatedHostResourceId
        }
      : null
    licenseType: licenseType
    userData: !empty(userData) ? base64(userData) : null
  }
}

resource vm_autoShutdownConfiguration 'Microsoft.DevTestLab/schedules@2018-09-15' = if (!empty(autoShutdownConfig)) {
  name: 'shutdown-computevm-${vm.name}'
  location: location
  properties: {
    status: autoShutdownConfig.?status ?? 'Disabled'
    targetResourceId: vm.id
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: autoShutdownConfig.?dailyRecurrenceTime ?? '19:00'
    }
    timeZoneId: autoShutdownConfig.?timeZone ?? 'UTC'
    notificationSettings: contains(autoShutdownConfig, 'notificationSettings')
      ? {
          status: autoShutdownConfig.?status ?? 'Disabled'
          emailRecipient: autoShutdownConfig.?notificationSettings.?emailRecipient ?? ''
          notificationLocale: autoShutdownConfig.?notificationSettings.?notificationLocale ?? 'en'
          webhookUrl: autoShutdownConfig.?notificationSettings.?webhookUrl ?? ''
          timeInMinutes: autoShutdownConfig.?notificationSettings.?timeInMinutes ?? 30
        }
      : null
  }
}

module vm_aadJoinExtension 'modules/extension.bicep' = if (extensionAadJoinConfig.enabled) {
  name: '${uniqueString(deployment().name, location)}-VM-AADLogin'
  params: {
    virtualMachineName: vm.name
    name: extensionAadJoinConfig.?name ?? 'AADLogin'
    location: location
    publisher: 'Microsoft.Azure.ActiveDirectory'
    type: osType == 'Windows' ? 'AADLoginForWindows' : 'AADSSHLoginforLinux'
    typeHandlerVersion: extensionAadJoinConfig.?typeHandlerVersion ?? (osType == 'Windows' ? '2.0' : '1.0')
    autoUpgradeMinorVersion: extensionAadJoinConfig.?autoUpgradeMinorVersion ?? true
    enableAutomaticUpgrade: extensionAadJoinConfig.?enableAutomaticUpgrade ?? false
    settings: extensionAadJoinConfig.?settings ?? {}
    suppressFailures: extensionAadJoinConfig.?suppressFailures ?? false
  }
}

module vm_microsoftAntiMalwareExtension 'modules/extension.bicep' = if (extensionAntiMalwareConfig.enabled) {
  name: '${uniqueString(deployment().name, location)}-VM-MicrosoftAntiMalware'
  params: {
    virtualMachineName: vm.name
    name: extensionAntiMalwareConfig.?name ?? 'MicrosoftAntiMalware'
    location: location
    publisher: 'Microsoft.Azure.Security'
    type: 'IaaSAntimalware'
    typeHandlerVersion: extensionAntiMalwareConfig.?typeHandlerVersion ?? '1.3'
    autoUpgradeMinorVersion: extensionAntiMalwareConfig.?autoUpgradeMinorVersion ?? true
    enableAutomaticUpgrade: extensionAntiMalwareConfig.?enableAutomaticUpgrade ?? false
    settings: extensionAntiMalwareConfig.?settings ?? {
      AntimalwareEnabled: 'true'
      Exclusions: {}
      RealtimeProtectionEnabled: 'true'
      ScheduledScanSettings: {
        day: '7'
        isEnabled: 'true'
        scanType: 'Quick'
        time: '120'
      }
    }
    suppressFailures: extensionAntiMalwareConfig.?suppressFailures ?? false
  }
  dependsOn: [
    vm_aadJoinExtension
  ]
}

module vm_azureGuestConfigurationExtension 'modules/extension.bicep' = if (extensionGuestConfigurationExtension.enabled) {
  name: '${uniqueString(deployment().name, location)}-VM-GuestConfiguration'
  params: {
    virtualMachineName: vm.name
    name: extensionGuestConfigurationExtension.?name ?? osType == 'Windows'
      ? 'AzurePolicyforWindows'
      : 'AzurePolicyforLinux'
    location: location
    publisher: 'Microsoft.GuestConfiguration'
    type: osType == 'Windows' ? 'ConfigurationforWindows' : 'ConfigurationForLinux'
    typeHandlerVersion: extensionGuestConfigurationExtension.?typeHandlerVersion ?? (osType == 'Windows' ? '1.0' : '1.0')
    autoUpgradeMinorVersion: extensionGuestConfigurationExtension.?autoUpgradeMinorVersion ?? true
    enableAutomaticUpgrade: extensionGuestConfigurationExtension.?enableAutomaticUpgrade ?? true
    forceUpdateTag: extensionGuestConfigurationExtension.?forceUpdateTag ?? '1.0'
    settings: extensionGuestConfigurationExtension.?settings ?? {}
    suppressFailures: extensionGuestConfigurationExtension.?suppressFailures ?? false
    protectedSettings: extensionGuestConfigurationExtension.?protectedSettings
  }
}

module vm_azureMonitorAgentExtension 'modules/extension.bicep' = if (extensionMonitoringAgentConfig.enabled) {
  name: '${uniqueString(deployment().name, location)}-VM-AzureMonitorAgent'
  params: {
    virtualMachineName: vm.name
    name: extensionMonitoringAgentConfig.?name ?? 'AzureMonitorAgent'
    location: location
    publisher: 'Microsoft.Azure.Monitor'
    type: osType == 'Windows' ? 'AzureMonitorWindowsAgent' : 'AzureMonitorLinuxAgent'
    typeHandlerVersion: extensionMonitoringAgentConfig.?typeHandlerVersion ?? (osType == 'Windows' ? '1.2' : '1.29')
    autoUpgradeMinorVersion: extensionMonitoringAgentConfig.?autoUpgradeMinorVersion ?? true
    enableAutomaticUpgrade: extensionMonitoringAgentConfig.?enableAutomaticUpgrade ?? false
    suppressFailures: extensionMonitoringAgentConfig.?suppressFailures ?? false
  }
  dependsOn: [
    vm_microsoftAntiMalwareExtension
  ]
}

module vm_dependencyAgentExtension 'modules/extension.bicep' = if (extensionDependencyAgentConfig.enabled) {
  name: '${uniqueString(deployment().name, location)}-VM-DependencyAgent'
  params: {
    virtualMachineName: vm.name
    name: extensionDependencyAgentConfig.?name ?? 'DependencyAgent'
    location: location
    publisher: 'Microsoft.Azure.Monitoring.DependencyAgent'
    type: osType == 'Windows' ? 'DependencyAgentWindows' : 'DependencyAgentLinux'
    typeHandlerVersion: extensionDependencyAgentConfig.?typeHandlerVersion ?? '9.10'
    autoUpgradeMinorVersion: extensionDependencyAgentConfig.?autoUpgradeMinorVersion ?? true
    enableAutomaticUpgrade: extensionDependencyAgentConfig.?enableAutomaticUpgrade ?? true
    settings: {
      enableAMA: extensionDependencyAgentConfig.?enableAMA ?? true
    }
    suppressFailures: extensionDependencyAgentConfig.?suppressFailures ?? false
  }
}

module vm_networkWatcherAgentExtension 'modules/extension.bicep' = if (extensionNetworkWatcherAgentConfig.enabled) {
  name: '${uniqueString(deployment().name, location)}-VM-NetworkWatcherAgent'
  params: {
    virtualMachineName: vm.name
    name: extensionNetworkWatcherAgentConfig.?name ?? 'NetworkWatcherAgent'
    location: location
    publisher: 'Microsoft.Azure.NetworkWatcher'

    type: osType == 'Windows' ? 'NetworkWatcherAgentWindows' : 'NetworkWatcherAgentLinux'
    typeHandlerVersion: extensionNetworkWatcherAgentConfig.?typeHandlerVersion ?? '1.4'
    autoUpgradeMinorVersion: extensionNetworkWatcherAgentConfig.?autoUpgradeMinorVersion ?? true
    enableAutomaticUpgrade: extensionNetworkWatcherAgentConfig.?enableAutomaticUpgrade ?? false
    suppressFailures: extensionNetworkWatcherAgentConfig.?suppressFailures ?? false
  }
  dependsOn: [
    vm_dependencyAgentExtension
  ]
}

resource cseIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2024-11-30' existing = if (!empty(extensionCustomScriptConfig.?protectedSettings.?managedIdentityResourceId)) {
  name: last(split(extensionCustomScriptConfig!.protectedSettings!.managedIdentityResourceId!, '/'))
  scope: resourceGroup(
    split(extensionCustomScriptConfig!.protectedSettings!.managedIdentityResourceId!, '/')[2],
    split(extensionCustomScriptConfig!.protectedSettings!.managedIdentityResourceId!, '/')[4]
  )
}

module vm_customScriptExtension 'modules/extension.bicep' = if (!empty(extensionCustomScriptConfig)) {
  name: '${uniqueString(deployment().name, location)}-VM-CustomScriptExtension'
  params: {
    virtualMachineName: vm.name
    name: extensionCustomScriptConfig.?name ?? 'CustomScriptExtension'
    location: location
    publisher: osType == 'Windows' ? 'Microsoft.Compute' : 'Microsoft.Azure.Extensions'
    type: osType == 'Windows' ? 'CustomScriptExtension' : 'CustomScript'
    typeHandlerVersion: extensionCustomScriptConfig.?typeHandlerVersion ?? (osType == 'Windows' ? '1.10' : '2.1')
    autoUpgradeMinorVersion: extensionCustomScriptConfig.?autoUpgradeMinorVersion ?? true
    enableAutomaticUpgrade: extensionCustomScriptConfig.?enableAutomaticUpgrade ?? false
    forceUpdateTag: extensionCustomScriptConfig.?forceUpdateTag
    suppressFailures: extensionCustomScriptConfig.?suppressFailures ?? false
    settings: {
      ...(!empty(extensionCustomScriptConfig!.?settings.?commandToExecute)
        ? { commandToExecute: extensionCustomScriptConfig!.?settings.?commandToExecute }
        : {})
      ...(!empty(extensionCustomScriptConfig!.?settings.?fileUris)
        ? { fileUris: extensionCustomScriptConfig!.?settings.fileUris }
        : {})
    }
    protectedSettings: {
      ...(!empty(extensionCustomScriptConfig!.?protectedSettings.?commandToExecute)
        ? { commandToExecute: extensionCustomScriptConfig!.protectedSettings!.?commandToExecute }
        : {})
      ...(!empty(extensionCustomScriptConfig!.?protectedSettings.?storageAccountName)
        ? { storageAccountName: extensionCustomScriptConfig!.protectedSettings!.storageAccountName! }
        : {})
      ...(!empty(extensionCustomScriptConfig!.?protectedSettings.?storageAccountKey)
        ? { storageAccountKey: extensionCustomScriptConfig!.protectedSettings!.storageAccountKey! }
        : {})
      ...(!empty(extensionCustomScriptConfig!.?protectedSettings.?fileUris)
        ? { fileUris: extensionCustomScriptConfig!.protectedSettings!.fileUris! }
        : {})
      ...(extensionCustomScriptConfig!.?protectedSettings.?managedIdentityResourceId != null
        ? {
            managedIdentity: !empty(extensionCustomScriptConfig!.protectedSettings!.?managedIdentityResourceId)
              ? {
                  clientId: cseIdentity!.properties.clientId // Uses user-assigned
                }
              : {} // Uses system-assigned
          }
        : {})
    }
  }
}

module vm_backup 'modules/protected-item.bicep' = if (!empty(backupVaultName)) {
  name: '${uniqueString(deployment().name, location)}-VM-Backup'
  params: {
    name: 'vm;iaasvmcontainerv2;${resourceGroup().name};${vm.name}'
    location: location
    policyId: az.resourceId(
      backupVaultResourceGroup,
      'Microsoft.RecoveryServices/vaults/backupPolicies',
      backupVaultName,
      backupPolicyName
    )
    protectedItemType: 'Microsoft.Compute/virtualMachines'
    protectionContainerName: 'iaasvmcontainer;iaasvmcontainerv2;${resourceGroup().name};${vm.name}'
    recoveryVaultName: backupVaultName
    sourceResourceId: vm.id
  }
  scope: az.resourceGroup(backupVaultResourceGroup)
}

@description('The name of the VM.')
output name string = vm.name

@description('The resource ID of the VM.')
output resourceId string = vm.id

@description('The name of the resource group the VM was created in.')
output resourceGroupName string = resourceGroup().name

@description('The principal ID of the system assigned identity.')
output systemAssignedMIPrincipalId string? = vm.?identity.?principalId

@description('The location the resource was deployed into.')
output location string = vm.location

// =============== //
//   Definitions   //
// =============== //

@export()
@description('The type describing an OS disk.')
type osDiskType = {
  @description('Optional. The disk name.')
  name: string?

  @description('Optional. Specifies the size of an empty data disk in gigabytes.')
  diskSizeGB: int?

  @description('Optional. Specifies how the virtual machine should be created.')
  createOption: 'Attach' | 'Empty' | 'FromImage'?

  @description('Optional. Specifies whether data disk should be deleted or detached upon VM deletion.')
  deleteOption: 'Delete' | 'Detach'?

  @description('Optional. Specifies the caching requirements.')
  caching: 'None' | 'ReadOnly' | 'ReadWrite'?

  @description('Optional. Specifies the ephemeral Disk Settings for the operating system disk.')
  diffDiskSettings: {
    @description('Required. Specifies the ephemeral disk placement for the operating system disk.')
    placement: ('CacheDisk' | 'NvmeDisk' | 'ResourceDisk')
  }?

  @description('Required. The managed disk parameters.')
  managedDisk: {
    @description('Optional. Specifies the storage account type for the managed disk.')
    storageAccountType:
      | 'PremiumV2_LRS'
      | 'Premium_LRS'
      | 'Premium_ZRS'
      | 'StandardSSD_LRS'
      | 'StandardSSD_ZRS'
      | 'Standard_LRS'
      | 'UltraSSD_LRS'?

    @description('Optional. Specifies the customer managed disk encryption set resource id for the managed disk.')
    diskEncryptionSetResourceId: string?
  }
}

@export()
@description('The type describing a data disk.')
type dataDiskType = {
  @description('Optional. The disk name. When attaching a pre-existing disk, this name is ignored and the name of the existing disk is used.')
  name: string?

  @description('Optional. Specifies the logical unit number of the data disk.')
  lun: int?

  @description('Optional. Specifies the size of an empty data disk in gigabytes. This property is ignored when attaching a pre-existing disk.')
  diskSizeGB: int?

  @description('Optional. Specifies how the virtual machine should be created. This property is automatically set to \'Attach\' when attaching a pre-existing disk.')
  createOption: 'Attach' | 'Empty' | 'FromImage'?

  @description('Optional. Specifies whether data disk should be deleted or detached upon VM deletion. This property is automatically set to \'Detach\' when attaching a pre-existing disk.')
  deleteOption: 'Delete' | 'Detach'?

  @description('Optional. Specifies the caching requirements. This property is automatically set to \'None\' when attaching a pre-existing disk.')
  caching: 'None' | 'ReadOnly' | 'ReadWrite'?

  @description('Optional. The number of IOPS allowed for this disk; only settable for UltraSSD disks. One operation can transfer between 4k and 256k bytes. Ignored when attaching a pre-existing disk.')
  diskIOPSReadWrite: int?

  @description('Optional. The bandwidth allowed for this disk; only settable for UltraSSD disks. MBps means millions of bytes per second - MB here uses the ISO notation, of powers of 10. Ignored when attaching a pre-existing disk.')
  diskMBpsReadWrite: int?

  @description('Required. The managed disk parameters.')
  managedDisk: {
    @description('Optional. Specifies the storage account type for the managed disk. Ignored when attaching a pre-existing disk.')
    storageAccountType:
      | 'PremiumV2_LRS'
      | 'Premium_LRS'
      | 'Premium_ZRS'
      | 'StandardSSD_LRS'
      | 'StandardSSD_ZRS'
      | 'Standard_LRS'
      | 'UltraSSD_LRS'?

    @description('Optional. Specifies the customer managed disk encryption set resource id for the managed disk.')
    diskEncryptionSetResourceId: string?

    @description('Optional. Specifies the resource id of a pre-existing managed disk. If the disk should be created, this property should be empty.')
    id: string?
  }
}

type publicKeyType = {
  @description('Required. Specifies the SSH public key data used to authenticate through ssh.')
  keyData: string

  @description('Required. Specifies the full path on the created VM where ssh public key is stored. If the file already exists, the specified key is appended to the file.')
  path: string
}

import { subResourceType } from 'br/public:avm/res/network/network-interface:0.5.1'

@export()
@description('The type describing the image reference.')
type imageReferenceType = {
  @description('Optional. Specified the community gallery image unique id for vm deployment. This can be fetched from community gallery image GET call.')
  communityGalleryImageId: string?

  @description('Optional. The resource Id of the image reference.')
  id: string?

  @description('Optional. Specifies the offer of the platform image or marketplace image used to create the virtual machine.')
  offer: string?

  @description('Optional. The image publisher.')
  publisher: string?

  @description('Optional. The SKU of the image.')
  sku: string?

  @description('Optional. Specifies the version of the platform image or marketplace image used to create the virtual machine. The allowed formats are Major.Minor.Build or \'latest\'. Even if you use \'latest\', the VM image will not automatically update after deploy time even if a new version becomes available.')
  version: string?

  @description('Optional. Specified the shared gallery image unique id for vm deployment. This can be fetched from shared gallery image GET call.')
  sharedGalleryImageId: string?
}

@export()
@description('Specifies information about the marketplace image used to create the virtual machine.')
type planType = {
  @description('Optional. The name of the plan.')
  name: string?

  @description('Optional. Specifies the product of the image from the marketplace.')
  product: string?

  @description('Optional. The publisher ID.')
  publisher: string?

  @description('Optional. The promotion code.')
  promotionCode: string?
}

@export()
@description('The type describing the set of certificates that should be installed onto the virtual machine.')
type vaultSecretGroupType = {
  @description('Optional. The relative URL of the Key Vault containing all of the certificates in VaultCertificates.')
  sourceVault: subResourceType?

  @description('Optional. The list of key vault references in SourceVault which contain certificates.')
  vaultCertificates: {
    @description('Optional. For Windows VMs, specifies the certificate store on the Virtual Machine to which the certificate should be added. The specified certificate store is implicitly in the LocalMachine account. For Linux VMs, the certificate file is placed under the /var/lib/waagent directory, with the file name <UppercaseThumbprint>.crt for the X509 certificate file and <UppercaseThumbprint>.prv for private key. Both of these files are .pem formatted.')
    certificateStore: string?

    @description('Optional. This is the URL of a certificate that has been uploaded to Key Vault as a secret.')
    certificateUrl: string?
  }[]?
}

@export()
@description('The type describing the gallery application that should be made available to the VM/VMSS.')
type vmGalleryApplicationType = {
  @description('Required. Specifies the GalleryApplicationVersion resource id on the form of /subscriptions/{SubscriptionId}/resourceGroups/{ResourceGroupName}/providers/Microsoft.Compute/galleries/{galleryName}/applications/{application}/versions/{version}.')
  packageReferenceId: string

  @description('Optional. Specifies the uri to an azure blob that will replace the default configuration for the package if provided.')
  configurationReference: string?

  @description('Optional. If set to true, when a new Gallery Application version is available in PIR/SIG, it will be automatically updated for the VM/VMSS.')
  enableAutomaticUpgrade: bool?

  @description('Optional. Specifies the order in which the packages have to be installed.')
  order: int?

  @description('Optional. If true, any failure for any operation in the VmApplication will fail the deployment.')
  treatFailureAsDeploymentFailure: bool?
}

@export()
@description('The type describing additional base-64 encoded XML formatted information that can be included in the Unattend.xml file, which is used by Windows Setup.')
type additionalUnattendContentType = {
  @description('Optional. Specifies the name of the setting to which the content applies.')
  settingName: 'FirstLogonCommands' | 'AutoLogon'?

  @description('Optional. Specifies the XML formatted content that is added to the unattend.xml file for the specified path and component. The XML must be less than 4KB and must include the root element for the setting or feature that is being inserted.')
  content: string?
}

@export()
@description('The type describing a Windows Remote Management listener.')
type winRMListenerType = {
  @description('Optional. The URL of a certificate that has been uploaded to Key Vault as a secret.')
  certificateUrl: string?

  @description('Optional. Specifies the protocol of WinRM listener.')
  protocol: 'Http' | 'Https'?
}

@export()
@description('The type of a \'CustomScriptExtension\' extension.')
type extensionCustomScriptConfigType = {
  @description('Optional. The name of the virtual machine extension. Defaults to `CustomScriptExtension`.')
  name: string?

  @description('Optional. Specifies the version of the script handler. Defaults to `1.10` for Windows and `2.1` for Linux.')
  typeHandlerVersion: string?

  @description('Optional. Indicates whether the extension should use a newer minor version if one is available at deployment time. Once deployed, however, the extension will not upgrade minor versions unless redeployed, even with this property set to true. Defaults to `true`.')
  autoUpgradeMinorVersion: bool?

  @description('Optional. How the extension handler should be forced to update even if the extension configuration has not changed.')
  forceUpdateTag: string?

  @description('Optional. The configuration of the custom script extension. Note: You can provide any property either in the `settings` or `protectedSettings` but not both. If your property contains secrets, use `protectedSettings`.')
  settings: {
    @description('Conditional. The entry point script to run. If the command contains any credentials, use the same property of the `protectedSettings` instead. Required if `protectedSettings.commandToExecute` is not provided.')
    commandToExecute: string?

    @description('Optional. URLs for files to be downloaded. If URLs are sensitive, for example, if they contain keys, this field should be specified in `protectedSettings`.')
    fileUris: string[]?
  }?

  @description('Optional. The configuration of the custom script extension. Note: You can provide any property either in the `settings` or `protectedSettings` but not both. If your property contains secrets, use `protectedSettings`.')
  @secure()
  protectedSettings: {
    @description('Conditional. The entry point script to run. Use this property if your command contains secrets such as passwords or if your file URIs are sensitive. Required if `settings.commandToExecute` is not provided.')
    commandToExecute: string?

    @description('Optional. The name of storage account. If you specify storage credentials, all fileUris values must be URLs for Azure blobs..')
    storageAccountName: string?

    @description('Optional. The access key of the storage account.')
    storageAccountKey: string?

    @description('Optional. The managed identity for downloading files. Must not be used in conjunction with the `storageAccountName` or `storageAccountKey` property. If you want to use the VM\'s system assigned identity, set the `value` to an empty string.')
    managedIdentityResourceId: string?

    @description('Optional. URLs for files to be downloaded.')
    fileUris: string[]?
  }?

  @description('Optional. Indicates whether failures stemming from the extension will be suppressed (Operational failures such as not connecting to the VM will not be suppressed regardless of this value). Defaults to `false`.')
  suppressFailures: bool?

  @description('Optional. Indicates whether the extension should be automatically upgraded by the platform if there is a newer version of the extension available. Defaults to `false`.')
  enableAutomaticUpgrade: bool?
}

type managedIdentitiesType = {
  @description('Optional. Enables system assigned managed identity on the resource.')
  systemAssigned: bool?

  @description('Optional. The resource ID(s) to assign to the resource.')
  userAssignedResourceIds: string[]?
}?

@export()
@description('The type describing the configuration profile.')
type autoShutDownConfigType = {
  @description('Optional. The status of the auto shutdown configuration.')
  status: 'Enabled' | 'Disabled'?

  @description('Optional. The time zone ID (e.g. China Standard Time, Greenland Standard Time, Pacific Standard time, etc.).')
  timeZone: string?

  @description('Optional. The time of day the schedule will occur.')
  dailyRecurrenceTime: string?

  @description('Optional. The resource ID of the schedule.')
  notificationSettings: {
    @description('Optional. The status of the notification settings.')
    status: 'Enabled' | 'Disabled'?

    @description('Optional. The email address to send notifications to (can be a list of semi-colon separated email addresses).')
    emailRecipient: string?

    @description('Optional. The locale to use when sending a notification (fallback for unsupported languages is EN).')
    notificationLocale: string?

    @description('Optional. The webhook URL to which the notification will be sent.')
    webhookUrl: string?

    @description('Optional. The time in minutes before shutdown to send notifications.')
    timeInMinutes: int?
  }?
}
