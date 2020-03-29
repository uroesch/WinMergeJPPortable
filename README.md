[![Build](https://github.com/uroesch/WinMergeJPPortable/workflows/build-package/badge.svg)](https://github.com/uroesch/WinMergeJPPortable/actions?query=workflow%3Abuild-package)
[![GitHub release (latest by date including pre-releases)](https://img.shields.io/github/v/release/uroesch/WinMergeJPPortable?include_prereleases)](https://github.com/uroesch/WinMergeJPPortable/releases)
[![Runs on](https://img.shields.io/badge/runs%20on-Win64%20%26%20Win32-blue)](#runtime-dependencies)

# WinMergeJP Portable for PortableApps.com

<img src="App/AppInfo/appicon_128.png" align=left>

[WinMergeJP](https://winmergejp.bitbucket.io/)  is an Open Source visual text
file differencing and merging tool for Win32 platforms. It is highly useful
for determing what has changed between project versions, and then merging 
changes between versions. It features visual differencing and merging of text 
files, a flexible editor with syntax highlighting, line numbers and word-wrap 
and handles DOS, UNIX and MAC text file formats. It also includes full support 
for archives with the bundled 7-Zip plugin. Both the 32-bit and 64-bit versions 
are included for maximum performance on every PC.

## Runtime dependencies
* 32-bit or 64-bit version of Windows.

## Status 
This PortableApps project is in beta stage. 

## Todo
- [ ] Documentation

## Build

### Prerequisites

* [PortableApps.com Launcher](https://portableapps.com/apps/development/portableapps.com_launcher)
* [PortableApps.com Installer](https://portableapps.com/apps/development/portableapps.com_installer)
* [Powershell](https://docs.microsoft.com/en-us/powershell/scripting/install/installing-powershell-core-on-linux?view=powershell-7)
* [Wine (Linux / MacOS only)](https://www.winehq.org/)

### Build

To build the installer run the following command in the root of the git repository.

```
powershell Other/Update/Update.ps1
```
