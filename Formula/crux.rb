class Crux < Formula
  desc "Terminal dashboard and menu bar monitor for AI coding tool token usage"
  homepage "https://github.com/amaljithkuttamath/crux"
  version "0.5.0"
  license "MIT"

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/amaljithkuttamath/crux/releases/download/v0.5.0/crux-macos-arm64.tar.gz"
      sha256 "58f480b86c372f95366b0de8050bf5662b8685e22a01381d8f62cd436faafdab"
    else
      url "https://github.com/amaljithkuttamath/crux/releases/download/v0.5.0/crux-macos-amd64.tar.gz"
      sha256 "a1a621463d37e8f802dfa9a1b445c757a8464995f520b7cf1928c35f7267b529"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/amaljithkuttamath/crux/releases/download/v0.5.0/crux-linux-arm64.tar.gz"
      sha256 "06777f0137aeeb144d6b02bbb88959673b0333c3f4f1dbe156868dd05b1721ce"
    else
      url "https://github.com/amaljithkuttamath/crux/releases/download/v0.5.0/crux-linux-amd64.tar.gz"
      sha256 "1a28e751c419c85431664dd226e3479013892c1e25158c79194037d6cce78b5e"
    end
  end

  def install
    bin.install "crux"

    if OS.mac? && File.directory?("CruxBar.app")
      prefix.install "CruxBar.app"
    end
  end

  def caveats
    if OS.mac?
      <<~EOS
        CruxBar (menu bar monitor) has been installed to:
          #{prefix}/CruxBar.app

        To launch:
          open #{prefix}/CruxBar.app

        To start at login:
          Add CruxBar to System Settings > General > Login Items
      EOS
    end
  end

  test do
    assert_match "crux", shell_output("#{bin}/crux --help")
  end
end
