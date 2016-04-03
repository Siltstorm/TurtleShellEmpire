ECHO OFF
REM  Thanks to Not So Grey Matter on SevenForums ( http://www.sevenforums.com/tutorials/78083-batch-files-create-menu-execute-commands.html )
REM  For giving me a menu starting point.

CLS
:MENU
ECHO.
ECHO  %COMPUTERNAME% is the computer name.
ECHO  %USERNAME% is the current user.
ECHO  %HOMEPATH% is the user's home directory.
ECHO  %UserDomain% is the user's domain.
ECHO  Changing location from  %CD% to system root.
ECHO OFF
cd %SYSTEMDRIVE%\
ECHO Current location is now %CD%.
ECHO ...............................................
ECHO PRESS 1, 2 OR 3 to select your task, or 4 to EXIT.
ECHO ...............................................
ECHO.
ECHO 1 - Path Exploitation
ECHO 2 - Search home directory for upper and lower instances of the string "pass"
ECHO 3 - Specify a string to use for searching
ECHO 4 - EXIT
ECHO.
SET /P M=Type 1, 2, 3, or 4 then press ENTER:
IF %M%==1 GOTO PATH
IF %M%==2 GOTO PASS
IF %M%==3 GOTO STRING
IF %M%==4 GOTO EOF

:PATH
ECHO  The full path is  %PATH% .
ECHO.
ECHO  The execute order is  %PATHEXT% .
ECHO.
ECHO  Let's check permissions on PATH:  (FEATURE NOT ENABLED YET)
PAUSE
GOTO MENU

:PASS
findstr /s /n /i *pass*
PAUSE
GOTO MENU

:STRING

SET /P SEARCHSTRING=Enter the string you want to use to search for a filename or word within a file, then press ENTER.  be careful with special characters:  
ECHO.
ECHO  You want to search for:  %SEARCHSTRING% .
ECHO.
SET /P SEARCHSEL=Do you want to search for a (F)ile or a (S)tring?  
IF %SEARCHSEL%==F GOTO FILESEARCH
IF %SEARCHSEL%==f GOTO FILESEARCH
IF %SEARCHSEL%==S GOTO STRINGSEARCH
IF %SEARCHSEL%==s GOTO STRINGSEARCH


:FILESEARCH
ECHO.
ECHO You chose to search for a file named %SEARCHSTRING%.
dir *"%SEARCHSTRING%"* /s /b

PAUSE
GOTO MENU

:STRINGSEARCH
ECHO.
ECHO  You chose to search for a string named %SEARCHSTRING%.
SET /P SPARAMS=Did you want to take forever and search the (W)hole drive, or would you rather (S)pecify a file?  
IF %SPARAMS%==W GOTO WHOLEDRIVE
IF %SPARAMS%==W GOTO WHOLEDRIVE
IF %SPARAMS%==S GOTO STRINGINFILE
IF %SPARAMS%==s GOTO STRINGINFILE

:WHOLEDRIVE
findstr /s /n /i *"%SEARCHSTRING%"*
GOTO MENU

:STRINGINFILE
SET /P SFPARAM=What file (please give the full path):  
findstr "%SEARCHSTRING%" "%SFPARAM%"
GOTO MENU



PAUSE
GOTO MENU

GOTO MENU