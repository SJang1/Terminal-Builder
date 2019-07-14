# Windows Terminal builder
Windows Terminal builder builds [windows terminal](https://github.com/microsoft/terminal) automactally.

## Prerequirements
All of the [Prerequirements on Windows Terminal](https://github.com/microsoft/terminal/blob/master/README.md#build-prerequisites)

..But I'll notify you when to do this : Opening the solution will [prompt you to install missing components automatically](https://devblogs.microsoft.com/setup/configure-visual-studio-across-your-organization-with-vsconfig/).

p.s.) You can use Visual Studio 2019 install config file [vsconfig](https://github.com/SJang1/Terminal-Builder/blob/master/vsconfig). It is on date 2019.07.14 and windows version 18936.1000(20H1 Preview).

## How to do?
First of all, Download **Make-Terminal.bat**
* run **Make-Terminal.bat** or **Make-Terminal.bat rel** to build Release.
* run **Make-Terminal.bat dbg** to build Debug.

After all of progress, source is under C:\terminal and batch file will tell you the exe file path.

## DO NOT...
* DO NOT run the file at C:\terminal\ (or in there) folder.
* DO NOT run with Windows Terminal. It will be killed.

## Update?
It will update Terminal if it exists. When updating, you can't use windows terminal.

## FAQ
Can I fix the path? => Not yet, Probley later. It has a small problem for it. ~~I am too lazy to fix it~~
