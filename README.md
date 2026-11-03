# janggi-app-public

바른앱 공방(Bareun App Studio)의 Android 앱 **「장기 - 큰 글씨 AI 대국·복기」**(`com.appforbaby.janggi`)에 들어 있는 오픈소스 장기 엔진 **Fairy-Stockfish**의 대응 소스(GNU GPL-3.0)와 앱의 개인정보처리방침을 공개하는 저장소입니다. 앱 본체 코드는 이 저장소에 없습니다.

This repository provides the GPL-3.0 corresponding source for the Fairy-Stockfish engine bundled in the Android app "Janggi - Big Text AI Game & Review" by Bareun App Studio, plus the app's privacy policy. It does not contain the app's own code.

## 개인정보처리방침 / Privacy policy

- 한국어: https://minimaljjang.github.io/janggi-app-public/privacy_ko.html
- English: https://minimaljjang.github.io/janggi-app-public/privacy_en.html

## 엔진 / Engine

| 항목 | 값 |
|------|----|
| 상위 프로젝트 | https://github.com/fairy-stockfish/Fairy-Stockfish (GPL-3.0) |
| 커밋 | [`53c1f2bd14a2d3b685904ccf8ec9dec8401800ff`](https://github.com/fairy-stockfish/Fairy-Stockfish/tree/53c1f2bd14a2d3b685904ccf8ec9dec8401800ff) (2026-10-30) |
| 수정 | **없음** (원본 소스 그대로, [`patches/`](patches/README.md) 참고) |
| 소스 | 서브모듈 [`fairy-stockfish/`](fairy-stockfish) (위 커밋 고정) + 같은 커밋의 소스 아카이브 [`source/Fairy-Stockfish-53c1f2bd….zip`](source/) (SHA-256은 같은 폴더의 `.sha256`) |
| 빌드 스크립트 | [`tool/build_engine.sh`](tool/build_engine.sh) (앱 저장소에서 쓰는 파일과 같음) |
| 평가 방식 | 클래식 평가, NNUE 신경망 파일 없음 (`-DNNUE_EMBEDDING_OFF`) |
| 포함 ABI | `arm64-v8a`, `x86_64` (32비트 기기는 앱 내장 AI를 사용) |

앱은 엔진을 수정하지 않고 별도 프로세스로 실행하며, UCI 텍스트 프로토콜(표준 입출력)로만 주고받습니다.
The app runs the unmodified engine as a separate process and talks to it only over UCI (stdin/stdout).

## 앱 버전 ↔ 엔진 대응표 / Version table

| 앱 버전 (versionName+versionCode) | 엔진 커밋 | NDK | `libfairystockfish.so` SHA-256 |
|------|------|------|------|
| 1.0.0+1 | `53c1f2bd14a2d3b685904ccf8ec9dec8401800ff` | r28 (`28.2.13676358`) | arm64-v8a `b1767b868d0a4ef20320d564911dcc7912d78ba59aff3f0f41844c9fc01097f3`<br>x86_64 `a0f41ac31a049b83857ab91163898cd508b1ea01091162c66d30b34e2042dd44` |

엔진이 바뀌는 앱 업데이트는 새 소스와 이 표를 먼저 올린 뒤에 배포합니다.

## 빌드 방법 / How to build

필요한 것: Android NDK r28 (`28.2.13676358`), Bash(Linux, macOS 또는 Windows Git Bash), git.

```bash
git clone https://github.com/minimaljjang/janggi-app-public.git
cd janggi-app-public
bash tool/build_engine.sh /path/to/android-ndk-r28
```

- 스크립트는 상위 저장소를 `../_engine_src/fsf`에 받아 위 커밋으로 체크아웃합니다(위치는 `FSF_WORK_DIR`로 바꿀 수 있음). 상위 저장소를 쓸 수 없으면 `source/`의 zip을 풀고, 스크립트의 `SRC`를 풀린 폴더의 `src`로 바꾼 뒤 스크립트 끝의 컴파일 부분(`build ...` 두 줄)만 실행하면 같은 결과물이 나옵니다. 서브모듈(`git submodule update --init`)로 받은 `fairy-stockfish/src`도 같은 소스입니다.
- 결과물: `android/app/src/main/jniLibs/{arm64-v8a,x86_64}/libfairystockfish.so` (실행 파일을 Android JNI 라이브러리 이름으로 포장한 것).
- 컴파일 옵션: `-std=c++17 -O3 -DNDEBUG -fno-exceptions -fPIE -stdlib=libc++ -DIS_64BIT -DUSE_POPCNT -DLARGEBOARDS -DPRECOMPUTED_MAGICS -DNNUE_EMBEDDING_OFF`, arm64는 `-DUSE_NEON`, x86_64는 `-msse4.1 -mpopcnt`, API 21, `-static-libstdc++`로 링크 후 `llvm-strip`.

## 라이선스 / License

- Fairy-Stockfish와 이 저장소의 빌드 스크립트: GNU General Public License v3.0 ([`LICENSE`](LICENSE), 상위 저장소의 `Copying.txt`와 같은 전문).
- `docs/`의 개인정보처리방침 문서는 앱 안내 문서입니다.

## 문의 / Contact

소스 요청이나 문의: ecosketch21@gmail.com (바른앱 공방 / Bareun App Studio)
