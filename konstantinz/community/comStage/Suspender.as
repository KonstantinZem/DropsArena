package konstantinz.community.comStage{
	import flash.events.TimerEvent; 
	import flash.events.Event; 
	import flash.utils.Timer;
	import konstantinz.community.comStage.*
	import konstantinz.community.auxilarity.*
	
	public class Suspender{
		
		private const INTERRUPT_MARK:int = 0;//Если подать функции stopIndividual это число, функция остановит всех особей не запуская таймер паузы
		private const ERROR_MARK:int = 0;//Сообщение об ошибке помечаются в messanger помечаеся цифрой 0
		
		private static var tickInterval:int = 20;//Интервал между тиками таймера
		
		private var individual:Individual;
		private var suspendTime:Timer;
		private var messanger:Messenger;
		private var indStepPulsor:Timer;//На каждый импульс этого таймера особь будет делать шаг
		private var immortal:Boolean;//Можно сделать особь бессмертной
		private var lifeTime:int//Время жизни в ходах
		private var config:Object
		private var chessDesk:Array;
		private var debugLevel:String;
		private var errorType:ModelErrors;
		private var msgString:String;
		
		private var individualState:String;//Помечаем состояние особи, чтобы не посылать стоп-команды если особь уже остановлена
		public var SuspenderEvent:DispatchEvent;//О результатах работы будем сообщать другим компонентам посредством сообщений
		//Приостанавливает активность особи на некоторое время
		
		function Suspender(individualName:Individual, desk:Array, extOptions:ConfigurationContainer){
			individualState = 'moved';
			individual = individualName;
			config = extOptions;
			chessDesk = desk;
			errorType = new ModelErrors();
			indStepPulsor = new Timer(tickInterval);
			SuspenderEvent = new DispatchEvent(); 
			indStepPulsor.addEventListener(TimerEvent.TIMER, step);//На каждый импульс этого таймера особь будет делать шаг
			debugLevel = config.getOption('main.debugLevel');
			messanger = new Messenger(debugLevel);
			messanger.setMessageMark('Suspender');
			immortal = false;//По умолчанию время жизни особи конечно
			
			lifeTime = config.getOption('main.lifeTime');
			
			if(lifeTime==0){//Если так, то особь становится бессмертной
				immortal=true;
				msgString = 'Individual ' + individual.getName() + ' will be immortal';
				messanger.message(msgString, 2);
				}
			
			msgString = 'Individual life time is ' + lifeTime;
			messanger.message(msgString, 2);
			
			indStepPulsor.start();
			individual.externalTimer();
			msgString = 'Suspender begin to serch individual ' + individual.getName();
			
			messanger.message(msgString, 1);
			}
		
		public function stopIndividual(time:int):void{
			
			try{
				if(time>INTERRUPT_MARK){//Если нам просто нужно сделать паузу на время
					if(individualState !='paused'){//Если особь снялась с паузы
						suspendTime = new Timer(time, 1);
						suspendTime.addEventListener(TimerEvent.TIMER, startIndividual);
						indStepPulsor.stop();
						individual.stop();
					
						individualState = 'paused';
						suspendTime.start();
					}
				}else{
					individualState='stoped';//Сигнализируем особи, что она должна остановится при любых условиях
					indStepPulsor.stop();
					}
				
			}catch(e:Error){//Если что то пошло не так
				msgString = 'Can not stop individual ' + individual.getName() + ': ' + errorType.indExemplarNotExist;
				messanger.message(msgString, ERROR_MARK);
				suspendTime.stop();//Сбрасываем паузу
				indStepPulsor.stop();//И вообще отключаем подачу сигналов к этой особи
				}
			}
		public function killIndividual():void{
			if(individualState=='moved'){
				individualState = 'stoped';
				}
				indStepPulsor.stop();//Останавливаем отсылку команд на совершение новых ходов
				suspendTime.stop();//Останавливаем ожидание команды на запуск тем особям которые в данный момент приостановлены
				individual.kill();
			}
		public function getTimeQuant():int{
			return tickInterval;
			}
		
		public function indState():String{
				return individualState;
			}
		
		/////////////////////////////////////////////Private//////////////////////////////////////////////////////////////////
		private function startIndividual(event:TimerEvent):void{
			try{
				if(individualState == 'paused'){   
				individualState = 'moved';
				msgString = 'Try to start individual ' + individual.getName();
				messanger.message(msgString, 3);
					
				indStepPulsor.start();
				SuspenderEvent.done();//Говорим о том что особи вновь запущены тому компоненту, который просил приостановить особей
				}
			}catch(e:Error){
				messanger.message(e.message, ERROR_MARK);
				indStepPulsor.stop();
				}
			}
			
		private function step(event:TimerEvent):void{
			try{
				if(!immortal){//Если особь не бессмертна, следим за временем жизни
					lifeTime = lifeTime - chessDesk[10][10]['lifeQuant'];
					if(lifeTime==0){//Если время жизни вышло
						indStepPulsor.stop();
						individual.kill();//Даем особи команду убиться
					}
				else{
					
					individual.doStep();
					}
				}
			}catch(e:Error){
				indStepPulsor.stop();
				msgString = 'Can not drive individual ' + individual.getName() + ': ' + errorType.indExemplarNotExist;
				messanger.message(msgString, ERROR_MARK);
				}
			
			
		}
		
	}
}
