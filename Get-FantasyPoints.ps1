function Get-FantasyPoints {
    [CmdletBinding(DefaultParameterSetName = 'NoPPR')]
    param(
        [double]
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('TotalPassYds')]
        $PassYds,

        [int]
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('TotalPassTD')]
        $PassTD,

        [int]
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('TotalInt')]
        $Int,

        [double]
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('TotalRushYds')]
        $RushYds,

        [int]
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('TotalRushTD')]
        $RushTD,

        [double]
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('TotalRecYds')]
        $RecYds,

        [int]
        [Parameter(ValueFromPipelineByPropertyName)]
        [Alias('TotalRecTD')]
        $RecTD,

        [int]
        [Parameter(ParameterSetName = 'NoPPR',
            ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName = 'FullPPR',
            Mandatory,
            ValueFromPipelineByPropertyName)]
        [Parameter(ParameterSetName = 'HalfPPR',
            Mandatory,
            ValueFromPipelineByPropertyName)]
        [Alias('TotalRec')]
        $Rec,

        [switch]
        [Parameter(ParameterSetName = 'FullPPR',
            Mandatory)]
        [Alias('F')]
        $PPR,

        [switch]
        [Parameter(ParameterSetName = 'HalfPPR',
            Mandatory)]
        [Alias('H')]
        $HPPR,

        [Parameter(ValueFromRemainingArguments)]
        $Extras
    )

    process {
        $ScoreHash = @{
            PassYds = 0.04
            PassTD  = 4
            Int     = -2
            RushYds = 0.1
            RushTD  = 6
            RecYds  = 0.1
            RecTD   = 6
        }

        $ScoreHash['Rec'] = switch ($PSCmdlet.ParameterSetName) {
            'NoPPR'   { 0   }
            'HalfPPR' { 0.5 }
            'FullPPR' { 1.0 }
        }

        $Points = 0

        $Stats = (
            'PassYds',
            'PassTD',
            'Int',
            'RushYds',
            'RushTD',
            'RecYds',
            'RecTD',
            'Rec'
        )

        foreach ($Stat in $Stats) {
            $Points += (Get-Variable -Name $Stat -ValueOnly) * $ScoreHash.$Stat
        }

        $Points
    }
}

('FanPts', 'Score') | ForEach-Object {
    Set-Alias -Name $_ -Value Get-FantasyPoints
}
