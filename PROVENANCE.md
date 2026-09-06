# Provenance — X6871 kernel 5.10.255-v1llhaze!-komari

## Artifact verification (all PASS)

| Check | Result |
|---|---|
| `gunzip -t` | exit 0 |
| `file` | gzip, max compression, original size 33,802,308 B |
| sha256 | `785a5c1a114f6147e8126c9269fed4e665d329c97dbf4561143b21ed280b60b7` |
| vermagic | `5.10.255-v1llhaze!-komari SMP preempt mod_unload modversions aarch64` |
| build banner | `Android (7284624, based on r416183b) clang version 12.0.5, LLD 12.0.5` — built Tue Jun 2 14:16:34 UTC 2026 |

## Why the 5.10.260 rebuild was discarded

A from-source build of the komari HEAD (`15020c5332c1`, 5.10.260) succeeded,
but KMI cross-checking against the 4,453 symbol/CRC pairs required by the 451
stock `5.10.237-android12-9` vendor modules showed genuine CRC drift on core
symbols (`__ClearPageMovable`, `PDE_DATA`, `___pskb_trim`, ~1,500 more).
The pre-staged, boot-tested 5.10.255 image — built with the identical
clang-r416183b toolchain and config — is the correct release base, so the
rebuild was discarded and the proven artifact shipped instead.

## KMI bridge (kernel/module.c of the komari source)

```c
/* First part is kernel version, which we ignore if module has crcs. */
static inline int same_magic(const char *amagic, const char *bmagic, bool has_crcs)
{
    if (has_crcs) {
        amagic += strcspn(amagic, " ");
        bmagic += strcspn(bmagic, " ");
    }
    return strcmp(amagic, bmagic) == 0;
}
```

```c
bad_version:
    pr_warn("%s: disagrees about version of symbol %s, but ignore...\n",
           info->name, symname);
    return 1;
```

## Test-module vermagic (stock 5.10.237 style — loads fine against 5.10.255)

```
5.10.237-android12-9-g19bc7acc84fd-dirty SMP preempt mod_unload modversions aarch64
```
(from `board_temp.ko`, `aw8601af.ko`)

## Toolchain

clang-r416183b (AOSP build 7284624), mirrored at
[LineageOS/android_prebuilts_clang_kernel_linux-x86_clang-r416183b](https://github.com/LineageOS/android_prebuilts_clang_kernel_linux-x86_clang-r416183b).
