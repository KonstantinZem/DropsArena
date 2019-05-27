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
	
	private var lifequant:int = 1; //Убыль жизни за ход. Должна быть включена в интерфейс этого типа плагинов
	private var image:Object; //Должна быть включена в интерфейс этого типа плагинов
	private var modelError:ModelErrors;
	private var numberOfInitilizedTasks:int
	
	function cover(){
		//messenger.setMessageMark('Ground cover plugin');
		modelError = new ModelErrors();
		}
	
	override public function initSpecial(task:Array, taskName:String, taskNumber:int):void{
		var currentTask:CoverTask
		
		task[taskNumber]= new CoverTask();
		
		currentTask = task[taskNumber];
		initCurrentTaskData(currentTask, taskName,  taskNumber);
		
		if(lifequant == 0){
			lifequant = 1;
			}
		
		currentTask.loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
		currentTask.loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
		currentTask.loader.load(new URLRequest(currentTask.imageName));
		}
	
	private function initCurrentTaskData(currentTask:CoverTask, taskName:String, taskNumber:int):void{
		
		currentTask.dataPath = 'plugins.' + pluginName + '.task.data.observation';
		var calendarData:String = currentTask.dataPath + '.day';
			
		currentTask.name = taskName;
		currentTask.number = taskNumber;
		currentTask.observationPosition = new Array(0,0,taskNumber,0);
		currentTask.currentDayPosition = new Array(0,0,taskNumber,0,0,0);

		currentTask.coverShema = new Array();
		currentTask.color = configuration.getOption(optionPath + 'color', currentTask.observationPosition);
		currentTask.currentDay = configuration.getOption(calendarData, currentTask.currentDayPosition);//Берем из аттрибутов дату наблюдения
		currentTask.behaviourFrequency = int(configuration.getOption(optionPath + 'behaviour_frequency', currentTask.observationPosition));
		
		if(currentTask.behaviourFrequency == 0 || currentTask.behaviourFrequency < 0){//Если в конфигурационном файле нет такой опции
			currentTask.behaviourFrequency = 100;
			msgString = 'Behaviour frequency: ' + modelError.varIsIncorrect;
			messenger.message(msgString, modelEvent.ERROR_MARK);
			}
		
		if(currentTask.behaviourFrequency > 100){
			currentTask.behaviourFrequency = 100;
			msgString = 'Behaviour frequency: ' + modelError.varIsIncorrect + ' It can not be greater then 100';
			messenger.message(msgString, modelEvent.ERROR_MARK);
			}
		
		currentTask.imageName = configuration.getOption(optionPath + 'picture', currentTask.observationPosition);
		currentTask.aDeley = int(configuration.getOption(optionPath + 'stepDeley', currentTask.observationPosition));
		currentTask.behaviourModelName = configuration.getOption(optionPath + 'behaviour_model', currentTask.observationPosition);//Какое поведение должна прявлять особь на закрашенных плагином участках
		
		if(currentTask.behaviourModelName == 'Error'){//Если в конфиге не указано название модели поведения
			currentTask.behaviourModelName = 'empty';//Оставляем название пустым
			}
		
		currentTask.switchingEvent = setSwitchingEvent(currentTask);
		currentTask.switchingInterval = setSwitchingInterval(currentTask);
		
		currentTask.loader = new Loader();
		currentTask.background = new ColorTransform();
		currentTask.background.color = currentTask.color;
	};

	private function onIOError(error:IOErrorEvent):void{
		msgString = "Unable to load picture: " + error.text; 
		messenger.message(msgString, modelEvent.ERROR_MARK);
		currentTask.loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
		pluginEvent.ready();//Сообщаем о том, что все уже сделано, ведь другие плагины тоже хотят загрузится
		}

	private function onLoadComplete(e:Event):void{//Функция запускается один раз сразу после старта плагина
		
		if(currentTaskNumber == task.length -1){//Дожидаемся момента, когда загрузятся все плагины
			
			for(var i:int = 0; i < task.length -1; i++){	
				image = task[i].loader.contentLoaderInfo.content;//Загружаем в память картинку напочвенного покрова
				addChild(image);
				task[i].loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);	
				modifyTable(task[i]);//Запускаем функционал, изменяющий структуры внутри этой программы 
				removeChild(image);//Удаляем вспомогательную картинку с рисунком напочвенного покрова
				task[i].loader = null;
				}
			image = null;
			pluginEvent.ready();//Сообщаем о том, что все уже сделано,
		}
		currentTaskNumber++;
	}

	private function modifyTable(currentTask:CoverTask):void{
		
		var xPos:int = 0;
		var yPos:int = 0;
		var counterI:int = 0;
		
		try{
		if(currentTask.coverShema == null){
			throw new Error('Cover shema array not initilized yet');
			}
		
		if(currentTask.coverShema.length == 0){//Если плагин запустился в первый раз, 
		
			initCoverShema(currentTask);//то сначала создаем схему напочвенного покрова, чтобы при его последующих запусках уменьшить объем обрабатываемой информации
			if(currentTask.behaviourFrequency > 0){
				initBehaviourShema(currentTask);
				}
			}else{
	
				counterI = currentTask.coverShema.length;
				for(var i:int = 0; i< counterI; i++){
					
					for(var j:int = 0; j< currentTask.coverShema[i].length; j++){
						xPos = currentTask.coverShema[i][j].controllX;
						yPos = currentTask.coverShema[i][j].controllY;
						communityStage.chessDesk[xPos][yPos].coverName = pluginName;
						communityStage.chessDesk[xPos][yPos].picture.transform.colorTransform = currentTask.background;
						communityStage.chessDesk[xPos][yPos].behaviourModel = currentTask.coverShema[i][j].behaviourModel;
						}
					
					}
				}
			}catch(e:Error){
				msgString = e.message;
				messenger.message(msgString, modelEvent.ERROR_MARK);
			}
		}
	
	private function initCoverShema(currentTask:CoverTask):void{
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
				currentTask.coverShema[i] = new Array();
				
				for(var j:int = 0; j<counterJ; j++){
					var aux:Object = new Object();
					pixelValue = bmd.getPixel(tableRoot[i][j].sqrX /2,tableRoot[i][j].sqrY /2).toString(16);
		
					if(pixelValue != 'ffffff'){//Если участок картинки не белый
						communityStage.chessDesk[i][j].picture.transform.colorTransform = currentTask.background;
						communityStage.chessDesk[i][j].speedDeleyA += currentTask.aDeley//Переопределяем скорость взрослых
						communityStage.chessDesk[i][j].speedDeleyY += currentTask.yDeley//И молодых особей
						communityStage.chessDesk[i][j].lifeQuant += lifequant;//Переопределяем время жизни особи за ход
						communityStage.chessDesk[i][j].coverName = pluginName;
						controllX = i;
						controllY =j;
						aux['controllX'] = controllX;
						aux['controllY'] = controllY;
						aux['behaviourModel'] = '';
						currentTask.coverShema[i].push(aux);
					}
				}	
		}
		bmd.dispose(); //Небольшая оптимизация, чтобы уменьшить занимаемую память
		bmd = null;
		
		msgString = 'Individuals speed now is ' + communityStage.chessDesk[controllX][controllY].speedDeleyA;
		messenger.message(msgString, modelEvent.INFO_MARK);
	    msgString = 'Individuals life decriasing now is ' + communityStage.chessDesk[controllX][controllY].lifeQuant + ' points after step';
	    messenger.message(msgString, modelEvent.INFO_MARK);
		}
		
	private function initBehaviourShema(currentTask:CoverTask):void{
		var aux:Array = new Array(0,1,2,3,4,5,6,7,8,9);//Этот массив нужен для присвоения модели поведения случайным клеткам из десяти
		var counterI:int = currentTask.coverShema.length;
		var counterD:int = 0;
		var initedCellsNumber:int = currentTask.behaviourFrequency/10;
		var cellNumber:int;
		
		for(var i:int = 0; i < counterI; i++){
			
			for(var j:int = 0; j< currentTask.coverShema[i].length; j = j + 10){
				counterD = j + initedCellsNumber;
				
				for(var d:int = j; d < counterD; d++){
					cellNumber = Math.round(Math.random() * (aux.length));//Выбираем случайную ячейку вспомогатеьного массива
					
					if(currentTask.coverShema[i][aux[cellNumber] + j] != undefined){
						currentTask.coverShema[i][aux[cellNumber] + j]['behaviourModel'] = currentTask.behaviourModelName;
						}
					aux.splice(cellNumber,1);
					
					}
					aux = new Array(0,1,2,3,4,5,6,7,8,9);
				}
			}
		}
	
	override public function startPluginJobe():void{
		
		modifyTable(currentTask);
		currentTask.currentDayPosition[4]++;
		
		currentTask.currentDay = configuration.getOption(currentTask.dataPath + '.day', currentTask.currentDayPosition);//Берем из конфига следующую дату запуска
		if(currentTask.currentDay == 'Error'){//Если мы выскочили за последнюю запись в данной секции кофига
			currentTask.currentDayPosition[4] = 0;
			currentTask.currentDay = configuration.getOption(currentTask.dataPath + '.day', currentTask.currentDayPosition);//Переходим к первое его записи
			}
		}
	
}
}
	
