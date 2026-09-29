#!/usr/bin/env bash
# Nokturno pro Stremio – instalace na Linux (Debian, Ubuntu, Raspberry Pi OS) jako služba systemd.
#
#   curl -fsSL https://raw.githubusercontent.com/nokturno-app/nokturno-stremio-app/main/install.sh \
#     | sudo bash -s -- [--domain nokturno.example.cz] [--port 7140] [--no-firewall] [--uninstall]
#
# Bez --domain: domácí síť, aplikace poslouchá na všech rozhraních, HTTPS přes local-ip.co.
# S --domain:   VPS s doménou, Caddy (certifikát Let's Encrypt) před aplikací na 127.0.0.1.
# Opakované spuštění aktualizuje aplikaci a zachová nastavení i data.
# Pro testy: --prefix SLOŽKA (vše pod ní) a --no-systemd (spustí aplikaci na pozadí bez systemd).
set -euo pipefail

REPO="nokturno-app/nokturno-stremio-app"
API="https://api.github.com/repos/$REPO/releases"

chyba() { echo "Chyba: $*" >&2; exit 1; }
info() { echo "==> $*"; }
varovani() { echo "Varování: $*" >&2; }

main() {
  local domena="" port="" firewall=1 odinstalovat=0 systemd=1 prefix=""
  while [ $# -gt 0 ]; do
    case "$1" in
      --domain) domena="${2:-}"; shift 2 ;;
      --domain=*) domena="${1#*=}"; shift ;;
      --port) port="${2:-}"; shift 2 ;;
      --port=*) port="${1#*=}"; shift ;;
      --no-firewall) firewall=0; shift ;;
      --uninstall) odinstalovat=1; shift ;;
      --no-systemd) systemd=0; shift ;;
      --prefix) prefix="${2%/}"; shift 2 ;;
      -h|--help) sed -n '2,10p' "$0" 2>/dev/null || true; exit 0 ;;
      *) chyba "neznámý přepínač $1" ;;
    esac
  done

  OPT="$prefix/opt/nokturno"
  BIN="$OPT/nokturno"
  DATA="$OPT/data"
  STAV="$OPT/install.conf"
  UNIT="$prefix/etc/systemd/system/nokturno.service"
  CADDY_DIR="$prefix/etc/caddy"
  CADDY_NOK="$CADDY_DIR/nokturno.caddy"
  ROOT=0; [ "$(id -u)" -eq 0 ] && ROOT=1
  [ "$ROOT" = 1 ] || [ -n "$prefix" ] || chyba "spusť skript přes sudo (… | sudo bash -s -- …)"
  [ "$ROOT" = 0 ] && systemd=0   # bez roota jen test v --prefix

  if [ "$odinstalovat" = 1 ]; then odinstaluj "$systemd"; return; fi

  # nastavení z minulé instalace, když ho přepínače nezmění
  if [ -f "$STAV" ]; then
    [ -n "$domena" ] || domena=$(sed -n 's/^domain=//p' "$STAV")
    [ -n "$port" ] || port=$(sed -n 's/^port=//p' "$STAV")
  fi
  port="${port:-7140}"
  case "$port" in ''|*[!0-9]*) chyba "port musí být číslo" ;; esac
  if [ "$port" -lt 1024 ] || [ "$port" -gt 65534 ]; then chyba "port musí být 1024 až 65534"; fi
  if [ -n "$domena" ] && ! printf '%s' "$domena" | grep -Eq '^([a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$'; then
    chyba "neplatná doména: $domena"
  fi
  command -v curl >/dev/null || chyba "chybí curl"

  stahni_aplikaci
  zaloz_uzivatele_a_slozky
  zapis_nastaveni "$domena" "$port"
  printf 'domain=%s\nport=%s\n' "$domena" "$port" > "$STAV"
  [ -n "$domena" ] && nastav_caddy "$domena" "$port"
  [ "$firewall" = 1 ] && [ "$ROOT" = 1 ] && [ -z "$prefix" ] && nastav_firewall "$domena" "$port"
  if [ "$systemd" = 1 ]; then spust_systemd "$domena" "$port"; else spust_na_pozadi "$domena" "$port"; fi
  over_beh "$port"
  shrnuti "$domena" "$port"
}

