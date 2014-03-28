<?
avf = require ("libavconv");

input  = "testInput.mp4"
outputDir = "Videos"
outputPrefix = "testInput"
urlPrefix = "http://192.168.1.53:8888/"
seconds, width, height = avf.createHLS(input, outputDir, outputPrefix, urlPrefix)

mg.write("* OK \n");
mg.write("* seconds: " .. seconds .. "\n");
mg.write("* width  : " .. width   .. "\n");
mg.write("* height : " .. height  .. "\n");
?>
