# Release Notes — x6871-kernel (Helios Kernel)

**Convention:** every release ships with a changelog and a "what's fixed"
section. Releases are mirrored to the Telegram release group
(Helios-Kernel Tester | X6871) with the same format.

## v1.0.1-komari-5.10.255 (current)

**Device:** Infinix GT 20 Pro (X6871) • MT6895 (Dimensity 8200 Ultimate)
**Base:** 5.10.255-v1llhaze!-komari (GKI 2.0 / android12-5.10 / KMI gen 9) — UNCHANGED from v1.0
**Toolchain:** AOSP clang-r416183b (clang + LLD 12.0.5)
**ZIP sha256:** `d5c9fdcba2e2fa7117028cd32d5b6845ec7edcbd1ffbb1497411a0f8e78ec978`
**Image.gz sha256:** `785a5c1a114f6147e8126c9269fed4e665d329c97dbf4561143b21ed280b60b7`

### What's fixed (vs v1.0)

- **Installer rebuilt on the official osm0sis AnyKernel3 (master 020dfec)** —
  the v1.0 zip shipped a hand-made META-INF bootstrap, so recoveries died
  with `Updater process ended with ERROR: 1` before any installer output
- Real AK3 `update-binary` + bundled `tools/` (ak3-core.sh + binaries) —
  previously missing entirely
- Device whitelist fixed for X6871 (`X6871`, `Infinix-X6871`, `Infinix_X6871`,
  `infinix_X6871`, `X6871-OP`, one per `device.nameN` line) — the old
  comma-list format could never match `ro.product.device`
- Explicit `BLOCK=boot` + A/B slot auto-detection (safe for this Virtual A/B,
  Android-12-launched device that has no separate init_boot partition)
- Kernel unchanged: same proven, boot-tested Image.gz (hash above)

### Changelog (carried over from v1.0 — same kernel)

- KernelSU integration (manual hooks) — root out of the box
- I/O schedulers added: BFQ + Kyber (mq-deadline stays default)
- zRAM: zstd default compressor
- Network: TCP BBR default congestion control
- CPU: schedutil governor + uclamp
- Hardened build: LTO-thin + CFI-Clang + Shadow Call Stack + KASLR
- Kernel-only installer: stock 5.10.237 vendor modules load via
  `same_magic()` prefix-skip + warn-only `check_version()` (never blocks)

## v1.0-komari-5.10.255 (BROKEN INSTALLER — superseded)

Kernel binary identical to v1.0.1, but the AnyKernel3 bootstrap was fabricated:
placeholder `update-binary`/`updater-script`, missing `tools/`, and a device
whitelist format that could never match. Result: `ERROR: 1` in OrangeFox before
any output. Do not use — flash v1.0.1.

## Template for future releases

```
## vX.Y-<base>

**Base:** <kernel version + localversion>
**ZIP sha256:** <hash>

### Changelog
- <feature/change>

### What's fixed
- <fix>

### Notes
- <caveats / testing status>
```
