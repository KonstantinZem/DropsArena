package konstantinz.community.auxilarity{
	import flash.events.Event;
	public class ModelEvent extends Event{
		 public static const MATURING:String = 'maturing';
		 public static const LOADING_ERROR:String = 'loading_error';
		 public static const FINISH:String = 'finish';
		 public static const PLUGIN_LOADED:String = 'plugin_loaded';
		 public static const DEATH:String = 'death';
		 public static const DONE:String = 'done';//Так мы говорим, что какой либо компонент сделал то что от него требовалось
		 
		 public function ModelEvent(type:String) {
             super(type);
        }
		 public override function toString():String { 
            return formatToString('ModelEvent');
        }
		
		}
}
