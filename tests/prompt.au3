; haciendo un prompt
#include <array.au3>
#include "include\dataset.au3"
local $aList
local $sTranscrypt, $sFileName
$sTranscrypt = @ScriptDir &"\list.txt"
$sFileName = @ScriptDir &"\text1.txt"
$aList = _dataset_open_transcription($sTranscrypt)
if @error then
MSgBox(16, "Open error", @error)
exit
EndIf
Local $hFile = FileOpen($sFileName, 2)
$sString = _ArrayToString($aList, @crlf, 0, default, @crlf, 1, 1)
if @error then
msgbox(16, "Error", @error)
else
FileWrite($hFile, $sString)
EndIf