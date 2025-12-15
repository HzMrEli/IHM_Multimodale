@echo off
cd /d "%~dp0"

echo Lancement de sra5...
start "sra5" /d "windows-amd64/sra5" cmd /c "sra5 -b 127.255.255.255:2010 -g grammar.grxml -p on && exit"

echo Lancement d'icar...
start "icar" /d "windows-amd64/icar" cmd /c "java -cp .;icar-1.2.jar;ivy-java-1.2.17.jar IcarClientIvy dictionnaires/dictionnaire_formes.dat && exit"
timeout /t 5 >nul

echo Lancement du moteur principal...
start "moteur" /d "windows-amd64" cmd /c "source.exe && exit"
timeout /t 3 >nul

echo Tous les services lancés !

