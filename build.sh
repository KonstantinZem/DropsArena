#!/bin/bash

srcPath='/Documents/Rabochie/projects/swf/swf_comunity/src'
cd $HOME$srcPath
# путь до каталога с Flex SDK
sdk=$HOME'/.programs/flex_sdk_4.6/'
# путь до компилятора mxmlc
mxmlc=$sdk'bin/mxmlc'
 
# запуск компилятора
"$mxmlc" main.as -output ../bin/model.swf -default-background-color 0xFFFFFF -default-size 1000 800 -use-network=false -static-link-runtime-shared-libraries=true
#Плагины формирования покрова
"$mxmlc" CoverMain.as -output ../bin/plugins/cover.swf -default-background-color 0xFFFFFF -default-size 1000 800 -use-network=false -strict=false -static-link-runtime-shared-libraries=true

"$mxmlc" activity.as -output ../bin/plugins/activity.swf -default-background-color 0xFFFFFF -default-size 1000 800 -use-network=false -strict=false -static-link-runtime-shared-libraries=true

"$mxmlc" morisitaCounter.as -output ../bin/plugins/morisitaCounter.swf -default-background-color 0xFFFFFF -default-size 1000 800 -use-network=false -strict=false -static-link-runtime-shared-libraries=true

cp ../bin/plugins/cover.swf ../bin/plugins/grass.swf
cp ../bin/plugins/cover.swf ../bin/plugins/grass1.swf
cp ../bin/plugins/cover.swf ../bin/plugins/grass2.swf
cp ../bin/plugins/cover.swf ../bin/plugins/grass3.swf
cp ../bin/plugins/cover.swf ../bin/plugins/grass4.swf
cp ../bin/plugins/cover.swf ../bin/plugins/ground.swf
cp ../bin/plugins/cover.swf ../bin/plugins/stones.swf
cp ../bin/plugins/cover.swf ../bin/plugins/mowing.swf
cp ../bin/plugins/cover.swf ../bin/plugins/relief.swf
cp ../bin/plugins/activity.swf ../bin/plugins/death.swf


cp configuration.xml ../bin
 
# открыть скомпилированную флещку
#open model.swf
