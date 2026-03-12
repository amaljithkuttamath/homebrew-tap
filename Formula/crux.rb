class Crux < Formula
  desc "Terminal dashboard for AI coding tool token usage"
  homepage "https://github.com/amaljithkuttamath/crux"
  version "0.2.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/amaljithkuttamath/crux/releases/download/v0.2.0/crux-macos-arm64.tar.gz"
      sha256 "34d56807ce40451327e8791eace305b7ead0e56c85b71117f8badabe39142b60"
    else
      url "https://github.com/amaljithkuttamath/crux/releases/download/v0.2.0/crux-macos-amd64.tar.gz"
      sha256 "c494b61bb558622022c523ee2525119ff126afeb86d07f53cae80ed4e70991f2"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/amaljithkuttamath/crux/releases/download/v0.2.0/crux-linux-arm64.tar.gz"
      sha256 "abb0c13bbbbe99b7d8f63b2f8de2d99b6f563eec370554fd4f46cc254dcc4a2d"
    else
      url "https://github.com/amaljithkuttamath/crux/releases/download/v0.2.0/crux-linux-amd64.tar.gz"
      sha256 "ad4e04c32982518ed3d952578b7dc2bacd277355c1c6a5a911f3b4efcaeac42f"
    end
  end

  def install
    bin.install "crux"
  end

  test do
    assert_match "crux", shell_output("#{bin}/crux --help")
  end
end
