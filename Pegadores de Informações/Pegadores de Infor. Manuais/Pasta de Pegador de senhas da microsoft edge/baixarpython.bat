@echo off
echo Baixando e instalando Python...

curl -o python-installer.exe https://www.python.org/ftp/python/3.12.2/python-3.12.2-amd64.exe

start /wait python-installer.exe /quiet InstallAllUsers=1 PrependPath=1 Include_test=0
del python-installer.exe

echo Python instalado com sucesso!
