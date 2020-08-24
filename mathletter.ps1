param([string]$mode = 'help', [int]$no, [string]$slug, [switch]$single = $false)

$VERSION = '0.0.2'
$TEXLIVE_VERSION = 2020

$currentDir = $PWD.Path
$rootDir = "$env:USERPROFILE\.mathletter"
$rootDirSlashed = $rootDir -replace '[\\]', '/'
$rootDirTilde = '~/.mathletter'
$tempDir = "$rootDir\.temp"
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

\setcounter{issue}{$no}
\setcounter{page}{0}

\allowdisplaybreaks
\emergencystretch=0pt

\addbibresource{$slug.bib}

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

$path = [Environment]::GetEnvironmentVariable('path', 'machine');

Set-Location $rootDir

function Print-Help {
    if (($path -like "*;$rootDir;*") -Or ($path -like "*;$rootDir")) {
        $prefix = ""
    } else {
        $prefix = ".\"
    }
    Write-Color "{green}=====> Math Letter Tools v$VERSION <======"
    Write-Color "          사용법:            {yellow}$($prefix)mathletter {white}-mode {yellow}[모드]"
    Write-Color "사용법 (cmd.exe): {white}powershell {yellow}$($prefix)mathletter {white}-mode {yellow}[모드]"
    Write-Color ""
    Write-Color "모드 목록:"
    Write-Color "    {yellow}help                       {gray}* 이 도움말을 출력합니다."
    Write-Color "    {yellow}install                    {gray}* Math Letter 컴파일에 필요한 프로그램들을 설치합니다."
    Write-Color "    {yellow}font                       {gray}* Math Letter 컴파일에 필요한 폰트들을 설치합니다."
    Write-Color "    {yellow}path                       {gray}* PATH 변수에 ~\.mathletter 경로를 추가합니다."
    Write-Color "    {yellow}update-sty                 {gray}* MathLetter.sty 파일을 업데이트합니다."
    Write-Color "    {yellow}update-tool                {gray}* MathLetter.ps1 파일을 업데이트합니다."
    Write-Color ""
    Write-Color "    {yellow}new {white}-no {yellow}[ML 번호]          {gray}* 새 Math Letter 폴더를 만듭니다."
    Write-Color "    {yellow}article {white}-no {yellow}[ML 번호]      {gray}* 새 아티클 폴더를 만듭니다."
    Write-Color "        {white}-slug {yellow}[폴더 이름]      {gray}  [폴더 이름]에는 알파벳, 숫자, 공백, -나 _만이 들어가야 합니다."
    Write-Color "    {yellow}compile {white}-no {yellow}[ML 번호]      {gray}* 아티클을 컴파일(조판)해서 build 폴더에 pdf 파일을 넣습니다."
    Write-Color "        [{white}-slug {yellow}[폴더 이름]{gray}]      [폴더 이름]에는 알파벳, 숫자, 공백, -나 _만이 들어가야 합니다."
    Write-Color "        {white}[-single]              {gray}  -slug를 생략하면 모든 아티클을 차례로 컴파일합니다."
    Write-Color "                                 -single 옵션을 주면 한 번만 조판합니다. (기본값은 tex->bib->tex)"
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

function Update-Sty {
    Write-Color "{yellow}[INFO] MathLetter.sty를 업데이트 하는 중..."
    Invoke-WebRequest `
        -OutFile "$rootDir\texlive\$TEXLIVE_VERSION\texmf\tex\latex\commonstuff\MathLetter.sty" `
        -Uri https://raw.githubusercontent.com/msquare-kaist/mathletter-package/master/MathLetter.sty
    
    Write-Color "{green}[INFO] MathLetter.sty 업데이트 완료"
}

function Update-Tool {
    Write-Color "{yellow}[INFO] MathLetter.ps1을 업데이트 하는 중..."
    $newestVersionString = (New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/kimkanu/mathletter.ps1/master/VERSION')
    if ($version -eq $VERSION) {
        Write-Color "{green}[INFO] MathLetter.ps1이 이미 최신 버전입니다."
    }
    else {
        Invoke-WebRequest `
            -OutFile "$rootDir\mathletter.ps1" `
            -Uri https://raw.githubusercontent.com/kimkanu/mathletter.ps1/master/mathletter.ps1
        
        Write-Color "{green}[INFO] MathLetter.ps1 업데이트 완료"
    }
}

if ($mode -eq 'help') {
    Print-Help
}
elseif ($mode -eq 'install') {
    # clear the directory
    Write-Color "{yellow}[INFO] 기존 폴더를 삭제하는 중..."
    Remove-Item "$rootDir\texlive" -Recurse -Force
    Write-Color "{green}[INFO] 기존 폴더 삭제 완료"

    # create temp directory
    Write-Color "{yellow}[INFO] 임시 폴더를 만드는 중..."
    New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
    Write-Color "{green}[INFO] 임시 폴더 생성 완료"
    
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
    
    # install additional packages
    $tlmgrPath = "$rootDir\texlive\$TEXLIVE_VERSION\bin\win32\tlmgr.bat"
    $texPackages = 'mwe changepage tcolorbox environ trimspaces ulem xifthen ifmtarg titlesec biblatex adjustbox collectbox tikz-cd pgfplots enumitem forloop minted'
    Write-Color "{yellow}[INFO] 추가 패키지를 설치하는 중..."
    Start-Process `
        -NoNewWindow -Wait `
        -FilePath $tlmgrPath `
        -ArgumentList "install $texPackages"
    Write-Color "{green}[INFO] 추가 패키지 설치 완료"

    # install fonts
    Write-Color "{yellow}[INFO] 폰트를 설치하는 중..."
    "    Noto Sans CJK KR 다운로드 중..."
    Invoke-WebRequest `
        -OutFile "$tempDir\NotoSansCJKkr-hinted.zip" `
        -Uri 'https://noto-website-2.storage.googleapis.com/pkgs/NotoSansCJKkr-hinted.zip'
    Expand-Archive  -LiteralPath "$tempDir\NotoSansCJKkr-hinted.zip" -DestinationPath "$tempDir\fonts" -Force
    Get-ChildItem "$tempDir\fonts" | Where-Object {$_.Extension -ne '.otf'} | Remove-Item

    "    Noto Serif CJK KR 다운로드 중..."
    Invoke-WebRequest `
        -OutFile "$tempDir\NotoSerifCJKkr-hinted.zip" `
        -Uri 'https://noto-website-2.storage.googleapis.com/pkgs/NotoSerifCJKkr-hinted.zip'
    Expand-Archive  -LiteralPath "$tempDir\NotoSerifCJKkr-hinted.zip" -DestinationPath "$tempDir\fonts"
    Get-ChildItem "$tempDir\fonts" | Where-Object {$_.Extension -ne '.otf'} | Remove-Item
    
    "    KoPub 2.0 서체 다운로드 중..."
    Invoke-WebRequest `
        -OutFile "$tempDir\KOPUB2.0_TTF_FONTS.zip" `
        -Uri 'http://www.kopus.org/download/KOPUB2.0_TTF_FONTS.zip'
    Expand-Archive  -LiteralPath "$tempDir\KOPUB2.0_TTF_FONTS.zip" -DestinationPath "$tempDir\fonts"
    Get-ChildItem "$tempDir\fonts" | Where-Object {$_.Extension -ne '.ttf'} | Remove-Item

    $shell = New-Object -ComObject Shell.Application
    $shell.Namespace(0x14).CopyHere($shell.Namespace("$tempDir\fonts").Items())
    Write-Color "{green}[INFO] 폰트 설치 완료"

    Write-Color "{yellow}[INFO] 임시 폴더를 삭제하는 중..."
    Remove-Item $tempDir -Recurse -Force
    Write-Color "{green}[INFO] 임시 폴더 삭제 완료"

    Write-Color "{yellow}[INFO] 실행 파일을 {green}'$rootDir'{yellow} 안으로 옮기는 중..."
    Move-Item -Path "$($PWD.Path)\mathletter.ps1" -Destination "$rootDir\mathletter.ps1"
    Write-Color "{green}[INFO] 옮기기 완료"

    Update-Sty

    Add-To-Path

    Remove-Item "$tempDir" -Recurse -Force

    Write-Color "=====> {green}설치 완료 {gray}<====="
}
elseif ($mode -eq 'font') {
    Write-Color "{yellow}[INFO] 임시 폴더를 만드는 중..."
    New-Item -ItemType Directory -Force -Path $tempDir | Out-Null
    Write-Color "{green}[INFO] 임시 폴더 생성 완료"

    # install fonts
    Write-Color "{yellow}[INFO] 폰트를 설치하는 중..."
    "    Noto Sans CJK KR 다운로드 중..."
    Invoke-WebRequest `
        -OutFile "$tempDir\NotoSansCJKkr-hinted.zip" `
        -Uri 'https://noto-website-2.storage.googleapis.com/pkgs/NotoSansCJKkr-hinted.zip'
    Expand-Archive  -LiteralPath "$tempDir\NotoSansCJKkr-hinted.zip" -DestinationPath "$tempDir\fonts" -Force
    Get-ChildItem "$tempDir\fonts" | Where-Object {$_.Extension -ne '.otf'} | Remove-Item

    "    Noto Serif CJK KR 다운로드 중..."
    Invoke-WebRequest `
        -OutFile "$tempDir\NotoSerifCJKkr-hinted.zip" `
        -Uri 'https://noto-website-2.storage.googleapis.com/pkgs/NotoSerifCJKkr-hinted.zip'
    Expand-Archive  -LiteralPath "$tempDir\NotoSerifCJKkr-hinted.zip" -DestinationPath "$tempDir\fonts"
    Get-ChildItem "$tempDir\fonts" | Where-Object {$_.Extension -ne '.otf'} | Remove-Item
    
    "    KoPub 2.0 서체 다운로드 중..."
    Invoke-WebRequest `
        -OutFile "$tempDir\KOPUB2.0_TTF_FONTS.zip" `
        -Uri 'http://www.kopus.org/download/KOPUB2.0_TTF_FONTS.zip'
    Expand-Archive  -LiteralPath "$tempDir\KOPUB2.0_TTF_FONTS.zip" -DestinationPath "$tempDir\fonts"
    Get-ChildItem "$tempDir\fonts" | Where-Object {($_.Extension -ne '.otf') -And ($_.Extension -ne '.ttf')} | Remove-Item

    $shell = New-Object -ComObject Shell.Application
    $shell.Namespace(0x14).CopyHere($shell.Namespace("$tempDir\fonts").Items())
    Write-Color "{green}[INFO] 폰트 설치 완료"

    Remove-Item "$tempDir" -Recurse -Force
}
elseif ($mode -eq 'path') {
    Add-To-Path
}
elseif ($mode -eq 'update-sty') {
    Update-Sty
}
elseif ($mode -eq 'update-tool') {
    Update-Tool
}
elseif ($mode -eq 'new') {
    New-Item -ItemType Directory -Force -Path "$rootDir\src" | Out-Null

    if (($no) -and ($no -gt 0)) {
        if (Test-Path "$rootDir\src\$no") {
            Write-Color "{red}[ERROR] $rootDir\src\$($no)이(가) 이미 존재합니다."
        }
        else {
            Write-Color "{yellow}[INFO] 새 Math Letter를 만드는 중..."
            New-Item -ItemType directory -Path "$rootDir\src\$no\articles" | Out-Null
            New-Item -ItemType directory -Path "$rootDir\src\$no\problems" | Out-Null
            New-Item -ItemType directory -Path "$rootDir\src\$no\cover" | Out-Null
            New-Item -ItemType directory -Path "$rootDir\src\$no\build" | Out-Null
        }
    }
    else {
        Write-Color "{red}[ERROR] ML 번호가 주어지지 않았습니다."
        Write-Color ""
        Print-Help
    }
}
elseif ($mode -eq 'article') {
    New-Item -ItemType Directory -Force -Path "$rootDir\src" | Out-Null

    if (($no) -and ($no -gt 0)) {
        if ($slug) {
            if ((Test-Path "$rootDir\src\$no\articles") -and (Test-Path "$rootDir\src\$no\build")) {
                if (Test-Path "$rootDir\src\$no\articles\$slug") {
                    Write-Color "{red}[ERROR] 아티클 $($slug)이(가) 이미 존재합니다."
                    Write-Color ""
                    Print-Help
                }
                else {
                    Write-Color "{yellow}[INFO] ML$($no)에 새 아티클을 만드는 중..."
                    New-Item -ItemType directory -Path "$rootDir\src\$no\articles\$slug" | Out-Null
                    Set-Content -Path "$rootDir\src\$no\articles\$slug\$slug.tex" -Value $sampleTeXContent
                    Set-Content -Path "$rootDir\src\$no\articles\$slug\$slug.bib" -Value $sampleBibContent
                }
            }
            else {
                Write-Color "{red}[ERROR] ML $no 폴더가 존재하지 않습니다."
                Write-Color ""
                Print-Help
            }
        }
        else {
            Write-Color "{red}[ERROR] 아티클 폴더 이름이 주어지지 않았습니다."
            Write-Color ""
            Print-Help
        }
    }
    else {
        Write-Color "{red}[ERROR] ML 번호가 주어지지 않았습니다."
        Write-Color ""
        Print-Help
    }
}
elseif ($mode -eq 'compile') {
    New-Item -ItemType Directory -Force -Path "$rootDir\src" | Out-Null

    if (($no) -and ($no -gt 0)) {
        if ($slug) {
            if ((Test-Path "$rootDir\src\$no\articles") -and (Test-Path "$rootDir\src\$no\build")) {
                if (Test-Path "$rootDir\src\$no\articles\$slug") {
                    Set-Location "$rootDir\src\$no\articles\$slug"
                    
                    Write-Color "{yellow}[INFO] ML$($no)의 아티클 $($slug)을(를) 조판하는 중..."
                    Start-Process `
                        -NoNewWindow -Wait `
                        -FilePath "$rootDir\texlive\$TEXLIVE_VERSION\bin\win32\xelatex.exe" `
                        -ArgumentList "$slug.tex"
                    if ($single -eq $false) {
                        Start-Process `
                            -NoNewWindow -Wait `
                            -FilePath "$rootDir\texlive\$TEXLIVE_VERSION\bin\win32\bibtex.exe" `
                            -ArgumentList "$slug.aux"
                        Start-Process `
                            -NoNewWindow -Wait `
                            -FilePath "$rootDir\texlive\$TEXLIVE_VERSION\bin\win32\xelatex.exe" `
                            -ArgumentList "$slug.tex"
                    }

                    Copy-Item "$rootDir\src\$no\articles\$slug\$slug.pdf" -Destination "$rootDir\src\$no\build"
                }
                else {
                    Write-Color "{red}[ERROR] 아티클 $($slug)이 존재하지 않습니다."
                    Write-Color ""
                    Print-Help
                }
            }
            else {
                Write-Color "{red}[ERROR] ML $no 폴더가 존재하지 않습니다."
                Write-Color ""
                Print-Help
            }
        }
        else {
            Write-Color "{yellow}[INFO] ML$($no)의 모든 아티클을 조판하는 중..."
            Get-ChildItem "$rootDir\src\$no\articles" | ForEach-Object {
                $slug = $_.BaseName
                Set-Location "$rootDir\src\$no\articles\$slug"

                Write-Color "{yellow}[INFO] ML$($no)의 아티클 $($slug)을(를) 조판하는 중..."
                Start-Process `
                    -NoNewWindow -Wait `
                    -FilePath "$rootDir\texlive\$TEXLIVE_VERSION\bin\win32\xelatex.exe" `
                    -ArgumentList "$slug.tex"
                if ($single -eq $false) {
                    Start-Process `
                        -NoNewWindow -Wait `
                        -FilePath "$rootDir\texlive\$TEXLIVE_VERSION\bin\win32\bibtex.exe" `
                        -ArgumentList "$slug.aux"
                    Start-Process `
                        -NoNewWindow -Wait `
                        -FilePath "$rootDir\texlive\$TEXLIVE_VERSION\bin\win32\xelatex.exe" `
                        -ArgumentList "$slug.tex"
                }

                Copy-Item "$rootDir\src\$no\articles\$slug\$slug.pdf" -Destination "$rootDir\src\$no\build"
            }
        }
    }
    else {
        Write-Color "{red}[ERROR] ML 번호가 주어지지 않았습니다."
        Write-Color ""
        Print-Help
    }
}
else {
    Write-Color "{red}[ERROR] 알 수 없는 모드입니다."
    Write-Color ""
    Print-Help
}

Set-Location $currentDir
