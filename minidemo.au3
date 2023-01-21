; a non-official example fixing a dataset (GUI)
#include "include\dataset.au3"
#include <GuiConstantsEx.au3>
main()
func main()
; declare:
global $hGui
global $idFix, $idProcess, $idApply
; create GUI:
$hGui = GuiCreate("Demonstration")
; controls:
$idLabel = GuiCtrlCreateLabel("Check the features you want to apply or uncheck the ones you don't want:", 10, 10, 200, 20)
$idFix = GuiCtrlCreateCheckbox("Fix transcription", 80, 10, 50, 20)
$idProcess = GuiCtrlCreateCheckbox("Process and convert audio", 80, 80, 50, 20)
$idApply = GuiCtrlCreateButton(Apply", 40, 40, 50, 20)
; Show GUI:
GuiSetState(@Sw_SHOW)
While 1
Switch GuiGetMsg()
case $idApply
_Dataset_tasks()
Case $GUI_EVENT_CLOSE
exitLoop
EndSwitch
WEnd
EndFunc
func _DatasetTasks()
; declare:
local $sWavsPath = "", $sListPath = ""
Select
case _IsChecked($idFix)
$sListPath = FileOpenDialog("Select the transcription", "", "Standard transcription (*.txt)")
If @error Then
MsgBox(16, "Error", "You must select a file to proceed")
exit
EndIf
$hGui = GuiCreate("Select language")
$idLabel = GuiCtrlCreateLabel("Select the language of this transcript", 10, 10, 300, 20)
$idChoose = GUICtrlCreateCombo("", 10, 80, 200, 20, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL))
GUICtrlSetData($idChoose, "en|es", "en")
$idOK = GuiCtrlCreateButton("OK", 80, 10, 50, 20)
GuiSetState(@SW_SHOW)
while 1
switch GuiGetMsg()
case $idOK
$sDatasetLang = GuiCtrlRead($idChoose)
GuiDelete($hGui)
exitLoop
Case $GUI_EVENT_CLOSE
MsgBox(16, "Error", "It is mandatory to select a language before continuing...")
Exit
EndSwitch
WEnd
_DatasetFixList($sListPath, $sDatasetLang)
if @error then
switch @error
case 1
MsgBox(16, "Error", "The transcript file does not exist.")
case 2
MSgBox(16, "Error", "The transcript file could not be read. Make sure the file is not already open by another application.")
case 3
MSgBox(16, "Error", "Failed to create file for new list fixed")
EndSwitch
exit
else
MsgBox(48, "Success!", "The dataset has been successfully fixed. In total, they were made " &@extended &" fixes. This includes changes to symbols, numbers to letters, final punctuation, etc. Good luck with the training!")
EndIf
case _IsChecked($idProcess)
$sWavsPath = FileSelectFolder("Select wavs folder", "")
If @error Then
MsgBox(16, "Error", "You must select a folder to proceed")
EndIf
_Dataset_Process_audios($sWavsPath, @ScriptDir & "\engines", true)
if @error then
switch @error
case 1
MsgBox(16, "Error", "Could not find ffmpeg for tis arch.")
case 2
MsgBox(16, "Error", "Your folder does not have the audios with the required compatible format")
case 3 to 6
MSgBox(16, "Error", "Execution failed. The process may not be successful.")
EndSwitch
exit
Else
MsgBox(48, "Success", "The audios have been fixed! Good luck with your training.")
EndIf
EndSelect
EndFunc
Func _IsChecked($idControlID)
	Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc   ;==>_IsChecked
