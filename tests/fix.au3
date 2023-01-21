#include "include\dataset.au3"
_DatasetFixList(@scriptDir &"\list2_converted.txt", "es", true)
if @error then
msgbox(16, "error", "Código: " &@error)
Else
msgbox(0, "éxito", "lista corregida")
EndIf
