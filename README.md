# AnyPackageDsc

[![gallery-image]][gallery-site]
[![build-image]][build-site]
[![cf-image]][cf-site]

[gallery-image]: https://img.shields.io/powershellgallery/dt/AnyPackageDsc
[build-image]: https://img.shields.io/github/actions/workflow/status/anypackage/dsc/ci.yml
[cf-image]: https://img.shields.io/codefactor/grade/github/anypackage/dsc
[gallery-site]: https://www.powershellgallery.com/packages/AnyPackageDsc
[build-site]: https://github.com/anypackage/dsc/actions/workflows/ci.yml
[cf-site]: https://www.codefactor.io/repository/github/anypackage/dsc


AnyPackage DSC resources module.

## Install AnyPackageDsc

```powershell
Install-Module AnyPackageDsc
```

## Documentation

Documentation is located in the [AnyPackage-Docs](https://github.com/AnyPackage/AnyPackage-Docs) repository.

## Known Issues

### DSC Resources Not Found

The `AnyPackageDsc` or `AnyPackage` module has to be imported before `Get-DscResource` or `Invoke-DscResource` will find the resource.
`AnyPackageDsc` requires types in `AnyPackage` and is most likely the issue with how `PSDesiredStateConfiguration` finds resources.
An issue has been logged and you can follow PowerShell/PSDesiredStateConfiguration#104 for updates.
