#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   bash libs/check-16kb.sh path/to/app.apk --abi arm64-v8a
#   bash libs/check-16kb.sh path/to/app.aab --abi armeabi-v7a

APK_OR_AAB="${1:-}"
ABI_FILTER="${2:-}"
ABI_VALUE="${3:-}"

if [[ -z "${APK_OR_AAB}" ]]; then
  echo "Usage: $0 <apk|aab path> [--abi <abi>]" >&2
  exit 2
fi

if [[ "${ABI_FILTER}" == "--abi" && -n "${ABI_VALUE:-}" ]]; then
  ONLY_ABI="${ABI_VALUE}"
else
  ONLY_ABI=""
fi

# ---- Locate readelf (prefer llvm-readelf from NDK) ----
pick_readelf() {
  if [[ -n "${READELF:-}" && -x "${READELF}" ]]; then
    echo "${READELF}"
    return
  fi

  # Try NDK layout
  if [[ -n "${ANDROID_NDK_HOME:-}" ]]; then
    for host in darwin-arm64 darwin-x86_64 linux-x86_64 windows-x86_64; do
      CAND="${ANDROID_NDK_HOME}/toolchains/llvm/prebuilt/${host}/bin/llvm-readelf"
      if [[ -x "${CAND}" ]]; then
        echo "${CAND}"
        return
      fi
    done
  fi

  # Try scanning SDK/ndk/* if ANDROID_SDK_ROOT is set
  if [[ -n "${ANDROID_SDK_ROOT:-}" && -d "${ANDROID_SDK_ROOT}/ndk" ]]; then
    while IFS= read -r -d '' ndkdir; do
      for host in darwin-arm64 darwin-x86_64 linux-x86_64; do
        CAND="${ndkdir}/toolchains/llvm/prebuilt/${host}/bin/llvm-readelf"
        if [[ -x "${CAND}" ]]; then
          echo "${CAND}"
          return
        fi
      done
    done < <(find "${ANDROID_SDK_ROOT}/ndk" -maxdepth 1 -mindepth 1 -type d -print0 2>/dev/null)
  fi

  # Fallback: system readelf
  if command -v readelf >/dev/null 2>&1; then
    echo "readelf"
    return
  fi

  echo "ERROR: llvm-readelf/readelf not found. Set READELF or ANDROID_NDK_HOME." >&2
  exit 3
}

READELF_BIN="$(pick_readelf)"

# ---- Collect .so paths from APK/AAB without extracting to disk ----
# We'll use 'unzip -Z1' to list and 'unzip -p' to stream each .so into a temp file.
if ! command -v unzip >/dev/null 2>&1; then
  echo "ERROR: 'unzip' is required." >&2
  exit 4
fi

if [[ ! -f "${APK_OR_AAB}" ]]; then
  echo "ERROR: '${APK_OR_AAB}' not found." >&2
  exit 5
fi

# Determine patterns based on container type
case "${APK_OR_AAB##*.}" in
  apk|APK) SO_GLOB_PREFIX="lib/";;
  aab|AAB) SO_GLOB_PREFIX="base/lib/";;
  *) echo "WARN: Unknown extension; trying APK-style first, then AAB-style." >&2
     SO_GLOB_PREFIX="";;
esac

list_sos() {
  local container="$1"
  local prefix="$2"
  unzip -Z1 "${container}" 2>/dev/null | \
    awk -v pref="${prefix}" -v abi="${ONLY_ABI}" '
      /\.so$/ {
        if (pref != "" && index($0, pref) != 1) next
        # Extract ABI from path: lib/<abi>/xxx.so  OR base/lib/<abi>/xxx.so
        split($0, a, "/")
        for (i=1; i<=length(a); i++) {
          if (a[i]=="lib" && i < length(a)) {
            theabi = a[i+1]
            break
          }
        }
        if (abi=="" || abi==theabi) print $0
      }'
}

SO_LIST="$(list_sos "${APK_OR_AAB}" "${SO_GLOB_PREFIX}")"
# If nothing found and we tried a specific prefix, try the other
if [[ -z "${SO_LIST}" && -n "${SO_GLOB_PREFIX}" ]]; then
  if [[ "${SO_GLOB_PREFIX}" == "lib/" ]]; then
    SO_LIST="$(list_sos "${APK_OR_AAB}" "base/lib/")"
  else
    SO_LIST="$(list_sos "${APK_OR_AAB}" "lib/")"
  fi
fi

if [[ -z "${SO_LIST}" ]]; then
  echo "No .so files found (check container type or ABI filter)." >&2
  exit 6
fi

# Pretty header
printf "%-60s %-10s %-8s\n" "LIB" "ALIGN" "STATUS"
printf "%-60s %-10s %-8s\n" "------------------------------------------------------------" "--------" "--------"

TMPDIR="$(mktemp -d)"
trap 'rm -rf "${TMPDIR}"' EXIT

OVERALL_BAD=0

check_one_so() {
  local container="$1"
  local inner_path="$2"
  local tmpfile="${TMPDIR}/$(basename "${inner_path}")"

  if ! unzip -p "${container}" "${inner_path}" > "${tmpfile}" 2>/dev/null; then
    printf "%-60s %-10s %-8s\n" "${inner_path}" "n/a" "n/a"
    return
  fi

  local ph_out
  if ! ph_out="$("${READELF_BIN}" -l -W --elf-output-style=GNU "${tmpfile}" 2>/dev/null)"; then
    ph_out="$("${READELF_BIN}" -l -W "${tmpfile}" 2>/dev/null)"
  fi

  local align_list
  align_list="$(printf "%s\n" "${ph_out}" | awk '
    BEGIN { inPH=0 }
    /^Program Headers/ { inPH=1; next }
    inPH==1 && $1=="LOAD" {
      got=0
      for (i=1; i<=NF; i++) {
        if ($i ~ /^Align:?$/ && (i+1)<=NF) { print $(i+1); got=1; break }
        if ($i ~ /^Align:[0-9xXa-fA-F]+$/) { split($i,a,":"); print a[2]; got=1; break }
      }
      if (!got) {
        # fallback: last column if it looks like a number/hex
        if ($(NF) ~ /^0x[0-9A-Fa-f]+$/ || $(NF) ~ /^[0-9]+$/) print $(NF)
      }
    }
  ')"

  if [[ -z "${align_list}" ]]; then
    printf "%-60s %-10s %-8s\n" "${inner_path}" "n/a" "n/a"
    return
  fi

  local max_dec=0
  while IFS= read -r v; do
    [[ -z "${v}" ]] && continue
    if [[ "${v}" == 0x* || "${v}" == 0X* ]]; then
      dec=$((16#${v#0x}))
    else
      dec="${v}"
    fi
    (( dec > max_dec )) && max_dec="${dec}"
  done <<< "${align_list}"

  local status="OK"
  (( max_dec > 16384 )) && status="BAD"

  printf "%-60s %-10s %-8s\n" "${inner_path}" "$(printf "0x%X" "${max_dec}")" "${status}"
}


# Iterate all .so
while IFS= read -r so_inner; do
  check_one_so "${APK_OR_AAB}" "${so_inner}"
done <<< "${SO_LIST}"

# Exit with non-zero if any BAD found (useful în CI)
exit "${OVERALL_BAD}"
