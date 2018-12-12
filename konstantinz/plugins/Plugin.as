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
	protected var switchingType:String;//timer переключается по сигналам от таймера or calendar_data - переключается по сигналам от другого плагина
	protected var switchingIntervalHasChanged:String;//Этот флаг поднимается, если на какое то время интервал между включениями плагина меняется со значения по умолчанию
	protected var msgString:String;
	protected var statisticFromRoot:Array;
	protected var currentDay:String;
	protected var currentDuration:int;//Переменная создана на тот случай, если для какого то отдельного наблдения нужно указать точное количество шагов
	protected var alreadyInited:String;
	protected var switchingInterval:int;//Интервал между включениями плагина
	protected var previosSvitchingInterval:int//Сюда будем сохранять предыдущий интервал между переключениями, чтобы позднее к нему вернуться
	protected var processingTimes:int//Количество циклов, оставшиеся до следующего срабатывания
	
	protected var errorType:ModelErrors;
	protected var modelEvent:ModelEvent
	protected var configuration:ConfigurationContainer;
	protected var communityStage:CommunityStage;
	
	public var messenger:Messenger;
	public var pluginName:String; //В эту переменную загрузчик плагина передает его имя
	public var pluginEvent:DispatchEvent;
	public var activeOnLoad:String;

	public function Plugin(){
		
		debugeLevel = '3';
		pluginName = 'noname';
		alreadyInited = 'fals';
		
		modelEvent = new ModelEvent();//Будем брать основные константы от сюда
		errorType = new ModelErrors();
		messenger = new Messenger(debugeLevel);
		pluginEvent = new DispatchEvent();
		statisticFromRoot = new Array('','');
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
				
			switchingType = configuration.getOption(optionPath + 'switching_event');
			switchingInterval = int(configuration.getOption(optionPath + 'switchingInterval'));
				
				if(switchingInterval == 0){
					msgString = 'Plugin ' + pluginName + ' switching interval not set. Plugin will start one time';
					messenger.message(msgString, modelEvent.INIT_MSG_MARK);
					}
				
				if(switchingType != 'timer' && switchingType != 'calendar_data'){//Если в конфиге тип переключения не указан или указан неправильно
					switchingType = 'timer';//даем переменной значение по умолчанию timer
					msgString = errorType.varIsIncorrect + '. ' + errorType.defaultValue + '- timer';
					messenger.message(msgString, modelEvent.INFO_MARK);
					}
			
			
			initSpecial();
			alreadyInited = 'true';//Помечаем что мы уже инициированы
			}
		
		}
	
	protected function setNewSwitchingInterval(newInterval:int):void{//Если надо где то задать особый интервал между переключениями плагина
		
		if(newInterval == 0){
			
			switchingIntervalHasChanged = 'false';
			msgString = '[' + currentDay + ']' + ' Switching interval has changed from ' + switchingInterval + ' steps to ' + previosSvitchingInterval + ' steps';
			messenger.message(msgString, modelEvent.INFO_MARK);
			switchingInterval = previosSvitchingInterval;
		}else{
			switchingIntervalHasChanged = 'true';
			previosSvitchingInterval = switchingInterval;//Возвращаем ранее сохраненное значение интервала переключения
			switchingInterval = newInterval
			msgString = '[' + currentDay + ']' + ' Switching interval has changed from ' + previosSvitchingInterval + ' steps to ' + newInterval + ' steps';
			messenger.message(msgString, modelEvent.INFO_MARK);
			}
		}
		
	public function initSpecial():void{//В этой функции будут инициироваться объекты и переменные, специфические для конкретного типа плагинов
		
		}
		
	public function startPluginJobe():void{
		
		}
	
	public function process():void{
	
		if(switchingInterval > 0 && processingTimes == switchingInterval){
			startPluginJobe();
			processingTimes = 0;
			}else{
				processingTimes ++;
				}
		}
	
	public function startPlugin(e:ModelEvent):void{
		
		}
	
	public function suspendPlugin(e:ModelEvent):void{
		
		}
		
	public function onNewStatistic(e:ModelEvent):void{//За счет этой функции плагин периодически запускается 
		if(switchingType == 'calendar_data' && e.target != pluginName){//Если к нам не пришло наше собственное сообщение
			statisticFromRoot = e.target.message.split(':');
			
			if(currentDay == statisticFromRoot[1]){
				startPluginJobe();//Запускаем основной функционал плагина
				}
			}
		
		}

}
}
