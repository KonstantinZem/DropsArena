package konstantinz.community.comStage{
public class individualBehavior{
	//Вспомогательный класс, для передачи особи множества параметров
	public var lifeTime:int;
	public var adultAge:int;//Время наступления половозрелости (в ходах)
	private var debugLevel:Boolean;
	
	function individualBehavior(rootOptions:Object){
	this.debugLevel = rootOptions.debugLevel;
	this.lifeTime = rootOptions.lifeTime;
	this.adultAge = rootOptions.adultAge;
	var msgStreeng = 'Individuals starts with parametrs: \n' + 'Life time = ' + lifeTime + ' steps.\n' + 'Adulting time = ' +  adultAge + ' steps.\n'
	debugMsg(msgStreeng)
	}
	private function debugMsg(msg:String){
			if(debugLevel){
				trace(msg);
			}
}
}
}