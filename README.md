# mathletter.ps1

Math Letter 관리 프로그램입니다. (Windows)

## 요구 사항

* PowerShell이 설치되어 있어야 합니다. (테스트한 환경: `PS v5.1.19041.1`, `PS v7.0.3`)
* 드라이브에 충분한 용량이 남아 있어야 합니다. (최소 2GB 필요)

## 명령어

### 처음 실행 시

다운로드 받은 mathletter.ps1이 있는 폴더에서 PowerShell을 엽니다. (또는 PowerShell을 연 후에 `cd [mathletter.ps1이 있는 폴더]`를 입력합니다.)

그 후, `.\mathletter -mode install`로 설치합니다.

### 설치 이후

`mathletter -mode help`를 참조하세요.

## 오류 발생 시

이슈 트래커나 톡으로 말씀해주세요.

## TODO

* [x] 도움말
* [x] TeX Live 설치
* [x] 폰트 설치
* [x] 환경 변수 PATH 설정
* [x] MathLetter.sty 업데이트
* [x] MathLetter.ps1 업데이트
* [x] ML 생성 명령
* [x] 아티클 생성 명령
* [x] 아티클 조판 명령
* [ ] 표지 생성 명령
  - [ ] 표지 조판 명령
* [ ] Git integration for the `src` directory?
* [ ] Error handling?

## Why XeLaTeX?

가능하면 LuaLaTeX을 쓰고 싶었으나 Noto 폰트가 용량이 커서 luaotfload가 out of memory로 죽기 때문에 XeLaTeX으로 컴파일합니다. 이 문제를 해결할 workaround가 있으면 LuaLaTeX으로 변경할 예정입니다.
