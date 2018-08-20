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
	protected var msgString:String;
	protected var statisticFromRoot:Array;
	protected var currentDay:String;
	protected var alreadyInited:String;
	
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
			dispatchedObjects = root.indSuspender;//Чтобы дальше root не встречался в тексте
			configuration = root.configuration;
			optionPath = 'plugins.'+ pluginName + '.';//Формируем путь к настройкам в XML файле на основе имя файла плагина
			communityStage = root.commStage;
				
			debugeLevel = configuration.getOption(optionPath + 'debugLevel');
				
			messenger.setDebugLevel (debugeLevel);
			messenger.setMessageMark(pluginName);
				
			msgString = 'Plugin ' + pluginName + ' has loaded';
			messenger.message(msgString, modelEvent.INIT_MSG_MARK);
				
			switchingType = configuration.getOption(optionPath + 'switching_event');
				
				if(switchingType != 'timer' && switchingType != 'calendar_data'){//Если в конфиге тип переключения не указан или указан неправильно
					switchingType = 'timer';//даем переменной значение по умолчанию timer
					msgString = errorType.varIsIncorrect + '. ' + errorType.defaultValue + '- timer';
					messenger.message(msgString, modelEvent.INFO_MARK);
					}
			
			alreadyInited = 'true';//Помечаем что мы уже инициированы
			initSpecial();
			
			}
		
		}
		
	public function initSpecial():void{//В этой функции будут инициироваться объекты и переменные, специфические для конкретного типа плагинов
		
		}
		
	public function startPluginJobe():void{
		
		}
	
	public function startPlugin(e:ModelEvent):void{
		
		}
	
	public function suspendPlugin(e:ModelEvent):void{
		
		}
		
	public function onNewStatistic(e:ModelEvent):void{
		if(switchingType == 'calendar_data' && e.target != pluginName){//Если к нам не пришло наше собственное сообщение
			statisticFromRoot = e.target.message.split(':');
			
			if(currentDay == statisticFromRoot[1]){
				startPluginJobe();//Запускаем основной функционал плагина
				}
			}
		
		}

}
}
