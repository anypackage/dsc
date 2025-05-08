﻿# Copyright (c) Thomas Nieto - All Rights Reserved
# You may use, distribute and modify this code under the
# terms of the MIT license.

using module AnyPackage
using namespace AnyPackage.Provider

enum Ensure {
    Absent
    Present
}

class APReason {
    [string] $Code

    [string] $Phrase
}

[DscResource()]
class Package {
    [DscProperty(Key)]
    [string] $Name

    [DscProperty(Key)]
    [string] $Version

    [DscProperty(Key)]
    [string] $Provider

    [DscProperty()]
    [bool] $Prerelease

    [DscProperty()]
    [string] $Source

    [DscProperty()]
    [hashtable] $AdditionalParameters = @{ }

    [DscProperty()]
    [bool] $Latest

    [DscProperty()]
    [Ensure] $Ensure = [Ensure]::Present

    [DscProperty(NotConfigurable)]
    [APReason[]] $Reasons

    static [Package[]] Export() {
        Get-PackageProvider -ListAvailable |
        Select-Object -ExpandProperty ModuleName -Unique |
        Import-Module

        $packages = @()
        foreach ($installedPackage in (Get-Package -ErrorAction Stop)) {
            $package = [Package]::new()
            $package.Name = $installedPackage.Name
            $package.Provider = $installedPackage.Provider.FullName

            if ($installedPackage.Version) {
                $package.Version = $installedPackage.Version
                $package.Prerelease = $installedPackage.Version.IsPrerelease
            } else {
                $package.Version = '*'
            }

            $package.Source = $installedPackage.Source
            $packages += $package
        }

        return $packages
    }

