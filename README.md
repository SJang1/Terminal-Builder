# Windows Terminal builder
Windows Terminal builder builds windows terminal automactally.

## Prerequirements
All of the [Prerequirements on Windows Terminal](https://github.com/microsoft/terminal/blob/master/README.md#build-prerequisites)

..But I'll notify you when to do this : Opening the solution will [prompt you to install missing components automatically](https://devblogs.microsoft.com/setup/configure-visual-studio-across-your-organization-with-vsconfig/).

## How to do?
Download and run Make-Terminal.bat **but with not Windows Terminal or not on C:\\terminal\\**
* run **Make-Terminal.bat** or **Make-Terminal.bat rel** to build Release.
* run **Make-Terminal.bat dbg** to build Debug.

It will update Terminal if it exists. When updating, you can't use windows terminal.