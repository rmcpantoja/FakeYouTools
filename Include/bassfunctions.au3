#include "bass.au3"
; #FUNCTION# ====================================================================================================================
; Name ..........: _Audio_init_start
; Description ...: BASS init
; Syntax ........: _Audio_init_start()
; Parameters ....: None
; Return values .: None
; Author ........: Mateo Cedillo
; Modified ......: 
; Remarks .......: 
; Related .......: 
; Link ..........: 
; Example .......: No
; ===============================================================================================================================
Func _Audio_init_start()
If _BASS_STARTUP(@ScriptDir & "\bass.dll") Then
If _BASS_Init(0, -1, 48000, 0) Then
If _BASS_SetConfig($BASS_CONFIG_NET_PLAYLIST, 1) = 0 Then
SetError(3)
EndIf
Else
SetError(2)
EndIf
Else
SetError(@error)
EndIf
EndFunc
; #FUNCTION# ====================================================================================================================
; Name ..........: _Set_buffer
; Description ...: Set buffer
; Syntax ........: _Set_buffer($buffer)
; Parameters ....: $buffer              - A boolean value.
; Return values .: None
; Author ........: Mateo Cedillo
; Modified ......: 
; Remarks .......: 
; Related .......: 
; Link ..........: 
; Example .......: No
; ===============================================================================================================================
Func _Set_buffer($buffer)
_BASS_SetConfig($BASS_CONFIG_NET_BUFFER, $buffer)
EndFunc
; #FUNCTION# ====================================================================================================================
; Name ..........: _Audio_stop
; Description ...: Stops and audio handle
; Syntax ........: _Audio_stop($MusicHandle)
; Parameters ....: $MusicHandle         - An unknown value.
; Return values .: None
; Author ........: Mateo Cedillo
; Modified ......: 
; Remarks .......: 
; Related .......: 
; Link ..........: 
; Example .......: No
; ===============================================================================================================================
Func _Audio_stop($MusicHandle)
_BASS_ChannelStop($MusicHandle)
EndFunc
; #FUNCTION# ====================================================================================================================
; Name ..........: _Audio_play
; Description ...: Plays a specific sound
; Syntax ........: _Audio_play($MusicHandle)
; Parameters ....: $MusicHandle         - An unknown value.
; Return values .: None
; Author ........: Mateo Cedillo
; Modified ......: 
; Remarks .......: 
; Related .......: 
; Link ..........: 
; Example .......: No
; ===============================================================================================================================
Func _Audio_play($MusicHandle)
_BASS_ChannelPlay($MusicHandle, 1)
EndFunc
; #FUNCTION# ====================================================================================================================
; Name ..........: _Audio_pause
; Description ...: stops playing a specific audio
; Syntax ........: _Audio_pause($MusicHandle)
; Parameters ....: $MusicHandle         - An unknown value.
; Return values .: None
; Author ........: Mateo Cedillo
; Modified ......: 
; Remarks .......: 
; Related .......: 
; Link ..........: 
; Example .......: No
; ===============================================================================================================================
Func _Audio_pause($MusicHandle)
If _Get_playstate($MusicHandle) = 2 Then
$BASS_PAUSE_POS = _BASS_ChannelGetPosition($MusicHandle, $BASS_POS_BYTE)
_BASS_ChannelPause($MusicHandle)
ElseIf _Get_playstate($MusicHandle) = 3 Then
_Audio_play($MusicHandle)
_BASS_ChannelSetPosition($MusicHandle, $BASS_PAUSE_POS, $BASS_POS_BYTE)
EndIf
EndFunc
; #FUNCTION# ====================================================================================================================
; Name ..........: _Audio_init_stop
; Description ...: stops playing a specific audio
; Syntax ........: _Audio_init_stop($MusicHandle)
; Parameters ....: $MusicHandle         - An unknown value.
; Return values .: None
; Author ........: Mateo Cedillo
; Modified ......: 
; Remarks .......: 
; Related .......: 
; Link ..........: 
; Example .......: No
; ===============================================================================================================================
Func _Audio_init_stop($MusicHandle)
_BASS_StreamFree($MusicHandle)
_BASS_Free()
EndFunc
; #FUNCTION# ====================================================================================================================
; Name ..........: _Set_url
; Description ...: set a URL as a sound to load to BASS
; Syntax ........: _Set_url($file)
; Parameters ....: $file                - A floating point number value.
; Return values .: None
; Author ........: Mateo Cedillo
; Modified ......: 
; Remarks .......: 
; Related .......: 
; Link ..........: 
; Example .......: No
; ===============================================================================================================================
Func _Set_url($file)
If FileExists($file) Then
$MusicHandle = _BASS_StreamCreateFile(False, $file, 0, 0, 0)
Else
$MusicHandle = _BASS_StreamCreateURL($file, 0, 1)
EndIf
If @error Then
Return SetError(1)
EndIf
Return $MusicHandle
EndFunc
; #FUNCTION# ====================================================================================================================
; Name ..........: _Get_pos
; Description ...: get the position of a song
; Syntax ........: _Get_pos($MusicHandle)
; Parameters ....: $MusicHandle         - An unknown value.
; Return values .: None
; Author ........: Mateo Cedillo
; Modified ......: 
; Remarks .......: 
; Related .......: 
; Link ..........: 
; Example .......: No
; ===============================================================================================================================
Func _Get_pos($MusicHandle)
$current = _BASS_ChannelGetPosition($MusicHandle, $BASS_POS_BYTE)
Return Round(_Bass_ChannelBytes2Seconds($MusicHandle, $current))
EndFunc
; #FUNCTION# ====================================================================================================================
; Name ..........: _Get_len
; Description ...: get the lenght of a song
; Syntax ........: _Get_len($MusicHandle)
; Parameters ....: $MusicHandle         - An unknown value.
; Return values .: None
; Author ........: Mateo Cedillo
; Modified ......: 
; Remarks .......: 
; Related .......: 
; Link ..........: 
; Example .......: No
; ===============================================================================================================================
Func _Get_len($MusicHandle)
$current = _BASS_ChannelGetLength($MusicHandle, $BASS_POS_BYTE)
Return Round(_Bass_ChannelBytes2Seconds($MusicHandle, $current))
EndFunc
; #FUNCTION# ====================================================================================================================
; Name ..........: _Set_pos
; Description ...: Set's the lenght of a song
; Syntax ........: _Set_pos($MusicHandle, $seconds)
; Parameters ....: $MusicHandle         - An unknown value.
;                  $seconds             - A string value.
; Return values .: None
; Author ........: Mateo Cedillo
; Modified ......: 
; Remarks .......: 
; Related .......: 
; Link ..........: 
; Example .......: No
; ===============================================================================================================================
Func _Set_pos($MusicHandle, $seconds)
_BASS_ChannelSetPosition($MusicHandle, _BASS_ChannelSeconds2Bytes($MusicHandle, $seconds), $BASS_POS_BYTE)
EndFunc
; #FUNCTION# ====================================================================================================================
; Name ..........: _Set_volume
; Description ...: Set's the volume of a song
; Syntax ........: _Set_volume($volume)
; Parameters ....: $volume              - A variant value.
; Return values .: None
; Author ........: Mateo Cedillo
; Modified ......: 
; Remarks .......: 
; Related .......: 
; Link ..........: 
; Example .......: No
; ===============================================================================================================================
Func _Set_volume($volume)
_BASS_SetConfig($BASS_CONFIG_GVOL_STREAM, $volume * 100)
EndFunc
; #FUNCTION# ====================================================================================================================
; Name ..........: _Get_volume
; Description ...: Gets the volume of a song
; Syntax ........: _Get_volume()
; Parameters ....: None
; Return values .: None
; Author ........: Mateo Cedillo
; Modified ......: 
; Remarks .......: 
; Related .......: 
; Link ..........: 
; Example .......: No
; ===============================================================================================================================
Func _Get_volume()
Return _BASS_GetConfig($BASS_CONFIG_GVOL_STREAM) / 100
EndFunc
; #FUNCTION# ====================================================================================================================
; Name ..........: _Get_bitrate
; Description ...: get the bit rate of an audio
; Syntax ........: _Get_bitrate($MusicHandle)
; Parameters ....: $MusicHandle         - An unknown value.
; Return values .: None
; Author ........: Mateo Cedillo
; Modified ......: 
; Remarks .......: 
; Related .......: 
; Link ..........: 
; Example .......: No
; ===============================================================================================================================
Func _Get_bitrate($MusicHandle)
$a = Round(_Bass_ChannelBytes2Seconds($MusicHandle, _BASS_ChannelGetLength($MusicHandle, $BASS_POS_BYTE)))
$return = Round(_BASS_StreamGetFilePosition($MusicHandle, $BASS_FILEPOS_END) * 8/ $a/ 1000)
If StringInStr($return, "-") Then
$return = _BASS_StreamGetFilePosition($MusicHandle, $BASS_FILEPOS_END) * 8 / _BASS_GetConfig($BASS_CONFIG_NET_BUFFER)
EndIf
Return $return
EndFunc
; #FUNCTION# ====================================================================================================================
; Name ..........: _Get_playstate
; Description ...: Get the playback status of a song
; Syntax ........: _Get_playstate($MusicHandle)
; Parameters ....: $MusicHandle         - An unknown value.
; Return values .: None
; Author ........: Mateo Cedillo
; Modified ......: 
; Remarks .......: 
; Related .......: 
; Link ..........: 
; Example .......: No
; ===============================================================================================================================
Func _Get_playstate($MusicHandle)
Switch _BASS_ChannelIsActive($MusicHandle)
Case $BASS_ACTIVE_STOPPED
$returnstate = 1
Case $BASS_ACTIVE_PLAYING
$returnstate = 2
Case $BASS_ACTIVE_PAUSED
$returnstate = 3
Case $BASS_ACTIVE_STALLED
$returnstate = 4
EndSwitch
Return $returnstate
EndFunc
; #FUNCTION# ====================================================================================================================
; Name ..........: _Get_streamtitle
; Description ...: get the name of the song
; Syntax ........: _Get_streamtitle($MusicHandle)
; Parameters ....: $MusicHandle         - An unknown value.
; Return values .: None
; Author ........: Mateo Cedillo
; Modified ......: 
; Remarks .......: 
; Related .......: 
; Link ..........: 
; Example .......: No
; ===============================================================================================================================
Func _Get_streamtitle($MusicHandle)
$pPtr = _BASS_ChannelGetTags($MusicHandle, $BASS_TAG_META)
$sStr = _BASS_PtrStringRead($pPtr)
If StringInStr($sStr, ";") Then
$infosplit = StringSplit($sStr, ";")
$infosplit[1] = StringReplace($infosplit[1], "'", "")
$infosplit[1] = StringReplace($infosplit[1], "StreamTitle=", "")
If StringInStr($infosplit[1], "-") Then
Return $infosplit[1]
EndIf
EndIf
EndFunc