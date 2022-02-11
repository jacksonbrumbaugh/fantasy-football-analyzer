function Merge-FoxStats {
    param(
        [int]
        [Parameter(Mandatory)]
        [ValidateRange(2018, 2019)]
        $Year,

        [int]
        [Parameter(Mandatory,
            ValueFromPipeline)]
        [ValidateRange(1, 17)]
        $Week,

        [string]
        $FanDir = "J:\FantasyFootball\Stats\$Year",

        [string]
        $OutFile = (Join-Path "$FanDir\Merged" ("NFL-$Year-W{0:D2}-Stats.csv" -f $Week ))
    )

    process {
        Write-Host "Week $Week"
        $PassDir = Join-Path $FanDir Passing
        $RushDir = Join-Path $FanDir Rushing
        $RecDir  = Join-Path $FanDir Receiving

        $PassStats = Get-ChildItem ("$PassDir\*W{0:D2}*" -f $Week) | ForEach-Object { Import-CSV $_ }
        $RushStats = Get-ChildItem ("$RushDir\*W{0:D2}*" -f $Week) | ForEach-Object { Import-CSV $_ }
        $RecStats  = Get-ChildItem ("$RecDir\*W{0:D2}*" -f $Week)  | ForEach-Object { Import-CSV $_ }

        $AllStats = $PassStats + $RushStats + $RecStats 

        $Players = $AllStats | Where-Object Position -in ('QB', 'RB', 'WR', 'TE') |
            Sort-Object -Property Position, Name |
            Select-Object -ExpandProperty Name -Unique

        $AllPlayerStats = @()
        foreach ($Player in $Players) {
            $PlayerStats = [PSCustomObject]@{ Name = $Player }

            $BasePlayerStats = $AllStats | Where-Object Name -eq $Player | Select-Object -First 1

            $BaseStats = (
                'Position',
                'Team',
                'Year',
                'Week'
            )

            foreach ($Stat in $BaseStats) {
                $PlayerStats | Add-Member -MemberType NoteProperty -Name $Stat -Value $BasePlayerStats.$Stat
            }

            $GetPassStats = (
                'PassYds',
                'PassTD',
                'PassComp',
                'PassAtt',
                'PassPct',
                'PassYdsPerAtt',
                'PassLong',
                'QBR',
                'Int',
                'Sacks'
            )

            $GetRushStats = (
                'RushYds',
                'RushTD',
                'RushAtt',
                'RushAve',
                'RushLong'
            )    

            $GetRecStats = (
                'RecYds',
                'RecTD',
                'Rec',
                'Targets',
                'RecAve',
                'RecLong'
            )        
    
            foreach ($Stat in ($GetPassStats + $GetRushStats + $GetRecStats)) {
                $PlayerStats | Add-Member -MemberType NoteProperty -Name $Stat -Value ''
            }

            if ($Player -in $PassStats.Name) {
                $PlayerPassStats = $PassStats | Where-Object Name -eq $Player
                foreach ($Stat in $GetPassStats) {
                    $PlayerStats.$Stat = $PlayerPassStats.$Stat
                }
            }

            if ($Player -in $RushStats.Name) {
                $PlayerRushStats = $RushStats | Where-Object Name -eq $Player

                foreach ($Stat in $GetRushStats) {
                    $PlayerStats.$Stat = $PlayerRushStats.$Stat
                }
            }

            if ($Player -in $RecStats.Name) {
                $PlayerRecStats = $RecStats | Where-Object Name -eq $Player

                foreach ($Stat in $GetRecStats) {
                    $PlayerStats.$Stat = $PlayerRecStats.$Stat
                }
            }

            $AllPlayerStats += $PlayerStats
        }

        $AllPlayerStats | Export-CSV -Path $OutFile -NoTypeInformation

    } # End process block

} # End function
