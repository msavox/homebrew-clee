class Clee < Formula
  desc "Terminal IDE with file-tree sidebar, embedded terminals and syntax highlighting"
  homepage "https://github.com/msavox/cleecode"
  # Both values are printed in the release workflow's run summary ("Homebrew source
  # checksum"), so bumping a version is a copy/paste.
  url "https://github.com/msavox/cleecode/archive/refs/tags/v0.4.2.tar.gz"
  sha256 "6850b0e5d07bed32b3613d4c7da50e0fc36542239a5ff5188b524494e9edda75"
  license "MIT"
  head "https://github.com/msavox/cleecode.git", branch: "master"

  depends_on "rust" => :build

  # Homebrew on Linux builds this from source too, and the clipboard integration (arboard)
  # needs libxcb there — on macOS the system frameworks cover it.
  on_linux do
    depends_on "pkgconf" => :build
    depends_on "libxcb"
  end

  def install
    # Builds the [[bin]] named `clee` (the crate itself is `cleecode`).
    system "cargo", "install", *std_cargo_args
    # Keep the bundled Nerd Font with the install, so it stays available even if the
    # source tree is gone.
    pkgshare.install "assets/fonts"
    man1.install "docs/clee.1"
  end

  def caveats
    <<~EOS
      The file-tree icons need a Nerd Font. To install the bundled one for your user:
        clee --install-font

      A copy also lives at:
        #{opt_pkgshare}/fonts

      Previews are optional extras, not requirements — without them CleeCode
      simply shows less, rather than failing:
        brew install poppler     PDF pages (ghostscript also works)
        brew install pandoc typst  Markdown as a real document, pictures and all
        brew install chafa       pictures inside a terminal pane
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/clee --version")
    assert_match "USAGE", shell_output("#{bin}/clee --help")
  end
end
