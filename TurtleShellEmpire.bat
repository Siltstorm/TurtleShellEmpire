ECHO OFF
REM  Thanks to Not So Grey Matter on SevenForums ( http://www.sevenforums.com/tutorials/78083-batch-files-create-menu-execute-commands.html )
REM  For giving me a menu starting point.
REM  This was designed for aiding in penetration testing on networks that are aggressively logging and monitoring Powershell.  
REM  Note that everything could be logged, but these are generally less noisy (log-wise) methods for traversing windows from the command line.
REM  Also note that many environments have cmd.exe and command.com disabled, but still allow the execution of batch scripts.
REM  Paswerd is used in the place of an obvious other word because, well, the other word might get bagged in a standard scan.  We don't want that.
CLS
:MENU
ECHO.
ECHO  %COMPUTERNAME% is the computer name.
ECHO  %USERNAME% is the current user.
ECHO  %HOMEPATH% is the user's home directory.
ECHO  %UserDomain% is the user's domain.
ECHO  You are currently using %UNAME% for a username and 
ECHO  %PWORD% for a password for NET USE Commands.
ECHO  Attempting to change location from  %CD% to system root.
ECHO OFF
cd %SYSTEMDRIVE%\
ECHO Current location is now %CD%.
ECHO ...............................................
ECHO PRESS 1, 2 OR 3 to select your task, or 4 to EXIT.
ECHO ...............................................
ECHO.
ECHO 1 - WMIC and Net Use Based Exploration
ECHO 2 - Search home directory for upper and lower instances of the string "pass"
ECHO 3 - Specify a string to use for searching
ECHO 4 - Load Credentials for NET USE commands
ECHO 5 - Network Based Discovery
ECHO 6 - Exit
ECHO.
SET /P M=Type 1, 2, 3, 4, or 5 then press ENTER:
IF %M%==1 GOTO WMICStuff
IF %M%==2 GOTO PASS
IF %M%==3 GOTO STRING
IF %M%==4 GOTO LOADCREDS
IF %M%==5 GOTO NET_DISCOVERY
IF %M%==6 GOTO EOF

:WMICStuff
ECHO.
ECHO.
ECHO ***WMIC Stuff***
ECHO  Strictly speaking, WMIC and NET USE may be monitored and may get you popped ( https://msdn.microsoft.com/en-us/library/aa392285%28v=vs.85%29.aspx )
ECHO  But hey, it's still an alternative to powershell.  And they'd have to be looking.
ECHO The Drive letters currently in use are:
ECHO.
wmic logicaldisk get caption
GOTO WMICSTUFF_2

:WMICSTUFF_2
ECHO.
ECHO.
ECHO  Your currently specified remote location and share is \\%DRVLOC%\%SHRLOC%
ECHO  Network drive will be bound to %DRVLTR%
ECHO 1 - Set the drive letter for a drive share
ECHO 2 - Specify the remote location
ECHO 3 - Specify a share at the remote location
ECHO 4 - Specify the domain
ECHO 5 - Map Drive
ECHO 6 - Return to main menu
SET /P M=Type 1, 2, 3, or 4 then press ENTER:
IF %M%==1 GOTO SETLETTER
IF %M%==2 GOTO REMLOC
IF %M%==3 GOTO SHARELOC
IF %M%==4 GOTO DOMSPEC
IF %M%==5 GOTO MAPDRIVE
IF %M%==6 GOTO MENU

	:SETLETTER
	SET /P DRVLTR=Type in a DIFFERENT letter that you want to use for your new drive, then press ENTER.  Enter Letter Here: 
	ECHO You set the drive letter to %DRVLTR%:
	PAUSE
	GOTO :WMICSTUFF_2

	:REMLOC
	ECHO Type in the share location that you want to map to %DRVLTR%.  This can be a NETBIOS name or an IP address.  
	SET /P DRVLOC=It should be in the format of BOBS_COMPUTER or 192.168.34.12:    
	ECHO You set the location for %DRVLTR%: to \\%DRVLOC%\
	PAUSE
	GOTO :WMICSTUFF_2	

	:SHARELOC
	ECHO Type in the share path at the location (location currently set to %DRVLOC%).  Backslashes--this is Windows folks, not Linux.
	SET /P SHRLOC=**No leading slash or trailing slash**  It should be in the format of c$ or "c$\Documents and Settings\":   
	ECHO You set the share to \%SHRLOC%\    
	ECHO The current path is \\%DRVLOC%\%SHRLOC%
	PAUSE
	GOTO :WMICSTUFF_2	

	:DOMSPEC
	SET /P DOMLOC=Type in the domain name (location currently set to %DOMLOC%).  No slashes:  
	ECHO You set the domain to \%DOMLOC%\    
	PAUSE
	GOTO :WMICSTUFF_2	

	:MAPDRIVE
	ECHO About to map \\%DRVLOC%\%SHRLOC% to %DRVLTR%: using user:  %DOMLOC%\%UNAME% and password:  %PWORD%
	ECHO The fully qualified command is 
	ECHO net use %DRVLTR%: \\%DRVLOC%\%SHRLOC% %PWORD% /user:%DOMLOC%\%UNAME%
	SET /P YN=Are you sure that you want to execute this command?  (y/n): 
	IF %YN%==y GOTO COMMIT_DRIVE
	PAUSE
	GOTO :WMICSTUFF	

		:COMMIT_DRIVE
		net use %DRVLTR%: \\%DRVLOC%\%SHRLOC% %PWORD% /user:%DOMLOC%\%UNAME%
		GOTO WMICSTUFF



REM ECHO  The full path is  %PATH% .
REM ECHO.
REM ECHO  The execute order is  %PATHEXT% .
REM ECHO.
REM ECHO  Let's check permissions on PATH:  (FEATURE NOT ENABLED YET)
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

:LOADCREDS
SET /P UNAME=Enter the username that you want to use for NET USE commands:  
ECHO.
ECHO  %UNAME% is now set as the username you will use.

SET /P PWORD=Enter the PASWERD that you want to use for NET USE commands:  
ECHO.
ECHO  %PWORD% is now set as the paswerd you will use.

ECHO.


PAUSE
GOTO MENU



:NET_DISCOVERY
ECHO.
ECHO.
ECHO  Let's poke around.  Some of this will be passive, some invasive.  
ECHO  I'll try to mark which is which.
ECHO.
ECHO 1 - List the current ARP cache
ECHO 2 - Specify the remote location
ECHO 3 - Specify a share at the remote location
ECHO 4 - Specify the domain
ECHO 5 - Map Drive
ECHO 6 - Return to main menu
SET /P M=Type 1, 2, 3, or 4 then press ENTER:
IF %M%==1 GOTO ARPC_READ
IF %M%==2 GOTO 
IF %M%==3 GOTO 
IF %M%==4 GOTO 
IF %M%==5 GOTO 
IF %M%==6 GOTO MENU

	:ARPC_READ
	arp -a
	PAUSE
	GOTO NET_DISCOVERY

PAUSE
GOTO MENU

GOT MENU