architektura() {
  local a
  a=$(dpkg --print-architecture 2>/dev/null || uname -m)   # dpkg: 32bit systém na 64bit jádře
  case "$a" in
    amd64|x86_64) echo amd64 ;;
    arm64|aarch64) echo arm64 ;;
    armhf|armel|armv7l|armv6l|arm) echo arm ;;
    i386|i686|386) echo 386 ;;
    *) chyba "architektura $a není podporovaná (jen amd64, arm64, arm, 386)" ;;
  esac
}

# Najde v JSON vydání soubor $1 a vypíše „verze adresa sha256“ (sha256 může chybět).
najdi_soubor() {
  tr ',{}' '\n' | sed 's/^[[:space:]]*//' | awk -v arch="$1" '
    /^"name": *"nokturno-[^"]*-linux-/ {
      n = $0; sub(/^"name": *"/, "", n); sub(/".*/, "", n)
      if (n ~ ("^nokturno-.*-linux-" arch "$")) { jmeno = n; dig = "" } else jmeno = ""
    }
    jmeno != "" && /^"digest": *"sha256:/ { dig = $0; sub(/^"digest": *"sha256:/, "", dig); sub(/".*/, "", dig) }
    jmeno != "" && /^"browser_download_url"/ {
      url = $0; sub(/^"browser_download_url": *"/, "", url); sub(/".*/, "", url)
      v = jmeno; sub(/^nokturno-/, "", v); sub(/-linux-.*/, "", v)
      print v, url, dig; exit
    }'
}

stahni_aplikaci() {
  local arch radek verze url sha tmp
  arch=$(architektura)
  radek=$(curl -fsSL "$API/latest" 2>/dev/null | najdi_soubor "$arch" || true)
  # poslední vydání může nést jen aktualizaci doplňku (zip) – pak první starší se souborem
  [ -n "$radek" ] || radek=$(curl -fsSL "$API?per_page=30" | najdi_soubor "$arch" || true)
  [ -n "$radek" ] || chyba "nenašel jsem soubor nokturno-*-linux-$arch ve vydáních $REPO"
  read -r verze url sha <<<"$radek"
  if [ -x "$BIN" ] && [ -f "$OPT/verze" ] && [ "$(cat "$OPT/verze")" = "$verze" ]; then
    info "Aplikace $verze je aktuální"
    return
  fi
  info "Stahuji Nokturno $verze ($arch)"
  mkdir -p "$OPT"
  tmp="$OPT/.nokturno.stahuje"
  curl -fL -# --retry 3 -o "$tmp" "$url" || { rm -f "$tmp"; chyba "stažení $url selhalo"; }
  if [ -n "$sha" ]; then
    echo "$sha  $tmp" | sha256sum -c --quiet - || { rm -f "$tmp"; chyba "otisk SHA-256 nesedí, soubor je poškozený"; }
  else
    varovani "vydání neuvádí otisk SHA-256, soubor neověřuji"
  fi
  chmod 0755 "$tmp"
  mv -f "$tmp" "$BIN"
  echo "$verze" > "$OPT/verze"
}

zaloz_uzivatele_a_slozky() {
  mkdir -p "$DATA"
  [ "$ROOT" = 1 ] || return 0
  if ! id nokturno >/dev/null 2>&1; then
    info "Zakládám systémového uživatele nokturno"
    useradd --system --home-dir "$DATA" --no-create-home --shell /usr/sbin/nologin nokturno
  fi
  chown -R nokturno:nokturno "$DATA"
  chmod 0750 "$DATA"
}

