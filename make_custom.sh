#!/bin/bash -x

# This is an example/reference compilation script. It works given a directory layout similar to:
# ../01_fdk-aac
# ../02_x264
# ../03_libav
# ../04_avconv_LUA_wrapper
# ../BUILD
# ../BUILD/lib
# It has been compiled in Ubuntu Linux 13.10 AMD64 with (Same host and build machine)

export LC_ALL=C
LIBAV_DIR=../03_libav         # <- An already compiled libav version is supposed to be already there
LUA_DIR=../01_lua-5.1.5/src   # <- liblua.a is supposed to be already there
DST_DIR=../BUILD/lib          # liblua_avconv.so will be placed here

if [ ! -d ${DST_DIR} ]; then
    mkdir -p ${DST_DIR}
fi
if [ ! -f ${LIBAV_DIR}/cmdutils.o ]; then
    echo "ERROR: Couldn't find a proper libav compilation in directory indicated. Check LIBAV_DIR value (${LIBAV_DIR})"
    exit 1
fi

DEBUG="-O0 -g" # Weird things happens whith -O2/O3 when debugging.
# DEBUG="-O3"

mv liblua_avconv.so liblua_avconv.so.0
mv ${DST_DIR}/liblua_avconv.so    ${DST_DIR}/liblua_avconv.so.0
gcc -g -O1 -D_GNU_SOURCE -I. -I${LIBAV_DIR} -I${LUA_DIR} -D_FORTIFY_SOURCE=2 -D_ISOC99_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_POSIX_C_SOURCE=200112 -D_XOPEN_SOURCE=600 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security  -std=c99 -fomit-frame-pointer -pthread -Wdeclaration-after-statement -Wall -Wdisabled-optimization -Wpointer-arith -Wredundant-decls -Wcast-qual -Wwrite-strings -Wtype-limits -Wundef -Wmissing-prototypes -Wstrict-prototypes -Wno-parentheses -Wno-switch -Wno-format-zero-length -Wno-pointer-sign -fno-math-errno -fno-signed-zeros -fno-tree-vectorize -Werror=implicit-function-declaration -Werror=missing-prototypes -Werror=return-type -Werror=declaration-after-statement -Werror=vla   -MMD -MF lua_avconv.d -MT lua_avconv.o -c -o lua_avconv.o lua_avconv.c ${CFLAGS}

if [[ $? != 0 ]]; then
    echo "\n\n\n"
    echo "Compilation failed"
    echo "\n\n\n"
    exit 1
fi

gcc -g --shared -L${DST_DIR} -L${LIBAV_DIR}/libavcodec -L${LIBAV_DIR}/libavdevice -L${LIBAV_DIR}/libavfilter -L${LIBAV_DIR}/libavformat -L${LIBAV_DIR}/libavresample -L${LIBAV_DIR}/libavutil -L${LIBAV_DIR}/libswscale  -Wl,-Bsymbolic-functions -Wl,-z,relro -lx264 -lfdk-aac -Wl,--as-needed -Wl,--warn-common -Wl,-rpath-link=libswscale:libavfilter:libavdevice:libavformat:libavcodec:libavutil:libavresample  -o liblua_avconv.so ${LIBAV_DIR}/cmdutils.o ${LIBAV_DIR}/avconv_opt.o ${LIBAV_DIR}/avconv_filter.o lua_avconv.o -L${LUA_DIR} -llua -lavdevice -lavfilter -lavformat -lavresample -lavcodec -lswscale -lavutil -lx264 -lva -lm -lz -pthread  

echo "Copying now liblua_avconv.so to target lib directory:"
cp liblua_avconv.so ${DST_DIR}/liblua_avconv.so
