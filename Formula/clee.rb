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
      url "https://github.com/msavox/cleecode/releases/download/v0.28.1/clee-v0.28.1-macos-arm64.tar.gz"
      sha256 "401e3a0591d8cb77b9796001f3279c3cdfbf669453c0ba4914e61c14ca73dd6b"
    end
    on_intel do
      url "https://github.com/msavox/cleecode/releases/download/v0.28.1/clee-v0.28.1-macos-x86_64.tar.gz"
      sha256 "5f4087be4325bee4e9e0dfb3936b5ab685afa7baf631eb7fef3ef84c600eeb30"
    end
  end

  on_linux do
    on_arm do
      url "https://github.com/msavox/cleecode/releases/download/v0.28.1/clee-v0.28.1-linux-arm64.tar.gz"
      sha256 "eae7b5b0a3a205b56349306ec0499d61f86555f9dad7a5e3249c03e790186a65"
    end
    on_intel do
      url "https://github.com/msavox/cleecode/releases/download/v0.28.1/clee-v0.28.1-linux-x86_64.tar.gz"
      sha256 "84e09a552901d9450ecec924927283f24fb09e731beec12118aed3d34e41c457"
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
