#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

GODOT_VERSION="${GODOT_VERSION:-4.7.2}"
GODOT_TAG="${GODOT_VERSION}-stable"
GODOT_RELEASE_BASE="https://github.com/godotengine/godot/releases/download/${GODOT_TAG}"

CACHE_ROOT="${XDG_CACHE_HOME:-$HOME/.cache}/a-ordem-godot/${GODOT_VERSION}"
EDITOR_ZIP="${CACHE_ROOT}/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip"
EDITOR_BIN="${CACHE_ROOT}/Godot_v${GODOT_VERSION}-stable_linux.x86_64"
TEMPLATES_TPZ="${CACHE_ROOT}/Godot_v${GODOT_VERSION}-stable_export_templates.tpz"

TEMPLATE_DIR="$HOME/.local/share/godot/export_templates/${GODOT_VERSION}.stable"
WEB_TEMPLATE="${TEMPLATE_DIR}/web_nothreads_release.zip"

PUBLISH_DIR="$ROOT_DIR/build/web"
EXPORT_HTML="${PUBLISH_DIR}/index.html"
IMPORT_LOG="$ROOT_DIR/build/godot-import.log"

echo "== A Ordem dos Cavaleiros / Render Web Build =="
echo "Godot: ${GODOT_VERSION}"
echo "Cache: ${CACHE_ROOT}"

for command in curl unzip; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "ERROR: required command '$command' is not available on the Render build image." >&2
    exit 1
  fi
done

mkdir -p "$CACHE_ROOT" "$TEMPLATE_DIR" "$ROOT_DIR/build"

if [[ ! -x "$EDITOR_BIN" ]]; then
  echo "Downloading Godot editor..."
  if [[ ! -f "$EDITOR_ZIP" ]]; then
    curl --fail --location --retry 3 --retry-delay 2       "${GODOT_RELEASE_BASE}/Godot_v${GODOT_VERSION}-stable_linux.x86_64.zip"       --output "$EDITOR_ZIP"
  fi

  unzip -o -q "$EDITOR_ZIP" -d "$CACHE_ROOT"
  chmod +x "$EDITOR_BIN"
else
  echo "Using cached Godot editor."
fi

if [[ ! -f "$WEB_TEMPLATE" ]]; then
  echo "Installing Web export template..."
  if [[ ! -f "$TEMPLATES_TPZ" ]]; then
    echo "First Render build downloads the official Godot export template package."
    echo "Later builds reuse Render's persistent XDG build cache."
    curl --fail --location --retry 3 --retry-delay 2       "${GODOT_RELEASE_BASE}/Godot_v${GODOT_VERSION}-stable_export_templates.tpz"       --output "$TEMPLATES_TPZ"
  fi

  rm -rf "$TEMPLATE_DIR"
  mkdir -p "$TEMPLATE_DIR"

  unzip -jo -q "$TEMPLATES_TPZ"     "templates/web_nothreads_release.zip"     "templates/web_nothreads_debug.zip"     "templates/version.txt"     -d "$TEMPLATE_DIR"
else
  echo "Using cached Web export template."
fi

echo "Godot binary version:"
"$EDITOR_BIN" --version

echo "Importing project resources and validating GDScript..."
rm -f "$IMPORT_LOG"
set +e
"$EDITOR_BIN" --headless --path "$ROOT_DIR" --import >"$IMPORT_LOG" 2>&1
IMPORT_STATUS=$?
set -e
cat "$IMPORT_LOG"

if [[ $IMPORT_STATUS -ne 0 ]] || grep -Eq 'SCRIPT ERROR:|Parse Error:|ERROR: Failed to load script' "$IMPORT_LOG"; then
  echo "ERROR: Godot project validation failed. Fix the script errors above before exporting." >&2
  exit 1
fi

echo "Exporting single-threaded Web build..."
rm -rf "$PUBLISH_DIR"
mkdir -p "$PUBLISH_DIR"

"$EDITOR_BIN" --headless --path "$ROOT_DIR"   --export-release "Web" "$EXPORT_HTML"

if [[ ! -f "$PUBLISH_DIR/index.html" ]]; then
  echo "ERROR: Godot export completed but build/web/index.html was not produced." >&2
  find "$PUBLISH_DIR" -maxdepth 2 -type f -print || true
  exit 1
fi

echo "Render publish directory ready:"
du -sh "$PUBLISH_DIR" || true
find "$PUBLISH_DIR" -maxdepth 1 -type f -printf '  %f\n' | sort
