#!/data/data/com.termux/files/usr/bin/bash
# STAR Plus — Fast Installer (แก้ค้างตอนอัปเดต)
# Repo: Markx755/Starplustool

set -e

REPO="Markx755/Starplustool"
ASSET_NAME="star_plus.zip"
MAIN_FILE="star_plus.py"
LATEST_API="https://api.github.com/repos/$REPO/releases/latest"
DIR="$HOME/star-tool"

echo "════════════════════════════════════════"
echo "  ⭐ STAR Plus · Auto Rejoin · Installer"
echo "════════════════════════════════════════"

# ── Animated installer ──────────────────────────────────────────────────────
spin() {
    local pid="$1"
    local msg="$2"
    local frames='|/-\'
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r  [%s] %s" "${frames:i++%4:1}" "$msg"
        sleep 0.08
    done
    printf "\r  [✓] %s\n" "$msg"
}

step() {
    printf "\n  \033[1m[%s/5]\033[0m %s\n" "$1" "$2"
}

step 1 "ตรวจสอบแพ็กเกจ..."
(pkg update -y --quiet 2>/dev/null || true) &
PID=$!
spin "$PID" "ตรวจสอบแพ็กเกจ..."
wait "$PID" 2>/dev/null || true

step 2 "ติดตั้งเครื่องมือ..."
(pkg install -y python python-pip curl jq unzip --quiet 2>/dev/null) &
PID=$!
spin "$PID" "ติดตั้งเครื่องมือ..."
wait "$PID"

step 3 "ติดตั้งไลบรารี..."
(pip install requests --quiet) &
PID=$!
spin "$PID" "ติดตั้งไลบรารี..."
wait "$PID"

step 4 "ดาวน์โหลด STAR Plus..."
DOWNLOAD_URL=$(curl -sL "$LATEST_API" | jq -r --arg name "$ASSET_NAME" \
    '.assets[] | select(.name==$name) | .browser_download_url')

if [ -z "$DOWNLOAD_URL" ] || [ "$DOWNLOAD_URL" = "null" ]; then
    echo "  ❌ ไม่พบไฟล์ $ASSET_NAME ใน GitHub Release ล่าสุด"
    exit 1
fi

mkdir -p "$DIR"
cd "$DIR"
curl -fL --progress-bar "$DOWNLOAD_URL" -o "$ASSET_NAME"

step 5 "ติดตั้ง STAR Plus..."
unzip -o "$ASSET_NAME" >/dev/null
rm -f "$ASSET_NAME"
chmod +x "$MAIN_FILE" 2>/dev/null || true

echo ""
echo "  ╔══════════════════════════════════════╗"
echo "  ║      ✨ INSTALLATION COMPLETE ✨     ║"
echo "  ╚══════════════════════════════════════╝"
echo ""
echo "  📁 ติดตั้งที่: $DIR"
echo "  🔑 ONLINE KEY"
echo ""
echo "  cd ~/star-tool && python star_plus.py"
echo ""
