#!/bin/bash

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
LIBAV_DIR_VLC=../BUILD_WIN.VLC # <- An already compiled libav version is supposed to be already there
LUA_DIR=../01_lua-5.1.5/src   # <- liblua.a is supposed to be already there
DST_DIR=../BUILD_WIN/lib      # liblua_avconv.dll will be placed here

LIB_NAME="liblua_avconv"


if [ ! -d ${DST_DIR} ]; then
    mkdir -p ${DST_DIR}
fi
if [ ! -f ${LIBAV_DIR}/cmdutils.o ]; then
    echo "ERROR: Couldn't find a proper libav compilation in directory indicated. Check LIBAV_DIR value (${LIBAV_DIR})"
    exit 1
fi

DEBUG="-O0 -g" # Weird things happens whith -O2/O3 when debugging.
# DEBUG="-O3"
CC="/usr/bin/i686-w64-mingw32-gcc"
CC_PREPROCESSOR="-I. -I${LIBAV_DIR} -I${LUA_DIR} -I${LIBAV_DIR_VLC}"
# CC_PREPROCESSOR="${CC_PREPROCESSOR} -I /usr/include/x86_64-linux-gnu/"
CC_WARM="-Wformat -std=c99 -fomit-frame-pointer -Wdeclaration-after-statement -Wall -Wdisabled-optimization -Wpointer-arith -Wredundant-decls -Wcast-qual -Wwrite-strings -Wtype-limits -Wundef -Wmissing-prototypes -Wstrict-prototypes -Wno-parentheses -Wno-switch -Wno-format-zero-length -Wno-pointer-sign"
CC_ERROR="-Werror=implicit-function-declaration -Werror=missing-prototypes -Werror=return-type -Werror=declaration-after-statement -Werror=vla "
CC_EXTRA="--param=ssp-buffer-size=4  -fno-math-errno -fno-signed-zeros -fno-tree-vectorize "
C_FLAGS="-g ${DEBUG} -D_GNU_SOURCE  -D_FORTIFY_SOURCE=2 -D_ISOC99_SOURCE -D_FILE_OFFSET_BITS=64 -D_LARGEFILE_SOURCE -D_POSIX_C_SOURCE=200112 -D_XOPEN_SOURCE=600 "

C_FLAGS="${C_FLAGS} ${CC_PREPROCESSOR} ${CC_ERROR} ${CC_EXTRA}"
OUTPUT="lua_avconv.o"
INPUT="lua_avconv.c"
if [ -f ${LIB_NAME}.dll            ]; then mv            ${LIB_NAME}.dll               ${LIB_NAME}.dll.0 ; fi
if [ -f ${DST_DIR}/${LIB_NAME}.dll ]; then mv ${DST_DIR}/${LIB_NAME}.dll    ${DST_DIR}/${LIB_NAME}.dll.0 ; fi
echo "debug: compilation command: \n ${CC} -c -o ${OUTPUT} ${INPUT} ${C_FLAGS} "
${CC} -c -o ${OUTPUT} ${INPUT} ${C_FLAGS} 
#                   

if [[ $? != 0 ]]; then
    echo "\n\n\n"
    echo "Compilation failed"
    echo "\n\n\n"
    exit 1
fi
MINGW_LINK_OPTS="-lpsapi"
${CC} -g --shared -L${DST_DIR} -L${LIBAV_DIR_VLC}/libavcodec -L${LIBAV_DIR_VLC}/libavdevice -L${LIBAV_DIR_VLC}/libavfilter -L${LIBAV_DIR_VLC}/libavformat -L${LIBAV_DIR_VLC}/libavresample -L${LIBAV_DIR_VLC}/libavutil -L${LIBAV_DIR_VLC}/libswscale  -Wl,-Bsymbolic-functions              -lx264 -lfdk-aac -Wl,--as-needed -Wl,--warn-common -Wl,-rpath-link=libswscale:libavfilter:libavdevice:libavformat:libavcodec:libavutil:libavresample  -o ${LIB_NAME}.dll ${LIBAV_DIR}/cmdutils.o ${LIBAV_DIR}/avconv_opt.o ${LIBAV_DIR}/avconv_filter.o lua_avconv.o -L${LUA_DIR} -llua -lavdevice -lavfilter -lavformat -lavresample -lavcodec -lswscale -lavutil             -lm  ${MINGW_LINK_OPTS}
# echo "Copying now ${LIB_NAME}.dll to target lib directory:"
# cp ${LIB_NAME}.dll ${DST_DIR}/${LIB_NAME}.dll
