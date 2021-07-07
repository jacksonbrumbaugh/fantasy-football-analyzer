function Get-YearStats {
    [CmdletBinding(DefaultParameterSetName = 'MergedStats')]
    param(
        [int]
        [Parameter(ValueFromPipeline,
            Position = 0)]
        [ValidateRange(2018, 2019)]
        $Year = 2019,

        [switch]
        [Parameter(Mandatory,
            ParameterSetName = 'PassStats')]
        [Parameter(ParameterSetName = 'RushStats')]
        [Alias('Pass')]
        $Passing,

        [switch]
        [Parameter(Mandatory,
            ParameterSetName = 'RushStats')]
        [Alias('Rush')]
        $Rushing,

        [switch]
        [Parameter(Mandatory,
            ParameterSetName = 'RecStats')]
        [Alias('Receiving')]
        $Rec,

        [switch]
        [Parameter(Mandatory,
            ParameterSetName = 'AllStats')]
        [Alias('Full')]
        $All
    )

    begin {
        $StatDir = Get-StatDir
        if (-not (Test-Path $StatDir)) {
            throw 'Cannot locate the fantasy football stats folder'
        }
    }

    process {
        $YearDir = Join-Path $StatDir $Year
        if (-not (Test-Path $YearDir)) {
            throw 'Cannot locate the $Year fantasy football stats folder'
        }

        $Stats = switch ($PSCmdlet.ParameterSetName) {
            'MergedStats' {
                Get-ChildItem $YearDir\Merged\*.csv -Filter *$Year*stats* | ForEach-Object {
                    Import-CSV $_
                }
                break
            }
            'AllStats' {
                $Passing = $Rushing = $Rec = $true
            }
            Default {
                foreach ($Var in ('Passing', 'Rushing', 'Rec')) {
                    $VarName = Get-Variable $Var | Select-Object -ExpandProperty Name
                    $VarValue = Get-Variable $Var -ValueOnly
                    if ($VarValue) {
                        Get-ChildItem $YearDir\*.csv -Recurse -Filter *$VarName* | ForEach-Object {
                            Import-CSV $_
                        }
                    }
                }
            }
        }

        $Stats
    }
}
