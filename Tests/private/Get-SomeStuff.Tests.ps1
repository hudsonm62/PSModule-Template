BeforeAll {
    $ModuleRoot = Resolve-Path -Path (Join-Path -Path $PSScriptRoot -ChildPath '../../PSModule')
    Import-Module $ModuleRoot -Force
}

Describe "Get-SomeStuff" {
    It 'Should return a greeting' {
        InModuleScope PSModule {
            $result = Get-SomeStuff
            $result | Should -Be 'Hello, Public Function!'
        }
    }
    It 'Should call Get-Content' {
        InModuleScope PSModule {
            Mock -CommandName Get-Content -MockWith { @('Mocked content') }
            $result = Get-SomeStuff
            Should -Invoke Get-Content -Exactly 1
        }
    }
    It 'Should match "Public Function" in the greeting' {
        InModuleScope PSModule {
            $result = Get-SomeStuff
            $result | Should -Match 'Public Function'
        }
    }
}
