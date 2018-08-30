package konstantinz.community.comStage.behaviour{
	
	import konstantinz.community.comStage.*;

public class MomentalDeath extends BaseMotionBehaviour{
	
	private var indSuspender:Suspender;
	
	function MomentalDeath():void{
		
		}
		
	public function setSuspender(suspender:Suspender):void{
		
		try{
			if(suspender == null){
				throw new Error('Individual suspender not set');
				}
				indSuspender = suspender;
		}catch(e:Error){
			messenger.message(e.message, modelEvent.ERROR_MARK);
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
			msgString = 'Individual ' + individualName + ': ' + e.message;
			messenger.message(msgString, modelEvent.ERROR_MARK);
			}
		}

}
}
