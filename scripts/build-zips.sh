#!/bin/bash
# Package the built Image.gz into an AnyKernel3 flashable zip (kernel-only flash).
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
KERNEL_SRC="${PROJECT_ROOT}/kernel"
OUT_DIR="${KERNEL_SRC}/out"
AK3_DIR="${PROJECT_ROOT}/anykernel3"

if [ ! -f "${OUT_DIR}/arch/arm64/boot/Image.gz" ]; then
  echo "[!] Image.gz not found at ${OUT_DIR}/arch/arm64/boot/Image.gz — run scripts/build-kernel.sh first."
  exit 1
fi

KVER="$(make -s -C "${KERNEL_SRC}" O="${OUT_DIR}" ARCH=arm64 kernelversion)"
ZIP_NAME="x6871-kernel-${KVER}-komari.zip"
STAGING="${AK3_DIR}/staging"

echo "[*] Staging AnyKernel3 (kernel-only: Image.gz, no modules, no DTB)..."
rm -rf "${STAGING}"
mkdir -p "${STAGING}"
cp "${OUT_DIR}/arch/arm64/boot/Image.gz" "${STAGING}/"
cp "${AK3_DIR}/anykernel.sh" "${STAGING}/"
cp -r "${AK3_DIR}/META-INF" "${STAGING}/"

echo "[*] Creating ${ZIP_NAME}..."
( cd "${STAGING}" && zip -r9y "${AK3_DIR}/${ZIP_NAME}" . -x "*.git*" )
rm -rf "${STAGING}"

sha256sum "${AK3_DIR}/${ZIP_NAME}"
echo "[+] Flashable zip: ${AK3_DIR}/${ZIP_NAME}"
echo "    Flash via TWRP/OrangeFox (kernel-only: boot_a/boot_b)."
