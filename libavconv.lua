-- frontend lua to avconv 

local debug = true;
local avf = {} -- avconvc frontend
local OS = false;
avf.loglevel = "error"

function _getNULLFile()
    -- this code is also used to detect whether we are on windows/unix.
    local result = "null"; -- default  (windows)
    f,serror=pcall(io.open,"/dev/null","r");
    if not serror == nil then
        f:close();
        result="/dev/null" ;
    end
    return result;
end

function _getos()
    if _getNULLFile() == "null" then
        os = "windows";
    else
        os = "linux"; -- actually it could be any other unix
    end
    return os;
end

local dirSeparator = "/" -- default Unix
if _getos() == "windows" then dirSeparator = "\\" end

function _runCommon(cmd)
    local common = ""
    common = common .. "-loglevel " .. avf.loglevel .. " "
    common = common .. "-y "
    common = common .. cmd
    if debug then print("debug: avf._runCommon: cmd:" .. common ); end
    local result = avconv.run(common) -- <-- This line invoques the LUA-C avconv wrapper
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
    if input        == "" or input        == nil then error ("input        empty/nil @ avf.createHLS"); end
    if outputDir    == "" or outputDir    == nil then error ("outputDir    empty/nil @ avf.createHLS"); end
    if outputPrefix == "" or outputPrefix == nil then error ("outputPrefix empty/nil @ avf.createHLS"); end
    if urlPrefix    == "" or urlPrefix    == nil then error ("urlPrefix    empty/nil @ avf.createHLS"); end
    index_m3u8 = outputDir .. _dirSeparator .. outputPrefix .. ".m3u8"
    cmd = "" 
    cmd = cmd .. "-i " .. input .. " "
    cmd = cmd .. "-bsf h264_mp4toannexb "
    cmd = cmd .. "-flags +global_header "
    cmd = cmd .. "-codec copy "
    cmd = cmd .. "-map 0 -f segment "
    cmd = cmd .. "-segment_time 20 "   -- TODO:(0) Parametrize (make it smaller for Live Content)
    cmd = cmd .. "-segment_list_size 10 "
    cmd = cmd .. "-segment_list ".. index_m3u8 .. ".tmp "
    cmd = cmd .. "-segment_list_type hls "
    cmd = cmd .. "-segment_list_entry_prefix ".. urlPrefix .." "
    cmd = cmd .. outputDir .. dirSeparator .. "%03d.ts"
    result = _runCommon(cmd);
    function _fixIndex()
        -- Read relative path in m3u8 and creates absolute path m3u8
        if debug then print("[DEBUG] _fixIndex: outputPrefix:" .. outputPrefix); end
        local inputFile = io.open(index_m3u8.. ".tmp" , "r");
        local outputFile = io.open(index_m3u8, "w");
        local body = "";
        for line in inputFile:lines() do
           -- body =  body .. line:gsub(".core.Videos.home.d.cast.d.cast.dev", "") .. "\n";
              lineOut = line; -- default
              local test_lineOut = string.gsub(lineOut, ".*Videos" , "/Videos" );
              outputFile:write(test_lineOut.."\r\n");
        end
        inputFile:close();
        outputFile:close();
    end
    _fixIndex();

    return result;

end

function avf.getThumbnail(input, outputDir, outputName)
    -- outputName : thumbnail file name without the (.png) prefix
    cmd = ""
    cmd = cmd .. "-i " .. input .. " "
    cmd = cmd .. "-ss 00:00:25.000 " -- TODO:(?) Arbitrary position in stream
    cmd = cmd .. "-f image2 "
    cmd = cmd .. "-vframes 1 "
    cmd = cmd .. outputDir .. dirSeparator .. outputName ..".png"
    return _runCommon(cmd);
end

function avf.getMetadata(input)
    cmd = ""
    cmd = cmd .. "-i " .. input .. " -f mp4 "
    cmd = cmd .. "-codec copy "
    cmd = cmd .. "-f image2 "
    cmd = cmd .. "-vframes 1 "
    cmd = cmd .. _getNULLFile();
    return _runCommon(cmd) -- seconds, width, height
end

return avf;
