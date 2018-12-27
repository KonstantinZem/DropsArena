package konstantinz.community.comStage{
	
	import flash.display.Sprite;

public class ChessCell{
	
	public var picture:Sprite;
	public var sqrX:int;
	public var sqrY:int;
	public var speedDeleyA:int;
	public var speedDeleyY:int;
	public var lifeQuant:int;
	public var individualName:int;
	public var numberOfIndividuals:Array;
	public var behaviourModel:String;
	public var cashe:String;
	
	public function ChessCell(){
		numberOfIndividuals = new Array(2);
		numberOfIndividuals['adult'] = 0;
		numberOfIndividuals['young'] = 0;
		}
}

}
