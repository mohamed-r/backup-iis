rem désactive l'affichage des commandes
@echo off
rem remise à blanc
cls

rem header
echo .
echo .
echo #######################################
echo ############ 1000 Mercis ##############
echo #######################################
echo ##### HEADER ########## HEADER  #######
echo #######################################
echo ######### Mohamed RHERBAOUI ###########
echo #######################################
echo .
echo .
echo .

rem définie le chemin Root des dossiers à backup
setlocal EnableDelayedExpansion
set rootPath=\\VIRTUAL-CRIQUET\c$\USERS\mrh.MILLEMERCIS\1m-iis-bkp
set serverfile=\\1Mgroup\Shares\Scripts\Backup_ConfIIS\inetpub.txt

set tempFile=%TEMP%\backup-iis.txt
set appcmd=%windir%\system32\inetsrv\appcmd.exe
set iiscnfg=%windir%\system32\IIsCnfg.vbs
set winpath=%windir%


rem On parse le fichier serverfile pour trouver le chemin de l'inetpub
FOR /f "tokens=1-2 delims=&" %%a IN (!serverfile!) DO (
IF /I %%a EQU %computername% (
set inetpub=%%b
)
)

IF NOT EXIST %rootPath%\%computername% (
@echo creation du repertoire:%rootPath%\%computername%
MD %rootPath%\%computername%
)

echo .
echo .
echo #####################################
echo # == Copy of the Inetpub Folder  == #
echo #####################################
echo .
echo .

rem Copie du Dossier Inetpub, l'option V vérifie l'intégrité du fichier copier (ralenti la copie)

xcopy /Y /S /E /V \\%computername%\!inetpub! %rootPath%\%computername%\Inetpub\

echo .
echo .
echo #####################################
echo # ==    Network Configuration    == #
echo #####################################
echo .
echo .

rem Récupération de la configuration réseau
MD %rootPath%\%computername%\Network\
netsh interface dump > %rootPath%\%computername%\Network\network-configuration.txt
if ERRORLEVEL == 1 (
set error="netsh interface failed"
)
echo Network configuration copied

echo .
echo .
echo #####################################################
echo # == Internet Information Services Configuration == #
echo #####################################################
echo .
echo .

rem On check la version de Windows afin de déterminer la version du service IIS<
cmd /c VER > !tempFile!
FOR /f "tokens=4 delims= " %%l in (!tempFile!) do (
set vs=%%l
if "!vs:~0,4!"=="5.2." (
MD %rootPath%\%computername%\IIS\
DEL !tempFile!
rem /children : Ajoute de manière récursive au fichier d'exportation les sous-clés de la clé spécifiée
cmd /c CScript.exe !winpath!\system32\IIsCnfg.vbs /export /s %computername% /f \\%computername%\!inetpub!\config.xml /sp / /children
REM Déplacement du fichier de configuration du serveur sauvegardé sur le serveur de sauvegarde
xcopy /Y /S /V \\%computername%\!inetpub!\config.xml %rootPath%\%computername%\IIS\
if ERRORLEVEL == 1 (
set error="Copy of IIS Configuration Failed"
)
DEL \\%computername%\!inetpub!\config.xml
)
if "!vs:~0,4!"=="6.0." (
MD %rootPath%\%computername%\IIS\
%appcmd%  add backup "Backup-%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%"
xcopy /Y /S /E /V !winpath!\System32\inetsrv\backup\Backup-%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2% %rootPath%\%computername%\IIS\
if ERRORLEVEL == 1 (
set error="Copy of IIS Configuration Failed"
)
)
if "!vs:~0,4!"=="6.1." (
MD %rootPath%\%computername%\IIS\
%appcmd% add backup "Backup-%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2%"
xcopy /Y /S /E /V !winpath!\System32\inetsrv\backup\Backup-%DATE:~6,4%-%DATE:~3,2%-%DATE:~0,2% %rootPath%\%computername%\IIS\ 
if ERRORLEVEL == 1 (
set error="Copy of IIS Configuration Failed"
)
)
)

echo .
echo .
echo #####################################################
echo #                  == Nagios ==                     #
echo #####################################################
echo .
echo .
if defined !error! (
echo "Backup Failed"
	echo %computername%;iis-bkp-task;2;Backup Failed : "!error!" | C:\Send_NSCA\send_nsca.exe -H nagios.1000mercis.com -d ";" -c C:\Send_NSCA\send_nsca.cfg
) else (
echo "Backup Completed Successfully"
	echo %computername%;iis-bkp-task;0;Backup Success : No Error | C:\Send_NSCA\send_nsca.exe -H nagios.1000mercis.com -d ";" -c C:\Send_NSCA\send_nsca.cfg
)
)
rem echo %1%	
rem pause
rem pushd / popd / cd