#requires -modules AnyPackageDsc, AnyPackage.PSResourceGet

using module AnyPackageDsc

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param()

Describe 'Package' {
    Context 'Export' {
        BeforeAll {
            $results = [Package]::Export()
        }

        It 'should return packages' {
            $results | Should -Not -BeNullOrEmpty
        }
    }
}
