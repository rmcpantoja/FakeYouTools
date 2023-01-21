; a small console progress functions:
global $vProgress, $vOldProgress
func _CreateProgress($iMin, $iMax)
return round($iMin/$iMax*100, 1)
EndFunc
func _PrintProgress($iMin, $iMax)
$vOldProgress = $vProgress
$vProgress = _CreateProgress($iMin, $iMax)
if ($vProgress <> $vOldProgress) then
ConsoleWrite($vProgress &"% - " &$iMin &"/" &$iMax &@crlf)
ElseIf $vProgress <0 then
Return SetError(1, 0, "")
EndIf
EndFunc