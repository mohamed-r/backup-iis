rem d�sactive l'affichage des commandes
@echo off
rem remise � blanc
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

rem d�finie le chemin Root des dossiers � backup
setlocal EnableDelayedExpansion
set rootPath=\\VIRTUAL-CRIQUET\c$\USERS\mrh.MILLEMERCIS\1m-iis-bkp

echo .
echo .
echo #####################################
echo #          == Git PULL  ==          #
echo #####################################
echo .
echo .
pushd !rootPath!
Git\cmd\git.cmd pull ./
popd