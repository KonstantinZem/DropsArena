package konstantinz.community.auxilarity{

	import konstantinz.community.auxilarity.ModelEvent;
	import flash.events.EventDispatcher;	
	
	//Класс предназначен для рассылки событий из тех компонентов, которые не могут рассылать их сами
	public class DispatchEvent extends EventDispatcher {
		public var currentChessDeskI:int;//Посылаем вместе с событием координаты объекта вызвавшего его
		public var currentChessDeskJ:int;
		public var pluginName:String;//Передаем плагину его имя так как сам он его не узнает. А это надо для загрузки, например, конфига
		public var individual:int;//Передаем номер особи в массиве
		public var scrollerPosition:Number;
		public var scrollingDirection:String;
		public var clickMessag:String;
		
		public function DispatchEvent(){
		}		
		public function maturing():void{
			dispatchEvent(new ModelEvent(ModelEvent.MATURING));
			currentChessDeskI = 0;
			currentChessDeskJ = 0;
		}
		
		public function death():void{
			dispatchEvent(new ModelEvent(ModelEvent.DEATH));	
		}
		
		public function ready():void{
			dispatchEvent(new ModelEvent(ModelEvent.FINISH));
		}
		
		public function pluginLoaded():void{
			dispatchEvent(new ModelEvent(ModelEvent.PLUGIN_LOADED));
			//pluginName = '';//Очищаем переменную после использования
		}
		
		public function done():void{
			dispatchEvent(new ModelEvent(ModelEvent.DONE));
			
		}
		
		public function clicking(clickNumber:String='single_click'):void{
			switch(clickNumber){
				case 'first_click':
					dispatchEvent(new ModelEvent(ModelEvent.FIRST_CLICK));
				break;
				case 'second_click':
					dispatchEvent(new ModelEvent(ModelEvent.SECOND_CLICK));
				break;
				case 'single_click':
					dispatchEvent(new ModelEvent(ModelEvent.CLICKING));
				break;
				default:
					trace('Wrong signal')
				}
			
			}
		
		public function scrolling():void{
			dispatchEvent(new ModelEvent(ModelEvent.SCROLLER_DATA));
		}	
			
	}
}
