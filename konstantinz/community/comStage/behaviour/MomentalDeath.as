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
			trace(e.message);
			}
		}
	public function killIndividual():void{
		try{
			if(indSuspender == null){
				throw new Error('Individual suspender not set');
				}
		indSuspender.killIndividual();
		}catch(e:Error){
			trace(e.message);
			}
		}

}
}
