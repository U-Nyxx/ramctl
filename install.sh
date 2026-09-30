#!/data/data/com.termux/files/usr/bin/bash

set -e

PREFIX_DIR="${PREFIX:-/data/data/com.termux/files/usr}"

echo "[1/3] Menyiapkan direktori sistem..."
mkdir -p "${PREFIX_DIR}/bin"
mkdir -p "${PREFIX_DIR}/lib/ramctl"

echo "[2/3] Memasang komponen RAMCTL..."
cp bin/ram "${PREFIX_DIR}/bin/ram"
cp lib/ramctl/*.sh "${PREFIX_DIR}/lib/ramctl/"

echo "[3/3] Memasang hak akses..."
chmod 755 "${PREFIX_DIR}/bin/ram"
chmod 644 "${PREFIX_DIR}/lib/ramctl/"*.sh

echo ""
echo -e "\033[32m✓ RAMCTL berhasil terpasang di sistem!\033[0m"
echo "Jalankan perintah:"
echo "  ram status"
echo "  ram monitor"

