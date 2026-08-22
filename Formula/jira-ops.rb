class JiraOps < Formula
  desc "Predictable, agent-friendly CLI for Jira Cloud"
  homepage "https://github.com/amaljithkuttamath/jira-ops"
  version "0.2.0-beta.2"
  license any_of: ["MIT", "Apache-2.0"]

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/amaljithkuttamath/jira-ops/releases/download/v0.2.0-beta.2/jira-ops-v0.2.0-beta.2-aarch64-apple-darwin.tar.gz"
      sha256 "a61543add70d200a5d8ae7431276ccc226f383cda8201a99dd3c2b720bbcc53a"
    else
      url "https://github.com/amaljithkuttamath/jira-ops/releases/download/v0.2.0-beta.2/jira-ops-v0.2.0-beta.2-x86_64-apple-darwin.tar.gz"
      sha256 "8201332c33f1a08193e4851453c9d4892200419c2fd8c74775e67117e446dfb8"
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/amaljithkuttamath/jira-ops/releases/download/v0.2.0-beta.2/jira-ops-v0.2.0-beta.2-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "3a8844e14854a30d8601c81ac4b85e59bdb95cf343b211bc1ce8fe1fb41cdda4"
    else
      url "https://github.com/amaljithkuttamath/jira-ops/releases/download/v0.2.0-beta.2/jira-ops-v0.2.0-beta.2-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "c25133d914175a552f8e52f23a82737480381132864ed882404f33022707b29f"
    end
  end

  def install
    bin.install "jira-ops"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/jira-ops version")
  end
end
