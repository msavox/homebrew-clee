# msavox/homebrew-clee

Homebrew tap for [CleeCode](https://github.com/msavox/cleecode) — `clee`, a terminal IDE with
a file-tree sidebar, embedded terminals, syntax highlighting and a run button.

## Install

```bash
brew install msavox/clee/clee
```

Then, for the file-tree icons (they need a Nerd Font):

```bash
clee --install-font
```

Restart your terminal afterwards.

## What this builds

The formula builds from source (`depends_on "rust" => :build`), so one recipe covers Apple
Silicon, Intel and Homebrew on Linux without maintaining bottles. On Linux it also pulls
`libxcb`, which the clipboard integration links against.

macOS is the supported platform. Linux works as far as CI can tell — it compiles, installs
and starts — but the editor has had no interactive testing there yet, so treat it as
experimental and report what breaks in the
[main repo](https://github.com/msavox/cleecode/issues).

Prebuilt binaries (macOS arm64/x86_64, Linux x86_64, Windows x86_64) are attached to each
[release](https://github.com/msavox/cleecode/releases) for anyone who would rather not build.

## Updating this tap for a new release

The release workflow in the main repo prints the two values to change (`url` and `sha256`) in
its run summary, under the "Homebrew source checksum" job. Copy them into
`Formula/clee.rb`, push, and the `Test formula` workflow here re-verifies the install on
macOS and Linux.
