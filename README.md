# Nokturno pro Stremio – aplikace

Nokturno je přehrávač a vyhledávač pro Stremio a Nuvio nad tvým vlastním úložištěm
(například WebDAV) i nad úložišti třetích stran, které si v nastavení zapneš. Běží jako
malá aplikace na tvém počítači, NASu nebo Android TV boxu. Samo žádný obsah nehostuje
ani nešíří. Za to, co přehráváš, odpovídáš ty – používej ho jen k obsahu, ke kterému máš právo.

## Instalace

1. Stáhni si z [vydání](../../releases/latest) soubor pro svoje zařízení:
   Windows, macOS (Intel / Apple), Linux (amd64, arm64, arm, 386) nebo APK pro Android a Android TV.
2. Spusť ho. Na Linuxu a macOS nejdřív `chmod +x`.
3. V prohlížeči otevři `http://<adresa toho zařízení>:7140/configure`, nastav a klikni na
   **Přidat do Stremia** nebo **Přidat do Nuvia**.

Stremio na tomtéž zařízení používá adresu `http://127.0.0.1:7140/…`, z jiného zařízení
v síti adresu s HTTPS, kterou aplikace vypíše při startu.

## Aktualizace

Aplikace se aktualizuje sama podle `update.json` v tomto repozitáři. Balík ověří podle
otisku SHA-256 a verzi, která nenaběhne, vrátí na předchozí.

## Pomoc

[Nápověda](https://nokturno-app.github.io/nokturno-napoveda/) a [Discord](https://discord.gg/ChmMPmDDEj).

Podmínky použití: [nokturno.stream/terms](https://nokturno.stream/terms).
