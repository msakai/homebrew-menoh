class Menoh < Formula
  desc "DNN inference library with MKL-DNN"
  homepage "https://github.com/pfnet-research/menoh/"
  # pull from git tag to get submodules
  url "https://github.com/pfnet-research/menoh.git",
      tag:      "v1.1.1",
      revision: "1b8e00f80e4342043097f5336d6f656951249308"
  revision 1
  head "https://github.com/pfnet-research/menoh.git"

  bottle do
    root_url "https://github.com/msakai/homebrew-menoh/releases/download/menoh-1.1.1_1"
    sha256 cellar: :any,                 catalina:     "bb1bd38662a761eb802958ebdc653ac4cba5f56e39c5818917c1a972c3127d2d"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "4ca6ee7b799454179340481d8b14aee22463e87a73f7550294c1a02806c7d4c2"
  end

  keg_only "it conflicts with the onednn formula"

  depends_on "cmake" => :build
  depends_on "protobuf"

  resource "mkldnn" do
    url "https://github.com/intel/mkl-dnn/archive/v0.16.tar.gz"
    sha256 "bbde839f5100855577cb781fc5c69e9661f2fdbab6b4da8ebe660fb887d00429"
  end

  def install
    resource("mkldnn").stage do
      system "cmake",
             "-DCMAKE_BUILD_TYPE=Release",
             "-DWITH_TEST=OFF",
             "-DWITH_EXAMPLE=OFF",
             "-DARCH_OPT_FLAGS=''",
             "-DCMAKE_INSTALL_RPATH=#{rpath}",
             "-Wno-error=unused-result",
              ".", *std_cmake_args
      system "make", "install"
    end

    system "cmake", ".", "-DENABLE_EXAMPLE=OFF", "-DCMAKE_INSTALL_RPATH=#{rpath}", *std_cmake_args
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include <stdio.h>
      #include <string.h>
      #include <menoh/menoh.h>

      int main()
      {
          return !(strlen(menoh_get_last_error_message())==0);
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lmenoh", "-o", "test"
    system "./test"
  end
end
