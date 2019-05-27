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

cp configuration.xml ../bin
 
# открыть скомпилированную флещку
#open model.swf
