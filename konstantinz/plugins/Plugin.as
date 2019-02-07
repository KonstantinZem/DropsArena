package konstantinz.plugins{
	
	import flash.display.Sprite;
	import flash.utils.*;
	import konstantinz.community.auxilarity.*;
	import konstantinz.community.comStage.*;
	import konstantinz.plugins.*;

public class Plugin extends Sprite{
	//Для всех плагинов общим будет код загрузки в память главной програмы, получение ссылок на такие ее структуры как сцена и особи
	
	protected var optionPath:String;//Указывает на место хранения количества активных особей в конфиге
	protected var debugeLevel:String;
	protected var statMessageHead:String;
	protected var switchingEvent:String;//steps переключается по сигналам от таймера or calendar_data - переключается по сигналам от другого плагина
	protected var switchingIntervalHasChanged:String;//Этот флаг поднимается, если на какое то время интервал между включениями плагина меняется со значения по умолчанию
	protected var msgString:String;
	protected var newStatisticMsg:Array;
	protected var currentDay:String;
	protected var currentDuration:int;//Переменная создана на тот случай, если для какого то отдельного наблдения нужно указать точное количество шагов
	protected var alreadyInited:String;
	protected var switchingInterval:int;//Интервал между включениями плагина
	protected var previosSwitchingInterval:int//Сюда будем сохранять предыдущий интервал между переключениями, чтобы позднее к нему вернуться
	protected var processingTimes:int//Количество циклов, оставшиеся до следующего срабатывания
	protected var prevStatisticMsg:String;//Статистические сообщения могут идти так интенсивно, что лучше хранить предыдущие сообщение и не реагировать на него, если оно придет несколько раз
	
	protected var errorType:ModelErrors;
	protected var modelEvent:ModelEvent
	protected var configuration:ConfigurationContainer;
	protected var communityStage:CommunityStage;
	
	public var messenger:Messenger;
	public var pluginName:String; //В эту переменную загрузчик плагина передает его имя
	public var pluginEvent:DispatchEvent;
	public var activeOnLoad:String;

	public function Plugin(){
		
		debugeLevel = '3'
		pluginName = 'noname';
		alreadyInited = 'fals';
		processingTimes = 0;
		
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
			optionPath = 'plugins.'+ pluginName + '.';//Формируем путь к настройкам в XML файле на основе имя файла плагина
			communityStage = root.commStage;
				
			debugeLevel = configuration.getOption(optionPath + 'debugLevel');
				
			messenger.setDebugLevel (debugeLevel);
			messenger.setMessageMark(pluginName);
				
			msgString = 'Plugin ' + pluginName + ' has loaded';
			messenger.message(msgString, modelEvent.INIT_MSG_MARK);
				
			switchingEvent = configuration.getOption(optionPath + 'switchingEvent');
			switchingInterval = int(configuration.getOption(optionPath + 'switchingInterval'));
				
				if(switchingInterval == 0){
					msgString = 'Plugin ' + pluginName + ' switching interval not set. Plugin will start one time';
					messenger.message(msgString, modelEvent.INIT_MSG_MARK);
					}
				
				if(switchingEvent != 'steps' && switchingEvent != 'calendar_data'){//Если в конфиге тип переключения не указан или указан неправильно
					switchingEvent = 'steps';//даем переменной значение по умолчанию steps
					msgString = errorType.varIsIncorrect + '. ' + errorType.defaultValue + '- steps';
					messenger.message(msgString, modelEvent.INFO_MARK);
					}
			
			initSpecial();
			alreadyInited = 'true';//Помечаем что мы уже инициированы
			}
		
		}
	
	protected function setNewSwitchingInterval(newInterval:int):void{//Если надо где то задать особый интервал между переключениями плагина
		
		if(newInterval == 0){
			
			switchingIntervalHasChanged = 'false';
			msgString = '[' + currentDay + ']' + ' Switching interval has changed from ' + switchingInterval + ' steps to ' + previosSwitchingInterval + ' steps';
			messenger.message(msgString, modelEvent.INFO_MARK);
			switchingInterval = previosSwitchingInterval;
		}else{
			switchingIntervalHasChanged = 'true';
			previosSwitchingInterval = switchingInterval;//Возвращаем ранее сохраненное значение интервала переключения
			switchingInterval = newInterval;
			msgString = '[' + currentDay + ']' + ' Switching interval has changed from ' + previosSwitchingInterval + ' steps to ' + newInterval + ' steps';
			messenger.message(msgString, modelEvent.INFO_MARK);
			}
		}
		
	public function initSpecial():void{//В этой функции будут инициироваться объекты и переменные, специфические для конкретного типа плагинов
		
		}
		
	public function startPluginJobe():void{
		
		}
	
	public function process():void{//Функция вызывается из main каждый раз, после цикла движения особей. Запускается если задан switchingInterval
		if(switchingEvent == 'steps'){
			if(switchingInterval > 0 && processingTimes == switchingInterval){//Если плагин выждал нужное количество шагов
				startPluginJobe();
				processingTimes = 0;
				}else{
					processingTimes ++;
					}
				}
			}
	
	public function startPlugin(e:ModelEvent):void{
		
		}
	
	public function suspendPlugin(e:ModelEvent):void{
		
		}
		
	public function onNewStatistic(e:ModelEvent):void{//За счет этой функции плагин периодически запускается 
		if(prevStatisticMsg != e.target.message && switchingEvent == 'calendar_data' && e.target.target != pluginName){//Если к нам не пришло наше собственное сообщение
			prevStatisticMsg = e.target.message;
			newStatisticMsg = e.target.message.split(':');
			
			if(currentDay == newStatisticMsg[1]){
				startPluginJobe();//Запускаем основной функционал плагина
				}
			}
		}

}
}
