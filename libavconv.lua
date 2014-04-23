-- frontend lua to avconv 

local debug = true;
local avf = {} -- avconvc frontend

avf.loglevel = "error"

function _runCommon(cmd)
    local common = ""
    common = common .. "-loglevel " .. avf.loglevel .. " "
    common = common .. "-y "
    common = common .. cmd
    if debug then print("debug: avf._runCommon: cmd:" .. common ); end
    local result = avconv.run(common) -- <-- This line invoques the LUA-C avconv wrapper
    if debug==true then print("deleteme avconv.run finished @ avf._runCommon"); end
    return result 
end

-- All following functions are just utility wrappers around _runCommon

-- COMMON PARAMETERS:
-- In the following function next parameters have the same mean for all functions:
--    input    : "anything" that libav can read -local file, udp stream,...
--    outputDir: any local server dir with write access to the lua engine
function avf.createHLS(input, outputDir, outputPrefix, urlPrefix)
    -- outputPrefix: The ".m3u8" index file without the .m3u8 suffix
    --               Ex: the input filename without the (mp4|avi|...) prefix
    -- urlPrefix: Will be added to the .m3u8. ex: http://streaming.mydomain.net/HLS/

    -- TODO:(0) For VoD do not remove segments. 
    --          For LiveContent let only 3-5 segments and then remove
    cmd = "" 
    cmd = cmd .. "-i " .. input .. " "
    cmd = cmd .. "-bsf h264_mp4toannexb "
    cmd = cmd .. "-flags +global_header "
    cmd = cmd .. "-codec copy "
    cmd = cmd .. "-map 0 -f segment "
    cmd = cmd .. "-segment_time 20 "   -- TODO:(0) Parametrize (make it smaller for Live Content)
    cmd = cmd .. "-segment_list_size 10 "
    cmd = cmd .. "-segment_list ".. outputDir .."/".. outputPrefix .. ".m3u8 "
    cmd = cmd .. "-segment_list_type hls "
    cmd = cmd .. "-segment_list_entry_prefix ".. urlPrefix .." "
    cmd = cmd .. "core/Videos/".. outputPrefix .."%03d.ts"
    return _runCommon(cmd);
end

function avf.getThumbnail(input, outputDir, outputName)
    -- outputName : thumbnail file name without the (.png) prefix

    cmd = ""
    cmd = cmd .. "-i " .. input .. " "
    cmd = cmd .. "-ss 00:00:25.000 " -- TODO:(?) Arbitrary position in stream
    cmd = cmd .. "-f image2 "
    cmd = cmd .. "-vframes 1 "
    cmd = cmd .. outputDir .. "/" .. outputName ..".png"
    return _runCommon(cmd);
end

function avf.getMetadata(input)
    local config = require("config");
    -- TODO(1): /dev/null doesn't work on Windows. 
    -- According to: http://stackoverflow.com/questions/313111/dev-null-in-windows
    cmd = "-i " .. input .. " -f mp4 "
    cmd = cmd .. "-codec copy "
    cmd = cmd .. config.nullFile;
    return _runCommon(cmd) -- seconds, width, height
end

return avf;
