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
		private var debugeMessage:DebugeMessenger;
		private var indStepPulsor:Timer;
		private var immortal:Boolean;//Можно сделать особь бессмертной
		private var lifeTime:int//Время жизни в ходах
		private var config:Object
		private var chessDesk:Array;
		private var debugLevel:String;
		private var errorType:ModelErrors;
		private var msgString:String;
		
		public var SuspenderEvent:DispatchEvent;//О результатах работы будем сообщать другим компонентам посредством сообщений
		//Приостанавливает активность особи на некоторое время
		function Suspender(individualName:Individual, desk:Array, extOptions:ConfigurationContainer){
			indName = individualName;
			config = extOptions;
			chessDesk = desk;
			errorType = new ModelErrors();
			indStepPulsor = new Timer(tickInterval);
			SuspenderEvent = new DispatchEvent(); 
			indStepPulsor.addEventListener(TimerEvent.TIMER, step);
			debugLevel = config.getOption('main.debugLevel');
			debugeMessage = new DebugeMessenger(debugLevel);
			debugeMessage.setMessageMark('Suspender');
			immortal = false;//По умолчанию время жизни особи конечно
			
			lifeTime = config.getOption('main.lifeTime');
			if(lifeTime==0){//Если так, то особь становится бессмертной
				immortal=true;
				msgString = 'Individual ' + indName.getName() + ' will be immortal';
				debugeMessage.message(msgString, 2);
				}
			msgString = 'Individual life time is ' + lifeTime;
			debugeMessage.message(msgString, 2);
			
			indStepPulsor.start();
			indName.externalTimer();
			msgString = 'Suspender begin to serch individual ' + indName.getName();
			
			debugeMessage.message(msgString, 1);
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
				debugeMessage.message(msgString, 0);
				suspendTime.stop();//Сбрасываем паузу
				indStepPulsor.stop();//И вообще отключаем подачу сигналов к этой особи
				}
			}
		public function getTimeQuant():int{
			return tickInterval;
			}
		
		/////////////////////////////////////////////Private//////////////////////////////////////////////////////////////////
		private function startIndividual(event:TimerEvent):void{
			try{
					msgString = 'Try to start individual ' + indName.getName();
					debugeMessage.message(msgString, 3);
					
					indStepPulsor.start();
					//indName.start();//
					SuspenderEvent.done();//Говорим о том что особи вновь запущены тому компоненту, который просил приостановить особей
			}catch(e:Error){
				trace(e)
				indStepPulsor.stop();
				}
			}
			
		private function step(event:TimerEvent):void{
			try{
				if(!immortal){//Если особь не бессмертна, следим за временем жизни
					lifeTime = lifeTime - chessDesk[10][10]['lifeQuant'];
					if(lifeTime==0){//Если время жизни вышло
						indStepPulsor.stop();
						//SuspenderEvent = null;
						indName.kill();//Даем особи команду убиться
					}
				else{
					indName.doStep();
					}
				}
			}catch(e:Error){
				indStepPulsor.stop();
				msgString = 'Error: Can not drive individual ' + indName.getName() + ': ' + errorType.indExemplarNotExist;
				debugeMessage.message(msgString, 0);
				}
			
			
		}
	}
}
