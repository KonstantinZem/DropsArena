package konstantinz.community.comStage.behaviour{
	
	import konstantinz.community.comStage.*;

public class MomentalDeath extends BaseMotionBehaviour{
	
	private var indSuspender:StepDispatcher;
	
	function MomentalDeath(dbgLevel:String):void{
		debugLevel = dbgLevel;
		
		}
		
	public function setSuspender(suspender:StepDispatcher):void{
		
		try{
			if(suspender == null){
				throw new Error('Individual suspender not set');
				}
				indSuspender = suspender;
		}catch(e:Error){
			ARENA::DEBUG{
				messenger.message(e.message, modelEvent.ERROR_MARK);
				}
			}
		}
	public function killIndividual():void{
		try{
			if(indSuspender == null){
				throw new Error('Individual suspender not set');
				}
			if(!indSuspender.hasOwnProperty('killIndividual')){
				throw new Error('killIndividual not found');
				}
			
			indSuspender.killIndividual();

		}catch(e:Error){
			ARENA::DEBUG{
				msgString = 'Individual ' + individualName + ': ' + e.message;
				messenger.message(msgString, modelEvent.ERROR_MARK);
				}
			}
		}

}
}