# host v nokturno.json (umí aplikace od 9.0.1; starší ho ignoruje a poslouchá na všech rozhraních)
zapis_nastaveni() {
  local host="0.0.0.0" soubor="$DATA/nokturno.json"
  [ -n "$1" ] && host="127.0.0.1"
  if [ ! -f "$soubor" ]; then
    cat > "$soubor" <<EOF
{
  "host": "$host",
  "port": $2,
  "https_port": $(($2 + 1)),
  "enable_https": true,
  "tmdb_key": "",
  "stats": true,
  "crash_reports": true,
  "update_url": ""
}
EOF
  elif grep -q '"host"' "$soubor"; then
    sed -i "s/\"host\": *\"[^\"]*\"/\"host\": \"$host\"/" "$soubor"
  elif grep -q '"' "$soubor"; then
    sed -i "0,/{/s//{\"host\": \"$host\", /" "$soubor"
  else
    echo "{\"host\": \"$host\"}" > "$soubor"
  fi
  if [ "$ROOT" = 1 ]; then chown nokturno:nokturno "$soubor"; fi
  chmod 0640 "$soubor"
}

# Příkaz aplikace. Port a HTTPS jdou přepínači, ty mají přednost před nokturno.json.
prikaz() {
  if [ -n "$1" ]; then
    echo "$BIN --data $DATA --port $2 --bez-https"
  else
    echo "$BIN --data $DATA --port $2 --https-port $(($2 + 1))"
  fi
}

nastav_caddy() {
  local domena="$1" port="$2" novy=0 caddyfile="$CADDY_DIR/Caddyfile"
  if [ "$ROOT" = 1 ] && [ -z "$prefix" ] && ! command -v caddy >/dev/null; then
    info "Instaluji Caddy z oficiálního repozitáře"
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq </dev/null
    apt-get install -y -qq ca-certificates curl gnupg </dev/null >/dev/null
    curl -fsSL https://dl.cloudsmith.io/public/caddy/stable/gpg.key \
      | gpg --dearmor --yes -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
    curl -fsSL https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt \
      > /etc/apt/sources.list.d/caddy-stable.list
    apt-get update -qq </dev/null
    apt-get install -y -qq caddy </dev/null >/dev/null
    novy=1
  fi
  mkdir -p "$CADDY_DIR"
  cat > "$CADDY_NOK" <<EOF
# Nokturno pro Stremio (install.sh). Při odinstalaci se smaže.
$domena {
	reverse_proxy 127.0.0.1:$port
}
EOF
  # výchozí Caddyfile balíčku (web na :80) nahradíme, cizí konfiguraci jen doplníme o import
  if [ -f "$caddyfile" ] && [ -z "$prefix" ] && [ "$(md5sum < "$caddyfile" | cut -d' ' -f1)" = \
      "$(dpkg-query -W -f='${Conffiles}\n' caddy 2>/dev/null | awk '$1 == "/etc/caddy/Caddyfile" {print $2}')" ]; then
    novy=1
  fi
  if [ "$novy" = 1 ] || [ ! -f "$caddyfile" ]; then
    echo "import $CADDY_NOK" > "$caddyfile"
  elif ! grep -qF "import $CADDY_NOK" "$caddyfile"; then
    printf '\nimport %s\n' "$CADDY_NOK" >> "$caddyfile"
  fi
  if command -v caddy >/dev/null; then
    caddy validate --adapter caddyfile --config "$caddyfile" >/dev/null 2>&1 \
      || { caddy validate --adapter caddyfile --config "$caddyfile" || true; chyba "Caddyfile $caddyfile neprošel kontrolou"; }
  fi
  if [ "$ROOT" = 1 ] && [ -z "$prefix" ] && command -v systemctl >/dev/null && [ -d /run/systemd/system ]; then
    systemctl enable --now caddy >/dev/null 2>&1 || true
    systemctl reload caddy 2>/dev/null || systemctl restart caddy
  fi
  over_dns "$domena"
}

