package konstantinz.plugins{

import flash.events.Event

	import flash.display.Sprite;
	import flash.errors.IllegalOperationError;
	import flash.events.TimerEvent; 
	import flash.utils.*;
	import konstantinz.community.auxilarity.*;
	import konstantinz.community.comStage.*;
	import konstantinz.plugins.*;
    
public class activitySwitcher extends Plugin{
	private const CRITIAL_IND_NUMBER:int = 3;//До какого количество особей плагин будет работать
	private const MAX_OPTIONS_LIST_SIZE:int = 1000;//Чтобы небыло бесконечных поисковых циклов, их надо ограничить
	
	private var dispatchedObjects:Vector.<Suspender>//Ссылка на массив с управляемыми объектами
	private var stopedObjects:Array;//Список остановленных в данный момент особей
	private var optionPosition:Array;
	private var suspendTime:int;//Время на которое нужно остановить особь
	private var numberOfData:int;//Количество наблюдений (переключений) в конфигурационном файле
	private var cycleCounter:int;
	private var currentActivitIndNumber:int = 1;//Позиция в таблице активности где надо искать текущее число особей, которых необходимо остановить
	private var activeIndividualsNumber:String;
	private var timerStatement:String;
	private var signalType:String;
	private var selectionType:String;//percents or items
	private var killStoped:String;//Будудт ли подвержены случайной смерти неактивные особи
	private var dataPath:String;
	private var stopingTimer:Timer;//Этот таймер включается сразу после запуска плагина и заставляет особей останавливаться через заданный промежуток времени
	private var calendarData:String
	private var firstInit:String
	
	public function activitySwitcher(){
		firstInit = 'true';
		killStoped = 'false';
		activeOnLoad = 'true';
		pluginEvent = new DispatchEvent();
		suspendTime = 5000;
		numberOfData = 0;
		messenger.setMessageMark('Activity switcher plugin');
		}
		
	override public function suspendPlugin(e:ModelEvent):void{
		msgString = 'Suspend plugin';
		messenger.message(msgString, modelEvent.INFO_MARK);
		stopingTimer.stop();
		}
	
	override public function startPlugin(e:ModelEvent):void{
		
		msgString = 'Restart plugin ';
		messenger.message(msgString, modelEvent.INFO_MARK);
		
		if(switchingType == 'timer'){
			stopingTimer.start();
			}
			
		}
		
	override public function startPluginJobe():void{
		stopInd();
		}
	
	 override public function initSpecial():void{
		 var time:int;
		 
		 dispatchedObjects = root.indSuspender;//Чтобы дальше root не встречался в тексте
		
		 dataPath = 'plugins.' + pluginName + '.data.observation';
		 calendarData = dataPath + '.day';
				
		 optionPosition = new Array(0,0,0,0,0);
				
		 currentDay = configuration.getOption(calendarData, optionPosition);//Берем из аттрибутов дату наблюдения
				
		signalType = configuration.getOption(optionPath + 'signal');
								
		if(signalType=='kill'){//Если плагин настроен чтобы убивать особей
		   killStoped = configuration.getOption(optionPath + 'killStoped');//Узнаем, должны ли мы убивать всех подряд или только активных осоей
				
			if(killStoped !='true' && killStoped !='false'){//Если опция killStoped напсиана неправильно
			   messenger.message('killStoped: ' + killStoped + '. ' + errorType.varIsIncorrect, 0);
			   killStoped = 'false';//Заменяем неправильное значение на значение по умолчанию 
			   }
			}
				
		selectionType = configuration.getOption(optionPath + 'selectionType');
				
				if(selectionType != 'percents' && selectionType != 'items'){
					selectionType = 'percents';
					msgString = errorType.varIsIncorrect + '. ' + errorType.defaultValue + ': percents';
					messenger.message(msgString, modelEvent.ERROR_MARK);
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
							messenger.message('wrong type of signal', modelEvent.ERROR_MARK);
							signalType = 'stop';
							statMessageHead = 'inactive_ind_numb';
				}
				
				time = setTimingQant();
				
				stopingTimer = new Timer(time);
				
				if(switchingType == 'timer'){
					stopingTimer.addEventListener(TimerEvent.TIMER, stopIndByTimer);
					}
				
				if(activeOnLoad=='true' && switchingType == 'timer'){
					stopingTimer.start();
					}
					
				cycleCounter = 1;
				msgString = 'cycle: ' + cycleCounter;
				
				setTimeout(pluginEvent.ready, 500);//Сообщение о том что плагин полностью готов к работе принимается функцией onPluginsJobeFinish в pluginLoader
		}
	
	private function setTimingQant():int{//Расчитываем время между переключениями
		try{
			var stepsFromConfig:String = configuration.getOption(optionPath + 'steps');//Из конфига получаем количество шагов которые должен отработать плагин
			var numberOfSteps:int;//Временной промежуток для таймера
			activeIndividualsNumber = dataPath + '.part';
			
			var timeQant:int;
			
			numberOfData = getNumberOfData(activeIndividualsNumber);//Получаем количество заданных вариантов
			
			if(dispatchedObjects[0] == undefined){
				throw new ReferenceError('Can not find dispatchedObjects');
				}else{
					timeQant = dispatchedObjects[0].getTimeQuant();//Получаем время переключения активности из первого драйвера особи
					}
		
			if(stepsFromConfig == 'Error'){
				throw new ArgumentError('Number of steps:' + errorType.varIsIncorrect + '. Get it from lifeTime option'); 
				}else{
					numberOfSteps = Math.round((int(stepsFromConfig)/numberOfData)*timeQant);//Расчитываем временной промежуток для таймера как (Количество шагов/Количество вариантов)*время таймера
					}
		
			}catch(e:ArgumentError){
				messenger.message(e.message, modelEvent.ERROR_MARK);
				numberOfSteps = int(configuration.getOption('main.lifeTime'));//Если для особии количество шагов не заданно, принимаем его как время жизн
				}
			
			catch(e:ReferenceError){
				msgString = e.message;
				messenger.message(msgString, modelEvent.ERROR_MARK);
				timeQant = 20;//Если не удалось получить информацию о частоте срабатывания таймера от драйвера особи, задаем таймер сами
				}
			
			return numberOfSteps;
		}
	
	private function getNumberOfData(dataPath:String):int{
		var numberOfData:int = 0;
		var optionValue:String = 'empty';
		
		try{
		
			while(optionValue != 'Error'){
				
				optionValue = configuration.getOption(activeIndividualsNumber, optionPosition);
				
				if(optionValue == null){
					throw new Error('OptionValue is null');
				}
				if(numberOfData > MAX_OPTIONS_LIST_SIZE){
					throw new Error('To much search repitings');//Если есть угроза войти в бесконечный цикл, аварийно выходим
					}
			
				numberOfData++;
				optionPosition[3] = numberOfData;
			}
			
		}catch(e:Error){
			msgString = e.message;
			messenger.message(msgString, modelEvent.ERROR_MARK);
			}
		return numberOfData;
		}
	
	private function stopIndByTimer(e:TimerEvent):void{
	
		if(switchingType == 'timer'){
			stopInd();
			}
		}
			
	private function stopInd():void{
		
		optionPosition[3] = currentActivitIndNumber;
		//Узнать размер таймера у особи, посмотреть число ходов в конфиге, запускать паузы по таймеру и не ждать ответа от драйверов особей
		try{
			var currentActivity:int;
		
			if(currentActivitIndNumber > (numberOfData - 2)){
				
				currentActivitIndNumber = 0;
				cycleCounter++;
				
					if(switchingType == 'timer'){
						msgString = 'cycle: ' + cycleCounter;
						messenger.message(msgString, modelEvent.STATISTIC_MARK);	
						}
				}else{
					currentActivitIndNumber++;
					currentActivity = int(configuration.getOption(activeIndividualsNumber, optionPosition));
					currentDay = configuration.getOption(calendarData, optionPosition);//Берем из конфига следующую дату
					}
							
				stopOnly(currentActivity, selectionType);
				

				msgString = 'Current stoped individuals part is ' +  currentActivitIndNumber + ':'+ currentActivity;
				messenger.message(msgString, 3);
				
				
				if(currentActivity != 'Error'){
					msgString = statMessageHead + ':' + currentActivity;
					messenger.message(msgString, modelEvent.STATISTIC_MARK);//Посылаем данные о количестве неактивных особей как статистику
					}
					
				if(switchingType == 'timer' && currentDay != 'Error'){
					msgString = 'calendar_data' + ':' + currentDay;//Передаем в статистику дату наблюдения
					messenger.message(msgString, modelEvent.STATISTIC_MARK);
					}
				
				}catch(e:Error){
					messenger.message(e.message, modelEvent.ERROR_MARK);
					}
		}
	
	private function stopOnly(objNumber:int, unit_type:String):void{
	//Передаются два параметра - число особей, которое надо остановить и единицы измерения - проценты или штуки
		var itemsNumber:int;
		stopedObjects = new Array;
		
		try{
	
		switch(unit_type){
		case 'percents':

			itemsNumber = 0;
			itemsNumber = Math.round((objNumber/100)*(dispatchedObjects.length))//Высчитываем количество из процентов
			
			for(var i:int = 0; i< itemsNumber; i++){//Определяем количество особей, которых надо остановить
				stopedObjects[i] = setObjRange();
				}
			stopedObjects.sort(Array.DESCENDING);//Это нужно, чтобы элементы удалялись один за одним начиная с самого последнего иначе есть риск обратится к уже несуществующему элементу
			
			for(i = 1; i< stopedObjects.length; i++){//По возможности убираем повторяющиеся элементы сдвигая их на шаг вперед. Понятно что снижает скорость, зато увеличивает точность
				if(stopedObjects[i]==stopedObjects[i-1]){
					stopedObjects[i]++;
					}
				}
			
			sendStop();
			
		break;

		case 'items':
			itemsNumber = 0;
			itemsNumber = objNumber - 1;
			
			for(i = 0; i< itemsNumber; i++){
				stopedObjects[i] = setObjRange();
				}
			
			stopedObjects.sort(Array.DESCENDING);//Это нужно, чтобы элементы удалялись один за одним начиная с самого последнего иначе есть риск обратится к уже несуществующему элементу
			
			for(i = 1; i< stopedObjects.length; i++){//По возможности убираем повторяющиеся элементы сдвигая их на шаг вперед. Понятно что снижает скорость, зато увеличивает точность
				if(stopedObjects[i]==stopedObjects[i-1]){
					stopedObjects[i]++;
					}
				}
			
			sendStop();
			
		break;
		
		default:
			itemsNumber = 0
			messenger.message('Wrong unit type', modelEvent.ERROR_MARK);
		}
	}catch(e:Error){
		messenger.message(e.message, modelEvent.ERROR_MARK);
		}
	}
	
	private function setObjRange():int{//поиск случайной особи
		var stopedObjPosition:int = 0;
		
			stopedObjPosition = Math.round(Math.random()* (dispatchedObjects.length - 2));
			
			if(dispatchedObjects[stopedObjPosition]==null){//Если особь существует и движеться
				stopedObjPosition = setObjRange();
				}
				
		return stopedObjPosition;
		}

	private function sendStop():void{
		var counter:int;
		try{
			if((dispatchedObjects.length - 1) < CRITIAL_IND_NUMBER){
				throw new IllegalOperationError(errorType.tooSmall + '. Number of individals less then critical');
				}
			
			for(var i:int = 0; i< stopedObjects.length; i++){//Пробигаемся по списку особей, которых надо остановить
				
				if(dispatchedObjects[stopedObjects[i]] != null){
				
					switch(signalType){
						case 'stop':	
						
							if(dispatchedObjects[stopedObjects[i]].hasOwnProperty('stopIndividual')){
								dispatchedObjects[stopedObjects[i]].stopIndividual(suspendTime);//Останавливаем особь на нужное время
							}
							else{
								throw new ReferenceError('Can not find function stopIndividual. It seems, that individual now not exist');
								}
						break;
						
						case 'kill':
							
							if(dispatchedObjects[stopedObjects[i]].hasOwnProperty('killIndividual')){
								
								if(killStoped =='true'){//Если можно, убиваем всех особей из выборки
									dispatchedObjects[stopedObjects[i]].killIndividual();
									
									}else{
										if(dispatchedObjects[stopedObjects[i]].indState()=='moved'){
											dispatchedObjects[stopedObjects[i]].killIndividual();//А иначе убиваем только тех, кто движеться
											}
									
										}
									}
									else{
										throw new ReferenceError('Can not find function killIndividual. It seems, that individual now not exist');
										}
						break;
						default:

							messenger.message('Wrong type of signal', modelEvent.ERROR_MARK);
					}
				
				}
				
			}
			
		}
		catch(e:IllegalOperationError){
			messenger.message(e.message, modelEvent.ERROR_MARK);
			stopingTimer.stop();//Прекращаем работу плагина
			messenger.message('Activity switcher plugin has finished working', 2);
		}
		catch(e:ReferenceError){
			messenger.message(e.message, modelEvent.ERROR_MARK);
			}
		catch(e:Error){
			messenger.message(e.message, modelEvent.ERROR_MARK);
			}
	}
}
}
