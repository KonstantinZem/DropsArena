package konstantinz.community.comStage.behaviour{
	//При коррекции моделей поведения изменения будут вносится сюда, в то время как класс Individual останется неизменным

public class MotionBehaviourSwitcher{
	
	private var baseMotionBehaviour:BaseMotionBehaviour;
	private var bestConditionsWalker:BestConditionsWalker;
	private var currentBehaviourName:String;
	private var viewDistance:int
	private var populationArea:Array;
	
	public var newBehaviour:BaseMotionBehaviour;

	public function MotionBehaviourSwitcher(currentPopulationArea:Array){
		baseMotionBehaviour = new BaseMotionBehaviour();
		bestConditionsWalker = new BestConditionsWalker();
		populationArea = currentPopulationArea;
		
		viewDistance = 5;
		
		newBehaviour = baseMotionBehaviour;
		
		baseMotionBehaviour.setPopulationArea(populationArea);
		bestConditionsWalker.setPopulationArea(populationArea);
		bestConditionsWalker.setViewDistance(viewDistance);
		currentBehaviourName = 'RandomWalker';
		}
	
	public function setViewDistance(distant:int):void{
		viewDistance = distant;
		bestConditionsWalker.setViewDistance(viewDistance);
		}
		
	public function switchBehaviour(behaviourName:String):void{
				
			if(currentBehaviourName !=behaviourName){
				currentBehaviourName = behaviourName;
				
				switch(behaviourName){
					
					case 'RandomWalker':
						newBehaviour = baseMotionBehaviour;
					break;
					
					case 'BestConditionsWalker':
						newBehaviour = bestConditionsWalker;
					break;
					default:
						newBehaviour = baseMotionBehaviour;
					break
					
					}
				}
			}

}

}
