package konstantinz.plugins{
	
	public class Task{
		//Global options
		public var name:String;
		public var number:int;
		public var currentDay:String;
		//Path were options will be observing
		public var dataPath:String;
		public var durationDataPath:String;
		public var observationPosition:Array;//Номер узла в конигурационном файле, в котором находятся настройки для таска
		//Switching options
		public var switchingInterval:int;//Интервал между включениями плагина
		public var previosSwitchingInterval:int//Сюда будем сохранять предыдущий интервал между переключениями, чтобы позднее к нему вернуться
		public var switchingIntervalHasChanged:String;//Этот флаг поднимается, если на какое то время интервал между включениями плагина меняется со значения по умолчанию
		public var switchingEvent:String;//steps переключается по сигналам от таймера or calendar_data - переключается по сигналам от другого плагина
		public var processingTimes:int//Количество циклов, оставшиеся до следующего срабатывания
		
		function Task(){
			debugeLevel = '3';
		}
	}	
}
