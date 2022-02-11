function Get-FoxPlayerName ($String) {
    # <a class="wisbb_fullPlayer" href="/nfl/sammy-watkins-player-stats">
    $String -replace ".*nfl/(.*)-play.*", '$1' -replace '-', ' '
}
