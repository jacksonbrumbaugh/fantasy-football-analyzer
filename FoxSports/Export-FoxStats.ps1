function Export-FoxStats {
    param(
        [array]
        [Parameter(Mandatory)]
        $Players,

        [int]
        [Parameter(Mandatory)]
        [ValidateRange(2018, 2019)]
        $Year,

        [int]
        [Parameter(Mandatory)]
        [ValidateRange(1, 17)]
        $Week,

        [string]
        [Parameter(Mandatory)]
        [ValidateSet('Passing', 'Rushing', 'Receiving')]
        $StatType
    )

    $StatDir = Get-StatDir

    $YearDir = Join-Path $StatDir $Year
    $StatTypeDir = Join-Path $YearDir $StatType

    foreach ($Dir in ($YearDir, $StatTypeDir)) {
        if (-not (Test-Path $Dir)) {
            New-Item -Path $Dir -ItemType Directory | Out-Null
        }
    }

    $FileName = Join-Path $StatTypeDir ("NFL-{2}-W{0:D2}-{1}.csv" -f $Week, $StatType, $Year)

    $FieldOrder = (
        'Name',
        'Position',
        'Team',
        'Year',
        'Week'
    )

    $FieldOrder += switch ($StatType) {
        'Passing' {
            'PassYds',
            'PassTD',
            'PassComp',
            'PassAtt',
            'PassPct',
            'PassYdsPerAtt',
            'PassLong',
            'QBR',
            'Int',
            'Sacks',
            'SackYds'
        }
        'Rushing' {
            'RushYds',
            'RushTD',
            'RushAtt',
            'RushAve',
            'RushLong'
        }
        'Receiving' {
            'RecYds',
            'RecTD',
            'Rec',
            'Targets',
            'RecAve',
            'RecLong'
        }
    }

    $Players | Select-Object -Property $FieldOrder | Export-CSV -Path $FileName -NoTypeInformation
}
