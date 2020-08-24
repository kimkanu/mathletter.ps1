param([string]$Mode = 'help', [int]$No, [string]$Slug, [switch]$Single = $false, [switch]$ShellEscape = $false)

$VERSION = '0.0.6'

$MATHLETTER_STY_RAW_REPO = 'https://raw.githubusercontent.com/msquare-kaist/mathletter-package/master'
$MATHLETTER_PS1_RAW_REPO = 'https://raw.githubusercontent.com/kimkanu/mathletter.ps1/master'
$MATHLETTER_COVER_RAW_REPO = 'https://raw.githubusercontent.com/kimkanu/mathletter-cover/master'

$currentDir = $PWD.Path
$rootDir = "$env:USERPROFILE\.mathletter"
$rootDirSlashed = $rootDir -replace '[\\]', '/'
$rootDirTilde = '~/.mathletter'
if (-Not (Test-Path "$rootDir\texlive")) {
    $TEXLIVE_VERSION = '{red}NOT INSTALLED'
}
else {
    $TEXLIVE_DISTS = (Get-ChildItem "$rootDir\texlive" | ForEach-Object { $_.Name } | Where-Object { $_ -match "^\d+$" } | ForEach-Object { [int]$_ } | Measure -Maximum)

    if ($TEXLIVE_DISTS.Count -eq 0) {
        $TEXLIVE_VERSION = '{red}NOT INSTALLED'
    }
    else {
        $TEXLIVE_VERSION = $TEXLIVE_DISTS.Maximum
    }
}
$tempDir = "$rootDir\.temp"
$commonstuffDir = "$rootDir\texlive\$TEXLIVE_VERSION\texmf\tex\latex\commonstuff"
$texliveProfilePath = "$tempDir\texlive.profile"
$texliveProfileContent = @"
# texlive.profile written on Sun Aug 23 09:49:02 2020 UTC
# It will NOT be updated and reflects only the
# installation profile at installation time.
selected_scheme scheme-custom
TEXDIR $rootDirSlashed/texlive/$TEXLIVE_VERSION
TEXMFCONFIG $rootDirTilde/texlive/$TEXLIVE_VERSION/texmf-config
TEXMFHOME $rootDirTilde/texlive/$TEXLIVE_VERSION/texmf
TEXMFLOCAL $rootDirSlashed/texlive/texmf-local
TEXMFSYSCONFIG $rootDirSlashed/texlive/$TEXLIVE_VERSION/texmf-config
TEXMFSYSVAR $rootDirSlashed/texlive/$TEXLIVE_VERSION/texmf-var
TEXMFVAR $rootDirTilde/texlive/$TEXLIVE_VERSION/texmf-var
binary_win32 1
collection-basic 1
collection-fontsrecommended 1
collection-fontutils 1
collection-langcjk 1
collection-langkorean 1
collection-latex 1
collection-latexrecommended 1
collection-luatex 1
collection-mathscience 1
collection-wintools 1
collection-xetex 1
instopt_adjustpath 1
instopt_adjustrepo 1
instopt_letter 0
instopt_portable 0
instopt_write18_restricted 1
tlpdbopt_autobackup 1
tlpdbopt_backupdir tlpkg/backups
tlpdbopt_create_formats 1
tlpdbopt_desktop_integration 0
tlpdbopt_file_assocs 0
tlpdbopt_generate_updmap 0
tlpdbopt_install_docfiles 1
tlpdbopt_install_srcfiles 1
tlpdbopt_post_code 1
tlpdbopt_sys_bin /usr/local/bin
tlpdbopt_sys_info /usr/local/share/info
tlpdbopt_sys_man /usr/local/share/man
tlpdbopt_w32_multi_user 0
"@

$sampleTeXContent = @"
% !TeX program = xelatex

\documentclass{book}
\usepackage{MathLetter}

\title{아티클 제목}
\author{아티클 저자}

