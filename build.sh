#!/bin/bash
cd /home/konstantin/Documents/Rabochie/swf/swf_comunity/src
# путь до каталога с Flex SDK
sdk='/home/konstantin/.programs/flex_sdk_4.6/'
# путь до компилятора mxmlc
mxmlc=$sdk'bin/mxmlc'
 
# запуск компилятора
"$mxmlc" main.as -output ../bin/model.swf -default-background-color 0xFFFFFF -default-size 1000 800 -use-network=false
"$mxmlc" CoverMain.as -output ../bin/plugins/cover.swf -default-background-color 0xFFFFFF -default-size 1000 800 -use-network=false -strict=false
cp ../bin/plugins/cover.swf ../bin/plugins/grass.swf
cp ../bin/plugins/cover.swf ../bin/plugins/ground.swf
cp ../bin/plugins/cover.swf ../bin/plugins/stones.swf
cp cover.cfg ../bin
cp grass.cfg ../bin
cp ground.cfg ../bin
cp stones.cfg ../bin
cp community.cfg ../bin
 
# открыть скомпилированную флещку
#open model.swf
