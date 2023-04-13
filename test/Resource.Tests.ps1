#requires -modules AnyPackageDsc

Describe 'Resource' {
    Context 'Get-DscResource' {
        It 'should return Package and Source resources' {
            Get-DscResource -Name Package, Source -Module AnyPackageDsc |
            Select-Object -ExpandProperty Name |
            Should -Be 'Package', 'Source'
        }
    }
}
