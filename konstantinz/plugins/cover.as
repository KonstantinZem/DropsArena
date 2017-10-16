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
	private var debug:Boolean = true;
	private var msg:String;
	private var image:*; //Должна быть включена в интерфейс этого типа плагинов
	//private var myRoot:*; //Должна быть включена в интерфейс этого типа плагинов. Это ссылка на главную программу
	private var loader:Loader;
	private var errors:Object;
	private var timer:Timer
	private var options:Object//В эту переменную будет загружатся класс, содержащий настройки
	
	public var pluginName:String; //Должна быть включена в интерфейс этого типа плагинов
	
	public var pluginEvent:Object;
	
public function cover(){
		
		msg = 'Ground cover plugin. Version 0.3\n'
		debugMessage(msg);
		
		ct = new ColorTransform();
		loader = new Loader();
		errors = new ModelErrors()
		pluginEvent = new DispatchEvent();
		pluginName = ''

		timer = new Timer(500, 1);//Ждем некоторое время, пока в главная программа не передаст нужные плагину параметры
		timer.addEventListener(TimerEvent.TIMER, loadOptions);
		timer.start();
		

		}
private function loadOptions(e:TimerEvent):void{
	//После небольшой паузы
	myRoot = root;//Устанавливаем ссылук на структуы главной программы
	var myName:String
	myName = pluginName + '.cfg';
	timer.stop();
	timer.removeEventListener(TimerEvent.TIMER, loadOptions);
  		
  		if(myRoot != null){//Если клип запущен из главной программы
			options = new CoverOptionsContainer(myName);
			options.addEventListener(CoverOptionsContainer.PLUG_LOADED, initPlugin);//
			
		}
		else{//Иначе просто выводим предупреждение о неправильном запуске
			msg = errors.pluginStartAlong;
			debugMessage(msg)
		}
	}
	
		
private function initPlugin(e:Event):void{
 
 options.removeEventListener(CoverOptionsContainer.PLUG_LOADED, initPlugin);//
 this.image = options.picture;
 this.color = options.color
 ct.color = this.color;
 this.adeley = options.adeley;
 
 msg = 'Wating for start...';
 debugMessage(msg);
		  
			if(pluginName !=''){//Если плагин знает све имя
				
				debug = options.debugLevel;
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoadComplete);
   				loader.load(new URLRequest(image));
			}
		
		
	
}

private function onLoadComplete(e:Event):void{
   image = loader.contentLoaderInfo.content;
   addChild(image);
   loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, onLoadComplete);
   trace("This plugin naime is " + pluginName)
   modifyTable()//Запускаем функционал, изменяющий структуры внутри этой программы
  
   
}

private function modifyTable():void{
			
	var bmd:BitmapData = image.bitmapData;
	image.x = myRoot.commStage.x;
   	image.y = myRoot.commStage.y;
   	image.height = myRoot.commStage.height
   	image.width = myRoot.commStage.width
			
   			
   	var tableRoot:Array = myRoot.commStage.chessDesk;
			for(var i:int = 0; i<tableRoot.length; i++){
				
				for(var j:int = 0; j<tableRoot[i].length; j++){
					var pixelValue:String = bmd.getPixel(tableRoot[i][j]['sqrX']/2,tableRoot[i][j]['sqrY']/2).toString(16)
		
					if(pixelValue!='ffffff'){//Если участок картинки не белый
						myRoot.commStage.chessDesk[i][j].picture.transform.colorTransform = ct;
						myRoot.commStage.chessDesk[i][j]['speedDeleyA'] += adeley//Переопределяем скорость взрослых
						myRoot.commStage.chessDesk[i][j]['speedDeleyY'] += YDELEY//И молодых особей
						myRoot.commStage.chessDesk[i][j]['lifeQuant'] += lifequant;//Переопределяем время жизни особи за ход
					}
						}
					
					}
					//По окончанию работы плагина
					removeChild(image);//Удаляем вспомогательную картинку с рисунком напочвенного покрова
					pluginEvent.ready();//Сообщаем о том, что все уже сделано,
	}
				
					
private function debugMessage(debugMsg:String):void{
		
	if(debug){
		trace(debugMsg);
		}
	}

	
	}
}
	
