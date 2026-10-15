[![Target build (arm64)](https://github.com/RameshPrajwal/Infotainment-Prototype/actions/workflows/target-build.yml/badge.svg)](https://github.com/RameshPrajwal/Infotainment-Prototype/actions/workflows/target-build.yml)

This project aims at re-creating an application explained in these tutorial videos and learn about Qt frameworks: 

https://youtu.be/Tq-E6lqO6tM?si=buVVUFjIKHS056tV

https://youtu.be/MEdJNc1tfwE?si=3rhBgMDuuJJISZMt


The present implementation UI status:  ![present_UI_implementation](present_UI_implementation.gif)

## Builds

| Build | Platform | How |
|---|---|---|
| Desktop | Linux / Windows / macOS, Qt 6.5+ with Qt Location | Open `TestPrototype.pro` or `CMakeLists.txt` in Qt Creator |
| Target | Raspberry Pi 4/5, Raspberry Pi OS Trixie 64-bit (Qt 6.8) | Built automatically by GitHub Actions, or cross-compiled from Qt Creator |

The target build, cross-compiling, testing on a QEMU virtual board without hardware,
and deploying to a Raspberry Pi with autostart are described in
**[docs/target-build.md](docs/target-build.md)**.

Download the latest arm64 build and its startup screenshot from the
[Actions tab](https://github.com/RameshPrajwal/Infotainment-Prototype/actions/workflows/target-build.yml)
(open a run → **Artifacts**), or from [Releases](https://github.com/RameshPrajwal/Infotainment-Prototype/releases) for tagged versions.
