#!/bin/sh
# Compiles the GLSL shaders to the .qsb files Qt loads. Needs qsb from Qt
# Shader Tools (Void: qt6-shadertools-devel). The .qsb files are committed,
# so this is only needed after editing a shader.
set -e

cd "$(dirname "$0")/.."
qsb=$(command -v qsb || echo /usr/lib/qt6/bin/qsb)

for frag in $(find Twilight -name '*.frag'); do
    echo "$frag"
    "$qsb" --glsl "100 es,120,150" --hlsl 50 --msl 12 -o "$frag.qsb" "$frag"
done
