package konstantinz.plugins{

import flash.events.Event

	import flash.display.Sprite;
	import flash.events.TimerEvent; 
	import flash.utils.*;
	import konstantinz.community.auxilarity.*;
	import konstantinz.plugins.*;
	import flash.xml.*
    
public class activitySwitcher extends Sprite{
	private var stopingTimer:Timer
	var timerStatement:String
	public var pluginName:String; //Должна быть включена в интерфейс этого типа плагинов
	public var pluginEvent:Object;
	private var dispatchedObjects:Array//Ссылка на массив с управляемыми объектами
	private var objectsRange:Array;
	private var suspendTime:int;
	private var activityData:XMLDocument;//Здесь будет хранится массив данных с информацией об активности
	private var stopedObjects:Array;//Список остановленных в данный момент особей
	private var stopedNumber:int;
	private var listenedSuspender:int
	private var currentActivitIndNumber:int = 0
	private var debugeLevel:String;
	private var debugeMessage:DebugeMessenger
	private var msgString:String;
	
	var timer:Timer;
	
	function activitySwitcher(){
		pluginEvent = new DispatchEvent();
		timer = new Timer(1000, 1);//Ждем некоторое время, пока в главная программа не передаст нужные плагину параметры
		timer.addEventListener(TimerEvent.TIMER, initPlugin);// потом запускаем программу
		timer.start();
		suspendTime = 5000
		
		}
	
	private function initPlugin(e:TimerEvent):void{
		
		timerStatement = 'start';
		
			if(root != null){
				var rawData:String = root.configuration.getOption('plugins.activity.data');
				debugeLevel = '3';
				debugeLevel = root.configuration.getOption('plugins.activity.debugLevel');
				debugeMessage = new DebugeMessenger(debugeLevel);
				debugeMessage.setMessageMark('Activity');
				
				var time:int
				activityData = prepareData(rawData);
				
				dispatchedObjects = root.indSuspender;
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
			debugeMessage.message(msgString, 0)
			}
		}
	
	private function setTimingQant():int{//Расчитываем время между переключениями
		try{
			var stepsFromConfig:String = root.configuration.getOption('plugins.activity.steps');//Из конфига получаем количество шагов которые должен отработать плагин
			var numberOfSteps:int;
			var numberOfData:int = activityData.firstChild.childNodes.length;//Получаем количество заданных вариантов
			var timeQant:int;
		
			if(dispatchedObjects[0] == undefined){
				throw new Error('Can not find dispatchedObjects')
				}else{
					timeQant = dispatchedObjects[0].getTimeQuant();//Получаем время переключения активности из первого драйвера особи
					}
		
			if(stepsFromConfig == 'Error'){
				throw new ArgumentError('Number of steps do not set. get it from lifeTime option'); 
				}else{
					numberOfSteps = Math.round((int(stepsFromConfig)/numberOfData)*timeQant);//Расчитываем временной промежуток для таймера
					}
			
			return numberOfSteps
		
			}catch(e:ArgumentError){
	
				debugeMessage.message(e, 0)
				numberOfSteps = int(root.configuration.getOption('main.lifeTime'));
				}
			catch(e:Error){
				msgString = e
				debugeMessage.message(msgString, 0)
				timeQant =20
				}
		}
	
	private function stopInd(e:TimerEvent):void{
		//Узнать размер таймера у особи, посмотреть число ходов в конфиге, запускать паузы по таймеру и не ждать ответа от драйверов особей
		try{
			var currentActivity:int
			
			if(currentActivitIndNumber > activityData.firstChild.childNodes.length - 1){
				msgString = 'New cycle: ' + currentActivitIndNumber
				debugeMessage.message(msgString, 3) 
				currentActivitIndNumber = 0;
					
				}else{
				currentActivity = int(activityData.firstChild.childNodes[currentActivitIndNumber].firstChild);
				currentActivitIndNumber++;
			}
				stopOnly(currentActivity, 'percents');
			
				msgString = 'Current stoped individuals part is = ' +  currentActivitIndNumber + ':'+ currentActivity;
				debugeMessage.message(msgString, 3);
				
				
			}catch(e:Error){
				debugeMessage.message(e, 0)
				}
		}
			
	private function stopOnly(objNumber:int, unit_type:String):void{
	//Передаются два параметра - число особей, которое надо остановить и единицы измерения - проценты или штуки
		var itemsNumber:int;
		stopedObjects = new Array;
	
		switch(unit_type){
		case 'percents':

			itemsNumber = 0
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
			debugeMessage.message('wrong unit type', 0);
		}
	}
	private function setObjRange():int{
		var stopedObjPosition:int = 0
		
			stopedObjPosition = Math.round(Math.random()*dispatchedObjects.length);
			
			if(dispatchedObjects[stopedObjPosition]==null){
				stopedObjPosition = setObjRange()
				}
				
		return stopedObjPosition
	}

	private function sendStop():void{
		try{
			for(var i:int = 0; i<stopedObjects.length; i++){
		
				if(dispatchedObjects[stopedObjects[i]] != null){
			
				dispatchedObjects[stopedObjects[i]].stopIndividual(suspendTime);//Останавливаем особь на нужное время
				listenedSuspender = i;
				
				}
				
			}
		}
		catch(e:Error){

		}
	
	
	}
}
}
