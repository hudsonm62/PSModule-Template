function Get-SomeStuff {
    [SomeDataClass]$Something = [SomeDataClass]::new('World')
    $data = Get-Content -Path (Join-Path -Path (Get-ModuleRoot) -ChildPath 'resources/SomeText.txt')
    $Something.Data = $data
    return "Hello, $($Something.ToString())!"
}
