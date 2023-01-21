#include "include\dataset.au3"
local $sWavsPath = "", $sDuracion = ""
consultarduracion()
func consultarduracion()
$sWavsPath = FileSelectFolder("selecciona la carpeta que contiene los audios", "")
If @error Then
MsgBox(16, "Error", "Debes seleccionar una carpeta para proceder")
EndIf
consoleWrite("Comenzando a verificar..." &@crlf)
$sDuracion = _Dataset_get_WavsDuration($sWavsPath, null, 1, true)
if @error then
MSgBox(16, "Error", "Ocurrió un error al obtener la duración. Recuerda que los audios deven estar en formato WAV. De todos modos, aquí está el código de error: " &@error)
exit
EndIF
consoleWrite("Finalizado. Saliendo..." &@crlf)
MSgBox(48, "Listo", "La duración total de todos los audios es de: " &$sDuracion)
EndFunc