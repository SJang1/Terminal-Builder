# Windows Terminal builder
Windows Terminal builder builds [windows terminal](https://github.com/microsoft/terminal) (semi)automatically.

## Prerequirements
[Git for Windows](https://git-scm.com/downloads/win)

All of the [Prerequirements on Windows Terminal](https://github.com/microsoft/terminal/blob/master/README.md#build-prerequisites) 
but I'll notify you when to do this : Opening the solution will prompt you to install missing components automatically ...or you can install using [vsconfig](https://github.com/SJang1/Terminal-Builder/blob/master/vsconfig) which has all the components made by me on 07.14.2019.

## How to do?
First of all, Download **Make-Terminal.bat**
* run **Make-Terminal.bat** to build Release.
* run **Make-Terminal.bat /D** to build Debug.
* use **--dir Directory** to make terminal not on C:\terminal.
* use **--git git-URL** for not to use [Microsoft/terminal](https://github.com/microsoft/terminal) git.

After all of progress, source is under C:\terminal or (Your-choice)\terminal and batch file will tell you the exe file path.

## DO NOT...
* DO NOT run the file at C:\terminal\ (or in there) folder.
* DO NOT run with Windows Terminal. It will be killed.

## Update?
It will update Terminal if it exists. When updating, you can't use windows terminal.

## FAQ
Can I fix the path? => Not yet, Probley later. It has a small problem for it. ~~I am too lazy to fix it~~
