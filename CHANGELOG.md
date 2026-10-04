# Změny – Nokturno pro Stremio

Přehled vydání aplikace. Stažení na stránce [vydání](https://github.com/nokturno-app/nokturno-stremio-app/releases), návod v [nápovědě](https://nokturno-app.github.io/nokturno-napoveda/cs/stremio-aplikace).

## 10.2.2 – drobné opravy (2026-10-04)

- Tlačítka v sekci Aplikace mají mezi sebou mezeru.

## 10.2.1 – adresa doplňku blokovaná DNS (2026-10-04)

- Když telefon nebo router zablokuje adresu doplňku (`…my.local-ip.co`), stránka nastavení řekne, co s tím: v Androidu Soukromé DNS na `one.one.one.one`, na routeru výjimka pro `my.local-ip.co`. Návod: [Časté problémy](https://nokturno-app.github.io/nokturno-napoveda/cs/stremio-instalace#caste-problemy).
- Stejnou kontrolu má i stránka z QR kódu.

## 10.0.2 – aktuální časté otázky (2026-10-03)

- Časté otázky ve formuláři odpovídají aplikaci u tebe: hesla jsou v profilu v aplikaci, změny účtů a předvoleb platí hned, doplněk se znovu přidává jen po změně katalogů.
- Nové otázky ke Koncertům a vlastním katalogům, chyby se hlásí na Discordu.

## 10.0.1 – vlastní katalogy s vlastním klíčem TMDB (2026-10-03)

- S vlastním klíčem TMDB (`tmdb_key` v `nokturno.json`) se vlastní katalogy berou přímo z TMDB a server Nokturna je jen záloha. Bez klíče se nic nemění.

## 10.0.0 – vlastní katalogy a koncerty (2026-10-03)

- **Vlastní katalogy.** Až 20 seznamů na domovské stránce Stremia, každý ve vlastní záložce. Založíš je ze šablony (Populární, Nejlépe hodnocené, Nové s CZ dabingem, Filmy ve 4K s CZ dabingem, Pohádky s CZ dabingem…) nebo podle žánrů, témat, země původu a let. Návod: [Vlastní katalogy](https://nokturno-app.github.io/nokturno-napoveda/cs/vlastni-katalogy).
- **Jen tituly se streamem.** Katalog ověřuje na pozadí, dokud aplikace běží, a ukáže jen to, co jde přehrát v kvalitě, jazyce zvuku a titulků, jakou chceš, i s 5.1.
- **Koncerty.** Zaškrtni hudební žánry a vlož klíč Last.fm (zdarma). Ve Stremiu přibude druh Koncerty se seznamy Nově přidané a Podle abecedy. Návod: [Koncerty](https://nokturno-app.github.io/nokturno-napoveda/cs/koncerty).
- Dřívější karta Katalogy (Populární, Nejlépe hodnocené) se sama převedla na vlastní katalogy.
- Po změně katalogů nebo koncertů doplněk ve Stremiu přidej znovu.

## 9.12.1 – heslo správce bez kódu (2026-10-03)

- **Heslo správce si nastavíš hned.** Pole „Kód z výpisu aplikace“ je pryč, při prvním otevření nastavení stačí zadat heslo dvakrát.
- Kdo nastavení otevře první, stane se správcem. Na veřejné adrese (VPS, vlastní doména) ho proto otevři hned po instalaci.
- Po 20 špatných heslech za 10 minut aplikace další pokusy na chvíli odmítá.

## 9.12.0 – správce aplikace (2026-10-03)

Aplikace pozná svého majitele podle **hesla správce**, ne podle sítě. Funguje tak stejně doma, na VPS i za vlastní doménou. Návod: [Heslo správce a profily kamarádů](https://nokturno-app.github.io/nokturno-napoveda/cs/stremio-aplikace#heslo-spravce-a-profily-kamaradu).

- **První spuštění.** Dokud heslo není, stránka `/configure` ukáže jen kartu *Heslo správce*. Heslo má aspoň 6 znaků.
- **Správce vidí** všechny profily (i ty, které si založili kamarádi), sekci **⚙ Aplikace** s přepínačem profilů, změnou hesla, odhlášením a kontrolou aktualizací, a povoluje zařízení.
- **Kamarádi a ostatní** heslo nepotřebují. Profil si založí a doplněk přidají jako dřív, v seznamu ale vidí jen profily, které si uložili ve svém prohlížeči. Sekci Aplikace ani cizí profily neuvidí.
- **Doplněk ve Stremiu a Nuviu** heslo nechce, adresa doplňku se nemění.
- **Přihlášení v jiném prohlížeči:** dole na stránce nastavení *Jsi správce aplikace? Přihlas se*. Přihlášení vydrží rok.
- **Změna hesla** v sekci Aplikace ukončí ostatní přihlášení správce.
- **Zapomenuté heslo:** v datové složce smaž ze souboru `aplikace.json` položku `spravce` a aplikaci restartuj. Na Androidu to jde jen smazáním dat aplikace (zmizí i profily).
- Heslo k celé stránce z 9.9.2 heslo správce nahradilo.

## 9.11.1 – drobné opravy (2026-10-03)

- Tlačítka Přidat do Stremia a Přidat do Nuvia u aplikace bez HTTPS adresu doplňku zkopírují místo otevření aplikace, které končilo chybou „Failed to fetch“.

## 9.9.4 – drobné opravy (2026-10-03)

- Sekce Aplikace (profily a heslo) je vidět hned na první obrazovce nastavení.

## 9.9.3 – drobné opravy (2026-10-03)

- Hláška pod tlačítkem Založit nový profil už na něm nelepí.

## 9.9.2 – profily a heslo v nastavení aplikace (2026-10-03)

- **Sekce Aplikace** na stránce nastavení (jen pro správce, ne přes veřejnou adresu): přepínač **Profily** a **heslo k nastavení**.
- **Bez profilů.** Kdo je vypne, dostane adresu doplňku s celým nastavením jako dřív. Už uložené profily fungují dál. Na první obrazovce je odkaz Nechci profily.
- **Heslo** chrání stránku nastavení a profily, když je aplikace dostupná z internetu. Doplněk ve Stremiu heslo nechce. Ukládá se jen jako hash.

## 9.9.1 – víc streamů z FastShare, CAM na řádku kvality (2026-10-03)

- **FastShare.** Soubory na nových datových serverech FastShare doplněk nepoznal, u nových filmů tak často zbyl jen jeden stream. Teď se ukážou všechny.
- **Značka CAM** je za kvalitou na tomtéž řádku (Full HD 🎥 CAM).
- **Bez profilů.** `NOKTURNO_PROFILY=0` vrátí nastavení jako dřív – celé nastavení v adrese doplňku, žádné profily.
- **Heslo.** `NOKTURNO_HESLO` chrání nastavení a profily heslem. Doplněk ve Stremiu heslo nechce.

## 9.9.0 – kodek obrazu, další vlajky a značka CAM (2026-10-02)

- **Kodek obrazu.** Popis streamu ukazuje kodek z hlavičky souboru (🎞 HEVC, AVC, AV1, MPEG-4…), ať je hned jasné, co tvůj přehrávač zvládne.
- **Další vlajky.** Zvuk v japonštině, korejštině, čínštině, ukrajinštině a dalších jazycích má vlastní vlajku.
- **Značka CAM.** Nahrávky z kina mají ve výpisu vždy značku 🎥 CAM. Nově mezi ně patří i soubory označené KINO, screener a R5 naopak ne – bývají to uniklé verze v dobré kvalitě.
- **Značky obrazu oddělené:** 4K DV • HDR10.
- **Anglický název.** Film, který má ve Stremiu původní název, najde i soubory pojmenované anglicky (La tregua × The Truce).
- **Filmy v kině.** Mezi streamy nového filmu se nepletou soubory starších filmů se stejným začátkem názvu (Resident Evil).

## 9.8.2 – drobné opravy (2026-10-02)

Ukončení aplikace v terminálu klávesami Ctrl+C už nekončí chybovým výpisem.

## 9.7.1 – výběr profilu i pro kamarády (2026-10-02)

Na sdílené instanci (`"sdilena": true`) vidí stránka nastavení i z internetu výběr profilů: založení nového profilu s názvem, otevření, přejmenování a smazání.

## 9.7.0 – nastavení pro kamarády (2026-10-02)

Aplikaci na VPS nebo jiném serveru s veřejnou adresou můžeš pustit i kamarádům. Volba `"sdilena": true` v souboru `nokturno.json` zpřístupní stránku nastavení i z internetu: kamarád si na ní založí vlastní profil se svými účty a doplněk přidá do svého Stremia.

## 9.6.2 – drobné opravy (2026-10-02)

Když stránka nastavení nedokáže načíst seznam profilů, ukáže rovnou formulář místo prázdné stránky.

## 9.6.1 – úložiště a FastShare hrají i ve Stremiu pro Android (2026-10-02)

Stremio pro Android neposílalo přihlášení k vlastnímu úložišti ani k FastShare, takže se film z nich nespustil a přehrávač jen přepínal. Soubor teď přehrávači předává aplikace Nokturno sama, přihlášení do Stremia neodchází. Upozornění o webovém přehrávači u streamů zmizelo.

## 9.6.0 – profily nastavení a QR kód (2026-10-02)

Nastavení se ukládá v aplikaci a adresa doplňku je krátká, bez hesel.

- **Profily nastavení.** Na stránce nastavení (`/configure`) založíš pojmenovaný profil (třeba *Obývák*, *Mobil*). Nastavení se uloží v aplikaci a adresa doplňku nese jen náhodný klíč profilu.
- **Změny bez nového přidání.** Účty, úložiště a předvolby uložíš tlačítkem **Uložit změny** a platí hned – doplněk do Stremia znovu nepřidáváš. Jen po změně katalogů je potřeba doplněk přidat znovu (Stremio si katalogy pamatuje).
- **Víc profilů.** Seznam uložených profilů s možností otevřít, přejmenovat nebo smazat. Profil bez názvu nejde založit.
- **QR kód pro mobil.** Tlačítko **QR pro mobil** ukáže kód, který na telefonu otevře stránku s tlačítky Přidat do Stremia, Přidat do Nuvia a Zkopírovat adresu.
- **Zdroje v záložkách.** Každý zdroj má ve formuláři vlastní záložku, vyplněný zdroj má zelenou tečku a lišta záložek zůstává při rolování nahoře.
- **Ověřit všechny účty.** Jedno tlačítko ověří všechny vyplněné účty naráz a výsledek ukáže v rámečku, klik na řádek otevře záložku zdroje.
- **Převod staré adresy.** Doplněk se starou dlouhou adresou (do 9.5.x) se po otevření nastavení ve Stremiu sám převede na profil. Pak ho přidej znovu a starý odeber.

## 9.5.4 – rychlejší hledání a pomoc při chybě přidání (2026-10-01)

Pomalý zdroj už seznam streamů nezdržuje a spojení se zdroji se používají opakovaně. Když router v domácí síti nepřeloží adresu doplňku (ochrana proti DNS rebinding), stránka nastavení to ukáže i s postupem a nabídne adresu 127.0.0.1. Drobné opravy.

## 9.5.2 – oprava HTTPS na macOS (2026-10-01)

Samostatný program pro macOS (a Linux bez systémových certifikátů) si nově nese vlastní kořenové certifikáty. Dřív na Macu s čipem Apple selhalo stažení certifikátu pro HTTPS v domácí síti.

## 9.5.1 – drobné opravy (2026-10-01)

Drobné opravy.

## 9.5.0 – služba Windows a macOS (2026-10-01)

Aplikace se dá nainstalovat jako služba, takže běží pořád – i po restartu a bez přihlášení.

- Windows: `nokturno-9.5.0-windows-amd64.exe --install` (potvrď oprávnění správce). Služba „Nokturno pro Stremio“ je ve services.msc, sama si povolí přístup v bráně firewall a po pádu se restartuje. Nastavení se přenese do C:\ProgramData\Nokturno. Odinstalace: `C:\ProgramData\Nokturno\nokturno.exe --uninstall`.
- macOS: `sudo ./nokturno-9.5.0-macos-arm64 --install` (nebo -amd64). Okno Terminálu už nemusí zůstat otevřené. Odinstalace: `sudo "/Library/Application Support/Nokturno/nokturno" --uninstall`.
- Na Windows druhé spuštění aplikace jen otevře nastavení v prohlížeči.

## 9.4.0 – skrytí nahrávek z kina (2026-09-30)

Ve formuláři je nový přepínač Skrýt nahrávky z kina (CAM, telesync), zapnutý ve výchozím stavu. Když zatím existuje jen nahrávka z kina, zobrazí se.

## 9.3.5 – opravy chyb (2026-09-30)

Drobné opravy.

## 9.3.4 – bez nahrávek z kina (2026-09-30)

Drobné opravy.

## 9.3.3 – opravy chyb (2026-09-30)

Drobné opravy.

## 9.3.2 – katalogy TMDB bez vlastního klíče (2026-09-30)

Drobné opravy.

## 9.3.1 – opravy chyb (2026-09-30)

Drobné opravy.

## 9.3.0 – ikona v oznamovací oblasti (2026-09-30)

Drobné opravy.

## 9.2.9 – opravy chyb (2026-09-30)

Drobné opravy.

## 9.2.8 – tlačítka v aplikaci v Androidu (2026-09-30)

Skrytá tlačítka v aplikaci už nejsou vidět.

## 9.2.7 – otevírání odkazů a aktualizace v Androidu (2026-09-30)

Odkazy v aplikaci se otevírají spolehlivěji a když se nepovede otevřít, aplikace řekne proč.

## 9.2.6 – stažení a instalace aktualizace v aplikaci (2026-09-30)

Tlačítko aktualizace v Androidu aplikaci stáhne a spustí instalaci.

## 9.2.5 – aktualizace APK bez odinstalace (2026-09-30)

Aplikace v Androidu se podepisuje stálým klíčem, takže se další verze nainstalují přes tu předchozí. Tuhle verzi je potřeba nainstalovat naposledy po odinstalování staré.

## 9.2.4 – aktualizace aplikace v Androidu (2026-09-30)

Aplikace v Androidu ukáže, jestli je dostupná novější verze, a nabídne její stažení.

## 9.2.3 – přidání do Stremia a Nuvia v Androidu a služba na pozadí (2026-09-30)

Přidání doplňku do Stremia a Nuvia na stejném zařízení v Androidu už nehlásí chybu TLS ani nezůstane na točícím se kolečku. Aplikace v Androidu běží jako služba na pozadí, po restartu i po aktualizaci se spustí sama, sama se znovu nahodí a ukazuje, jestli jí Android neomezuje baterii.

## 9.2.2 – logo v Nuviu (2026-09-30)

Drobné opravy.

## 9.2.1 – bez ukázek ve výběru streamu (2026-09-30)

Bez ukázek a krátkých videí ve výběru streamu.

## 9.0.9 (2026-09-29)

Drobné opravy.

## 9.0.8 (2026-09-29)

Drobné opravy.

## 9.0.7 – kontrola aktualizací z nastavení (2026-09-29)

Drobné opravy.

## 9.0.6 (2026-09-29)

Drobné opravy.

## 9.0.5 (2026-09-29)

Drobné opravy.

## 9.0.4 – opravy chyb (2026-09-29)

Opravy chyb.

## 9.0.0 – první vydání aplikace (2026-09-29)

Nokturno pro Stremio jako aplikace, která běží u tebe: Windows, macOS, Linux a Android.
