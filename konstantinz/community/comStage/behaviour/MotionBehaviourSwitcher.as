package konstantinz.community.comStage.behaviour{
	//При коррекции моделей поведения изменения будут вносится сюда, в то время как класс Individual останется неизменным

	import konstantinz.community.comStage.*;
	
public class MotionBehaviourSwitcher{
	
	private var baseMotionBehaviour:BaseMotionBehaviour;
	private var bestConditionsWalker:BestConditionsWalker;
	private var momentalDeath:MomentalDeath;
	private var indSuspender:StepDispatcher;
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
		
	public function setSuspender(suspender:StepDispatcher):void{
		indSuspender = suspender;
		momentalDeath.setSuspender(indSuspender);
		}
	
	public function setViewDistance(distant:int):void{
		viewDistance = distant;
		bestConditionsWalker.setViewDistance(viewDistance);
		}
		
	public function switchBehaviour(behaviourName:String):void{
				
			if(currentBehaviourName != behaviourName && indSuspender.statement() != 'dead' && indSuspender.statement() != 'stop'){
				currentBehaviourName = behaviourName;
				
				switch(behaviourName){
					
					case 'RandomWalker':
						newBehaviour = baseMotionBehaviour;
					break;
					
					case 'BestConditionsWalker':
						newBehaviour = bestConditionsWalker;
						bestConditionsWalker.reset();//Если поведение переключилось когда остались шаги, их предварительно надо сбросить
					break;
					
					case 'MomentalDeath':
						
						momentalDeath.killIndividual();
					break;
					default:
						newBehaviour = baseMotionBehaviour;
					break;
					
					}
				}
			}
		public function getCurrentBehaviour():String{
			return currentBehaviourName;
			}
	}

}
