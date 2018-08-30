package konstantinz.community.comStage.behaviour{
	//При коррекции моделей поведения изменения будут вносится сюда, в то время как класс Individual останется неизменным

	import konstantinz.community.comStage.*;
	
public class MotionBehaviourSwitcher{
	
	private var baseMotionBehaviour:BaseMotionBehaviour;
	private var bestConditionsWalker:BestConditionsWalker;
	private var momentalDeath:MomentalDeath;
	private var indSuspender:Suspender;
	private var currentBehaviourName:String;
	private var viewDistance:int;
	private var populationArea:Array;
	
	public var newBehaviour:BaseMotionBehaviour;

	public function MotionBehaviourSwitcher(currentPopulationArea:Array){
		baseMotionBehaviour = new BaseMotionBehaviour();
		bestConditionsWalker = new BestConditionsWalker();
		momentalDeath = new MomentalDeath();
		populationArea = currentPopulationArea;
		
		viewDistance = 5;
		
		newBehaviour = baseMotionBehaviour;
		
		baseMotionBehaviour.setPopulationArea(populationArea);
		bestConditionsWalker.setPopulationArea(populationArea);
		bestConditionsWalker.setViewDistance(viewDistance);
		
		
		currentBehaviourName = 'RandomWalker';
		}
	public function setSuspender(suspender:Suspender):void{//Для некоторых моделей поведения надо будет обращаться к объктам вне особи
		indSuspender = suspender;
		momentalDeath.setSuspender(indSuspender);
		}
	
	public function setViewDistance(distant:int):void{
		viewDistance = distant;
		bestConditionsWalker.setViewDistance(viewDistance);
		}
		
	public function switchBehaviour(behaviourName:String):void{
				
			if(currentBehaviourName !=behaviourName && indSuspender.indState() != 'stoped'){
				currentBehaviourName = behaviourName;
				
				switch(behaviourName){
					
					case 'RandomWalker':
						newBehaviour = baseMotionBehaviour;
					break;
					
					case 'BestConditionsWalker':
						newBehaviour = bestConditionsWalker;
					break;
					
					case 'MomentalDeath':
						
						momentalDeath.killIndividual();
					break;
					default:
						newBehaviour = baseMotionBehaviour;
					break
					
					}
				}
			}

}

}
