#!/bin/bash
cd "$(dirname "$0")/.."
SRC="$PWD"
WORK="$SRC/build/.webproj"
mkdir -p "$WORK" build/web
rsync -a --delete --exclude .git --exclude build --exclude shots --exclude .shots "$SRC/" "$WORK/"
find "$WORK/Assets/Sprite" -name "*.png" -size +150k | while read -r f; do
	sed -i 's/^compress\/mode=0$/compress\/mode=1/; s/^compress\/lossy_quality=.*/compress\/lossy_quality=0.85/' "$f.import"
done
timeout 900 flatpak run org.godotengine.Godot --headless --path "$WORK" --import 2>&1 | grep -E "ERROR" | head -5
timeout 900 flatpak run org.godotengine.Godot --headless --path "$WORK" --export-release Web "$SRC/build/web/index.html" 2>&1 | grep -E "ERROR" | head -5
ls -la build/web
