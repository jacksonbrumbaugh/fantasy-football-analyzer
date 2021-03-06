function Get-YearTotals {
    [CmdletBinding()]
    param(
        [int]
        [ValidateRange(2018, 2019)]
        $Year = 2019,

        [switch]
        $QB,

        [switch]
        $RB,

        [switch]
        $TE,

        [switch]
        $WR,

        [switch]
        [Alias('Silent')]
        $HideProgress
    )

    process {
        $YearStats = Get-YearStats $Year

        $FantasyPositions = ('QB', 'RB', 'TE', 'WR')
        $SelectPositions = @()

        if ($QB -or $RB -or $TE -or $WR) {
            foreach ($Pos in $FantasyPositions) {
                $AddPos = Get-Variable $Pos -ValueOnly
                if ($AddPos) {
                    $SelectPositions += $Pos
                }
            }
        } else {
            $SelectPositions = $FantasyPositions
        }

        $SelectedStats = $YearStats | Where-Object Position -in $SelectPositions | Sort-Object Name

        $ScoringStats = (
            'PassYds',
            'PassTD',
            'PassComp',
            'PassAtt',
            'Int',
            'RushYds',
            'RushTD',
            'RushAtt',
            'RecYds',
            'RecTD',
            'Rec',
            'Targets'
        )

        $YearTotals = New-Object -TypeName System.Collections.ArrayList

        $TotalsHash = [ordered]@{}

        $n = 0
        $StatLinesCount = $SelectedStats.count
        $ProgressInterval = [int]($StatLinesCount / 100)

        foreach ($StatLine in $SelectedStats) {
            $n++

            if (-not ($HideProgress)) {
                if (-not ($n % $ProgressInterval)) {
                    $ProgressParams = @{
                        Activity        = 'Totaling Player Stats'
                        # Status          = "Adding Stat Line $n"
                        PercentComplete = (100 * $n / $StatLinesCount)
                    }

                    Write-Progress @ProgressParams
                }
            }

            $Name = $StatLine.Name
            if ($Name -notin $TotalsHash.Keys) {
                $TotalsHash.$Name = [ordered]@{
                    Name     = $Name
                    Position = $StatLine.Position
                    Year     = $Year
                    Teams    = @()
                    Weeks    = @()
                }

                foreach ($Stat in $ScoringStats) {
                    $TotalStat = 'Total' + $Stat
                    $TotalsHash.$Name.$TotalStat = $null
                }
            }

            $Team = $StatLine.Team
            if ($Team -notin $TotalsHash.$Name.Teams) {
                $TotalsHash.$Name.Teams += $Team
            }

            $TotalsHash.$Name.Weeks += $StatLine.Week

            foreach ($Stat in $ScoringStats) {
                $TotalStat = 'Total' + $Stat
                $WeekStat = $StatLine.$Stat
                if ($WeekStat) {
                    $TotalsHash.$Name.$TotalStat += [int]$WeekStat
                }
            }
        } # End foreach StatLine

        foreach ($Player in $TotalsHash.Keys) {
            $PlayerTotals = New-Object -TypeName psobject -Property $TotalsHash.$Player
            $YearTotals.Add($PlayerTotals) | Out-Null
        }

        $YearTotals

    } # End process block

} # End function
