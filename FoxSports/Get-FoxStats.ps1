function Get-FoxStats {
    [CmdletBinding()]
    param(
        [string]
        [Parameter(Mandatory)]
        [ValidateSet('Pass', 'Passing',
            'Rush', 'Rushing',
            'Rec', 'Receiving')]
        $Type,

        [int]
        [Parameter(Mandatory)]
        [ValidateRange(2018, 2019)]
        $Year,

        [int]
        [Parameter(Mandatory)]
        [ValidateRange(1, 17)]
        $Week
    )

    $Positions = Get-FoxPlayerPosition

    $FullType = switch ($Type) {
        'Pass' {
            'Passing'
        }
        'Rush' {
            'Rushing'
        }
        'Rec' {
            'Receiving'
        }
        Default {
            $Type
        }
    }

    $StatNameHash = Get-FoxStatNameHash $FullType

    $Players = @()
    $NumOfPages = 1
    for ($Page = 1; $Page -le $NumOfPages; $Page++) {
        $WebPage = "https://www.foxsports.com/nfl/stats?season=" +
            $Year + "&week=1" + ( "{0:D2}" -f $Week ) +
            "&category=" + $FullType + "&page=" + $Page

        $Request = Invoke-WebRequest -URI $WebPage -UseBasicParsing

        $Content = $Request.content.split("`n")

        if ($Page -eq 1) {
            $ColumnNames = ($Content -match "sorter-digit").ForEach{
                ($_ -replace ".*title=(.+)>",'$1' -replace '"','').trim()
            }

            $NumOfCols = $ColumnNames.count

            $CheckPagesLine = $Content -match "page.*next"
            $NumOfPages = if ($CheckPagesLine) {
                $PagesLines = $CheckPagesLine.split('|')
                $PagesLines[-2] -replace ".*>(\d+)</a>",'$1'
            } else {
                1
            }
        }

        $Use = $Content -match "fullPlayer|<td|team-stats.>" | Where-Object { $_ -notlike "*fixed*" }

        $RawFullPlayers = $Use -match "FullPlayer"

        for ($n = 0; $n -lt $RawFullPlayers.count; $n++) {
            $Start = $n * ($NumOfCols + 2)
            $End = $NumOfCols + 1 + $n * ($NumOfCols + 2)
            $Raw = $Use[$Start .. $End]

            $Name = Get-FoxPlayerName $Raw[0]
            $Team = Get-FoxTeamName $Raw[1]
            $Pos  = $Positions.$Name

            $PlayerStats = [PSCustomObject]@{
                Name     = $Name
                Position = $Pos
                Team     = $Team
                Year     = $Year
                Week     = $Week
            }

            for ($i = 0; $i -lt $NumOfCols; $i++) {
                $StatName = $StatNameHash.($ColumnNames[$i])
                $StatValue = Get-FoxStatValue $Raw[$i + 2]
                $PlayerStats | Add-Member -MemberType NoteProperty -Name $StatName -Value $StatValue
            }

            $Players += $PlayerStats
        }
    }

    Export-FoxStats -Players $Players -Year $Year -Week $Week -StatType $FullType
}
