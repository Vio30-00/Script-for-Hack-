@echo off
echo Instalando dependências necessárias...
pip install pywin32 pycryptodome

echo Iniciando extração de dados...
python extrair_tudo.py

echo FINALIZADO!
pause
