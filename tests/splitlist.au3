#include <fileConstants.au3>
_dataset_open_transcription(@ScriptDir &"\examples\list2.txt")
if @error then msgbox(16, "Error", @error)
func _dataset_open_transcription($sListPath)
local $aFile
if not FileExists($sListPath) then return setError(1, 0, "")
$aFile = FileReadToArray($sListPath)
If @error Then Return SetError(2, 0, "")
local $aSplit[uBound($aFile)][2]
For $i = 0 To UBound($aFile) -1
$aSplit[$I][0] = StringSplit($aFile[$I], "|")[1]
$aSplit[$I][1] = StringSplit($aFile[$I], "|")[2]
Next
return $aSplit
EndFunc