class Clee < Formula
  desc "Terminal IDE with file-tree sidebar, embedded terminals and syntax highlighting"
  homepage "https://cleecode.marunja.com"
  license "MIT"

  # `brew install --HEAD clee` still compiles master, which is the one case where there is no
  # binary to download — so the toolchain is asked for here and nowhere else.
  head do
    url "https://github.com/msavox/cleecode.git", branch: "master"
    depends_on "rust" => :build
    on_linux do
      depends_on "pkgconf" => :build
    end
  end

  # The release already builds a binary for every platform Homebrew runs on, so this installs
  # that instead of a Rust toolchain and a four-minute compile of syntect, image and ratatui.
  # `brew install clee` is now a download.
  #
  # Every checksum here is published beside its asset as a `.sha256` file, which is what
  # `scripts/bump.sh` reads — and it verifies the bytes rather than trusting that file. Do the
  # same if you ever fill these in by hand: check what you hashed is an archive first. A
  # `curl | shasum` while GitHub was answering 429 once put the hash of a 199-byte error page
  # in here, and a formula with the wrong checksum does not fail loudly — it downloads,
  # mismatches, and looks like a hung install.
  on_macos do
    on_arm do
      url "https://github.com/msavox/cleecode/releases/download/v0.28.3/clee-v0.28.3-macos-arm64.tar.gz"
      sha256 "e593b5731093374acee1efbe40e1985ef84ab04d90727779611e762945fd9668"
    end
    on_intel do
      url "https://github.com/msavox/cleecode/releases/download/v0.28.3/clee-v0.28.3-macos-x86_64.tar.gz"
      sha256 "4fe0402da1ee6b8912b7ecf1ea9f8ac4ca6d46546f53e3286f0c53866c9db12a"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/msavox/cleecode/releases/download/v0.28.3/clee-v0.28.3-linux-arm64.tar.gz"
      sha256 "a60a4c02dea360ca0085ce47a5d61e6b175939e0cd47b5af8ca8be942cac32d7"
    end
    on_intel do
      url "https://github.com/msavox/cleecode/releases/download/v0.28.3/clee-v0.28.3-linux-x86_64.tar.gz"
      sha256 "726f3c4613e80117385178c82e4ed8e06a6ca731ce175027e5351b846b9f74d4"
    end
    # The clipboard integration (arboard) links libxcb, and a prebuilt binary needs it at run
    # time rather than only at build time. On macOS the system frameworks cover it.
    depends_on "libxcb"
  end

  def install
    if build.head?
      # Builds the [[bin]] named `clee` (the crate itself is `cleecode`).
      system "cargo", "install", *std_cargo_args
      pkgshare.install "assets/fonts"
      man1.install "docs/clee.1"
    else
      # The release tarball carries the binary, the man page and the bundled Nerd Font, with
      # one directory at the top that Homebrew has already stripped.
      bin.install "clee"
      pkgshare.install "fonts"
      man1.install "clee.1"
    end
  end

  def caveats
    <<~EOS
      The file-tree icons need a Nerd Font. To install the bundled one for your user:
        clee --install-font

      A copy also lives at:
        #{opt_pkgshare}/fonts

      On macOS, to give CleeCode an icon in the Dock and let Finder open
      files with it (needs Ghostty, and builds the bundle locally so it
      arrives without Gatekeeper's quarantine):
        clee --install-app

      Previews are optional extras, not requirements — without them CleeCode
      simply shows less, rather than failing:
        brew install poppler     PDF pages (ghostscript also works)
        brew install pandoc typst  Markdown as a real document, pictures and all
        brew install chafa       pictures inside a terminal pane

      The numeric workspaces (clee -w octave, clee -w pylab) drive the
      interpreter you already have, and nothing is installed into it.
      Nothing here is bundled either:
        brew install octave      an Octave session to run cells in
        brew install gnuplot     plots from an Octave session with no display
                                 (a remote server over ssh) — it needs no X
        pip install matplotlib   plots from a Python session — it has to be
                                 the same python your terminal runs
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/clee --version")
    assert_match "USAGE", shell_output("#{bin}/clee --help")
  end
end
