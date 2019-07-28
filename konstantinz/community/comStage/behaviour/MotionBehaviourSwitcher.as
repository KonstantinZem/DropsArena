package konstantinz.community.comStage.behaviour{
	//При коррекции моделей поведения изменения будут вносится сюда, в то время как класс Individual останется неизменным

	import flash.events.Event;
	import konstantinz.community.comStage.*;
	import konstantinz.community.auxilarity.*;
	
public class MotionBehaviourSwitcher{
	private const DEFAULT_BEHAVIOUR_NAME:String = 'RandomWalker';
	
	private var baseMotionBehaviour:BaseMotionBehaviour;
	private var bestConditionsWalker:BestConditionsWalker;
	private var momentalDeath:MomentalDeath;
	private var migrationBehaviour:MigrationBehaviour;
	private var indSuspender:StepDispatcher;
	private var messenger:Messenger;
	private var currentBehaviourName:String;//Через эту переменную можно узнать какая линия поведения сейчас активирована
	private var viewDistance:int;
	private var populationArea:Array;
	private var configuration:ConfigurationContainer;
	private var debugLevel:String;
	
	public var newBehaviour:BaseMotionBehaviour;

	public function MotionBehaviourSwitcher(currentPopulationArea:Array, configSource:ConfigurationContainer, dbgLevel:String ='3'){
		debugLevel = dbgLevel;
		configuration = configSource;
		messenger = new Messenger(debugLevel);
		messenger.setMessageMark('Behaviour Switcher');
		
		baseMotionBehaviour = new BaseMotionBehaviour(debugLevel);
		bestConditionsWalker = new BestConditionsWalker(debugLevel);
		migrationBehaviour = new MigrationBehaviour(configuration, debugLevel);
		momentalDeath = new MomentalDeath(debugLevel);
		populationArea = currentPopulationArea;
		
		viewDistance = int(configuration.getOption('main.behaviourSwitching.viewDistance'));
		
		newBehaviour = baseMotionBehaviour;
		
		baseMotionBehaviour.setPopulationArea(populationArea);
		bestConditionsWalker.setPopulationArea(populationArea);
		bestConditionsWalker.setViewDistance(viewDistance);
		migrationBehaviour.setPopulationArea(populationArea);
		
		currentBehaviourName = DEFAULT_BEHAVIOUR_NAME;
		}
		
	public function setSuspender(suspender:StepDispatcher):void{
		indSuspender = suspender;
		bestConditionsWalker.setIndividualNumber(indSuspender.indNumber);
		momentalDeath.setSuspender(indSuspender);
		migrationBehaviour.setSuspender(indSuspender);
		migrationBehaviour.setIndividualNumber(indSuspender.indNumber)
		}
		
	
	public function setViewDistance(distant:int):void{
		viewDistance = distant;
		bestConditionsWalker.setViewDistance(viewDistance);
		}
		
	public function onIndividualStateChange(event:Event):void{
		migrationBehaviour.collision();//При встечи двух особей даем знать об этом migrationBehaviour, который ведет подсчет встреч
		switchBehaviour('MigrationBehaviour');//Если модуль 'migrationBehaviour' решит, что условий для сохранения этой линии поведения недостаточно, то поведение вернется к предыдущему на следующем шаге
		};
	
	public function onNextStep(event:Event):void{//Функция вызывается каждый раз, когда особь делает очередной шаг
	
		if(newBehaviour.getState() != 'hold'){//Если линия поведения длящаяся несколько шагов уже закончилась
			newBehaviour = baseMotionBehaviour;//Переключаемся на линию поведения по умолчанию но она станет доступна только на следующем шаге
			currentBehaviourName = DEFAULT_BEHAVIOUR_NAME;
			}
		};
		
	public function switchBehaviour(behaviourName:String):void{
			try{	
				if(newBehaviour.getState() == 'reset'//Если текущая линия поведения уже закончилась
					|| newBehaviour.getState() == 'constant' //Или если текущая линия поведения вообще реализуется в течении одного хода
					&& currentBehaviourName != behaviourName
					&& indSuspender.statement() != 'dead' //Если особь жива
					&& indSuspender.statement() != 'stop'//И она движется
					){
				
					currentBehaviourName = behaviourName;
				
					switch(behaviourName){
						case 'RandomWalker':
							newBehaviour = baseMotionBehaviour;
						break;
					
						case 'BestConditionsWalker':
							bestConditionsWalker.reset();//Если поведение переключилось когда остались шаги, их предварительно надо сбросить
							newBehaviour = bestConditionsWalker;
						break;
						
						case 'MigrationBehaviour':
							newBehaviour = migrationBehaviour;
						break;
					
						case 'MomentalDeath':
							momentalDeath.killIndividual();
						break;

						default:
							newBehaviour = baseMotionBehaviour;
							throw new Error('Wrong behaviour name');
						break;
					
						}
					}
				}catch(error:Error){
					ARENA::DEBUG{
						messenger.message('Individual ' + indSuspender.indNumber + '. ' + error +': ' + behaviourName, 0);
						currentBehaviourName = DEFAULT_BEHAVIOUR_NAME;
						}
					
					newBehaviour = baseMotionBehaviour;//В случае ошибки сбрасываемся на базовую модель поведения
					}
			}
		
		public function getCurrentBehaviour():String{
			return newBehaviour.getName();
			}
	}

}