over_dns() {
  local domena="$1" ip4 ip6 dns
  ip4=$(curl -4 -fsS --max-time 5 https://1.1.1.1/cdn-cgi/trace 2>/dev/null | sed -n 's/^ip=//p' || true)
  ip6=$(curl -6 -fsS --max-time 5 'https://[2606:4700:4700::1111]/cdn-cgi/trace' 2>/dev/null | sed -n 's/^ip=//p' || true)
  dns=$(getent ahosts "$domena" 2>/dev/null | awk '{print $1}' | sort -u || true)
  if [ -z "$dns" ]; then
    varovani "doména $domena nemá záznam A ani AAAA. Nastav ho na ${ip4:-${ip6:-veřejnou IP tohoto stroje}}, jinak Caddy nezíská certifikát."
  elif { [ -z "$ip4" ] || ! grep -qxF "$ip4" <<<"$dns"; } && { [ -z "$ip6" ] || ! grep -qxF "$ip6" <<<"$dns"; }; then
    varovani "doména $domena míří na $(echo "$dns" | tr '\n' ' ')a tento stroj má ${ip4:-?} ${ip6:-}. Oprav záznam A/AAAA (za proxy Cloudflare je to v pořádku)."
  fi
}

nastav_firewall() {
  local ssh
  command -v ufw >/dev/null || return 0
  info "Nastavuji firewall ufw"
  if [ -n "$1" ]; then
    ssh=$(echo "${SSH_CONNECTION:-}" | awk '{print $4}')
    ufw allow 22/tcp >/dev/null
    [ -n "$ssh" ] && [ "$ssh" != 22 ] && ufw allow "$ssh/tcp" >/dev/null
    ufw allow 80/tcp >/dev/null
    ufw allow 443/tcp >/dev/null
    ufw --force enable >/dev/null
  elif ufw status | grep -q '^Status: active'; then
    ufw allow "$2:$(($2 + 1))/tcp" >/dev/null   # domácí síť: jen když ufw už běží
  fi
}

spust_systemd() {
  if ! command -v systemctl >/dev/null || [ ! -d /run/systemd/system ]; then
    chyba "systemd neběží. Spusť aplikaci ručně: $(prikaz "$1" "$2")"
  fi
  cat > "$UNIT" <<EOF
[Unit]
Description=Nokturno pro Stremio
After=network-online.target
Wants=network-online.target

[Service]
User=nokturno
Group=nokturno
ExecStart=$(prikaz "$1" "$2")
Restart=always
RestartSec=5
NoNewPrivileges=yes
ProtectSystem=strict
ProtectHome=yes
ReadWritePaths=$DATA
PrivateTmp=yes
PrivateDevices=yes
ProtectKernelTunables=yes
ProtectKernelModules=yes
ProtectControlGroups=yes
RestrictSUIDSGID=yes
RestrictNamespaces=yes
LockPersonality=yes
RestrictAddressFamilies=AF_INET AF_INET6 AF_UNIX AF_NETLINK

[Install]
WantedBy=multi-user.target
EOF
  systemctl daemon-reload
  systemctl enable nokturno >/dev/null 2>&1
  systemctl restart nokturno
}

# Jen pro test bez systemd: aplikace na pozadí, výpis do $DATA/nokturno.log.
spust_na_pozadi() {
  local pid
  if [ -f "$OPT/nokturno.pid" ]; then
    pid=$(cat "$OPT/nokturno.pid")
    kill "$pid" 2>/dev/null && while kill -0 "$pid" 2>/dev/null; do sleep 1; done
  fi
  # shellcheck disable=SC2046  # příkaz se má rozdělit na slova
  if [ "$ROOT" = 1 ]; then
    nohup runuser -u nokturno -- $(prikaz "$1" "$2") > "$DATA/nokturno.log" 2>&1 &
  else
    nohup $(prikaz "$1" "$2") > "$DATA/nokturno.log" 2>&1 &
  fi
  echo $! > "$OPT/nokturno.pid"
}

over_beh() {
  local _
  info "Čekám, až aplikace naběhne"
  for _ in $(seq 1 60); do
    if curl -fsS --max-time 3 "http://127.0.0.1:$1/health" >/dev/null 2>&1; then return 0; fi
    sleep 2
  done
  varovani "aplikace do 2 minut neodpověděla. Výpis: journalctl -u nokturno -n 50"
}

mistni_ip() {
  ip -4 route get 192.0.2.1 2>/dev/null | sed -n 's/.* src \([0-9.]*\).*/\1/p' | head -n1
}

shrnuti() {
  local domena="$1" port="$2" ip adresa
  echo
  echo "Nokturno $(cat "$OPT/verze") je nainstalované."
  echo "  aplikace: $BIN"
  echo "  data a nastavení: $DATA (nokturno.json)"
  if [ -n "$domena" ]; then
    adresa="https://$domena/configure"
    if command -v ss >/dev/null && ss -ltnH "( sport = :$port )" 2>/dev/null | grep -qv '127.0.0.1'; then
      varovani "tato verze aplikace poslouchá na všech rozhraních, port $port zavři firewallem. Opraví to verze 9.0.1 (spusť skript znovu)."
    fi
  else
    ip=$(mistni_ip); ip="${ip:-<IP tohoto stroje>}"
    adresa="http://$ip:$port/configure"
  fi
  cat <<EOF

Přidání do Stremia a Nuvia:
  1. V prohlížeči otevři $adresa
  2. Vyplň vlastní úložiště a účty zdrojů, u každého dej Ověřit, potvrď podmínky.
  3. Klikni na Přidat do Stremia nebo Přidat do Nuvia (pro ruční vložení Zkopírovat adresu).
EOF
  if [ -z "$domena" ]; then
    echo "  Z jiného zařízení v síti dostane Stremio adresu https://…my.local-ip.co:$((port + 1)), port $((port + 1)) musí být otevřený."
  fi
  echo "Adresa doplňku obsahuje tvoje účty, nikomu ji neposílej."
  echo "Aktualizace: aplikace se aktualizuje sama, nový soubor stáhne opětovné spuštění tohoto skriptu."
}

odinstaluj() {
  local caddyfile="$CADDY_DIR/Caddyfile"
  info "Odinstalovávám Nokturno"
  if [ "$1" = 1 ] && command -v systemctl >/dev/null; then
    systemctl disable --now nokturno >/dev/null 2>&1 || true
  fi
  if [ -f "$OPT/nokturno.pid" ]; then kill "$(cat "$OPT/nokturno.pid")" 2>/dev/null || true; rm -f "$OPT/nokturno.pid"; fi
  rm -f "$UNIT"
  if [ "$1" = 1 ] && command -v systemctl >/dev/null; then systemctl daemon-reload; fi
  if [ -f "$CADDY_NOK" ]; then
    rm -f "$CADDY_NOK"
    if [ -f "$caddyfile" ]; then
      sed -i "\#^import $CADDY_NOK\$#d" "$caddyfile"
      grep -q '[^[:space:]]' "$caddyfile" || echo "# prázdná konfigurace (Nokturno odinstalováno)" > "$caddyfile"
    fi
    if [ "$1" = 1 ] && command -v systemctl >/dev/null; then systemctl reload caddy 2>/dev/null || true; fi
  fi
  rm -f "$BIN" "$OPT/verze" "$STAV" "$OPT/.nokturno.stahuje"
  echo "Hotovo. Data a nastavení zůstala v $DATA (smažeš je: rm -rf $DATA)."
  echo "Uživatel nokturno a Caddy zůstaly, odebereš je: userdel nokturno; apt-get remove caddy"
}

main "$@"
