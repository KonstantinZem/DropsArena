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
	


public class activitySwitcher extends Sprite{
	var myTimer:Timer
	var timerStatement:String
	public var pluginName:String; //Должна быть включена в интерфейс этого типа плагинов
	public var pluginEvent:Object;
	private var dispatchedObjects:Array//Ссылка на массив с управляемыми объектами
	private var objectsRange:Array
	private var suspendTime:int

	private var stopedObjects:Array
	var timer:Timer
	
	function activitySwitcher(){
		pluginEvent = new DispatchEvent();
		timer = new Timer(1000, 1);//Ждем некоторое время, пока в главная программа не передаст нужные плагину параметры
		timer.addEventListener(TimerEvent.TIMER, initPlugin);// потом запускаем программу
		timer.start();
		suspendTime = 5000
		}
	
	function initPlugin(e:TimerEvent):void{
		
		timerStatement = 'start'
		myTimer = new Timer(5000)
		myTimer.addEventListener(TimerEvent.TIMER, stopInd);
			if(root != null){
				dispatchedObjects = root.indSuspender;
				myTimer.start();
			}
		pluginEvent.ready()
		}
	
	private function stopInd(event:TimerEvent):void{
			
			if(timerStatement=='start'){
				stopOnly(30, 'percents');
				timerStatement = 'stop';
			}
			else{
				timerStatement = 'start'
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
			trace('wrong unit type')
		}
	}
	private function setObjRange():int{
		var stopedObjPosition:int = 0
		
			stopedObjPosition = Math.round(Math.random()*dispatchedObjects.length);
			trace('Stoped element is ' + stopedObjPosition)
			
			if(dispatchedObjects[stopedObjPosition]==null){
				stopedObjPosition = setObjRange()
				}
				
		return stopedObjPosition
	}

private function sendStop():void{
	try{
	for(var i:int = 0; i<stopedObjects.length; i++){
		
		if(dispatchedObjects[stopedObjects[i]] != null){
			
			dispatchedObjects[stopedObjects[i]].stopIndividual(suspendTime)
		}
		}
	}
	catch(e:Error){

		}
	
	
	}
}
}
