function Get-AllFoxStats {
    param(
        [int[]]
        [ValidateRange(2018, 2019)]
        $Years = (2018, 2019),

        [string[]]
        [ValidateSet('Pass', 'Passing', 'Rush', 'Rushing', 'Rec', 'Receiving')]
        $Stats = (
            'Passing',
            'Rushing',
            'Receiving'
        ),

        [int[]]
        [ValidateRange(1, 17)]
        $Weeks = 1..17,

        [int]
        $IndentSize = 2
    )

    foreach ($Year in $Years) {
        Write-Host ("{0}| $Year" -f (" " * $IndentSize * 0))
        foreach ($Stat in $Stats) {
            $Stat = switch ($Stat) {
                'Pass' { 'Passing' }
                'Rush' { 'Rushing' }
                'Rec'  { 'Receiving'}
                Default { $Stat }
            }
            Write-Host ("{0}| $Stat" -f (" " * $IndentSize * 1))
            foreach ($Week in $Weeks) {
                Write-Host ("{0}| $Stat Week $Week" -f (" " * $IndentSize * 2))
                Get-FoxStats -Type $Stat -Year $Year -Week $Week
            }
            Write-Host ''
        }
        foreach ($Week in $Weeks) {
            Merge-FoxStats -Year $Year -Week $Week
        }
        Write-Host ''
    }
}
