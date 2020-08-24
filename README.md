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

`mathletter -mode help`를 참조하셔도 됩니다.

* `mathletter` 또는 `mathletter -mode help`: 도움말을 출력합니다.
* `mathletter -mode install`: Math Letter 컴파일에 필요한 프로그램들을 설치합니다.
* `mathletter -mode font`: Math Letter 컴파일에 필요한 폰트들을 설치합니다.
* `mathletter -mode path`: PATH 변수에 `~\.mathletter` 경로를 추가합니다.
* `mathletter -mode update-sty`: MathLetter.sty 패키지 파일을 업데이트합니다.
* `mathletter -mode update-tool`: MathLetter.ps1 실행 파일과 assets을 업데이트합니다.
* `mathletter -mode new -no [ML 번호]`: 새 Math Letter 폴더를 만듭니다.
* `mathletter -mode open -no [ML 번호]`: 해당 ML 폴더를 파일 탐색기에서 엽니다.
* `mathletter -mode article -no [ML 번호] -slug [폴더 이름]`: 새 아티클 폴더를 만듭니다.
  + [폴더 이름]에는 알파벳, 숫자, 공백, -나 _만이 들어가야 합니다.
* `mathletter -mode compile -no [ML 번호] [-slug [폴더 이름]] [-single]`: 아티클을 컴파일(조판)해서 build 폴더에 pdf 파일을 넣습니다.
  + [폴더 이름]에는 알파벳, 숫자, 공백, `-`나 `_`만이 들어가야 합니다. 
  + `-slug`를 생략하면 모든 아티클을 차례로 컴파일합니다.
  + `-single` 옵션을 주면 한 번만 조판합니다. (기본값은 tex->bib->tex)
* `mathletter -mode cover -no [ML 번호] [-slug [폴더 이름]] [-single]`: 해당 ML 폴더의 cover.json을 기반으로 커버를 만들고 조판합니다.

#### 예시

```powershell
mathletter -mode new -no 265      # .mathletter\src\265 폴더와 관련 파일을 만듭니다.
mathletter -mode article -no 265 -slug 'awesome-article'
     # .mathletter\src\265\articles\awesome-article 안에 sample TeX 파일을 만듭니다.
mathletter -mode compile -no 265 -slug 'awesome-article'
     # 위에서 만든 아티클을 조판합니다.
mathletter -mode compile -no 265  # ML 265의 모든 아티클을 조판합니다.
mathletter -mode cover -no 265
     # .mathletter\src\265\cover\cover.json 파일을 기반으로 ML 265의 표지를 만듭니다.
```

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
* [x] 표지 생성 명령
  - [x] 표지 조판 명령
* [ ] `-shell-escape`
* [ ] GUI for generating cover.json
* [ ] Git integration for the `src` directory?
* [ ] Error handling?

## Why XeLaTeX?

가능하면 LuaLaTeX을 쓰고 싶었으나 Noto 폰트가 용량이 커서 luaotfload가 out of memory로 죽기 때문에 XeLaTeX으로 컴파일합니다. 이 문제를 해결할 workaround가 있으면 LuaLaTeX으로 변경할 예정입니다.