\fontsettingtrue
\mergedcountertrue

\setcounter{issue}{$No}
\setcounter{page}{0}

\allowdisplaybreaks
\emergencystretch=0pt

\addbibresource{$Slug.bib}

\begin{document}

\maketitle[알아봅시다]

\section{섹션 이름}

\begin{MLPar}
첫 번째 문단

연속된 문단은 두 줄을 띄워 같은 MLPar 안에 작성합니다.

연속된 문단은 또 다시 두 줄을 띄워 같은 MLPar 안에 작성합니다.
\end{MLPar}

\Picture{example-image-a}[width=.25\textwidth, center]

\begin{MLPar}
    연속되지 않은 문단은 별도의 MLPar 안에 씁니다.
\end{MLPar}

\begin{MLThm}[정리 \cite{einstein}]
    정리를 쓰는 곳
    \[ \frac{d}{dx} \cos \pi = - \sin \pi. \]
\end{MLThm}

\PrintBibliography

\end{document}
"@

$sampleBibContent = @'
@article{einstein,
    author =       "Albert Einstein",
    title =        "{Zur Elektrodynamik bewegter K{\"o}rper}. ({German})
        [{On} the electrodynamics of moving bodies]",
    journal =      "Annalen der Physik",
    volume =       "322",
    number =       "10",
    pages =        "891--921",
    year =         "1905",
    DOI =          "http://dx.doi.org/10.1002/andp.19053221004"
}
'@

$path = [Environment]::GetEnvironmentVariable('path', 'machine');
if (($path -like "*;$rootDir;*") -Or ($path -like "*;$rootDir")) {
    $prefix = ""
} else {
    $prefix = ".\"
}

Set-Location $rootDir

function Write-Color() {
    Param (
        [string] $text = $(Write-Error "You must specify some text"),
        [switch] $NoNewLine = $false
    )

    $startColor = $host.UI.RawUI.ForegroundColor;

    $text.Split( [char]"{", [char]"}" ) | ForEach-Object { $i = 0; } {
        if ($i % 2 -eq 0) {
            Write-Host $_ -NoNewline;
        }
        else {
            if ($_ -in [enum]::GetNames("ConsoleColor")) {
                $host.UI.RawUI.ForegroundColor = ($_ -as [System.ConsoleColor]);
            }
        }

        $i++;
    }

    if (!$NoNewLine) {
        Write-Host;
    }
    $host.UI.RawUI.ForegroundColor = $startColor;
}

