diff --git a/CMakeLists.txt b/CMakeLists.txt
index 3c890c8..ec8e877 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -1,5 +1,5 @@
 cmake_minimum_required(VERSION 3.0)
-project(double-conversion VERSION 3.0.0)
+project(double-conversion-tf VERSION 3.0.0)
 
 set(headers
     double-conversion/bignum.h
@@ -12,7 +12,7 @@ set(headers
     double-conversion/strtod.h
     double-conversion/utils.h)
 
-add_library(double-conversion
+add_library(double-conversion-tf
             double-conversion/bignum.cc
             double-conversion/bignum-dtoa.cc
             double-conversion/cached-powers.cc
@@ -23,11 +23,11 @@ add_library(double-conversion
             double-conversion/strtod.cc
             ${headers})
 target_include_directories(
-    double-conversion PUBLIC
+    double-conversion-tf PUBLIC
     $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>)
 
 # pick a version #
-set_property(TARGET double-conversion PROPERTY SOVERSION ${PROJECT_VERSION})
+set_property(TARGET double-conversion-tf PROPERTY SOVERSION ${PROJECT_VERSION})
 
 # set up testing if requested
 option(BUILD_TESTING "Build test programs" OFF)
@@ -79,7 +79,7 @@ configure_package_config_file(
 #   * header location after install: <prefix>/include/double-conversion/*.h
 #   * headers can be included by C++ code `#include <double-conversion/*.h>`
 install(
-    TARGETS double-conversion
+    TARGETS double-conversion-tf
     EXPORT "${targets_export_name}"
     LIBRARY DESTINATION "lib"
     ARCHIVE DESTINATION "lib"
@@ -91,7 +91,7 @@ install(
 #   * double-conversion/*.h -> <prefix>/include/double-conversion/*.h
 install(
     FILES ${headers}
-    DESTINATION "${include_install_dir}/double-conversion"
+    DESTINATION "${include_install_dir}/double-conversion-tf"
 )
 
 # Config
diff --git a/double-conversion/bignum-dtoa.cc b/double-conversion/bignum-dtoa.cc
index 526f96e..d5093c2 100644
--- a/double-conversion/bignum-dtoa.cc
+++ b/double-conversion/bignum-dtoa.cc
@@ -27,10 +27,10 @@
 
 #include <cmath>
 
-#include <double-conversion/bignum-dtoa.h>
+#include <double-conversion-tf/bignum-dtoa.h>
 
-#include <double-conversion/bignum.h>
-#include <double-conversion/ieee.h>
+#include <double-conversion-tf/bignum.h>
+#include <double-conversion-tf/ieee.h>
 
 namespace double_conversion {
 
diff --git a/double-conversion/bignum-dtoa.h b/double-conversion/bignum-dtoa.h
index 9d15ce3..4c9f2a0 100644
--- a/double-conversion/bignum-dtoa.h
+++ b/double-conversion/bignum-dtoa.h
@@ -28,7 +28,7 @@
 #ifndef DOUBLE_CONVERSION_BIGNUM_DTOA_H_
 #define DOUBLE_CONVERSION_BIGNUM_DTOA_H_
 
-#include <double-conversion/utils.h>
+#include <double-conversion-tf/utils.h>
 
 namespace double_conversion {
 
diff --git a/double-conversion/bignum.cc b/double-conversion/bignum.cc
index a7bc86d..7804560 100644
--- a/double-conversion/bignum.cc
+++ b/double-conversion/bignum.cc
@@ -25,8 +25,8 @@
 // (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 // OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
-#include <double-conversion/bignum.h>
-#include <double-conversion/utils.h>
+#include <double-conversion-tf/bignum.h>
+#include <double-conversion-tf/utils.h>
 
 namespace double_conversion {
 
diff --git a/double-conversion/bignum.h b/double-conversion/bignum.h
index 238a351..2107fe1 100644
--- a/double-conversion/bignum.h
+++ b/double-conversion/bignum.h
@@ -28,7 +28,7 @@
 #ifndef DOUBLE_CONVERSION_BIGNUM_H_
 #define DOUBLE_CONVERSION_BIGNUM_H_
 
-#include <double-conversion/utils.h>
+#include <double-conversion-tf/utils.h>
 
 namespace double_conversion {
 
diff --git a/double-conversion/cached-powers.cc b/double-conversion/cached-powers.cc
index 6f771e9..4467548 100644
--- a/double-conversion/cached-powers.cc
+++ b/double-conversion/cached-powers.cc
@@ -29,9 +29,9 @@
 #include <cmath>
 #include <cstdarg>
 
-#include <double-conversion/utils.h>
+#include <double-conversion-tf/utils.h>
 
-#include <double-conversion/cached-powers.h>
+#include <double-conversion-tf/cached-powers.h>
 
 namespace double_conversion {
 
diff --git a/double-conversion/cached-powers.h b/double-conversion/cached-powers.h
index eabff4a..2af46dd 100644
--- a/double-conversion/cached-powers.h
+++ b/double-conversion/cached-powers.h
@@ -28,7 +28,7 @@
 #ifndef DOUBLE_CONVERSION_CACHED_POWERS_H_
 #define DOUBLE_CONVERSION_CACHED_POWERS_H_
 
-#include <double-conversion/diy-fp.h>
+#include <double-conversion-tf/diy-fp.h>
 
 namespace double_conversion {
 
diff --git a/double-conversion/diy-fp.cc b/double-conversion/diy-fp.cc
index 82b0d08..88c0458 100644
--- a/double-conversion/diy-fp.cc
+++ b/double-conversion/diy-fp.cc
@@ -26,8 +26,8 @@
 // OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 
-#include <double-conversion/diy-fp.h>
-#include <double-conversion/utils.h>
+#include <double-conversion-tf/diy-fp.h>
+#include <double-conversion-tf/utils.h>
 
 namespace double_conversion {
 
diff --git a/double-conversion/diy-fp.h b/double-conversion/diy-fp.h
index e2011d4..bbaaf22 100644
--- a/double-conversion/diy-fp.h
+++ b/double-conversion/diy-fp.h
@@ -28,7 +28,7 @@
 #ifndef DOUBLE_CONVERSION_DIY_FP_H_
 #define DOUBLE_CONVERSION_DIY_FP_H_
 
-#include <double-conversion/utils.h>
+#include <double-conversion-tf/utils.h>
 
 namespace double_conversion {
 
diff --git a/double-conversion/double-conversion.cc b/double-conversion/double-conversion.cc
index feabe1f..4267b95 100644
--- a/double-conversion/double-conversion.cc
+++ b/double-conversion/double-conversion.cc
@@ -29,14 +29,14 @@
 #include <locale>
 #include <cmath>
 
-#include <double-conversion/double-conversion.h>
-
-#include <double-conversion/bignum-dtoa.h>
-#include <double-conversion/fast-dtoa.h>
-#include <double-conversion/fixed-dtoa.h>
-#include <double-conversion/ieee.h>
-#include <double-conversion/strtod.h>
-#include <double-conversion/utils.h>
+#include <double-conversion-tf/double-conversion.h>
+
+#include <double-conversion-tf/bignum-dtoa.h>
+#include <double-conversion-tf/fast-dtoa.h>
+#include <double-conversion-tf/fixed-dtoa.h>
+#include <double-conversion-tf/ieee.h>
+#include <double-conversion-tf/strtod.h>
+#include <double-conversion-tf/utils.h>
 
 namespace double_conversion {
 
diff --git a/double-conversion/double-conversion.h b/double-conversion/double-conversion.h
index 1ccd7fc..59fb306 100644
--- a/double-conversion/double-conversion.h
+++ b/double-conversion/double-conversion.h
@@ -28,7 +28,7 @@
 #ifndef DOUBLE_CONVERSION_DOUBLE_CONVERSION_H_
 #define DOUBLE_CONVERSION_DOUBLE_CONVERSION_H_
 
-#include <double-conversion/utils.h>
+#include <double-conversion-tf/utils.h>
 
 namespace double_conversion {
 
diff --git a/double-conversion/fast-dtoa.cc b/double-conversion/fast-dtoa.cc
index e5c2222..5ba79da 100644
--- a/double-conversion/fast-dtoa.cc
+++ b/double-conversion/fast-dtoa.cc
@@ -25,11 +25,11 @@
 // (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 // OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
-#include <double-conversion/fast-dtoa.h>
+#include <double-conversion-tf/fast-dtoa.h>
 
-#include <double-conversion/cached-powers.h>
-#include <double-conversion/diy-fp.h>
-#include <double-conversion/ieee.h>
+#include <double-conversion-tf/cached-powers.h>
+#include <double-conversion-tf/diy-fp.h>
+#include <double-conversion-tf/ieee.h>
 
 namespace double_conversion {
 
diff --git a/double-conversion/fast-dtoa.h b/double-conversion/fast-dtoa.h
index ac4317c..66f5fae 100644
--- a/double-conversion/fast-dtoa.h
+++ b/double-conversion/fast-dtoa.h
@@ -28,7 +28,7 @@
 #ifndef DOUBLE_CONVERSION_FAST_DTOA_H_
 #define DOUBLE_CONVERSION_FAST_DTOA_H_
 
-#include <double-conversion/utils.h>
+#include <double-conversion-tf/utils.h>
 
 namespace double_conversion {
 
diff --git a/double-conversion/fixed-dtoa.cc b/double-conversion/fixed-dtoa.cc
index 8c111ac..400b361 100644
--- a/double-conversion/fixed-dtoa.cc
+++ b/double-conversion/fixed-dtoa.cc
@@ -27,8 +27,8 @@
 
 #include <cmath>
 
-#include <double-conversion/fixed-dtoa.h>
-#include <double-conversion/ieee.h>
+#include <double-conversion-tf/fixed-dtoa.h>
+#include <double-conversion-tf/ieee.h>
 
 namespace double_conversion {
 
diff --git a/double-conversion/fixed-dtoa.h b/double-conversion/fixed-dtoa.h
index a9436fc..015d402 100644
--- a/double-conversion/fixed-dtoa.h
+++ b/double-conversion/fixed-dtoa.h
@@ -28,7 +28,7 @@
 #ifndef DOUBLE_CONVERSION_FIXED_DTOA_H_
 #define DOUBLE_CONVERSION_FIXED_DTOA_H_
 
-#include <double-conversion/utils.h>
+#include <double-conversion-tf/utils.h>
 
 namespace double_conversion {
 
diff --git a/double-conversion/ieee.h b/double-conversion/ieee.h
index baaeced..7e9e917 100644
--- a/double-conversion/ieee.h
+++ b/double-conversion/ieee.h
@@ -28,7 +28,7 @@
 #ifndef DOUBLE_CONVERSION_DOUBLE_H_
 #define DOUBLE_CONVERSION_DOUBLE_H_
 
-#include <double-conversion/diy-fp.h>
+#include <double-conversion-tf/diy-fp.h>
 
 namespace double_conversion {
 
diff --git a/double-conversion/strtod.cc b/double-conversion/strtod.cc
index 4392ae6..87dcc06 100644
--- a/double-conversion/strtod.cc
+++ b/double-conversion/strtod.cc
@@ -28,10 +28,10 @@
 #include <climits>
 #include <cstdarg>
 
-#include <double-conversion/bignum.h>
-#include <double-conversion/cached-powers.h>
-#include <double-conversion/ieee.h>
-#include <double-conversion/strtod.h>
+#include <double-conversion-tf/bignum.h>
+#include <double-conversion-tf/cached-powers.h>
+#include <double-conversion-tf/ieee.h>
+#include <double-conversion-tf/strtod.h>
 
 namespace double_conversion {
 
diff --git a/double-conversion/strtod.h b/double-conversion/strtod.h
index 3226516..92a1201 100644
--- a/double-conversion/strtod.h
+++ b/double-conversion/strtod.h
@@ -28,7 +28,7 @@
 #ifndef DOUBLE_CONVERSION_STRTOD_H_
 #define DOUBLE_CONVERSION_STRTOD_H_
 
-#include <double-conversion/utils.h>
+#include <double-conversion-tf/utils.h>
 
 namespace double_conversion {
 
