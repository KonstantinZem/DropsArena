package konstantinz.community.comStage.behaviour{
	public class MaturingBehaviour{

		private var adultAge:int; //Возраст наступления половозрелости
		private var maturingDeley:int;//Промежуток между размножениями
		private var currentDeleyTime:int
		private var indAgeState:String// adult or young 
		
		public function MaturingBehaviour():void{

			maturingDeley = 0;
			adultAge = 100;
			currentDeleyTime = 0;//Особь начнет размножаться сразу после того как повзрослеет
			indAgeState = 'young';
		};
		
		public function setAdultAge(newAge:int):void{
			try{
				adultAge = newAge;
				if(adultAge < 0){
					throw new Error('Adult age is less then zerro')
					}
				}catch(e:Error){
					adultAge = 1;
					trace(e.message)
					}
			};
		
		public function setDeley(newDeley:int):void{
			maturingDeley = newDeley;
		};
		
		public function onIndividualStep():void{
			tryToChangeAgeState();
			};
		
		public function getState():String{
			return indAgeState;
			};
		
		public function timeToMaturing():Boolean{
			if(indAgeState == 'adult' && isTimeToMaturing()==true){
				return true;
			}else{
				return false;
				}
		};
		
		private function tryToChangeAgeState():void{
			//Определяет повзрослела ли особь
			if(adultAge > 0){//Если время повзрослеть еще не насталло
				adultAge--;//Приближаем совершеннолетие еще на шаг
				}
				else{
					if(adultAge==0){//После этого adultAge станет меньше нуля и сообщение появлятся не должно
						indAgeState = 'adult';
						adultAge--;
						}
				}
			};
			
		private function isTimeToMaturing():Boolean{
			if(currentDeleyTime == 0){
				currentDeleyTime = maturingDeley;
				return true;
				}else{
					currentDeleyTime--;
					return false;
					}
		}
	}
}
