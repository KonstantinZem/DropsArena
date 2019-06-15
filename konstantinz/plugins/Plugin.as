package konstantinz.plugins{
	
	import flash.display.Sprite;
	import flash.utils.*;
	import konstantinz.community.auxilarity.*;
	import konstantinz.community.comStage.*;
	import konstantinz.plugins.*;

public class Plugin extends Sprite{
	//Для всех плагинов общим будет код загрузки в память главной програмы, получение ссылок на такие ее структуры как сцена и особи
	private const MAX_OPTIONS_LIST_SIZE:int = 100;
	
	private var prevStatisticMsg:String;
	private var tLength:int;
	
	protected var optionPath:String;//Указывает на место хранения количества активных особей в конфиге
	protected var debugeLevel:String;
	protected var msgString:String;
	protected var newStatisticMsg:Array;
	
	protected var task:Array;//Здесь каждый бывший плагин будет хранить свои данные
	protected var taskList:Array;
	protected var currentTask:Object;
	protected var alreadyInited:String;
	protected var currentTaskNumber:int;
	
	protected var errorType:ModelErrors;
	protected var modelEvent:ModelEvent
	protected var configuration:ConfigurationContainer;
	protected var communityStage:CommunityStage;
	
	public var messenger:Messenger;
	public var pluginName:String; //В эту переменную загрузчик плагина передает его имя
	public var pluginEvent:DispatchEvent;
	
	public function Plugin(){
		
		debugeLevel = '3';
		pluginName = 'noname';
		alreadyInited = 'fals';
		currentTaskNumber = 0
		
		modelEvent = new ModelEvent();//Будем брать основные константы от сюда
		errorType = new ModelErrors();
		messenger = new Messenger(debugeLevel);
		pluginEvent = new DispatchEvent();
		newStatisticMsg = new Array('','');
		errorType = new ModelErrors();
		}
	
	public function initPlugin(e:ModelEvent):void{//Функция запускается сообщением PLUGIN_LOADED из pluginLoader
			
		if(alreadyInited != 'true'){//Чтобы не инициироваться по сто раз после прихода сообшщения от других плагинов
			dispatchedObjects = root.individuals;//Чтобы дальше root не встречался в тексте
			configuration = root.configuration;
			optionPath = 'plugins.'+ pluginName + '.task.';//Формируем путь к настройкам в XML файле на основе имя файла плагина
			communityStage = root.commStage;
				
			debugeLevel = configuration.getOption(optionPath + 'debugLevel');
				
			messenger.setDebugLevel (debugeLevel);
			messenger.setMessageMark(pluginName);
				
			msgString = 'Plugin ' + pluginName + ' has loaded';
			messenger.message(msgString, modelEvent.INIT_MSG_MARK);
			
			taskList = new Array();
			
			prepareListOfTasks(pluginName, optionPath, taskList);
			
			if(taskList.length > 0){//Надо проверить, чтобы длинна taskList не была отрицательная
				task = new Array(taskList.length - 1);
			}else{
				task = new Array();
			}
			
			tLength = taskList.length;
			for(var i:int = 0; i < tLength; i++){
				initSpecial(task, taskList[i]['name'], taskList[i]['number']);
				}
			alreadyInited = 'true';//Помечаем что мы уже инициированы
			}
		
		}
	private function prepareListOfTasks(pluginName:String, optionPath:String, taskList:Array):int{
		
		var observationPosition:Array = new Array(0,0,0,0);
		var numberOfObservingsInConfig:int = 0;
		var optionValue:String = 'empty';
		var taskName:String = optionPath + 'name';
		
		try{
		
		if(taskList == null){
		   throw new Error('TaskList array not initilizing yet');
		    }
		
		
		
			while(optionValue != 'Error'){//Пока не вышли за пределы списка наблюдений
				
				optionValue = configuration.getOption(taskName, observationPosition);
				
				taskList[observationPosition[2]] = new Array;
				taskList[observationPosition[2]]['number'] = observationPosition[2];
				taskList[observationPosition[2]]['name'] = optionValue;
				
				if(optionValue == null){
					throw new ReferenceError('Can non get current active inividuals number from config');
					}
				if(numberOfObservingsInConfig > MAX_OPTIONS_LIST_SIZE){
					throw new Error('To much search repitings: ' + numberOfObservingsInConfig);//Если есть угроза войти в бесконечный цикл, аварийно выходим
					}
				observationPosition[2]++;
				numberOfObservingsInConfig++;
			}
			taskList.pop();//Последний элемент массива бкдет равен Error, поэтому его надо удалить
			
		}catch(e:Error){
			msgString = e.message;
			messenger.message(msgString, modelEvent.ERROR_MARK);
			}
		
		observationPosition[3] = 0;//Корректируем
		numberOfObservingsInConfig--;//Корректируем
		
		msgString = 'Number of observations is ' + numberOfObservingsInConfig;
		messenger.message(msgString, modelEvent.DEBUG_MARK);
		
		return numberOfObservingsInConfig;
		}
	
	protected function setNewSwitchingInterval(newInterval:int):void{//Если надо где то задать особый интервал между переключениями плагина
		
		if(newInterval == 0){
			switchingIntervalHasChanged = 'false';
			msgString = '[' + currentTask.currentDay + ']' + ' Switching interval has changed from ' + currentTask.switchingInterval + ' steps to ' + currentTask.previosSwitchingInterval + ' steps';
			messenger.message(msgString, modelEvent.INFO_MARK);
			currentTask.switchingInterval = currentTask.previosSwitchingInterval;
		}else{
			switchingIntervalHasChanged = 'true';
			currentTask.previosSwitchingInterval = currentTask.switchingInterval;//Возвращаем ранее сохраненное значение интервала переключения
			currentTask.switchingInterval = newInterval;
			msgString = '[' + currentTask.currentDay + ']' + ' Switching interval has returned from ' + currentTask.previosSwitchingInterval + ' steps to ' + newInterval + ' steps';
			messenger.message(msgString, modelEvent.INFO_MARK);
			}
		}
		
	public function initSpecial(task:Array, taskName:String, taskNumber:int):void{//В этой функции будут инициироваться объекты и переменные, специфические для конкретного типа плагинов
		
		}
		
	protected function setSwitchingInterval(currentTask:Object):int{
		  var newSwitchingInterval:int = 0;
		
			newSwitchingInterval = int(configuration.getOption(optionPath + 'switchingInterval', currentTask.observationPosition));
			
			if(newSwitchingInterval == 0){
				msgString = 'Plugin ' + pluginName + ' switching interval not set. Plugin will start one time';
				messenger.message(msgString, modelEvent.INIT_MSG_MARK);
				}
				return newSwitchingInterval;
		};
	protected function setSwitchingEvent(currentTask:Object):String{
		var newSwitchingEvent:String;
		newSwitchingEvent = configuration.getOption(optionPath + 'switchingEvent', currentTask.observationPosition);
		
		if(newSwitchingEvent != 'steps' && newSwitchingEvent != 'calendar_data'){//Если в конфиге тип переключения не указан или указан неправильно
			newSwitchingEvent = 'steps';//даем переменной значение по умолчанию steps
			msgString = errorType.varIsIncorrect + '. ' + errorType.defaultValue + '- steps';
			messenger.message(msgString, modelEvent.INFO_MARK);
			}
			return newSwitchingEvent;
	};
		
	public function startPluginJobe():void{//В зависимости от типа плагина, содержание тасков будет различаться
		
		}
	
	public function process():void{//Функция вызывается из main каждый раз, после цикла движения особей. Запускается если задан switchingInterval
		for(var i:int = 0; i< tLength; i++){
			
			if(task[i].switchingEvent == 'steps'){
				
				if(task[i].switchingInterval > 0 && task[i].processingTimes == task[i].switchingInterval){//Если плагин выждал нужное количество шагов
					currentTask = task[i];
					startPluginJobe();
					task[i].processingTimes = 0;
					}else{
						task[i].processingTimes ++;
						}
					}
				}
			}
	
	public function startPlugin(e:ModelEvent):void{
		
		}
	
	public function suspendPlugin(e:ModelEvent):void{
		
		}
		
	public function onNewStatistic(e:ModelEvent):void{//За счет этой функции плагин периодически запускается 
		
		if(prevStatisticMsg != e.target.message && e.target.target != pluginName){//Если к нам не пришло наше собственное сообщение
			prevStatisticMsg = e.target.message;
			newStatisticMsg = e.target.message.split(':');
			
			for(var i:int = 0; i < tLength; i++){
				//trace(task[i].name + ': ' + task[i].currentDay)
				if(task[i].switchingEvent == 'calendar_data' && task[i].currentDay == newStatisticMsg[1]){
					currentTask = task[i];
					msgString = 'Plugin get new calendar data '+ e.target.message;
					messenger.message(msgString, modelEvent.DEBUG_MARK);
					startPluginJobe();//Запускаем основной функционал плагина
					}
				}
			}
			messenger.setMessageMark(pluginName);
		}

}
}