function Print-Help {
    Write-Color "{green}=====> Math Letter Tools v$VERSION <======"
    Write-Color "TeX Live 버전: {yellow}$TEXLIVE_VERSION"
    Write-Color ""
    Write-Color "          사용법:            {yellow}$($prefix)mathletter {white}-mode {yellow}[모드]"
    Write-Color "사용법 (cmd.exe): {white}powershell {yellow}$($prefix)mathletter {white}-mode {yellow}[모드]"
    Write-Color ""
    Write-Color "모드 목록:"
    Write-Color "    {yellow}help                       {gray}* 이 도움말을 출력합니다."
    Write-Color "    {yellow}install                    {gray}* Math Letter 컴파일에 필요한 프로그램들을 설치합니다."
    Write-Color "    {yellow}font                       {gray}* Math Letter 컴파일에 필요한 폰트들을 설치합니다."
    Write-Color "    {yellow}path                       {gray}* PATH 변수에 ~\.mathletter 경로를 추가합니다."
    Write-Color "    {yellow}update-sty                 {gray}* MathLetter.sty 패키지 파일을 업데이트합니다."
    Write-Color "    {yellow}update-tool                {gray}* MathLetter.ps1 실행 파일과 assets을 업데이트합니다."
    Write-Color ""
    Write-Color "    {yellow}new {white}-no {yellow}[ML 번호]          {gray}* 새 Math Letter 폴더를 만듭니다."
    Write-Color "    {yellow}open {white}-no {yellow}[ML 번호]         {gray}* 해당 ML 폴더를 파일 탐색기에서 엽니다."
    Write-Color "    {yellow}article {white}-no {yellow}[ML 번호]      {gray}* 새 아티클 폴더를 만듭니다."
    Write-Color "        {white}-slug {yellow}[폴더 이름]      {gray}  [폴더 이름]에는 알파벳, 숫자, 공백, -나 _만이 들어가야 합니다."
    Write-Color "    {yellow}compile {white}-no {yellow}[ML 번호]      {gray}* 아티클을 컴파일(조판)해서 build 폴더에 pdf 파일을 넣습니다."
    Write-Color "        [{white}-slug {yellow}[폴더 이름]{gray}]      [폴더 이름]에는 알파벳, 숫자, 공백, -나 _만이 들어가야 합니다."
    Write-Color "        {white}[-single]                {white}-Slug{gray}를 생략하면 모든 아티클을 차례로 컴파일합니다."
    Write-Color "        {white}[-ShellEscape]           {white}-Single{gray} 옵션을 주면 한 번만 조판합니다. (기본값은 tex->bib->tex)"
    Write-Color "                                 {white}-ShellEscape{gray} 옵션을 주면 -shell-escape로 조판합니다."
    Write-Color "    {yellow}cover {white}-no {yellow}[ML 번호]        {gray}* 해당 ML 폴더의 cover.json을 기반으로 커버를 만들고 조판합니다."
}

function Add-To-Path {
    Write-Color "{yellow}[INFO] 환경 변수 PATH에 추가하는 중..."
    if (($path -like "*;$rootDir;*") -Or ($path -like "*;$rootDir")) {
        Write-Color "{yellow}[INFO] 이미 PATH에 등록되어 있습니다."
    }
    elseif ($path.EndsWith(";")) {
        $path += "$rootDir;"
        Start-Process -Wait powershell -Verb runAs "[Environment]::SetEnvironmentVariable('path', '$path', 'Machine');"
        Write-Color "{green}[INFO] PATH에 추가 완료"
        Write-Color "{yellow}[INFO] {gray}이제 .\ 없이 {yellow}mathletter{gray}으로 실행할 수 있습니다."
    }
    else {
        $path += ";$rootDir"
        Start-Process -Wait powershell -Verb runAs "[Environment]::SetEnvironmentVariable('path', '$path', 'Machine');"
        Write-Color "{green}[INFO] PATH에 추가 완료"
        Write-Color "{yellow}[INFO] {gray}이제 .\ 없이 {yellow}mathletter{gray}으로 실행할 수 있습니다."
    }
}

function Clear-TeXLive {
    Write-Color "{yellow}[INFO] 기존 폴더를 삭제하는 중..."
    Remove-Item "$rootDir\texlive" -Recurse -Force
    Write-Color "{green}[INFO] 기존 폴더 삭제 완료"
}

function Clear-TempDir {
    Write-Color "{yellow}[INFO] 임시 폴더를 삭제하는 중..."
    Remove-Item $tempDir -Recurse -Force
    Write-Color "{green}[INFO] 임시 폴더 삭제 완료"
}

function Create-TempDir {
    Write-Color "{yellow}[INFO] 임시 폴더를 만드는 중..."
    New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
    Write-Color "{green}[INFO] 임시 폴더 생성 완료"
}

