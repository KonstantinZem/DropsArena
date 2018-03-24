package konstantinz.community.comStage{
	import flash.events.TimerEvent; 
	import flash.events.Event; 
	import flash.utils.Timer;
	import konstantinz.community.comStage.*
	import konstantinz.community.auxilarity.*
	
	public class Suspender{
		private static var tickInterval:int = 20;//Интервал между тиками таймера
		private var indName:*
		private var suspendTime:Timer;
		private var indStepPulsor:Timer;
		private var immortal:Boolean;//Можно сделать особь бессмертной
		private var lifeTime:int//Время жизни в ходах
		private var config:Object
		private var chessDesk:Array;
		private var debugLevel:String;
		private var errorType:ModelErrors;
		private var msgMark:String = '[suspender]: ';//Помечаем тип объекта в отладочных сообщениях
		private var msgString:String;
		
		//Приостанавливает активность особи на некоторое время
		function Suspender(individualName:Individual, desk:Array, extOptions:ConfigurationContainer){
			indName = individualName;
			
			msgString = 'Suspender begin to serch individual ' + indName.getName();
			
			debugMsg(msgString);
			config = extOptions;
			chessDesk = desk;
			errorType = new ModelErrors();
			indStepPulsor = new Timer(tickInterval); 
			indStepPulsor.addEventListener(TimerEvent.TIMER, step);
			debugLevel = config.getOption('main.debugLevel');
			immortal = false;//По умолчанию время жизни особи конечно
			
			lifeTime = config.getOption('main.lifeTime');
			if(lifeTime==0){//Если так, то особь становится бессмертной
				immortal=true;
				msgString = 'Individual ' + indName.getName() + ' will be immortal';
				debugMsg(msgString);
				}
			msgString = 'Individual life time is ' + lifeTime;
			debugMsg(msgString);
			
			indStepPulsor.start();
			indName.externalTimer();
			}
		
		public function stopIndividual(time:int):void{
			
			try{
				suspendTime = new Timer(time, 1)
				suspendTime.addEventListener(TimerEvent.TIMER, startIndividual);
				suspendTime.start();
				indStepPulsor.stop();
				indName.stop();
			}catch(e:Error){//Если что то пошло не так
				msgString = 'Error: Can not stop individual ' + indName.getName() + ': ' + errorType.indExemplarNotExist;
				debugMsg(msgString);
				suspendTime.stop();//Сбрасываем паузу
				indStepPulsor.stop();//И вообще отключаем подачу сигналов к этой особи
				}
			}
		private function startIndividual(event:TimerEvent):void{
			try{
					msgString = 'Try to start individual ' + indName.getName();
					debugMsg(msgString);
					
					indStepPulsor.start();
					indName.start();
				
			}catch(e:Error){
				indStepPulsor.stop();
				}
			}
			
		private function step(event:TimerEvent):void{
			try{
				if(!immortal){//Если особь не бессмертна, следим за временем жизни
					lifeTime = lifeTime - chessDesk[10][10]['lifeQuant'];
					if(lifeTime<0){//Если время жизни вышло
						indStepPulsor.stop();
						indStepPulsor = null;
						indName.kill();//Даем особи команду убиться
					}
				else{
					indName.doStep();
					}
				}
			}catch(e:Error){
				indStepPulsor.stop();
				msgString = 'Error: Can not drive individual ' + indName.getName() + ': ' + errorType.indExemplarNotExist;
				debugMsg(msgString);
				}
			
			
		}
		
		private function debugMsg(msg:String):void{
			if(debugLevel=='true'){
				trace(msgMark + msg + ';\n');
			}
			}
	}
}
