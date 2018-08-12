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
	import konstantinz.community.auxilarity.*;
	import konstantinz.plugins.*;
	
public class cover extends Plugin{
	
	private var aDeley:int = 1//Задержка при движении взрослых особей. Должна быть включена в интерфейс этого типа плагинов
	private var yDeley:int = 3//Задержка при движении молодых особей. Должна быть включена в интерфейс этого типа плагинов
	private var lifequant:int = 1; //Убыль жизни за ход. Должна быть включена в интерфейс этого типа плагинов
	private var color:Number = 0x000000; //Должна быть включена в интерфейс этого типа плагинов. Определяет цвет участка с данными характеристиками
	private var ct:ColorTransform;
	private var imageName:String;
	private var image:Object; //Должна быть включена в интерфейс этого типа плагинов
	private var loader:Loader;
	
	function cover(){
		ct = new ColorTransform();
		loader = new Loader();
		}
	
	override public function initPlugin(e:TimerEvent):void{
		timer.stop();
		timer.removeEventListener(TimerEvent.TIMER, initPlugin);
	
		if(root != null && pluginName !=''){//Если клип запущен из главной программы и плагин знает свое имя
		
			optionPath = 'plugins.'+ pluginName + '.';
			configuration = root.configuration;
 
			debugeLevel = configuration.getOption(optionPath + 'debugLevel');
			messenger.setDebugLevel(debugeLevel);
			messenger.setMessageMark(pluginName);
 
			msgString = 'Wating for start...';
			messenger.message(msgString, modelEvent.DEBUG_MARK);
	
			initSpecial();
   				
		}else{//Иначе просто выводим предупреждение о неправильном запуске
			msgString = errorType.pluginStartAlong;
			messenger.message(msgString, modelEvent.ERROR_MARK);
		}	
	}
	
	override public function initSpecial():void{
		
		imageName = configuration.getOption(optionPath + 'picture');
		color = configuration.getOption(optionPath + 'color');
		ct.color = this.color;
		adeley = configuration.getOption(optionPath + 'stepDeley');
			
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
		var controllX:int;
		var controllY:int;
		var bmd:BitmapData = image.bitmapData;
		var counterI:int;
		var counterJ:int;
	
		image.x = root.commStage.x;
		image.y = root.commStage.y;
		image.height = root.commStage.height;
		image.width = root.commStage.width;
				
		var tableRoot:Array = root.commStage.chessDesk;
		counterI = tableRoot.length;
			
		for(var i:int = 0; i< counterI; i++){
				
				counterJ = tableRoot[i].length;
				
				for(var j:int = 0; j<counterJ; j++){
					var pixelValue:String = bmd.getPixel(tableRoot[i][j]['sqrX']/2,tableRoot[i][j]['sqrY']/2).toString(16);
		
					if(pixelValue!='ffffff'){//Если участок картинки не белый
						root.commStage.chessDesk[i][j].picture.transform.colorTransform = ct;
						root.commStage.chessDesk[i][j].speedDeleyA += aDeley//Переопределяем скорость взрослых
						root.commStage.chessDesk[i][j].speedDeleyY += yDeley//И молодых особей
						root.commStage.chessDesk[i][j].lifeQuant += lifequant;//Переопределяем время жизни особи за ход
						controllX = i;
						controllY =j;
					}
				}	
		}
		
		bmd.dispose(); //Небольшая оптимизация, чтобы уменьшить занимаемую память
		bmd = null;
	    //По окончанию работы плагина
		//Выводим результат работы
		msgString = 'Individuals speed now is ' + root.commStage.chessDesk[controllX][controllY].speedDeleyA;
		messenger.message(msgString, 2);
	    msgString = 'Individuals life decriasing now is ' + root.commStage.chessDesk[controllX][controllY].lifeQuant + ' points after step';
	    messenger.message(msgString, 2);
		removeChild(image);//Удаляем вспомогательную картинку с рисунком напочвенного покрова
		pluginEvent.ready();//Сообщаем о том, что все уже сделано,
	}
	
}
}
	
