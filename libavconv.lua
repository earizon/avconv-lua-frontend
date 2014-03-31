-- frontend lua to avconv 

local debug = false
local avf = {} -- avconvc frontend

avf.loglevel = "error"

function _runCommon(cmd)
    common = ""
    common = common .. "-loglevel " .. avf.loglevel .. " "
    common = common .. "-y "
    common = common .. cmd
    return avconv.run(cmd) -- <-- This line invoques the LUA-C avconv wrapper
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
    cmd = cmd .. "-flags +global_header "
    cmd = cmd .. "-codec copy "
    cmd = cmd .. "-map 0 -f segment "
    cmd = cmd .. "-segment_time 20 "   -- TODO:(0) Parametrize (make it smaller for Live Content)
    cmd = cmd .. "-segment_list_size 10 "
    cmd = cmd .. "-segment_list ".. outputDir .."/".. outputPrefix .. ".m3u8 "
    cmd = cmd .. "-segment_list_type hls "
    cmd = cmd .. "-segment_list_entry_prefix ".. urlPrefix .." "
    cmd = cmd .. "Videos/".. outputPrefix .."%03d.ts"
    return _runCommon(cmd);
end

function avf.getThumbnail(input, outputDir, outputName)
    -- outputName : thumbnail file name without the (.png) prefix

    cmd = ""
    cmd = cmd .. "-y "
    -- man avconv: "-ss position: When used as input option seeks in this input file to position, when used as an output option 
    -- decodes but discards input until the timestamps reach position. This is slower, but more accurate."
    cmd = cmd .. "-ss 00:00:25.000 " -- TODO:(?) Arbitrary position in stream
    cmd = cmd .. "-i " .. input .. " "
    cmd = cmd .. "-f image2 "
    cmd = cmd .. "-vframes 1 "
    cmd = cmd .. outputDir .. "/" .. outputName ..".png"
    return _runCommon(cmd);
end

function avf.getMetadata(input)
    -- TODO(1): /dev/null doesn't work on Windows. 
    -- According to: http://stackoverflow.com/questions/313111/dev-null-in-windows
    cmd = "-i " .. input .. " -codec copy -f mp4  /dev/null"
    return _runCommon(cmd) -- seconds, width, height
end

return avf;
