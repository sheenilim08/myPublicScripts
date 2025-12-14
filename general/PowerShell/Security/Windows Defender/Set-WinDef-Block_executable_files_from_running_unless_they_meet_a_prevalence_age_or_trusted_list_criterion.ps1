# https://learn.microsoft.com/en-us/defender-endpoint/attack-surface-reduction-rules-reference?view=o365-worldwide#block-executable-files-from-running-unless-they-meet-a-prevalence-age-or-trusted-list-criteriono

param($enableRule=$true)

$windowsDefenderGUIDRule = "01443614-cd74-433a-b99e-2ecdc07bfc25"
$windowsDefenderRuleName = "Block executable files from running unless they meet a prevalence, age, or trusted list criterion"

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