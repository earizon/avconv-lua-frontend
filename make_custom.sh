#!/bin/bash -x

LIBAV_DIR=../03_libav
LUA_DIR=../04_lua-5.1.5/src

if [ ! -f ${LIBAV_DIR}/cmdutils.o ]; then
    echo "ERROR: Couldn't find a proper libav compilation in directory indicated. Check LIBAV_DIR value (${LIBAV_DIR})"
    exit 1
fi

mv liblua_avconv.so liblua_avconv.so.0
sudo rm -f /usr/local/viotech/lib/liblua_avconv.so
gcc -g -I. -I${LIBAV_DIR} -I${LUA_DIR} -D_FORTIFY_SOURCE=2 -D_ISOC99_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_POSIX_C_SOURCE=200112 -D_XOPEN_SOURCE=600 -g -O2 -fstack-protector --param=ssp-buffer-size=4 -Wformat -Werror=format-security -I/usr/local/viotech/include   -I/usr/local/viotech/include     -std=c99 -fomit-frame-pointer -pthread -g -Wdeclaration-after-statement -Wall -Wdisabled-optimization -Wpointer-arith -Wredundant-decls -Wcast-qual -Wwrite-strings -Wtype-limits -Wundef -Wmissing-prototypes -Wstrict-prototypes -Wno-parentheses -Wno-switch -Wno-format-zero-length -Wno-pointer-sign -O3 -fno-math-errno -fno-signed-zeros -fno-tree-vectorize -Werror=implicit-function-declaration -Werror=missing-prototypes -Werror=return-type -Werror=declaration-after-statement -Werror=vla   -MMD -MF lua_avconv.d -MT lua_avconv.o -c -o lua_avconv.o lua_avconv.c ${CFLAGS}

if [[ $? != 0 ]]; then
    echo "\n\n\n"
    echo "Compilation failed"
    echo "\n\n\n"
    exit 1
fi

gcc -g --shared -L../${LIBAV_DIR}/libavcodec -L../${LIBAV_DIR}/libavdevice -L../${LIBAV_DIR}/libavfilter -L../${LIBAV_DIR}/libavformat -L../${LIBAV_DIR}/libavresample -L../${LIBAV_DIR}/libavutil -L../${LIBAV_DIR}/libswscale  -Wl,-Bsymbolic-functions -Wl,-z,relro -L/usr/local/viotech/lib -lx264 -lfdk-aac -Wl,--as-needed -Wl,--warn-common -Wl,-rpath-link=libswscale:libavfilter:libavdevice:libavformat:libavcodec:libavutil:libavresample  -o liblua_avconv.so ${LIBAV_DIR}/cmdutils.o ${LIBAV_DIR}/avconv_opt.o ${LIBAV_DIR}/avconv_filter.o lua_avconv.o   -lavdevice -lavfilter -lavformat -lavresample -lavcodec -lswscale -lavutil -lx264 -lva -lm -lz -pthread  

echo "Copying now liblua_avconv.so to target lib directory:"
sudo cp liblua_avconv.so /usr/local/viotech/lib/liblua_avconv.so

