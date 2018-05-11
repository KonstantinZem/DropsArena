﻿package konstantinz.plugins{

import flash.events.Event

	import flash.display.Sprite;
	import flash.events.TimerEvent; 
	import flash.utils.*;
	import konstantinz.community.auxilarity.*;
	import konstantinz.plugins.*;
	import flash.xml.*
    
public class activitySwitcher extends Sprite{
	private var stopingTimer:Timer;
	private var timerStatement:String;
	private var dispatchedObjects:Array//Ссылка на массив с управляемыми объектами
	private var configuration:ConfigurationContainer;
	private var objectsRange:Array;
	private var suspendTime:int;//Время на которое нужно остановить особь
	private var activityData:XMLDocument;//Здесь будет хранится массив данных с информацией об активности
	private var stopedObjects:Array;//Список остановленных в данный момент особей
	private var stopedNumber:int;
	private var currentActivitIndNumber:int = 0;//Позиция в таблице активности где надо искать текущее число особей, которых необходимо остановить
	private var debugeLevel:String;
	private var msgString:String;
	private var timer:Timer;
	private var signalType:String;
	private var optionPath:String;
	private var statMessageHead:String;
	private var killStoped:String;//Будудт ли подвержены случайной смерти неактивные особи
	private var errorType:ModelErrors;
	public var messenger:Messenger;
	public var pluginName:String; //В эту переменную загрузчик плагина передает его имя
	public var pluginEvent:Object;
	
	function activitySwitcher(){
		debugeLevel = '3';
		pluginName = '';
		killStoped = 'false';
		pluginEvent = new DispatchEvent();
		timer = new Timer(1000, 1);//Ждем некоторое время, пока в главная программа не передаст нужные плагину параметры
		timer.addEventListener(TimerEvent.TIMER, initPlugin);// потом запускаем программу
		timer.start();
		suspendTime = 5000;
		messenger = new Messenger(debugeLevel);
		}
	
	private function initPlugin(e:TimerEvent):void{
			
			if(root != null && pluginName !=''){
				errorType = new ModelErrors();
				dispatchedObjects = root.indSuspender;//Чтобы дальше root не встречался в тексте
				configuration = root.configuration;
				optionPath = 'plugins.'+ pluginName + '.';//Формируем путь к настройкам ф XML файле на основе имя файла плагина
				
				var rawData:String = configuration.getOption(optionPath + 'data');
				var time:int;
	
				debugeLevel = configuration.getOption(optionPath + 'debugLevel');
				
				messenger.setDebugLevel (debugeLevel);
				messenger.setMessageMark(pluginName);
				
				signalType = configuration.getOption(optionPath + 'signal');
				killStoped = configuration.getOption(optionPath + 'killStoped');
				
				if(killStoped !='true'&& killStoped !='false'){
					messenger.message('killStoped: ' + errorType.varIsIncorrect, 0);//
					killStoped = 'false';
					}
				
				switch(signalType){
						case 'stop':		
							statMessageHead = 'inactive_ind_numb';
						break;
						case 'kill':
							statMessageHead = 'dead_ind_numb';
						break;
						case 'Error':
							signalType = 'stop';
							statMessageHead = 'inactive_ind_numb';
						default:
							messenger.message('wrong type of signal', 0);
							signalType = 'stop';
							statMessageHead = 'inactive_ind_numb';
				}
				
				activityData = prepareData(rawData);
				time = setTimingQant();
				stopingTimer = new Timer(time);
				stopingTimer.addEventListener(TimerEvent.TIMER, stopInd);
				stopingTimer.start();
			}
		pluginEvent.ready();
		}
	
	private function prepareData(dataString:String):XMLDocument{//Переводим данные об активности из строки в конфиге в XML объект в памяти плагина
		try{
			var dataXML:XMLDocument;
			dataXML = new XMLDocument();
			dataXML.ignoreWhite = true;
			dataXML.parseXML(dataString);
			return dataXML;
		}catch(e:Error){
			msgString = 'Error: data file is corruped';
			messenger.message(msgString, 0);
			}
		}
	
	private function setTimingQant():int{//Расчитываем время между переключениями
		try{
			var stepsFromConfig:String = configuration.getOption(optionPath + 'steps');//Из конфига получаем количество шагов которые должен отработать плагин
			var numberOfSteps:int;//Временной промежуток для таймера
			var numberOfData:int = activityData.firstChild.childNodes.length;//Получаем количество заданных вариантов
			var timeQant:int;
		
			if(dispatchedObjects[0] == undefined){
				throw new Error('Can not find dispatchedObjects');
				}else{
					timeQant = dispatchedObjects[0].getTimeQuant();//Получаем время переключения активности из первого драйвера особи
					}
		
			if(stepsFromConfig == 'Error'){
				throw new ArgumentError('Number of steps do not set. get it from lifeTime option'); 
				}else{
					numberOfSteps = Math.round((int(stepsFromConfig)/numberOfData)*timeQant);//Расчитываем временной промежуток для таймера как (Количество шагов/Количество вариантов)*время таймера
					}
		
			}catch(e:ArgumentError){
	
				messenger.message(e, 0)
				numberOfSteps = int(configuration.getOption('main.lifeTime'));//Есл особии количество шагов не заданно, принимаем его как время жизн
				}
			catch(e:Error){
				msgString = e;
				messenger.message(msgString, 0);
				timeQant =20;
				}
			
			return numberOfSteps;
		}
	
	private function stopInd(e:TimerEvent):void{
		//Узнать размер таймера у особи, посмотреть число ходов в конфиге, запускать паузы по таймеру и не ждать ответа от драйверов особей
		try{
			var currentActivity:int;
			
			if(currentActivitIndNumber > activityData.firstChild.childNodes.length - 1){
				msgString = 'New cycle: ' + currentActivitIndNumber;
				messenger.message(msgString, 3) 
				currentActivitIndNumber = 0;
					
				}else{
				currentActivity = int(activityData.firstChild.childNodes[currentActivitIndNumber].firstChild);
				currentActivitIndNumber++;
			}
				stopOnly(currentActivity, 'percents');
			
				msgString = 'Current stoped individuals part is = ' +  currentActivitIndNumber + ':'+ currentActivity;
				messenger.message(msgString, 3);
				msgString = statMessageHead + ':' + currentActivity;
				messenger.message(msgString, 10);//Посылаем данные о количестве неактивных особей как статистику
				
				
			}catch(e:Error){
				messenger.message(e, 0);
				}
		}
			
	private function stopOnly(objNumber:int, unit_type:String):void{
	//Передаются два параметра - число особей, которое надо остановить и единицы измерения - проценты или штуки
		var itemsNumber:int;
		stopedObjects = new Array;
	
		switch(unit_type){
		case 'percents':

			itemsNumber = 0;
			itemsNumber = Math.round((objNumber/100)*dispatchedObjects.length)//Высчитываем количество из процентов
			for(var i:int = 0; i< itemsNumber; i++){
			
			stopedObjects[i] = setObjRange();
			}
			sendStop();
		break;

		case 'items':
			itemsNumber = 0
			itemsNumber = objNumber;
			for(i = 0; i< itemsNumber; i++){
				stopedObjects[i] = setObjRange()
			}
			
			sendStop();
		break;
		
		default:
			itemsNumber = 0
			messenger.message('wrong unit type', 0);
		}
	}
	private function setObjRange():int{//поиск случайной особи
		var stopedObjPosition:int = 0;
		
			stopedObjPosition = Math.round(Math.random()*dispatchedObjects.length);
			
			if(dispatchedObjects[stopedObjPosition]==null){//Если особь существует и движеться
				stopedObjPosition = setObjRange();
				}
				
		return stopedObjPosition;
	}

	private function sendStop():void{
		try{
			for(var i:int = 0; i<stopedObjects.length; i++){
		
				if(dispatchedObjects[stopedObjects[i]] != null){
					switch(signalType){
						case 'stop':		
							dispatchedObjects[stopedObjects[i]].stopIndividual(suspendTime);//Останавливаем особь на нужное время
						break;
						case 'kill':
							if(killStoped =='true'){//Если можно, убиваем всех особей из выборки
								dispatchedObjects[stopedObjects[i]].killIndividual();
							}else{
								if(dispatchedObjects[stopedObjects[i]].indState()=='moved'){
									dispatchedObjects[stopedObjects[i]].killIndividual();//А иначе убиваем только тех, кто движеться
									}
								}
						break;
						default:
							messenger.message('wrong type of signal', 0);
				}
				
				}
				
			}
		}
		catch(e:Error){

		}
	
	
	}
}
}
