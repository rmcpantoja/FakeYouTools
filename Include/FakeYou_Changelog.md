# changelog:

This is the changelog for Au3 FakeYou UDF. Thanks to everyone who helped with code, solutions, and suggestions.

## 0.5

* Updated JSON dependency from 2015.01.08 to 2021.11.06
* The examples have been rewritten and are all in an "examples" folder, maybe a help file or something will be built in the future. It is also to be organized.
* Added cache support in _FakeYouGetVoicesList and two optional parameters
* Added _FakeYouGetLanguajes, which gets all available languages from the database without repeating them.
* added _FakeYouGetVoicesFromLanguage
* added _FakeYouGetVoiceModelToken. 
	* This function can be used with the following two alternatives:
		* Creating a variable of the type _FakeYouGetVoicesFromLanguage($aVoicesList, $sLanguage)[$ivoiceNumber]
		* Or creating a variable of the type _FakeYouGetVoicesList()[$iVoiceNumber][6]
	* Using one of the two methods, you can set the $sVoicename parameter to the variable that contains the name of the voice, which is obtained from the two methods explained above.
* Added "__CleanArray" internal function

## 0.4.3

* fixed some UDF headers and indentation

## 0.4.2

* fixed _FakeYouWaitForAudioComplete, where it should exit the loop not without first returning error when there is a case of "dead"

## 0.4.1

* Improved and fixed _FakeYou_getDirectAudio

## 0.4

* Added _FakeYou_getDirectAudio function
	* This function does the whole process to create and get the job token, status and finally the audio URL without the need to do it manually.

## 0.3.1

* Fixed _FakeYouWaitForAudioComplete
* fixed _FakeYouGetAudioStatus
* Fixed a very important JSON bugs in _FakeYouGetQueueStatus and _FakeYouGetAudioURL

## 0.3

### important

New beta functions have been added. For now we do not guarantee that they will work properly.

* Added _FakeYouWaitForAudioComplete function
	* Although this function was added in the version, it was an empty function
	* Added $sInferenceJobToken parameter, which is very useful to wait until the process completes based on that job token.
* Added _FakeYouGetQueueStatus
* Added _FakeYouGetAudioURL

## 0.2

This UDF has been completely rewritten, thanks to @danifirex who made this work possible.