package konstantinz.plugins{
		
	public class MorisitaTask extends Task{
		
		public var releveSize:int;//Количество пробных площадок
		public var plotsXQuantaty:int;//Колиство квадратов в ряду
		public var plotsYQuantaty:int;//Колиство квадратов в столбце
		public var plotsPosition:Array;//Координаты площадок (чтобы не высчитывать их каждый раз заново)
		public var plotsCells:Array;
		public var investigatedAreaPosition:Array;//Координаты верхнего и нижнего углов зоны, в которой будет высчитываться показатель
		
		function MorisitaTask(){
			
		};
	}
	
}
