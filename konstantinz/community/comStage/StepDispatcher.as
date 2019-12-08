package konstantinz.community.comStage{
    //Класс будет находится внутри особи и будет заставлять эту особь двигаться
	import flash.events.Event; 
    import flash.events.EventDispatcher;
    import flash.events.IOErrorEvent;
	import konstantinz.community.comStage.*
	import konstantinz.community.auxilarity.*
	
	public class StepDispatcher extends EventDispatcher{
		
		private const IMMORTAL_SIGHN:int = -2;
		private const MOVING_SIGHT:String = 'moving';
		private const SUSPEND_SIGHT:String = 'suspend';
		private const STOP_SIGHT:String = 'stop';
		private const DEAD_SIGHT:String = 'dead';
		private const COLLISION_SIGHT:String = 'collision';
		
		private var indState:String;
		private var lifeTime:int;
		private var pauseTime:int;
		private var messenger:Messenger;
		private var collisionTime:int;
		private var debugLevel:String;
		
		public static const DO_STEP:String = 'do_step';//Событие посылается особи, внутри которой находится экземпляр этого класса
		public static const STEP_DONE:String = 'step_done'; //Посылается объекту MotionBehavior, его функции onNextStep
		public static const SUSPEND:String = 'suspend';
		public static const COLLISION:String = 'collision';
		
		public var indNumber:int//Номер особи, посылающей событие
		public var message:String;
		
		function StepDispatcher(dbgl:String ='3'){
			debugLevel = dbgl;
			indState = MOVING_SIGHT;
			indNumber = 0;
			lifeTime = IMMORTAL_SIGHN;
			messenger = new Messenger(debugLevel);
			messenger.setMessageMark('Step dispatcher');
			
			ARENA::DEBUG{
				messenger.message('Step dispatcher ' + indNumber  + ' has been created');
				}
			}
			
		public function statement(NewState:String = 'nothing', statementTime:int = 0):String{//Через эту функцию можно влиять на состояние особи
			if(indState != STOP_SIGHT){
			switch(NewState){
				case 'moving':
					indState = MOVING_SIGHT;
				break;
				case 'suspend':
					indState = SUSPEND_SIGHT;
					message = indState;
					pauseTime = statementTime;
					dispatchEvent(new Event(StepDispatcher.SUSPEND));
				break;
				case 'stop':
					indState = STOP_SIGHT;
					pauseTime = statementTime;
				break;
				case 'dead':
					indState = DEAD_SIGHT;
				break;
				
				case 'collision':
					indState = COLLISION_SIGHT;
					message = indState;
					collisionTime = 2;//Нужно чтобы изменение цвета особи можно было заметить
					dispatchEvent(new Event(StepDispatcher.COLLISION));
				break;
				case 'nothing':
					indState = indState;
				break
				default:
					indState = indState;
				break;
				}
				}
				return indState;
			}
		
		public function doStep():void{//Сигнал приходит от предыдущей особи
			if(indState != STOP_SIGHT && indState != SUSPEND_SIGHT && pauseTime < 0){//Если уже можно передвигаться
			  if(lifeTime != IMMORTAL_SIGHN){//Если особь не бессмертная
				lifeTime --;
				if(lifeTime < -1 && indState != DEAD_SIGHT && indState != SUSPEND_SIGHT && indState != STOP_SIGHT){//Если жизнь особи уже истекла, но пометки о ее смерти еще нет
					killIndividual();
					}
				}
				message = indState;
				dispatchEvent(new Event(StepDispatcher.DO_STEP));
			}else{
				pauseTime--;
			
				if(pauseTime < 0){//особь сама меняет статус по истечении паузы
					pauseTime = -1;
					indState = MOVING_SIGHT;
					}
				}
				if(indState == COLLISION_SIGHT){
					collisionTime --;
					}
				if(collisionTime < 0){
					indState = MOVING_SIGHT;
					collisionTime = 0;
					}
			}
		
		public function stepDone():void{
			dispatchEvent(new Event(StepDispatcher.STEP_DONE));
			
			}
		public function killIndividual():void{
			indState = DEAD_SIGHT;
			}
		public function setLifeTime(newLifeTime:int):void{
			lifeTime = newLifeTime;
			}
			
		public function getLifeTime():int{
			return lifeTime;
			}
			
		public function setIndividualNumber(newIndNumber:int):void{
			indNumber = newIndNumber;
			}
			
		public function getIndividualNumber():int{
			return indNumber;
			}
		
		public function getStepsNumber():int{
			return lifeTime;
			}
	}
}
