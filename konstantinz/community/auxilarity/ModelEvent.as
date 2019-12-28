package konstantinz.community.auxilarity{
	import flash.events.Event;
	public class ModelEvent extends Event{
		 public static const MATURING:String = 'maturing';
		 public static const LOADING_ERROR:String = 'loading_error';
		 public static const FINISH:String = 'finish';
		 public static const PLUGIN_LOADED:String = 'plugin_loaded';
		 public static const DEATH:String = 'death';
		 public static const DONE:String = 'done';//Так мы говорим, что какой либо компонент сделал то что от него требовалось
		 public static const SCROLLER_DATA:String = 'scroller_data';
		 public static const CLICKING:String = 'clicking';
		 public static const FIRST_CLICK:String = 'firstClick';
		 public static const SECOND_CLICK:String = 'secondClick';
		 public static const NEW_STATISTIC:String = 'new_statistic';
		 public const ERROR_MARK:int = 0;//Сообщение об ошибке помечаются в messanger помечаеся цифрой 0
		 public const INIT_MSG_MARK:int = 1;//Сообщения, при загрузки - выгрузки компонентов
		 public const INFO_MARK:int = 2;
		 public const DEBUG_MARK:int = 3;
		 public const IOERROR_MARK:int = 4;//Ошибки, возникающие при невозможности загрузить внешний компонент
		 public const STATISTIC_MARK:int = 11;//Сообщение статистического характера помечаются в messanger помечаеся цифрой 11
		
		 public function ModelEvent(type:String='') {
             super(type);
        }
		 public override function toString():String { 
            return formatToString('ModelEvent');
        }
		
		}
}
