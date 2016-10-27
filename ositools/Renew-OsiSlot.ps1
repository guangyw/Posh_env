
# Or Renew-OsiSlot

[CmdletBinding()]
param (
  [parameter(Mandatory=$true)]
  [string]$SlotName
)

$SlotName = $SlotName.Trim()

$RenewUrl = "http://osiam/alterbatch.aspx?op=renew&batch=$SlotName"

$resp = Invoke-WebRequest $RenewUrl -UseDefaultCredential

if ($resp.StatusCode -eq 200)
{
  # Renew exceeding max duration also yields status code 200

  # Get the expiration time from returned HTML
  if ($resp.Content -match ".+(<table id=""body_CheckoutsTable""(.|\n)+</table>).*")
  {
    $table = $matches[1]
    $table = $table.Replace("&nbsp;", " ")
    $xml = [xml]$table
    # TODO: show how far away is the expiration time is from now
    return $xml.table.tr[2].td[5]
  }
  else
  {
    Write-Warning "Cannot find expiration time"
    return $resp
  }
}
else
{
  Write-Error "Failed to renew, status code $($resp.StatusCode)"
}
