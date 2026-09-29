# Nokturno pro Stremio – aplikace

Nokturno je přehrávač a vyhledávač pro **Stremio** a **Nuvio** nad tvým vlastním úložištěm
(například WebDAV na NASu) i nad úložišti třetích stran, které si v nastavení zapneš.
Běží jako malá aplikace u tebe – na počítači, NASu nebo Android TV boxu – a Stremio se na ni
ptá jako na každý jiný doplněk. Nokturno samo žádný obsah nehostuje ani nešíří.

**Proč aplikace u tebe, a ne doplněk na cizím serveru?** Stremio posílá nastavení doplňku, tedy i jména a hesla k účtům (WebShare, FastShare, Přehraj.to…), v jeho adrese – a tu dostává server, na kterém doplněk běží. U doplňku na cizím serveru tak svoje přihlašovací údaje svěřuješ někomu dalšímu. Když doplněk běží u tebe, údaje zůstávají jen na tvém zařízení a nikdo jiný je nevidí. Je to jediný způsob, jak mít ve Stremiu účty a nikomu je nedávat.

> **Patří k sobě:** Nokturno je i jako [**doplněk pro Kodi**](https://github.com/nokturno-app/plugin.video.nokturno) a jako [**integrace pro Home Assistant**](https://github.com/nokturno-app/nokturno-ha) (HACS). Všechny stojí na společném jádru.

Tady jsou jen hotové aplikace ke stažení a soubor `update.json`, podle kterého se aplikace
sama aktualizuje. Návody a řešení problémů jsou v [nápovědě](https://nokturno-app.github.io/nokturno-napoveda/cs/stremio-aplikace).

## Stažení

Všechno je v [posledním vydání](../../releases/latest). Vyber soubor podle zařízení:

| Zařízení | Soubor |
|---|---|
| Windows 10 a 11 (64bit) | `nokturno-<verze>-windows-amd64.exe` |
| Mac s čipem Apple (M1 a novější) | `nokturno-<verze>-macos-arm64` |
| Mac s procesorem Intel | `nokturno-<verze>-macos-amd64` |
| Linux, běžné PC a NAS (64bit) | `nokturno-<verze>-linux-amd64` |
| Linux na ARM 64bit (Raspberry Pi 4 a 5 s 64bit systémem, ARM NAS) | `nokturno-<verze>-linux-arm64` |
| Linux na ARM 32bit (starší Raspberry Pi) | `nokturno-<verze>-linux-arm` |
| Linux 32bit | `nokturno-<verze>-linux-386` |
| Android, Android TV, Google TV | `nokturno-<verze>.apk` |

Soubor `nokturno-<verze>.zip` a `update.json` jsou pro automatické aktualizace, stahovat je nemusíš.

## Spuštění

Aplikace musí běžet, kdykoli se díváš. Nejlíp na zařízení, které je pořád zapnuté (NAS, TV box),
nebo přímo na tom, kde Stremio pouštíš.

### Windows
1. Spusť `nokturno-<verze>-windows-amd64.exe`.
2. Když Windows ukáže „Systém Windows ochránil váš počítač“, klikni na **Další informace → Přesto spustit**.
   Aplikace není podepsaná certifikátem, proto to Windows hlásí.
3. Když se brána firewall zeptá na přístup, povol ho pro **soukromé sítě** (jinak ji Stremio z jiného zařízení nenajde).
4. Otevře se okno s výpisem. Dokud je otevřené, aplikace běží. Zavřením ji vypneš.

Ať se spouští sama: stiskni `Win + R`, napiš `shell:startup` a do otevřené složky vlož zástupce na `.exe`.

### macOS
1. V Terminálu přejdi do složky se staženým souborem a povol spuštění:
   ```bash
   chmod +x nokturno-*-macos-*
   xattr -d com.apple.quarantine nokturno-*-macos-*
   ```
   Druhý příkaz odstraní značku staženého souboru. Bez něj macOS (Gatekeeper) spuštění zablokuje,
   protože aplikace není podepsaná. Jinak to jde i přes **Nastavení systému → Soukromí a zabezpečení → Přesto otevřít**.
2. Spusť ji: `./nokturno-<verze>-macos-arm64` (nebo `-amd64`). Okno Terminálu nech otevřené.

### Linux
```bash
chmod +x nokturno-*-linux-*
./nokturno-<verze>-linux-amd64
```
Ať běží pořád i po restartu, stačí uživatelská služba systemd, třeba `~/.config/systemd/user/nokturno.service`:
```ini
[Unit]
Description=Nokturno pro Stremio

[Service]
ExecStart=%h/nokturno/nokturno-9.0.0-linux-amd64
Restart=on-failure

[Install]
WantedBy=default.target
```
Pak `systemctl --user enable --now nokturno` a `loginctl enable-linger $USER`. Aktualizace se stahují
do datové složky, soubor v `ExecStart` se proto při nové verzi měnit nemusí.

### Android a Android TV
1. Povol instalaci z neznámých zdrojů pro aplikaci, kterou APK otevřeš (prohlížeč, správce souborů, na TV
   třeba **Downloader**).
2. Nainstaluj `nokturno-<verze>.apk` a otevři **Nokturno**. Aplikace ukáže adresy pro nastavení.
3. Běží na pozadí s trvalým oznámením „Nokturno běží“ a po zapnutí zařízení se spustí sama.

## Instalace jedním příkazem (Linux, VPS, Raspberry Pi)

Na Debianu, Ubuntu a Raspberry Pi OS nainstaluje aplikaci jako službu systemd (běží pořád, i po restartu):

```bash
curl -fsSL https://raw.githubusercontent.com/nokturno-app/nokturno-stremio-app/main/install.sh | sudo bash
```

Skript pozná architekturu (amd64, arm64, arm, 386), stáhne aplikaci z posledního vydání a ověří otisk SHA-256.
Aplikace je v `/opt/nokturno/nokturno`, nastavení a data v `/opt/nokturno/data` (`nokturno.json`),
služba se jmenuje `nokturno` (`systemctl status nokturno`, výpis `journalctl -u nokturno`).

- **Domácí síť (bez přepínačů):** aplikace poslouchá na portu 7140 a 7141 (HTTPS přes local-ip.co) jako na počítači.
  Nastavení otevřeš na `http://<IP stroje>:7140/configure`.
- **VPS s doménou:** `… | sudo bash -s -- --domain nokturno.example.cz`. Skript nainstaluje
  [Caddy](https://caddyserver.com) s certifikátem Let's Encrypt, aplikace poslouchá jen na `127.0.0.1`
  a nastavení je na `https://nokturno.example.cz/configure`. Záznam A (nebo AAAA) domény musí mířit
  na veřejnou IP serveru. Je-li nainstalovaný `ufw`, povolí porty 22, 80 a 443 a zapne ho.

| Přepínač | Co dělá |
|---|---|
| `--domain DOMÉNA` | VPS s doménou a Caddy (viz výše) |
| `--port 7140` | jiný port aplikace (HTTPS v domácí síti je vždy o jedna vyšší) |
| `--no-firewall` | nesahá na `ufw` |
| `--uninstall` | odstraní službu, aplikaci a konfiguraci Caddy pro Nokturno, data nechá v `/opt/nokturno/data` |

Opakované spuštění stáhne novější aplikaci a zachová nastavení i data. Doménu a port si pamatuje,
nemusíš je zadávat znovu.

Adresa doplňku obsahuje tvoje účty. Když aplikaci vystavíš do internetu na doméně, adresu nikomu neposílej.

## Přidání do Stremia a Nuvia

1. Otevři v prohlížeči nastavení doplňku:
   - na zařízení, kde aplikace běží: `http://127.0.0.1:7140/configure`,
   - z jiného zařízení ve stejné síti: `http://<IP adresa toho zařízení>:7140/configure`
     (adresu vypíše aplikace při startu, v Androidu je na hlavní obrazovce).
2. Vyplň vlastní úložiště a případně účty zdrojů, u každého dej **Ověřit**. Potvrď souhlas s podmínkami.
3. Klikni na **Přidat do Stremia** nebo **Přidat do Nuvia**. Pro Streamlet a ruční vložení je
   **Zkopírovat adresu**.
4. Na televizi se doplněk objeví sám, když ho přidáš na telefonu nebo počítači pod stejným účtem Stremio.

Adresa doplňku obsahuje tvoje nastavení i účty. Nikomu ji neposílej.

### Proč adresa začíná na `https://…my.local-ip.co`
Stremio přijme doplněk přes obyčejné `http` jen z téhož zařízení (`127.0.0.1`). Z jiného zařízení v síti
chce HTTPS s platným certifikátem. Aplikace proto otevře i port **7141** s adresou
`https://192-168-1-10.my.local-ip.co:7141` (pro IP 192.168.1.10). Služba [local-ip.co](https://local-ip.co)
takové jméno přeloží zpátky na tvoji místní IP a k tomu zveřejňuje certifikát. Stejně to dělá Luna.
Data tečou jen po tvé domácí síti. Formulář otevřený přes IP adresu dá tuhle adresu do doplňku sám.

Když se IP adresa zařízení změní, přestane doplněk ve Stremiu fungovat. V routeru proto zařízení nastav
pevnou IP (rezervace DHCP).

## Nastavení aplikace

Při prvním spuštění vznikne v datové složce soubor `nokturno.json`:

| Systém | Datová složka |
|---|---|
| Windows | `%APPDATA%\Nokturno` |
| macOS | `~/Library/Application Support/Nokturno` |
| Linux | `~/.local/share/nokturno` |

| Volba | Výchozí | Co dělá |
|---|---|---|
| `host` | `0.0.0.0` | adresa poslechu, za reverzní proxy `127.0.0.1` (od verze 9.0.4) |
| `public_url` | `""` | veřejná adresa doplňku, kterou ukáže `/configure`, např. `https://nokturno.example.cz` – když formulář otevíráš přes Tailscale nebo domácí síť (od verze 9.0.5) |
| `soukroma` | `false` | `true` = soukromá instance: doplněk obslouží jen nastavení povolená tlačítkem *Povolit na tomhle serveru* na `/configure` nebo `nokturno --povolit <adresa doplňku>` (od verze 9.0.4) |
| `port` | `7140` | port nastavení a doplňku přes http |
| `https_port` | `7141` | port HTTPS pro Stremio z jiného zařízení |
| `enable_https` | `true` | `false` vypne HTTPS (pak doplněk funguje jen na tomtéž zařízení) |
| `tmdb_key` | prázdné | vlastní klíč TMDB, zapne katalogy TMDB (Populární, Nejlépe hodnocené) |
| `stats` | `true` | `false` vypne anonymní statistiky |
| `crash_reports` | `true` | `false` vypne hlášení o pádech |

Po úpravě aplikaci restartuj. Port jde změnit i při spuštění: `--port 7150 --https-port 7151`,
HTTPS vypne `--bez-https`, jinou datovou složku určí `--data SLOŽKA`.

## Aktualizace

Aplikace se aktualizuje sama. Při startu a pak každých 6 hodin se podívá do `update.json` v tomto repozitáři.
Novou verzi stáhne, ověří otisk SHA-256 a spustí. Když nová verze nenaběhne, vrátí se k předchozí.
Na Androidu se nová verze stahuje při spuštění služby, tedy po zapnutí zařízení nebo otevření aplikace.

Aktualizuje se jen samotný doplněk. Nový spustitelný soubor nebo APK stahovat nemusíš, dokud to nenapíšeme
v nápovědě nebo na Discordu.

## Když něco nejde

- **Stremio doplněk nepřidá nebo u `…my.local-ip.co` hlásí chybu.** Některé routery blokují jména,
  která se překládají na domácí IP (ochrana proti DNS rebinding). Povol v routeru výjimku pro `local-ip.co`,
  nebo v zařízení se Stremiem nastav DNS `1.1.1.1`.
- **Nastavení se z jiného zařízení neotevře.** Zkontroluj, že obě zařízení jsou ve stejné síti, aplikace běží
  a firewall pouští porty 7140 a 7141.
- **„Address already in use“ při startu.** Port 7140 už používá jiný program. Spusť aplikaci s `--port 7150 --https-port 7151`.
- **Stream s „⚠️ Ve webovém přehrávači se nepřehraje“** (vlastní úložiště, FastShare) hraje jen v aplikaci Stremio
  nebo Nuvio, ne ve Stremiu v prohlížeči.
- **U filmu nejsou streamy Nokturna.** V nastavení doplňku dej u každého zdroje **Ověřit**. Víc v
  [nápovědě](https://nokturno-app.github.io/nokturno-napoveda/cs/stremio-zadne-streamy).

Další návody: [nápověda Nokturna](https://nokturno-app.github.io/nokturno-napoveda/). Dotazy: [Discord](https://discord.gg/ChmMPmDDEj), fórum #pomoc.

## Statistiky a soukromí

Aplikace posílá anonymní statistiky používání a hlášení o pádech na server Nokturna. Vypneš je volbami
`stats` a `crash_reports` v `nokturno.json`. Účty ani adresa doplňku se neposílají. Podrobnosti:
[nokturno.stream/privacy](https://nokturno.stream/privacy).

## Podmínky použití

Nokturno je přehrávač a vyhledávač nad tvým vlastním úložištěm i nad úložišti třetích stran, které si zapneš.
Soubory leží na serverech těchto služeb a přehrávač si je stahuje přímo odtud. Nokturno neověřuje právní status
jednotlivých souborů. Používej ho jen k obsahu, ke kterému máš právo. Za to, co přehráváš, odpovídáš ty.

Plné znění: [nokturno.stream/terms](https://nokturno.stream/terms). Oznámení porušení práv:
[nokturno.stream/abuse](https://nokturno.stream/abuse).

## Licence

Aplikaci smíš zdarma stáhnout a používat pro osobní, nekomerční účely. Kopírování, úpravy a další šíření bez svolení nejsou dovolené,
viz [LICENSE](LICENSE).
