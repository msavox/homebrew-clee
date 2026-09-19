# msavox/homebrew-clee

Homebrew tap for [CleeCode](https://github.com/msavox/cleecode) — `clee`, a terminal IDE with
a file-tree sidebar, embedded terminals, syntax highlighting and a run button.

## Install

```bash
brew tap msavox/clee
brew trust msavox/clee
brew install clee
```

All three steps are needed. A formula is Ruby code Homebrew runs on your machine, so recent
versions refuse to load one from a third-party tap until you trust its source — and tapping
does not imply trusting. Skipping it gives:

```
Error: Refusing to load formula msavox/clee/clee from untrusted tap msavox/clee.
```

The fully qualified `brew install msavox/clee/clee` avoids the `tap` step but still needs the
`trust` one. Those three parts are *user* / *tap* / *formula*; `clee` repeats only because the
tap and the command share a name. Afterwards `brew upgrade clee` and `brew uninstall clee`
work as usual.

Then, for the file-tree icons (they need a Nerd Font):

```bash
clee --install-font
```

Restart your terminal afterwards.

## What this installs

The binary the release already built, for whichever of the four platforms Homebrew is running
on: macOS arm64 and x86_64, Linux arm64 and x86_64. `brew install clee` is a download, not a
compile — there is no `depends_on "rust"`, so nobody drags in a toolchain to get an editor. On
Linux it pulls `libxcb`, which the clipboard integration links against and a prebuilt binary
needs at run time.

Bottles would be the Homebrew-native way to do this, and they are not used on purpose: a bottle
is tied to one macOS version, so they mean a build matrix and a new row every time Apple ships
a release. The four release tarballs cover every platform Homebrew supports and cost one script
run per version.

`brew install --HEAD clee` still compiles master, which is the one case with no binary to
download. That is where the Rust toolchain is asked for, and nowhere else.

macOS is the supported platform. Linux works as far as CI can tell — it installs and starts —
but the editor has had no interactive testing there yet, so treat it as experimental and report
what breaks in the [main repo](https://github.com/msavox/cleecode/issues).

## Updating this tap for a new release

```
scripts/bump.sh 0.28.2
```

That is the whole of it. Four platforms means four urls and four checksums, which is the price
of handing people a binary instead of a compile — so nothing is typed by hand: the release
publishes a `.sha256` beside every asset, and the script reads those.

It does not take them on trust. Every archive is downloaded and hashed, and the result is
compared with the published file, because the published file is only a claim. Each download is
checked to *be* an archive first: GitHub under load answers with a 200 and a two-line
"429: Too Many Requests" body, and that body has a perfectly good sha256. A formula with a wrong
checksum does not fail loudly — it downloads, mismatches, and looks to the user like a hung
install. That has happened here once.

Then push, and the `Test formula` workflow re-verifies the install on macOS and Linux.
