function Get-FoxStatValue ($String) {
    # <td class="wisbb_priorityColumn">25</td>
    $String -replace ".*>(.*)<.*", '$1'
}
