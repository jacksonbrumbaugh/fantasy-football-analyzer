function Get-FoxTeamName ($String) {
    # <span class="wisbb_tableAbbrevLink">			<a href="/nfl/dallas-cowboys-team-stats">DAL</a>
    if ($String -like "*team-stats*") {
        $String -replace ".*team-stats.>(.*)</a.*", '$1'
    } else {
        Write-Warning "Wrong raw line input to $($MyInvoation.MyCommand).  Cannot determine team."
    }
}
