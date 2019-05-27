package konstantinz.plugins{
	import flash.geom.ColorTransform;
	import flash.display.Loader;
		
	public class ActivityTask extends Task{
		
		//Global options
		public var firstInit:String;
		public var statMessageHead:String;
		public var numberOfObservingsInConfig:int;//Количество наблюдений (переключений) в конфигурационном файле
		public var activeIndividualsNumberPosition:String;
		//Switching options
		public var currentDuration:int;//Переменная создана на тот случай, если для какого то отдельного наблдения нужно указать точное количество шагов
		public var cycleCounter:int;
		public var currentActivityPosition:int;//Позиция в таблице активности где надо искать текущее число особей, которых необходимо остановить
		//Activity structures and options
		public var activityObservationPosition:Array;//Номер узла в конигурационном файле, в котором находятся данные о количестве активных особей для отдельного таска
		public var stopedIndividuals:Array;//Список остановленных в данный момент особей
		public var signalType:String;//тип сигнала, по которому будет активироваться таск
		public var selectionType:String;//percents or items
		public var killStoped:String;//Можно ли убивать неактивных особей
		
		function ActivityTask(){
			
		};
	}
	
}
