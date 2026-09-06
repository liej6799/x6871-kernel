# x6871-kernel — Infinix GT 20 Pro (X6871)

Build environment, packaging scripts, and CI for a custom GKI kernel for the
Infinix GT 20 Pro (X6871, MediaTek MT6895 / Dimensity 8200 Ultimate).

## Device

| | |
|---|---|
| Device | Infinix GT 20 Pro (X6871) |
| SoC | MediaTek MT6895 (Dimensity 8200 Ultimate) |
| Kernel base | Linux 5.10 — GKI 2.0, `android12-5.10`, KMI generation 9 |
| Boot image | header v4, A/B slots, `Image.gz`, 64 MB boot partition |
| Stock vendor modules | `5.10.237-android12-9-g19bc7acc84fd` (vendor_dlkm — untouched by this kernel) |
| DTB / DTBO | stock `mt6895.dtb` + `dtbo.img` (rm69220 CSOT 144 Hz panel overlay) — never replaced |

## Release artifact (proven, boot-tested)

The [v1.0.1-komari-5.10.255 release](../../releases/tag/v1.0.1-komari-5.10.255)
ships the verified kernel — built on the **official osm0sis AnyKernel3**
installer (v1.0 shipped a broken fabricated bootstrap and is superseded):
identical copies are committed at `anykernel3/kernel-X6871-v1.0.1-komari-5.10.255.zip`
and `prebuilt/Image.gz`.

- **Kernel:** `5.10.255-v1llhaze!-komari SMP preempt mod_unload modversions aarch64`
- **Toolchain:** AOSP clang-r416183b (clang 12.0.5 + LLD 12.0.5) — the same prebuilt that produced the image
- **Image.gz sha256:** `785a5c1a114f6147e8126c9269fed4e665d329c97dbf4561143b21ed280b60b7`
- **Source lineage:** [vlxlxlv/android-kernel-common-5.10](https://github.com/vlxlxlv/android-kernel-common-5.10) (branch `v1llhaze-komari`), GPL-2.0
- **Config:** [`configs/x6871_defconfig`](configs/x6871_defconfig)

### Features (from the proven config)

- KernelSU (manual hooks)
- I/O schedulers: kyber + BFQ (mq-deadline default)
- zRAM default compressor: zstd
- TCP congestion: BBR default
- CPU frequency governor: schedutil (+ uclamp)
- Hardening: LTO-thin + CFI-clang + shadow call stack, KASLR, `CONFIG_MODVERSIONS`

## KMI compatibility with stock vendor modules

The device's stock vendor modules are built against `5.10.237-android12-9`, while
this kernel reports `5.10.255-v1llhaze!-komari`. They load anyway because:

1. `same_magic()` (kernel/module.c) skips the version prefix when the module
   carries symbol CRCs (`CONFIG_MODVERSIONS=y`) — only the common
   ` SMP preempt mod_unload modversions aarch64` suffix is compared.
2. `check_version()` is warn-only on symbol-CRC disagreement (emits a
   `pr_warn` and returns success), so CRC drift never blocks a module load.

Full verification evidence: [PROVENANCE.md](PROVENANCE.md).

## Install

1. Boot into TWRP / OrangeFox custom recovery.
2. Flash `kernel-X6871-v1.0.1-komari-5.10.255.zip`.
3. Reboot.

**Kernel-only flash:** the installer writes `Image.gz` to the boot partitions
only (A/B slot-aware). DTB, DTBO, vendor_boot and vendor_dlkm are untouched —
revert any time by reflashing the stock boot image.

## Build from source

```bash
./scripts/build-kernel.sh   # clones pinned komari source, builds Image.gz
./scripts/build-zips.sh      # packages the AnyKernel3 flashable zip
```

Requirements: Linux host, `git`, `zip`, `libssl-dev`, `libelf-dev`, `gcc-aarch64-linux-gnu`.
The toolchain (clang-r416183b) is fetched automatically by `scripts/setup-toolchain.sh`.

> **Version note:** the pinned komari commit builds **5.10.260** — newer than
> the proven 5.10.255 release. CI output is therefore **experimental**
> (it still loads stock modules thanks to the warn-only CRC policy, but the
> boot-tested artifact is the 5.10.255 release). [PROVENANCE.md](PROVENANCE.md)
> documents why the 5.10.260 rebuild was discarded as the release base.

## CI

GitHub Actions (`.github/workflows/build.yml`) builds `Image.gz` from the
pinned source on every push to `main` and uploads the AnyKernel3 zip as an
artifact.

## Release convention

Every release ships with a changelog and a "what's fixed" section — see
[RELEASE-NOTES.md](RELEASE-NOTES.md). Releases are mirrored to the Telegram
release group (Helios-Kernel Tester | X6871).

## Repository layout

```
├── configs/x6871_defconfig       proven kernel config
├── scripts/                      toolchain setup / build / packaging
├── anykernel3/                   official AnyKernel3 installer tree + built zip
├── prebuilt/Image.gz             loose copy of the proven kernel
├── docs/                         build + provenance logs
└── .github/workflows/build.yml   CI
```

## Credits

- Kernel source: [vlxlxlv](https://github.com/vlxlxlv/android-kernel-common-5.10) (v1llhaze-komari)
- AnyKernel3: [osm0sis](https://github.com/osm0sis/AnyKernel3)
