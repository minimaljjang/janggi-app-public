#!/usr/bin/env bash
# Builds Fairy-Stockfish (GPL-3.0) for Android as an executable named
# libfairystockfish.so and copies it into android/app/src/main/jniLibs/<abi>/.
#
# Android only lets apps exec files from nativeLibraryDir, so the engine is
# shipped like a JNI library and started as a process (see MainActivity.kt
# and lib/services/stockfish_service_io.dart).
#
# armeabi-v7a is not built: the large-board build (needed for janggi's
# 9x10 board) uses unsigned __int128 bitboards, which 32-bit ARM lacks.
# 32-bit devices fall back to the built-in Dart AI.
#
# Usage: tool/build_engine.sh [path-to-ndk]
set -euo pipefail

FSF_REPO=https://github.com/fairy-stockfish/Fairy-Stockfish.git
FSF_COMMIT=53c1f2bd14a2d3b685904ccf8ec9dec8401800ff

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NDK="${1:-${ANDROID_NDK_HOME:-/c/Android/sdk/ndk/28.2.13676358}}"
WORK="${FSF_WORK_DIR:-$ROOT/../_engine_src}"
API=21

case "$(uname -s)" in
  MINGW*|MSYS*|CYGWIN*) HOST=windows-x86_64; EXE=.exe ;;
  Darwin) HOST=darwin-x86_64; EXE= ;;
  *) HOST=linux-x86_64; EXE= ;;
esac
TC="$NDK/toolchains/llvm/prebuilt/$HOST/bin"
CXX="$TC/clang++$EXE"
STRIP="$TC/llvm-strip$EXE"

mkdir -p "$WORK"
if [ ! -d "$WORK/fsf/.git" ]; then
  git clone "$FSF_REPO" "$WORK/fsf"
fi
git -C "$WORK/fsf" fetch --depth 1 origin "$FSF_COMMIT" 2>/dev/null || true
git -C "$WORK/fsf" checkout -q "$FSF_COMMIT"
SRC="$WORK/fsf/src"

SRCS="benchmark.cpp bitbase.cpp bitboard.cpp endgame.cpp evaluate.cpp main.cpp
  material.cpp misc.cpp movegen.cpp movepick.cpp pawns.cpp position.cpp psqt.cpp
  search.cpp thread.cpp timeman.cpp tt.cpp uci.cpp ucioption.cpp tune.cpp
  syzygy/tbprobe.cpp nnue/evaluate_nnue.cpp nnue/features/half_ka_v2.cpp
  partner.cpp parser.cpp piece.cpp variant.cpp xboard.cpp
  nnue/features/half_ka_v2_variants.cpp"

COMMON="-std=c++17 -O3 -DNDEBUG -fno-exceptions -fPIE -stdlib=libc++
  -DIS_64BIT -DUSE_POPCNT -DLARGEBOARDS -DPRECOMPUTED_MAGICS
  -DNNUE_EMBEDDING_OFF -Wno-everything"

build() {
  local abi=$1 target=$2 extra=$3
  local obj="$WORK/obj/$abi"
  mkdir -p "$obj"
  echo "== $abi"
  for f in $SRCS; do
    # shellcheck disable=SC2086
    "$CXX" --target=$target$API $COMMON $extra -c "$SRC/$f" \
      -o "$obj/$(basename "$f" .cpp).o" &
    while [ "$(jobs -rp | wc -l)" -ge 8 ]; do wait -n; done
  done
  wait
  local out="$ROOT/android/app/src/main/jniLibs/$abi/libfairystockfish.so"
  mkdir -p "$(dirname "$out")"
  "$CXX" --target=$target$API -fPIE -pie -static-libstdc++ "$obj"/*.o \
    -lm -latomic -o "$out"
  "$STRIP" "$out"
  ls -l "$out"
}

build arm64-v8a aarch64-linux-android "-DUSE_NEON"
build x86_64 x86_64-linux-android "-msse4.1 -mpopcnt"
