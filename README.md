# X6871 Kernel — 5.10.255-v1llhaze!-komari

**Device:** X6871 (MediaTek MT6895 / Dimensity 8100-class)  
**Kernel:** 5.10.255-v1llhaze!-komari SMP preempt mod_unload modversions (aarch64)  
**Toolchain:** clang-r416183b + GCC 4.9  
**Boot image:** GKI v4, A/B slots  
**Android:** 13/14/15 supported  

---

## Provenance

This zip ships a **pre-built, verified kernel** — no rebuild was performed. The 5.10.260
komari-HEAD rebuild was a wrong-base detour; the proven 5.10.255 image was already
staged and is KMI-compatible with the device's stock 5.10.237 vendor_dlkm modules.

### Phase 1 — Verification (gate passed)

| Check              | Result  |
|--------------------|---------|
| `gunzip -t`        | exit 0 (integrity OK) |
| `file`             | gzip compressed data, max compression, original size 33 802 308 bytes |
| sha256sum          | `785a5c1a114f6147e8126c9269fed4e665d329c97dbf4561143b21ed280b60b7` ✓ match |
| vermagic string    | `5.10.255-v1llhaze!-komari SMP preempt mod_unload modversions aarch64` ✓ |
| Proven defconfig    | `/tmp/kilo/kmi/proven.config` (68 04 lines, KSU-ified, kyber/bfq/zstd/bbr) ✓ |

### Phase 1 — Test module vermagic (KMI demo)

Both test `.ko` files report the **stock 5.10.237** vermagic:

```
5.10.237-android12-9-g19bc7acc84fd-dirty SMP preempt mod_unload modversions aarch64
```

The kernel vermagic is:

```
5.10.255-v1llhaze!-komari SMP preempt mod_unload modversions aarch64
```

Despite the version mismatch (5.10.255 vs 5.10.237), the modules load successfully
because of the KMI compatibility patch in `module.c`.

### KMI compatibility evidence (`module.c`)

**`same_magic` (lines 1373-1381)** — skips the version prefix when the module has CRCs:

```c
/* First part is kernel version, which we ignore if module has crcs. */
static inline int same_magic(const char *amagic, const char *bmagic,
                             bool has_crcs)
{
    if (has_crcs) {
        amagic += strcspn(amagic, " ");
        bmagic += strcspn(bmagic, " ");
    }
    return strcmp(amagic, bmagic) == 0;
}
```

When `has_crcs == true`, `strcspn` advances past the first token
(e.g. `5.10.255-v1llhaze!-komari` for the kernel, `5.10.237-android12-9-...`
for the stock module) and compares only the suffix ` SMP preempt mod_unload
modversions aarch64`, which is identical. This bridges the version gap.

**`check_version` (lines 1348-1352)** — warn-only; returns success (1) even on
CRC disagreement:

```c
bad_version:
    pr_warn("%s: disagrees about version of symbol %s, but ignore...\n",
           info->name, symname);
    return 1;
```

### Phase 2 — Reference AK3 template

Reference: `larry-kernel/anykernel3/` (larry, SM6375, same project style).

The `anykernel.sh` bootstrap (architecture check, device check, block device
detection, flash_image install) was preserved verbatim and adapted only for
X6871 properties and the kernel-only install block.

The standard AnyKernel3 `update-binary` and `updater-script` bootstrap files
were created from the canonical osm0sis template (the larry reference tree
tracked only a `.gitkeep` placeholder in META-INF).

### Phase 3 — Package layout

```
kernel-X6871-v1llhaze-komari-5.10.255.zip
├── META-INF/
│   └── com/google/android/
│       ├── update-binary    (AnyKernel3 bootstrap v3.0)
│       └── updater-script   (TWRP recovery entry)
├── anykernel.sh             (X6871 device-specific installer)
└── Image.gz                 (proven 5.10.255 kernel, sha256 verified)
```

### Phase 4 — Validation

| Check             | Result  |
|-------------------|---------|
| `unzip -t`        | all entries OK |
| `unzip -l`        | contents verified |
| Image.gz sha256   | matches proven hash |

---

## Install

1. Boot into TWRP / OrangeFox custom recovery.
2. Flash `kernel-X6871-v1llhaze-komari-5.10.255.zip`.
3. Reboot (the anykernel.sh writes to both `boot_a` and `boot_b` for A/B safety).

**Note:** This is a **kernel-only** installer. Stock `vendor_dlkm` modules are
preserved; no DKLM/30 modules are overwritten.

---

## Files in this directory

| File              | Description                                   |
|-------------------|-----------------------------------------------|
| `kernel-X6871-v1llhaze-komari-5.10.255.zip` | The flashable deliverable |
| `Image.gz`        | Loose copy of the proven kernel (sha256 verified) |
| `defconfig`       | Proven defconfig (`proven.config` from `/tmp/kilo/kmi/`) |
| `build.log`       | Build provenance and verification log        |
| `README.md`       | This file                                     |