function Install-TeXLive {
    # download install-tl.zip
    Write-Color "{yellow}[INFO] TeX Live를 다운로드 하는 중..."
    Invoke-WebRequest `
        -OutFile "$tempDir\install-tl.zip" `
        -Uri http://mirror.ctan.org/systems/texlive/tlnet/install-tl.zip
    Expand-Archive `
        -LiteralPath "$tempDir\install-tl.zip" `
        -DestinationPath "$tempDir"
    Write-Color "{green}[INFO] TeX Live 다운로드 완료"

    # create texlive.profile
    Write-Color "{yellow}[INFO] TeX Live 설치 프로파일을 생성하는 중..."
    Set-Content -Path $texliveProfilePath -Value $texliveProfileContent
    Write-Color "{green}[INFO] TeX Live 설치 프로파일 생성 완료"

    # install texlive
    Write-Color "{yellow}[INFO] TeX Live를 설치하는 중..."
    Start-Process `
        -NoNewWindow -Wait `
        -FilePath "$tempDir\install-tl-*\install-tl-windows.bat" `
        -ArgumentList "-no-gui -profile $tempDir\texlive.profile -non-admin"
    Write-Color "{green}[INFO] TeX Live 설치 완료"
    
    $TEXLIVE_DISTS = (Get-ChildItem "texlive" | ForEach-Object { $_.Name } | Where-Object { $_ -match "^\d+$" } | ForEach-Object { [int]$_ } | Measure -Maximum)
    if ($TEXLIVE_DISTS.Count -gt 0) {
        $TEXLIVE_VERSION = $TEXLIVE_DISTS.Maximum
    }
    
    # install additional packages
    $tlmgrPath = "$rootDir\texlive\$TEXLIVE_VERSION\bin\win32\tlmgr.bat"
    $texPackages = 'mwe changepage tcolorbox environ trimspaces ulem xifthen ifmtarg titlesec biblatex adjustbox collectbox tikz-cd pgfplots enumitem forloop minted varwidth datetime pagecolor fmtcount'
    Write-Color "{yellow}[INFO] 추가 패키지를 설치하는 중..."
    Start-Process `
        -NoNewWindow -Wait `
        -FilePath $tlmgrPath `
        -ArgumentList "install $texPackages"
    Write-Color "{green}[INFO] 추가 패키지 설치 완료"
}

function Install-Fonts {
    Create-TempDir
    New-Item -ItemType Directory -Force -Path "$rootDir\fonts" | Out-Null

    Write-Color "{yellow}[INFO] 폰트를 설치하는 중..."
    "    Noto Sans CJK KR 다운로드 중..."
    Invoke-WebRequest `
        -OutFile "$tempDir\NotoSansCJKkr-hinted.zip" `
        -Uri 'https://noto-website-2.storage.googleapis.com/pkgs/NotoSansCJKkr-hinted.zip'
    Expand-Archive  -LiteralPath "$tempDir\NotoSansCJKkr-hinted.zip" -DestinationPath "$rootDir\fonts" -Force
    Get-ChildItem "$rootDir\fonts" | Where-Object {$_.Extension -ne '.otf'} | Remove-Item

    "    Noto Serif CJK KR 다운로드 중..."
    Invoke-WebRequest `
        -OutFile "$tempDir\NotoSerifCJKkr-hinted.zip" `
        -Uri 'https://noto-website-2.storage.googleapis.com/pkgs/NotoSerifCJKkr-hinted.zip'
    Expand-Archive  -LiteralPath "$tempDir\NotoSerifCJKkr-hinted.zip" -DestinationPath "$rootDir\fonts"
    Get-ChildItem "$rootDir\fonts" | Where-Object {$_.Extension -ne '.otf'} | Remove-Item
    
    "    KoPub 2.0 서체 다운로드 중..."
    Invoke-WebRequest `
        -OutFile "$tempDir\KOPUB2.0_TTF_FONTS.zip" `
        -Uri 'http://www.kopus.org/download/KOPUB2.0_TTF_FONTS.zip'
    Expand-Archive  -LiteralPath "$tempDir\KOPUB2.0_TTF_FONTS.zip" -DestinationPath "$rootDir\fonts"
    Get-ChildItem "$rootDir\fonts" | Where-Object {($_.Extension -ne '.ttf') -and ($_.Extension -ne '.otf')} | Remove-Item

    Write-Color "{green}[INFO] 폰트 다운로드 완료"
    Write-Color "{green}[INFO] {red}(중요){green} $rootDir\fonts 폴더에 들어가서 폰트를 모두 선택 후 '모든 사용자용으로' 설치해주세요."
}

