# https://learn.microsoft.com/en-us/defender-endpoint/attack-surface-reduction-rules-reference?view=o365-worldwide#block-execution-of-potentially-obfuscated-scripts

param($enableRule=$true)

$windowsDefenderGUIDRule = "5beb7efe-fd9a-4556-801d-275e5ffc04cc"
$windowsDefenderRuleName = "Block execution of potentially obfuscated scripts"

function main() {
    if ($enableRule) {
        Write-Host "Enabling ASR Rule '$($windowsDefenderRuleName)'"
        Add-MpPreference -AttackSurfaceReductionRules_Ids $windowsDefenderGUIDRule -AttackSurfaceReductionRules_Actions Enabled
    } else {
        Write-Host "Disabling ASR Rule '$($windowsDefenderRuleName)'"
        Add-MpPreference -AttackSurfaceReductionRules_Ids $windowsDefenderGUIDRule -AttackSurfaceReductionRules_Actions Disabled
    }
}

main