    [Package] Get() {
        $currentState = [Package]@{
            Name     = $this.Name
            Provider = $this.Provider
        }

        $params = @{
            Name        = $this.Name
            Provider    = $this.Provider
            ErrorAction = 'Stop'
        }

        if ($this.Version -ne '*') {
            $params['Version'] = $this.Version
        }

        if (-not $this.Provider.Contains('\')) {
            throw "Not a valid Provider full name: '$($this.Provider)'"
        }

        try {
            Import-Module ($this.Provider).Split('\')[0] -ErrorAction Stop

            $package = Get-Package @params |
                Sort-Object -Property Version -Descending |
                Select-Object -First 1

            $currentState.Ensure = [Ensure]::Present
            $currentState.Source = $package.Source
            $currentState.Version = $package.Version
            $currentState.Prerelease = $package.Version.IsPrerelease
        } catch [PackageNotFoundException] {
            $currentState.Ensure = [Ensure]::Absent
        }

        if ($this.Ensure -ne $currentState.Ensure) {
            $currentState.Reasons += [APReason]@{
                Code   = 'Package:Package:Ensure'
                Phrase = "Package '$($this.Name)' should be '$($this.Ensure)' but was '$($currentState.Ensure)'."
            }
        }

        if ($this.Source -and $this.Source -ne $currentState.Source) {
            $currentState.Reasons += [APReason]@{
                Code   = 'Package:Package:Source'
                Phrase = "Source should be '$($this.Source)' but was '$($currentState.Source)'."
            }
        }

        if (-not $this.Prerelease -and $this.Prerelease -ne $currentState.Prerelease) {
            $currentState.Reasons += [APReason]@{
                Code   = 'Package:Package:Prerelease'
                Phrase = 'Prerelease versions not allowed.'
            }
        }

        if ($this.Latest) {
            if ($this.Source) { $params['Source'] = $this.Source }
            $params['Prerelease'] = $this.Prerelease

            $latestPackage = Find-Package @params |
                Sort-Object -Property Version -Descending |
                Select-Object -First 1

            if ([PackageVersion]$currentState.Version -lt $latestPackage.Version) {
                $currentState.Reasons += [APReason]@{
                    Code   = 'Package:Package:Latest'
                    Phrase = "Version should be '$($latestPackage.Version)' but was '$($currentState.Version)'."
                }
            }
        }

        return $currentState
    }

    [void] Set() {
        if ($this.Test()) { return }

        $params = @{
            Name        = $this.Name
            Provider    = $this.Provider
            ErrorAction = 'Stop'
        }

        if ($this.Version -ne '*') {
            $params['Version'] = $this.Version
        }

        $currentState = $this.Get()

        if ($this.Ensure -eq [Ensure]::Present) {
            if ($this.Source) { $params['Source'] = $this.Source }

            if ($this.Latest) {
                $params['Version'] = Find-Package @params |
                    Sort-Object -Property Version -Descending |
                    Select-Object -ExpandProperty Version -First 1
            }

            # Can't splat using property
            $additionalParams = $this.AdditionalParameters

            if ($currentState.Ensure -eq [Ensure]::Present -and
                (Get-PackageProvider -Name $this.Provider).Operations.HasFlag([PackageProviderOperations]::Update)) {
                Update-Package @params @additionalParams
            } else {
                Install-Package @params @additionalParams
            }

        } elseif ($currentState.Ensure -eq [Ensure]::Present) {
            Uninstall-Package @params
        }
    }

    [bool] Test() {
        return $this.Get().Reasons.Count -eq 0
    }
}

[DscResource()]
class Source {
    [DscProperty(Key)]
    [string] $Name

    [DscProperty(Key)]
    [string] $Provider

    [DscProperty(Mandatory)]
    [string] $Location

    [DscProperty()]
    [bool] $Trusted

    [DscProperty()]
    [hashtable] $AdditionalParameters = @{ }

    [DscProperty()]
    [Ensure] $Ensure = [Ensure]::Present

    [DscProperty(NotConfigurable)]
    [APReason[]] $Reasons

    static [Source[]] Export() {
        Get-PackageProvider -ListAvailable |
        Select-Object -ExpandProperty ModuleName -Unique |
        Import-Module

        $sources = @()
        foreach ($installedSource in (Get-PackageSource -ErrorAction Stop)) {
            $source = [Source]::new()
            $source.Name = $installedSource.Name
            $source.Provider = $installedSource.Provider.FullName
            $source.Location = $installedSource.Location
            $source.Trusted = $installedSource.Trusted
            $sources += $source
        }

        return $sources
    }

    [Source] Get() {
        $currentState = [Source]@{
            Name     = $this.Name
            Provider = $this.Provider
        }

        $params = @{
            Name        = $this.Name
            Provider    = $this.Provider
            ErrorAction = 'Stop'
        }

        if (-not $this.Provider.Contains('\')) {
            throw "Not a valid Provider full name: '$($this.Provider)'"
        }

        try {
            Import-Module ($this.Provider).Split('\')[0] -ErrorAction Stop

            $source = Get-PackageSource @params

            $currentState.Ensure = [Ensure]::Present
            $currentState.Location = $source.Location
            $currentState.Trusted = $source.Trusted
        } catch [PackageSourceNotFoundException] {
            $currentState.Ensure = [Ensure]::Absent
        }

        if ($this.Ensure -ne $currentState.Ensure) {
            $currentState.Reasons += [APReason]@{
                Code   = 'Source:Source:Ensure'
                Phrase = "Package source '$($this.Name)' should be '$($this.Ensure)' but was '$($currentState.Ensure)'."
            }
        }

        if ($this.Location -ne $currentState.Location) {
            $currentState.Reasons += [APReason]@{
                Code   = 'Source:Source:Location'
                Phrase = "Location should be '$($this.Location)' but was '$($currentState.Location)'."
            }
        }

        if ($this.Trusted -ne $currentState.Trusted) {
            $currentState.Reasons += [APReason]@{
                Code   = 'Source:Source:Trusted'
                Phrase = "Trusted should be '$($this.Trusted)' but was '$($currentState.Trusted)'."
            }
        }

        return $currentState
    }

    [void] Set() {
        if ($this.Test()) { return }

        $params = @{
            Name        = $this.Name
            Provider    = $this.Provider
            ErrorAction = 'Stop'
        }

        $currentState = $this.Get()

        if ($this.Ensure -eq [Ensure]::Present) {
            $params['Location'] = $this.Location
            $params['Trusted'] = $this.Trusted

            # Can't splat using property
            $additionalParams = $this.AdditionalParameters

            if ($currentState.Ensure -eq [Ensure]::Present) {
                Set-PackageSource @params @additionalParams
            } else {
                Register-PackageSource @params @additionalParams
            }

        } elseif ($currentState.Ensure -eq [Ensure]::Present) {
            Unregister-PackageSource @params
        }
    }

    [bool] Test() {
        return $this.Get().Reasons.Count -eq 0
    }
}
