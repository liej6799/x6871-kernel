#!/bin/bash
# Toolchain setup for the X6871 (MT6895) GKI kernel build.
# clang-r416183b — the exact toolchain that built the proven 5.10.255 image.
set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TC="${PROJECT_ROOT}/toolchain"

if [ ! -x "${TC}/clang-r416183b/bin/clang" ]; then
  echo "[*] Downloading clang-r416183b (LineageOS mirror of the AOSP prebuilt)..."
  mkdir -p "${TC}"
  git clone --depth=1 -b lineage-20.0 \
    https://github.com/LineageOS/android_prebuilts_clang_kernel_linux-x86_clang-r416183b \
    "${TC}/clang-r416183b"
fi

export PATH="${TC}/clang-r416183b/bin:${PATH}"
export LLVM=1
export LLVM_IAS=1
export CROSS_COMPILE=aarch64-linux-gnu-
export CC=clang

# Host-tool OpenSSL 3.x compatibility (kernel 5.10 host tools include
# openssl/engine.h, which was removed in OpenSSL 3.0).
if [ ! -f "${TC}/stubs/openssl/engine.h" ]; then
  mkdir -p "${TC}/stubs/openssl"
  cat > "${TC}/stubs/openssl/engine.h" <<'STUB'
/* OpenSSL 3.x compatibility stub: engine.h was removed upstream.
 * Minimal placeholder so kernel 5.10 host tools (extract-cert etc.)
 * compile on modern hosts. */
#ifndef OPENSSL_STUB_ENGINE_H
#define OPENSSL_STUB_ENGINE_H
#endif
STUB
fi
export HOSTCFLAGS="-I${TC}/stubs"

echo "[+] Toolchain ready:"
clang --version | head -1
