package konstantinz.community.auxilarity{

	import konstantinz.community.auxilarity.ModelEvent;
	import flash.events.EventDispatcher;	
	
	//Класс предназначен для рассылки событий из тех компонентов, которые не могут рассылать их сами
	public class DispatchEvent extends EventDispatcher {
		public var currentChessDeskI:int;//Посылаем вместе с событием координаты объекта вызвавшего его
		public var currentChessDeskJ:int;
		public var pluginName:String;//Передаем плагину его имя так как сам он его не узнает. А это надо для загрузки, например, конфига
		
		public function DispatchEvent(){
		}		
		public function maturing():void{
			dispatchEvent(new ModelEvent(ModelEvent.MATURING));
			currentChessDeskI = 0
			currentChessDeskJ = 0
		}
		
		public function ready():void{
			dispatchEvent(new ModelEvent(ModelEvent.FINISH));
		}
		
		public function pluginLoaded():void{
			dispatchEvent(new ModelEvent(ModelEvent.PLUGIN_LOADED));
			pluginName = "";//Очищаем переменную после использования
		}
	}
}