function Update-Sty {
    Write-Color "{yellow}[INFO] MathLetter.sty를 업데이트 하는 중..."
    Invoke-WebRequest `
        -OutFile "$commonstuffDir\MathLetter.sty" `
        -Uri "$MATHLETTER_STY_RAW_REPO/MathLetter.sty"

    Write-Color "{green}[INFO] MathLetter.sty 업데이트 완료"
}

function Fetch-Assets {
    Write-Color "{yellow}[INFO] 로고 파일을 다운로드 하는 중..."
    Invoke-WebRequest `
        -OutFile "$commonstuffDir\math.pdf" `
        -Uri "$MATHLETTER_COVER_RAW_REPO/math.pdf"
    Invoke-WebRequest `
        -OutFile "$commonstuffDir\logo.pdf" `
        -Uri "$MATHLETTER_COVER_RAW_REPO/logo.pdf"
    
    Write-Color "{green}[INFO] 로고 파일 다운로드 완료"

    Write-Color "{yellow}[INFO] 표지 템플릿 파일을 다운로드 하는 중..."
    Invoke-WebRequest `
        -OutFile "$commonstuffDir\cover.tex.ps1.template" `
        -Uri "$MATHLETTER_COVER_RAW_REPO/cover.tex.ps1.template"
    Invoke-WebRequest `
        -OutFile "$commonstuffDir\cover.json" `
        -Uri "$MATHLETTER_COVER_RAW_REPO/cover.json"
    
    Write-Color "{green}[INFO] 표지 템플릿 파일 다운로드 완료"
}

function Update-Tool {
    Write-Color "{yellow}[INFO] MathLetter.ps1을 업데이트 하는 중..."
    $newestVersionString = (New-Object System.Net.WebClient).DownloadString("$MATHLETTER_PS1_RAW_REPO/VERSION")
    if ($version -eq $VERSION) {
        Write-Color "{green}[INFO] MathLetter.ps1이 이미 최신 버전입니다."
    }
    else {
        Invoke-WebRequest `
            -OutFile "$rootDir\mathletter.ps1" `
            -Uri "$MATHLETTER_PS1_RAW_REPO/mathletter.ps1"
        
        Write-Color "{green}[INFO] MathLetter.ps1 업데이트 완료"
    }
}

