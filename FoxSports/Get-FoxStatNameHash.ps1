function Get-FoxStatNameHash {
    param(
        [string]
        [Parameter(Mandatory)]
        [ValidateSet('Passing', 'Rushing', 'Receiving')]
        $Type
    )

    $StatHash = switch ($Type) {
        'Passing' {
            @{
                'Completions' = 'PassComp'
                'Attempts' = 'PassAtt'
                'Completion %' = 'PassPct'
                'Passing Yards' = 'PassYds'
                'Passing Yards / Attempt' = 'PassYdsPerAtt'
                'Passing Touchdowns' = 'PassTD'
                'Interceptions' = 'Int'
                'QB Rating' = 'QBR'
                'Pass Long' = 'PassLong'
                'Sacks' = 'Sacks'
                'Sack Yards' = 'SackYds'
            }
        }
        'Rushing' {
            @{
                'Attempts' = 'RushAtt'
                'Rushing Yards' = 'RushYds'
                'Rushing Yards / Attempt' = 'RushAve'
                'Rushing Touchdowns' = 'RushTD'
                'Longest Rush' = 'RushLong'
            }
        }
        'Receiving' {
            @{
                'Receptions' = 'Rec'
                'Receiving Yards' = 'RecYds'
                'Targets' = 'Targets'
                'Yards / Reception' = 'RecAve'
                'Receiving Touchdowns' = 'RecTD'
                'Receiving Long' = 'RecLong'
            }
        }
    }

    $StatHash
}
