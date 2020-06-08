package konstantinz.community.comStage{

public class IndividualState{
	public var currentX:int = 0;//Её текущие координаты на экране
	public var currentY:int = 0;
	public var previousX:int = 0;//Е1 предыдущие координаты
	public var previousY:int = 0;
	public var direction:int = 0;
	public var border:Boolean = false;
	public var behaviour:String = '';
	public var statement:String = '';
	public var age:String = '';
	public var cellX:int = 0;//Еее текущие положение в массиве cessDesk
	public var cellY:int = 0;
	public var name:int;//Номер особи
	
	
	public function IndividualState():void{
		
	};
	
}
}
