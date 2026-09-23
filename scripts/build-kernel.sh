#!/bin/bash
# Build the X6871 (MT6895) GKI kernel Image.gz from the v1llhaze-komari source.
#
# NOTE ON VERSIONS: the pinned komari commit is 5.10.260. The *proven,
# boot-tested* release artifact is 5.10.255 (see PROVENANCE.md and the
# v1.0-komari-5.10.255 GitHub release). Builds from this script are
# therefore EXPERIMENTAL until boot-tested.
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
KERNEL_SRC="${PROJECT_ROOT}/kernel"
KOMARI_COMMIT="15020c5332c18af361b42c415f07cd3046723027"

source "${SCRIPT_DIR}/setup-toolchain.sh"

if [ ! -d "${KERNEL_SRC}/.git" ]; then
  echo "[*] Cloning v1llhaze-komari source..."
  git clone https://github.com/vlxlxlv/android-kernel-common-5.10 "${KERNEL_SRC}"
fi
git -C "${KERNEL_SRC}" checkout "${KOMARI_COMMIT}"

echo "[*] Applying Droidspaces GKI kABI patches (SYSVIPC + POSIX_MQUEUE)..."
patch -d "${KERNEL_SRC}" -p1 --forward < "${PROJECT_ROOT}/patches/droidspaces/001-sysvipc-kabi.patch"
patch -d "${KERNEL_SRC}" -p1 --forward < "${PROJECT_ROOT}/patches/droidspaces/002-posix-mqueue-kabi.patch"

export ARCH=arm64
OUT_DIR="${KERNEL_SRC}/out"
mkdir -p "${OUT_DIR}"

if [ ! -f "${OUT_DIR}/.config" ]; then
  echo "[*] Seeding proven defconfig..."
  cp "${PROJECT_ROOT}/configs/x6871_defconfig" "${OUT_DIR}/.config"
  # GKI whitelist file is not present in this tree; harmless for Image-only builds.
  "${KERNEL_SRC}/scripts/config" --file "${OUT_DIR}/.config" --disable TRIM_UNUSED_KSYMS
fi

echo "[*] olddefconfig..."
make -C "${KERNEL_SRC}" O="${OUT_DIR}" ARCH=arm64 LLVM=1 LLVM_IAS=1 olddefconfig

echo "[*] Building Image.gz (LTO-thin + CFI; this takes a while)..."
make -C "${KERNEL_SRC}" O="${OUT_DIR}" ARCH=arm64 LLVM=1 LLVM_IAS=1 \
  CROSS_COMPILE=aarch64-linux-gnu- CC=clang HOSTCFLAGS="-I${PROJECT_ROOT}/toolchain/stubs" \
  -j"$(nproc)" Image.gz 2>&1 | tee "${PROJECT_ROOT}/build.log"

KVER="$(make -s -C "${KERNEL_SRC}" O="${OUT_DIR}" ARCH=arm64 kernelversion)"
sha256sum "${OUT_DIR}/arch/arm64/boot/Image.gz"
echo "[+] Done: ${OUT_DIR}/arch/arm64/boot/Image.gz (kernel ${KVER}-v1llhaze!-komari)"
