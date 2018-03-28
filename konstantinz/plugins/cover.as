﻿// Author: Konstantin Zemoglyadchuk konstantinz@bk.ru
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
	import flash.net.URLRequest
	import flash.display.Sprite
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.ColorTransform;
	import flash.display.Loader;
	import flash.events.TimerEvent; 
	import flash.utils.*;
	import konstantinz.community.auxilarity.*;
	import konstantinz.plugins.*;
	
public class cover extends Sprite{
	
	private var adeley:int = 1//Задержка при движении взрослых особей. Должна быть включена в интерфейс этого типа плагинов
	private var YDELEY:int = 3//Задержка при движении молодых особей. Должна быть включена в интерфейс этого типа плагинов
	private var lifequant:int = 1; //Убыль жизни за ход. Должна быть включена в интерфейс этого типа плагинов
	private var color:Number = 0x000000; //Должна быть включена в интерфейс этого типа плагинов. Определяет цвет участка с данными характеристиками
	private var ct:ColorTransform;
	private var BORDERCOLOR:Number = 0x000000;
	private var debug:String = 'true';
	private var msg:String;
	private var image:*; //Должна быть включена в интерфейс этого типа плагинов
	private var myRoot:*; //Должна быть включена в интерфейс этого типа плагинов. Это ссылка на главную программу
	private var loader:Loader;
	private var errors:Object;
	private var timer:Timer
	private var options:Object//В эту переменную будет загружатся класс, содержащий настройки
	
	public var pluginName:String; //Должна быть включена в интерфейс этого типа плагинов
	public var pluginEvent:Object;
	
function cover(){
		
		msg = 'Ground cover plugin. Version 0.3\n'
		debugMessage(msg);
		
		ct = new ColorTransform();
		loader = new Loader();
		errors = new ModelErrors()
		pluginEvent = new DispatchEvent();
		pluginName = ''

		timer = new Timer(1000, 1);//Ждем некоторое время, пока в главная программа не передаст нужные плагину параметры
		timer.addEventListener(TimerEvent.TIMER, initPlugin);// потом запускаем программу
		timer.start();
		}
	
private function initPlugin(e:TimerEvent):void{
	timer.stop();
	timer.removeEventListener(TimerEvent.TIMER, initPlugin);
	
	if(root != null){//Если клип запущен из главной программы
		
		if(pluginName !=''){//Если плагин знает све имя
		
			var optionPath:String = 'plugins.'+ pluginName + '.'
 
			this.image = root.configuration.getOption(optionPath + 'picture');
			this.color = root.configuration.getOption(optionPath + 'color');
			ct.color = this.color;
			this.adeley = root.configuration.getOption(optionPath + 'stepDeley');
			this.debug = root.configuration.getOption(optionPath + 'debugLevel');
 
			msg = 'Wating for start...';
			debugMessage(msg);
	
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, onIOError);
   			loader.load(new URLRequest(image));
   				
   		}
	}else{//Иначе просто выводим предупреждение о неправильном запуске
		msg = errors.pluginStartAlong;
		debugMessage(msg)
	}	
}

private function onIOError(error:IOErrorEvent){
	 trace("Unable to load picture: " + error.text); 
	 loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, onIOError);
	 pluginEvent.ready();//Сообщаем о том, что все уже сделано, ведь другие плагины тоже хотят загрузится
	}

private function onLoadComplete(e:Event):void{
   image = loader.contentLoaderInfo.content;
   addChild(image);
   loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
   msg = "This plugin naime is " + pluginName;
   debugMessage(msg);
   modifyTable()//Запускаем функционал, изменяющий структуры внутри этой программы 
}

private function modifyTable():void{
	var controllX:int
	var controllY:int
	
	var bmd:BitmapData = image.bitmapData;
	image.x = root.commStage.x;
   	image.y = root.commStage.y;
   	image.height = root.commStage.height
   	image.width = root.commStage.width
			
   			
   	var tableRoot:Array = root.commStage.chessDesk;
			
		for(var i:int = 0; i<tableRoot.length; i++){
				
				for(var j:int = 0; j<tableRoot[i].length; j++){
					var pixelValue:String = bmd.getPixel(tableRoot[i][j]['sqrX']/2,tableRoot[i][j]['sqrY']/2).toString(16)
		
					if(pixelValue!='ffffff'){//Если участок картинки не белый
						root.commStage.chessDesk[i][j].picture.transform.colorTransform = ct;
						root.commStage.chessDesk[i][j]['speedDeleyA'] += adeley//Переопределяем скорость взрослых
						root.commStage.chessDesk[i][j]['speedDeleyY'] += YDELEY//И молодых особей
						root.commStage.chessDesk[i][j]['lifeQuant'] += lifequant;//Переопределяем время жизни особи за ход
						controllX = i
						controllY =j
					}
				}	
		}
		//По окончанию работы плагина
		//Выводим результат работы
		msg = 'Individuals speed now is ' + root.commStage.chessDesk[controllX][controllY]['speedDeleyA'];
		debugMessage(msg);
	    msg = 'Individuals life decriasing now is ' + root.commStage.chessDesk[controllX][controllY]['lifeQuant'] + ' points after step';
	    debugMessage(msg);
	    
		removeChild(image);//Удаляем вспомогательную картинку с рисунком напочвенного покрова
		pluginEvent.ready();//Сообщаем о том, что все уже сделано,
}

private function summsry():void{//Печатаем в консоль результат работы плагина
	
	}
								
private function debugMessage(debugMsg:String):void{
		
	if(debug=='true'){
		trace(debugMsg);
	}
}

	
}
}
	