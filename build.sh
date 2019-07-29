#!/bin/bash

buildDate=`date +"%m-%d-%y"`
srcPath='/Documents/Rabochie/projects/swf/swf_comunity/src';

cd $HOME$srcPath
# путь до каталога с Flex SDK
sdk=$HOME'/.programs/flex_sdk_4.6/'
# путь до компилятора mxmlc
mxmlc=$sdk'bin/mxmlc'
 
# запуск компилятора
"$mxmlc" main.as -output ../bin/model.swf -default-background-color 0xFFFFFF -default-size 1000 800 -use-network=false -static-link-runtime-shared-libraries=true  -compiler.define=ARENA::DEBUG,false -creator "Konstantin Zemoglyadchuk" -title "Drops Arena" -description "Population model"
#Плагины формирования покрова
"$mxmlc" CoverMain.as -output ../bin/plugins/cover.swf -default-background-color 0xFFFFFF -default-size 1000 800 -use-network=false -strict=false -static-link-runtime-shared-libraries=true -compiler.define=ARENA::DEBUG,false

"$mxmlc" activity.as -output ../bin/plugins/activity.swf -default-background-color 0xFFFFFF -default-size 1000 800 -use-network=false -strict=false -static-link-runtime-shared-libraries=true -compiler.define=ARENA::DEBUG,false

"$mxmlc" morisitaCounter.as -output ../bin/plugins/morisitaCounter.swf -default-background-color 0xFFFFFF -default-size 1000 800 -use-network=false -strict=false -static-link-runtime-shared-libraries=true -compiler.define=ARENA::DEBUG,false

zip -r '../dropsArens_'$buildDate'.zip' ../bin ../src/konstantinz ../src/*.as ../src/configuration.xml ../src/build.sh ../src/README.md
