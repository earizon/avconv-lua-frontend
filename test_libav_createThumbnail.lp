<?  
os.execute('echo [deleteme] createThumbnail 0');
avf = require ("libavconv");

os.execute('echo [deleteme] createThumbnail 1');
input  = "testInput.mp4"
outputDir = "Thumbnails"
outputName = "testInputThumbnail"

os.execute('echo [deleteme] createThumbnail 2');
seconds, width, height = avf.getThumbnail(input, outputDir, outputName);
os.execute('echo [deleteme] createThumbnail 3');

mg.write("* OK \n");
mg.write("* seconds: " .. seconds .. "\n");
mg.write("* width  : " .. width   .. "\n");
mg.write("* height : " .. height  .. "\n");
?>
