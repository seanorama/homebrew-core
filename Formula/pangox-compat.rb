class PangoxCompat < Formula
  desc "Library for laying out and rendering of text"
  homepage "http://pango.org"
  url "https://download.gnome.org/sources/pangox-compat/0.0/pangox-compat-0.0.2.tar.xz"
  sha256 "552092b3b6c23f47f4beee05495d0f9a153781f62a1c4b7ec53857a37dfce046"
  revision 1

  bottle do
    sha256 "206ca566f90950e25b78b5494328f2d047710f2a79986aa3a8c905f6ef47974b" => :el_capitan
    sha256 "0436736de80b61ef5f88ef01c82df32a5c9115a82b421fa610efae2fe1f7ab9d" => :yosemite
    sha256 "e819755afd6ba06780fd14adc5a20f53b3b47c26adbd1219c26a4f0ec9f5abbd" => :mavericks
  end

  depends_on "pkg-config" => :build
  depends_on "pango"
  depends_on :x11

  def install
    system "./configure", "--disable-dependency-tracking", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <pango/pangox.h>
      #include <string.h>

      int main(int argc, char *argv[]) {
        return strcmp(PANGO_RENDER_TYPE_X, "PangoRenderX");
      }
    EOS
    gettext = Formula["gettext"]
    glib = Formula["glib"]
    pango = Formula["pango"]
    flags = (ENV.cflags || "").split + (ENV.cppflags || "").split + (ENV.ldflags || "").split
    flags += %W[
      -I#{gettext.opt_include}
      -I#{glib.opt_include}/glib-2.0
      -I#{glib.opt_lib}/glib-2.0/include
      -I#{include}/pango-1.0
      -I#{pango.opt_include}/pango-1.0
      -I#{MacOS::X11.include}
      -D_REENTRANT
      -L#{gettext.opt_lib}
      -L#{glib.opt_lib}
      -L#{lib}
      -L#{pango.opt_lib}
      -L#{MacOS::X11.lib}
      -lX11
      -lglib-2.0
      -lgobject-2.0
      -lintl
      -lpango-1.0
      -lpangox-1.0
    ]
    system ENV.cc, "test.c", "-o", "test", *flags
    system "./test"
  end
end
