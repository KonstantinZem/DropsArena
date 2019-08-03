package konstantinz.plugins{
	import flash.geom.ColorTransform;
	import flash.display.Loader;
		
	public class CoverTask extends Task{
		
		//Global options
		public var currentDayPosition:Array;
		//Behaviour
		public var behaviourFrequency:int;
		public var behaviourModelName:String;//Как себя должна вести особь, если попадет на данную клетку
		public var aDeley:int//Задержка при движении взрослых особей. Должна быть включена в интерфейс этого типа плагинов
		public var yDeley:int//Задержка при движении молодых особей. Должна быть включена в интерфейс этого типа плагинов
		//Image options
		public var loader:Loader;
		public var imageName:String;
		//Color shema
		public var background:ColorTransform;
		public var useColorBackground:String = 'true';
		public var coverShema:Array;//Схема напочвенного покрова может загружаться в процессе работы программы несколько раз. Чтобы не загружать битмап каждый раз, надо заранее создать схему
		public var color:Number; //Определяет цвет участка с данными характеристиками
		public var previosBackground:ColorTransform;//Какой цвет имела ячейка перед изменением (сохраняем на всякий случай)
		
		function CoverTask(){
			
		};
	}
	
}