if ($Mode -eq 'help') {
    Print-Help
}
elseif ($Mode -eq 'install') {
    Clear-TeXLive
    Create-TempDir
    Install-TeXLive
    Install-Fonts
    Clear-TempDir

    Write-Color "{yellow}[INFO] 실행 파일을 {green}'$rootDir'{yellow} 안으로 옮기는 중..."
    Move-Item -Path "$($PWD.Path)\mathletter.ps1" -Destination "$rootDir\mathletter.ps1"
    Write-Color "{green}[INFO] 옮기기 완료"

    Update-Sty
    Fetch-Assets
    Add-To-Path
    Write-Color "=====> {green}설치 완료 {gray}<====="
}
elseif ($Mode -eq 'font') {
    Install-Fonts
    Clear-TempDir
}
elseif ($Mode -eq 'path') {
    Add-To-Path
}
elseif ($Mode -eq 'update-sty') {
    Update-Sty
}
elseif ($Mode -eq 'update-tool') {
    Update-Tool
    Fetch-Assets
}
elseif ($Mode -eq 'new') {
    New-Item -ItemType Directory -Force -Path "$rootDir\src" | Out-Null

    if (-Not (($No) -and ($No -gt 0))) {
        Write-Color "{red}[ERROR] ML 번호가 주어지지 않았습니다."
        Write-Color ""
        Print-Help
    }
    elseif (Test-Path "$rootDir\src\$No") {
        Write-Color "{red}[ERROR] $rootDir\src\$($No)이(가) 이미 존재합니다."
    }
    else {
        Write-Color "{yellow}[INFO] 새 Math Letter를 만드는 중..."
        New-Item -ItemType directory -Path "$rootDir\src\$No\articles" | Out-Null
        New-Item -ItemType directory -Path "$rootDir\src\$No\problems" | Out-Null
        New-Item -ItemType directory -Path "$rootDir\src\$No\build" | Out-Null

        New-Item -ItemType directory -Path "$rootDir\src\$No\cover" | Out-Null
        Copy-Item "$commonstuffDir\cover.json" -Destination "$rootDir\src\$No\cover"

    }
}
elseif ($Mode -eq 'open') {
    New-Item -ItemType Directory -Force -Path "$rootDir\src" | Out-Null

    if (-Not (($No) -and ($No -gt 0))) {
        Write-Color "{red}[ERROR] ML 번호가 주어지지 않았습니다."
        Write-Color ""
        Print-Help
    }
    elseif (Test-Path "$rootDir\src\$No") {
        Write-Color "{yellow}[INFO] ML $No 폴더를 여는 중..."
        Invoke-Item "$rootDir\src\$No"
    }
    else {
        Write-Color "{red}[ERROR] $rootDir\src\$No 폴더가 존재하지 않습니다."
        Write-Color ""
        Print-Help
    }
}
elseif ($Mode -eq 'article') {
    New-Item -ItemType Directory -Force -Path "$rootDir\src" | Out-Null

    if (-Not (($No) -and ($No -gt 0))) {
        Write-Color "{red}[ERROR] ML 번호가 주어지지 않았습니다."
        Write-Color ""
        Print-Help
    }
    elseif (-Not ($Slug)) {
        Write-Color "{red}[ERROR] 아티클 폴더 이름이 주어지지 않았습니다."
        Write-Color ""
        Print-Help
    }
    elseif (-Not ((Test-Path "$rootDir\src\$No\articles") -and (Test-Path "$rootDir\src\$No\build"))) {
        Write-Color "{red}[ERROR] ML $No 폴더가 존재하지 않습니다."
        Write-Color ""
        Print-Help
    }
    elseif (Test-Path "$rootDir\src\$No\articles\$Slug") {
        Write-Color "{red}[ERROR] 아티클 $($Slug)이(가) 이미 존재합니다."
        Write-Color ""
        Print-Help
    }
    else {
        Write-Color "{yellow}[INFO] ML$($No)에 새 아티클을 만드는 중..."
        New-Item -ItemType directory -Path "$rootDir\src\$No\articles\$Slug" | Out-Null
        Set-Content -Path "$rootDir\src\$No\articles\$Slug\$Slug.tex" -Value $sampleTeXContent
        Set-Content -Path "$rootDir\src\$No\articles\$Slug\$Slug.bib" -Value $sampleBibContent
    }
}
elseif ($Mode -eq 'compile') {
    New-Item -ItemType Directory -Force -Path "$rootDir\src" | Out-Null

    if ($TEXLIVE_VERSION -eq '{red}NOT INSTALLED' -Or (-Not (Test-Path "$rootDir\texlive\$TEXLIVE_VERSION\bin\win32"))) {
        Write-Color "{red}[ERROR] 먼저 $($prefix)mathletter -mode install을 실행해 주세요."
        Write-Color ""
        Print-Help
    }
    elseif (-Not (($No) -and ($No -gt 0))) {
        Write-Color "{red}[ERROR] ML 번호가 주어지지 않았습니다."
        Write-Color ""
        Print-Help
    }
    elseif (-Not ((Test-Path "$rootDir\src\$No\articles") -and (Test-Path "$rootDir\src\$No\build"))) {
        Write-Color "{red}[ERROR] ML $No 폴더가 존재하지 않습니다."
        Write-Color ""
        Print-Help
    }
    elseif (-Not ($Slug)) {
        Write-Color "{yellow}[INFO] ML$($No)의 모든 아티클을 조판하는 중..."
        Get-ChildItem "$rootDir\src\$No\articles" | ForEach-Object {
            $Slug = $_.BaseName
            Set-Location "$rootDir\src\$No\articles\$Slug"

            Write-Color "{yellow}[INFO] ML$($No)의 아티클 $($Slug)을(를) 조판하는 중..."
            Start-Process `
                -NoNewWindow -Wait `
                -FilePath "$rootDir\texlive\$TEXLIVE_VERSION\bin\win32\xelatex.exe" `
                -ArgumentList "$Slug.tex"
            if ($Single -eq $false) {
                Start-Process `
                    -NoNewWindow -Wait `
                    -FilePath "$rootDir\texlive\$TEXLIVE_VERSION\bin\win32\bibtex.exe" `
                    -ArgumentList "$Slug.aux"
                Start-Process `
                    -NoNewWindow -Wait `
                    -FilePath "$rootDir\texlive\$TEXLIVE_VERSION\bin\win32\xelatex.exe" `
                    -ArgumentList "$Slug.tex"
            }

            Copy-Item "$rootDir\src\$No\articles\$Slug\$Slug.pdf" -Destination "$rootDir\src\$No\build"
        }
    }
    elseif (-Not (Test-Path "$rootDir\src\$No\articles\$Slug")) {
        Write-Color "{red}[ERROR] 아티클 $($Slug)이 존재하지 않습니다."
        Write-Color ""
        Print-Help
    }
    else {
        Set-Location "$rootDir\src\$No\articles\$Slug"

        if ($ShellEscape) {
            $texPrefix = '-shell-escape '
        }
        else {
            $texPrefix = ''
        }
        
        Write-Color "{yellow}[INFO] ML$($No)의 아티클 $($Slug)을(를) 조판하는 중..."
        Start-Process `
            -NoNewWindow -Wait `
            -FilePath "$rootDir\texlive\$TEXLIVE_VERSION\bin\win32\xelatex.exe" `
            -ArgumentList "$texPrefix$Slug.tex"
        if ($Single -eq $false) {
            Start-Process `
                -NoNewWindow -Wait `
                -FilePath "$rootDir\texlive\$TEXLIVE_VERSION\bin\win32\bibtex.exe" `
                -ArgumentList "$Slug.aux"
            Start-Process `
                -NoNewWindow -Wait `
                -FilePath "$rootDir\texlive\$TEXLIVE_VERSION\bin\win32\xelatex.exe" `
                -ArgumentList "$texPrefix$Slug.tex"
        }

        Copy-Item "$rootDir\src\$No\articles\$Slug\$Slug.pdf" -Destination "$rootDir\src\$No\build"
    }
}
elseif ($Mode -eq 'cover') {
    New-Item -ItemType Directory -Force -Path "$rootDir\src" | Out-Null

    if ($TEXLIVE_VERSION -eq '{red}NOT INSTALLED' -Or (-Not (Test-Path "$rootDir\texlive\$TEXLIVE_VERSION\bin\win32"))) {
        Write-Color "{red}[ERROR] 먼저 $($prefix)mathletter -mode install을 실행해 주세요."
        Write-Color ""
        Print-Help
    }
    elseif (-Not (($No) -and ($No -gt 0))) {
        Write-Color "{red}[ERROR] ML 번호가 주어지지 않았습니다."
        Write-Color ""
        Print-Help
    }
    elseif (-Not ((Test-Path "$rootDir\src\$No\cover") -and (Test-Path "$rootDir\src\$No\build"))) {
        Write-Color "{red}[ERROR] ML $No 폴더가 존재하지 않습니다."
        Write-Color ""
        Print-Help
    }
    elseif (-Not (Test-Path "$rootDir\src\$No\cover\cover.json")) {
        Write-Color "{red}[ERROR] cover.json 파일이 존재하지 않습니다."
        Write-Color ""
        Print-Help
    }
    else {
        if (-Not ((Test-Path "$commonstuffDir\math.pdf") -and (Test-Path "$commonstuffDir\logo.pdf") -and (Test-Path "$commonstuffDir\cover.tex.ps1.template"))) {
            Fetch-Assets
        }
        Write-Color "{yellow}[INFO] cover.tex 파일을 만드는 중..."

        $json = (Get-Content "$rootDir\src\$No\cover\cover.json").Replace('<Issue>', $No) | ConvertFrom-Json
        $articles = $json.Articles | Foreach-Object { "  [$($_.Title)]%" } | Join-String -Separator "`n"
        $articlePages = $json.Articles | Foreach-Object { "  [$($_.Page)]%" } | Join-String -Separator "`n"
        $problems = $json.Problems | Foreach-Object { "  [$($_.Title)]%" } | Join-String -Separator "`n"
        $problemPages = $json.Problems | Foreach-Object { "  [$($_.Page)]%" } | Join-String -Separator "`n"
        $coverContent = (Get-Content "$commonstuffDir\cover.tex.ps1.template").
            Replace('<IssueNumber>', $json.Issue).
            Replace('<Month>', $json.Month).
            Replace('<Year>', $json.Year).
            Replace('<DateIssuedKor>', $json.DateIssuedKor).
            Replace('<DatePrintedKor>', $json.DatePrintedKor).
            Replace('<NumberOfArticles>', $json.Articles.Length).
            Replace('<Articles>', $articles).
            Replace('<ArticlePages>', $articlePages).
            Replace('<NumberOfProblems>', $json.Problems.Length).
            Replace('<Problems>', $problems).
            Replace('<ProblemPages>', $problemPages).
            Replace('<President>', $json.Officers.President).
            Replace('<VicePresident>', $json.Officers.VicePresident).
            Replace('<EditorHead>', $json.Officers.Editor).
            Replace('<AcademicHead>', $json.Officers.Academic).
            Replace('<OlympiadHead>', $json.Officers.Olympiad).
            Replace('<BankAccount>', $json.Club.BankAccount).
            Replace('<Homepage>', $json.Club.Homepage).
            Replace('<Email>', $json.Club.Email).
            Replace('<PostCode>', $json.Club.PostCode).
            Replace('<Address>', $json.Club.Address).
            Replace('<Name>', $json.Club.Name).
            Replace('<SubscriptionPay>', $json.Club.SubscriptionPay).
            Replace('<Profs>', $json.Club.Profs).
            Replace('<Publisher>', $json.Club.Publisher)
        Set-Content -Path "$rootDir\src\$No\cover\cover.tex" -Value $coverContent

        Set-Location "$rootDir\src\$No\cover"

        Write-Color "{yellow}[INFO] cover.tex 파일을 조판하는 중..."
        Start-Process `
            -NoNewWindow -Wait `
            -FilePath "$rootDir\texlive\$TEXLIVE_VERSION\bin\win32\xelatex.exe" `
            -ArgumentList "cover.tex"
        Start-Process `
            -NoNewWindow -Wait `
            -FilePath "$rootDir\texlive\$TEXLIVE_VERSION\bin\win32\xelatex.exe" `
            -ArgumentList "cover.tex"
        Write-Color "{green}[INFO] cover.tex 조판 완료"

        Copy-Item "$rootDir\src\$No\cover\cover.pdf" -Destination "$rootDir\src\$No\build"
    }
}
else {
    Write-Color "{red}[ERROR] 알 수 없는 모드입니다."
    Write-Color ""
    Print-Help
}

Set-Location $currentDir
