# TextSniper Local

개인 사용을 위한 로컬 macOS 메뉴바 OCR 앱입니다. Apple Silicon Mac 전용이며 배포, App Store, notarization은 목표에서 제외합니다.

## 기능

- 메뉴바에서 `텍스트 캡처` 실행
- 전역 단축키 `Cmd + Shift + 2`
- 메뉴바의 `단축키 설정...`에서 캡처 단축키 변경
- 메뉴바에서 `로그인 시 실행` 토글
- 드래그로 화면 영역 선택
- Apple Vision OCR로 한국어/영어 텍스트 인식
- 인식 결과를 클립보드에 자동 복사

## 요구사항

- Apple Silicon Mac
- macOS 13 이상
- Xcode Command Line Tools 또는 Xcode

## 빌드

```bash
./Scripts/build_app.sh
```

빌드가 끝나면 다음 앱 번들이 생성됩니다.

```text
build/TextSniperLocal.app
```

빌드 스크립트는 `arm64-apple-macosx13.0` triple을 사용하고, 생성된 실행 파일이 `arm64` 단일 바이너리인지 검증합니다.
`Assets/AppIcon.png`에서 `Packaging/Resources/AppIcon.icns`도 함께 생성해 앱 번들에 포함합니다.

## 실행

```bash
open build/TextSniperLocal.app
```

실행 후 메뉴바의 텍스트 아이콘을 클릭하거나 `Cmd + Shift + 2`를 누르면 캡처가 시작됩니다.

## 단축키 변경

메뉴바 아이콘을 클릭한 뒤 `단축키 설정...`을 선택합니다. 설정 창의 입력 영역을 클릭하고 원하는 키 조합을 누르면 즉시 저장되고 전역 단축키가 다시 등록됩니다.

## 로그인 시 실행

메뉴바 아이콘을 클릭한 뒤 `로그인 시 실행`을 선택하면 현재 앱이 로그인 항목으로 등록됩니다. macOS가 승인을 요구하는 경우 시스템 설정의 로그인 항목에서 허용해야 합니다.

## 권한

첫 실행 또는 첫 캡처 시 화면 기록 권한이 필요할 수 있습니다.

1. 시스템 설정을 엽니다.
2. 개인정보 보호 및 보안으로 이동합니다.
3. 화면 기록에서 `TextSniper Local`을 허용합니다.
4. 앱을 다시 실행합니다.

메뉴바의 `화면 기록 권한 열기` 항목으로도 설정 화면을 열 수 있습니다.

## 개발 검증

```bash
swift test
swift build
```
