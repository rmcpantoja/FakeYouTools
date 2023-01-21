#include <Dataset.au3>
; interacting whit dataset reordering
global $iNumber
global $sListPath, $sWavsPath
msgBox(48, "Welcome", "This is an interactive script using the Fakeyou toolkit using the dataset management library." &@crlf &"Here we will use the function change the order of the entire dataset (audios and transcripts) from a certain number. This is useful when we are working on a dataset of the same voice from audio 1 and we want to merge it with the other dataset, based on the number of audios and transcripts it has to merge it into one. Let's get started!")
Main()
Func main()
$sWavsPath = FileSelectFolder("Select dataset folder (containing a wavs subfolder inside it)", "")
If @error Then
MsgBox(16, "Error", "You must select a folder to proceed. Exiting...")
exit
Else
MsgBox(0, "OK", "Next step: select the transcript file. Remember that it must be in LJSpeech format.")
EndIf
$sListPath = FileOpenDialog("Select the transcription", "", "Standard transcription (*.txt)")
If @error Then
MsgBox(16, "Error", "You must select a file to proceed")
exit
Else
MsgBox(0, "Last step", "Change the order from what number?")
EndIf
$iNumber = Int(InputBox("Number", "order from #"))
if not isInt($iNumber) or not isNumber($iNumber) then
MsgBox(16, "Error", "You must enter a number to do this. Exiting...")
Exit
Else
MsgBox(0, "Lets go", "Press OK to start and change the numbering. We will notify you when everything is ready.")
EndIf
_changeDatasetOrder($sWavsPath, $sListPath, $iNumber)
if @error then
switch @error
case 1
MsgBox(16, "Error", "No files with the *.wav extension were found.")
case 2
MsgBox(16, "Error", "The transcript file could not be opened. Check that it is in the correct format.")
Case 3
MsgBox(16, "Error", "The new converted transcription file could not be created.")
case 4
MsgBox(16, "Error", "The file list could not be sorted.")
EndSwitch
Exit
Else
MsgBox(48, "Ready", "Order changed. Now you can merge this dataset with the previous one." &@crlf &"The new transcript file is named FileName_Converted.txt")
EndIF
EndFunc