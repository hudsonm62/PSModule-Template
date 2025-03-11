BeforeAll {
    $ModuleRoot = Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath '../../PSModule')
    Import-Module $ModuleRoot -Force
}

Describe "Get-SomeData" {
    It 'Should return a greeting' {
        InModuleScope PSModule {
            $result = Get-SomeData
            $result | Should -Be 'Hello, Public Function!'
        }
    }
    It 'Should call Get-SomeStuff' {
        InModuleScope PSModule {
            Mock -CommandName Get-SomeStuff -MockWith { @('Mocked content') }
            $result = Get-SomeData
            Should -Invoke Get-SomeStuff -Exactly 1
        }
    }
} 
