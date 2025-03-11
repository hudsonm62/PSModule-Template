class SomeDataClass {
    [string] $Data

    SomeDataClass([string]$Data) {
        $this.Data = $Data
    }

    [string] ToString() {
        return $this.Data
    }
}
