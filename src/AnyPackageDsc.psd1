@{
    RootModule = 'AnyPackageDsc.psm1'
    ModuleVersion = '0.2.0'
    CompatiblePSEditions = @('Desktop', 'Core')
    GUID = 'e5131fb7-67c1-4068-b20b-9bc8b03d6976'
    Author = 'Thomas Nieto'
    Copyright = '(c) 2025 Thomas Nieto. All rights reserved.'
    Description = 'AnyPackage DSC resources.'
    RequiredModules = @('AnyPackage')
    PowerShellVersion = '5.1'
    FunctionsToExport = @()
    CmdletsToExport = @()
    DscResourcesToExport = @('Package', 'Source')
    PrivateData = @{
        PSData = @{
            Tags = @('DesiredStateConfiguration', 'DSC', 'DSCResource', 'AnyPackage', 'Windows', 'Linux', 'MacOS')
            LicenseUri = 'https://github.com/anypackage/dsc/blob/main/LICENSE'
            ProjectUri = 'https://github.com/anypackage/dsc'
        }
    }
}
