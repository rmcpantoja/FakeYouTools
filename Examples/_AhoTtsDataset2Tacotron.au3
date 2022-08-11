#INCLUDE "..\INCLUDE\DATASET.AU3"
example()
func example()
local $iResult, $sPath = @scriptDir, $sListFileName = "frases.txt"
$iResult = _AhoTtsDataset2Tacotron($sPath, $sListFileName, true)
if @error then
switch @error
case 1
MsgBox(16, "Error", "The wavs were not found.")
case 2
MsgBox(16, "Error", "The transcript file does not exist.")
case 3
MsgBox(16, "Error", "The transcript file could not be read.")
case 4
MsgBox(16, "Error", "The converted file list could not be created.")
EndSwitch
Else
MsgBox(0, "Success", "Dataset converted.")
EndIf
EndFunc