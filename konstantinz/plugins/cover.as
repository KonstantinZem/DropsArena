// Author: Konstantin Zemoglyadchuk konstantinz@bk.ru
// Copyright (C) 2017 Konstantin Zemoglyadchuk
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

package konstantinz.plugins{
	
	import flash.events.Event
	import flash.errors.IOError;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.display.Loader;
	import flash.events.TimerEvent; 
	import konstantinz.community.comStage.*;
	import konstantinz.community.auxilarity.*;
	import konstantinz.plugins.*;
	
public class cover extends Plugin{
	
	private var aDeley:int = 1//Задержка при движении взрослых особей. Должна быть включена в интерфейс этого типа плагинов
	private var yDeley:int = 3//Задержка при движении молодых особей. Должна быть включена в интерфейс этого типа плагинов
	private var lifequant:int = 1; //Убыль жизни за ход. Должна быть включена в интерфейс этого типа плагинов
	private var behaviourFrequency:int;
	private var color:Number = 0x000000; //Определяет цвет участка с данными характеристиками
	private var ct:ColorTransform;
	private var imageName:String;
	private var behaviourModelName:String;
	private var image:Object; //Должна быть включена в интерфейс этого типа плагинов
	private var loader:Loader;
	private var optionPosition:Array;
	private var coverShema:Array;//Схема напочвенного покрова может загружаться в процессе работы программы несколько раз. Чтобы не загружать битмап каждый раз, надо заранее создать схему
	private var modelError:ModelErrors;
	
	function cover(){
		ct = new ColorTransform();
		loader = new Loader();
		messenger.setMessageMark('Ground cover plugin');
		coverShema = new Array;
		modelError = new ModelErrors();
		}
	
	override public function initSpecial():void{
		optionPosition = new Array(0,0,0,0,0);
		
		dataPath = 'plugins.' + pluginName + '.data.observation';
		calendarData = dataPath + '.day';
		
		behaviourFrequency = int(configuration.getOption(optionPath + 'behaviour_frequency'));
		
		if(behaviourFrequency == 0 || behaviourFrequency < 0){
			behaviourFrequency = 100;
			msgString = 'Behaviour frequency: ' + modelError.varIsIncorrect;
			messenger.message(msgString, modelEvent.ERROR_MARK);
			}
		
		if(behaviourFrequency > 100){
			behaviourFrequency = 100;
			msgString = 'Behaviour frequency: ' + modelError.varIsIncorrect + ' It can not be greater then 100';
			messenger.message(msgString, modelEvent.ERROR_MARK);
			}
		
		imageName = configuration.getOption(optionPath + 'picture');
		color = configuration.getOption(optionPath + 'color');
		ct.color = color;
		adeley = configuration.getOption(optionPath + 'stepDeley');
		behaviourModelName = configuration.getOption(optionPath + 'behaviour_model');//Какое поведение должна прявлять особь на закрашенных плагином участках
		
		if(behaviourModelName == 'Error'){//Если в конфиге не указано название модели поведения
			behaviourModelName = 'empty';//Оставляем название пустым
			}
		
		if(lifequant == 0){
			lifequant = 1;
			}
		
		currentDay = configuration.getOption(calendarData, optionPosition);//Берем из аттрибутов дату наблюдения
			
		loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
		loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
		loader.load(new URLRequest(imageName));
		}

	private function onIOError(error:IOErrorEvent):void{
		msgString = "Unable to load picture: " + error.text; 
		messenger.message(msgString, modelEvent.ERROR_MARK);
		loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
		pluginEvent.ready();//Сообщаем о том, что все уже сделано, ведь другие плагины тоже хотят загрузится
	}

	private function onLoadComplete(e:Event):void{
		image = loader.contentLoaderInfo.content;
		addChild(image);
		loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
		modifyTable();//Запускаем функционал, изменяющий структуры внутри этой программы 
	}

	private function modifyTable():void{
		var xPos:int = 0;
		var yPos:int = 0;
		var counterI:int = 0;
		if(coverShema.length == 0){//Если плагин запустился в первый раз, 
			initCoverShema ();//то сначала создаем схему напочвенного покрова, чтобы при его последующих запусках уменьшить объем обрабатываемой информации
			if(behaviourFrequency > 0){
				initBehaviourShema();
				}
			pluginEvent.ready();//Сообщаем о том, что все уже сделано,
			}else{
				counterI = coverShema.length;
				for(var i:int = 0; i< counterI; i++){
					for(var j:int = 0; j< coverShema[i].length; j++){
						xPos = coverShema[i][j].controllX;
						yPos = coverShema[i][j].controllY;
						communityStage.chessDesk[xPos][yPos].coverName = pluginName;
						communityStage.chessDesk[xPos][yPos].picture.transform.colorTransform = ct;
						communityStage.chessDesk[xPos][yPos].behaviourModel = coverShema[i][j].behaviourModel;
						}
					
					}
				}
		}
	
	private function initCoverShema():void{
		var controllX:int;
		var controllY:int;
		var bmd:BitmapData = image.bitmapData;
		var counterI:int;
		var counterJ:int;
	
		image.x = communityStage.x;
		image.y = communityStage.y;
		image.height = communityStage.height;
		image.width = communityStage.width;
				
		var tableRoot:Array = communityStage.chessDesk;
		counterI = tableRoot.length;
			
		for(var i:int = 0; i< counterI; i++){
				var pixelValue:String;
				counterJ = tableRoot[i].length;
				coverShema[i] = new Array();
				
				for(var j:int = 0; j<counterJ; j++){
					var aux:Object = new Object();
					pixelValue = bmd.getPixel(tableRoot[i][j].sqrX /2,tableRoot[i][j].sqrY /2).toString(16);
		
					if(pixelValue != 'ffffff'){//Если участок картинки не белый
						communityStage.chessDesk[i][j].picture.transform.colorTransform = ct;
						communityStage.chessDesk[i][j].speedDeleyA += aDeley//Переопределяем скорость взрослых
						communityStage.chessDesk[i][j].speedDeleyY += yDeley//И молодых особей
						communityStage.chessDesk[i][j].lifeQuant += lifequant;//Переопределяем время жизни особи за ход
						communityStage.chessDesk[i][j].coverName = pluginName;
						controllX = i;
						controllY =j;
						aux['controllX'] = controllX;
						aux['controllY'] = controllY;
						aux['behaviourModel'] = '';
						coverShema[i].push(aux);
						
					}
				}	
		}
		bmd.dispose(); //Небольшая оптимизация, чтобы уменьшить занимаемую память
		bmd = null;
		removeChild(image);//Удаляем вспомогательную картинку с рисунком напочвенного покрова
		msgString = 'Individuals speed now is ' + communityStage.chessDesk[controllX][controllY].speedDeleyA;
		messenger.message(msgString, modelEvent.INFO_MARK);
	    msgString = 'Individuals life decriasing now is ' + communityStage.chessDesk[controllX][controllY].lifeQuant + ' points after step';
	    messenger.message(msgString, modelEvent.INFO_MARK);
		}
		
	private function initBehaviourShema():void{
		var aux:Array = new Array(0,1,2,3,4,5,6,7,8,9);//Этот массив нужен для присвоения модели поведения случайным клеткам из десяти
		var counterI:int = coverShema.length;
		var counterD:int = 0;
		var initedCellsNumber:int = behaviourFrequency/10;
		var cellNumber:int;
		
		for(var i:int = 0; i < counterI; i++){
			
			for(var j:int = 0; j< coverShema[i].length; j = j + 10){
				counterD = j + initedCellsNumber;
				
				for(var d:int = j; d < counterD; d++){
					cellNumber = Math.round(Math.random() * (aux.length));//Выбираем случайную ячейку вспомогатеьного массива
					
					if(coverShema[i][aux[cellNumber] + j] != undefined){
						coverShema[i][aux[cellNumber] + j]['behaviourModel'] = behaviourModelName;
						}
					aux.splice(cellNumber,1);
					
					}
					aux = new Array(0,1,2,3,4,5,6,7,8,9);
				}
			}
		}
	
	override public function startPluginJobe():void{
		modifyTable();
		optionPosition[3]++;
		currentDay = configuration.getOption(calendarData, optionPosition);
		if(currentDay == 'Error'){//Если мы выскочили за последнюю запись в данной секции кофига
			optionPosition[3] = 0;
			currentDay = configuration.getOption(calendarData, optionPosition);//Переходим к первое его записи
			}
		}
	
}
}
	
