#requires -modules AnyPackageDsc, AnyPackage.PSResourceGet

using module AnyPackageDsc

[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
param()

Describe 'Source' {
    Context 'Export' {
        BeforeAll {
            $results = [Source]::Export()
        }

        It 'should return sources' {
            $results | Should -Not -BeNullOrEmpty
        }
    }
}
