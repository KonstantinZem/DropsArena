// Author: Konstantin Zemoglyadchuk konstantinz@bk.ru
// Copyright (C) 2017 Konstantin Zemoglyadchuk
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

package konstantinz.community.comStage{
	
	import flash.events.TimerEvent; 
	import flash.utils.*;
	import konstantinz.community.comStage.*;
	import konstantinz.community.comStage.behaviour.*;
	import konstantinz.community.auxilarity.*;

	public class Individual{
		//Класс, описывающий поведение отдельного организма в сообществе
		
		private var tickInterval:int = 20;//Интервал между тиками таймера
		private var lifeStart:Date
		private var lifeEnd:Date;
		private var date:Date;
		private var indNumber:int;
		private var maturingDeley:int;//Промежуток между размножениями
		private var adultAge:int;//Время взросления. Передается из настроек
		private var offspringsQuant:int;
		private var currentChessDeskI:int;//Номер строки текущего квадрата
		private var currentChessDeskJ:int;//Номер столбца текущего квадрата
		private var previosChessDeskI:int;
		private var previosChessDeskJ:int
		private var stepLength:int;//Длинна шага особи
		private var indDirection:int;//Текущие направление
		private var deleySteps:int;//количество ходов, которые надо пропустить для замедления движения
		private var chessDesk:Array; //Ссылка на внешний массив с координатами и условиями среды
		private var msgString:String;
		private var debugLevel:String;
		private var indStatus:String;//Так как особи могут подаваться внешние команды, надо всегда знать может ли особь эти команды выполнить
		private var currentBehaviourName:String;//Переключаться поведение будет только если название поведения из пришедшего сообщения будет отличаться от записанного сюда
		private var myBehaviour:BaseMotionBehaviour;
		private var modelEvent:ModelEvent;
		private var indConfiguration:ConfigurationContainer;
		private var messenger:Messenger;
		private var errorType:ModelErrors;//Контейнер для ошибок;
		private var timerForIndividuals:Timer; //Не самое удачное решение, снабдить каждую особь своим таймером, но сделать один из главного класса у меня не получается
				
		public var IndividualEvent:DispatchEvent;
		public var motionBehaviour:MotionBehaviourSwitcher;
		public var individualPicture:IndividualGraphicInterface;
		
		
		function Individual(desk:Array, behaviour:ConfigurationContainer, ...args){

			IndividualEvent = new DispatchEvent();
			errorType = new ModelErrors();
			
			try{
				indConfiguration = behaviour;
				debugLevel = indConfiguration.getOption('main.debugLevel');
				messenger = new Messenger(debugLevel);
				messenger.setMessageMark('Individual');
				modelEvent = new ModelEvent();//Будем брать основные константы от сюда
				indNumber = args[0];
				
				previosChessDeskI = 0;
				previosChessDeskJ = 0;
				
			
				if(args[0]==undefined){
					indNumber = Math.round(Math.random()*1000);;
					msgString = 'Individual ' + errorType.idUndefined + ' There were set random name ' + indNumber;
					messenger.message(msgString, modelEvent.INFO_MARK);
					}
				
				stepLength = int(indConfiguration.getOption('main.stepLength'));
				
				if(stepLength <= 0){
					stepLength = 1;
					msgString = 'Step length: ' + errorType.varIsIncorrect;
					messenger.message(msgString, modelEvent.ERROR_MARK);
					}
				
				adultAge = int(indConfiguration.getOption('main.adultAge'));
				offspringsQuant = int(indConfiguration.getOption('main.offspringsQuant'))//Количество оставленных потомков
				maturingDeley = 0;

				chessDesk = desk;
			
				individualPicture = new IndividualGraphicInterface(
					2,
					int(indConfiguration.getOption('main.individualSize')),//Максимальный размер особи
					adultAge
					);
					
				individualPicture.drawIndividual();
			
				motionBehaviour = new MotionBehaviourSwitcher(chessDesk);
				motionBehaviour.setViewDistance(int(indConfiguration.getOption('main.behaviourSwitching.viewDistance')));

				myBehaviour = motionBehaviour.newBehaviour;
				myBehaviour.setIndividualNumber(indNumber);
				myBehaviour.setStepLength(stepLength);
			
				if(args[1]==undefined||args[2]==undefined){
					currentChessDeskI = 0;//Если не указано начальное положение особи, начинаем двигаться с верхнего левого угла (первый квадрат)
					currentChessDeskJ = 0;
				}else{
					currentChessDeskI = args[1];
					currentChessDeskJ = args[2];
					}
			
				deleySteps = 1;
				timerForIndividuals = new Timer(tickInterval); 
				timerForIndividuals.addEventListener(TimerEvent.TIMER, internalMoveImpuls);
				timerForIndividuals.start();
				
				lifeStart = new Date();
				
				msgString = 'Individual ' + indNumber + ' has created. \n It current position is '+ currentChessDeskI+ ':' + currentChessDeskJ;
				messenger.message(msgString, modelEvent.INIT_MSG_MARK);
				
				indStatus = 'active';
			
			}catch(error:ArgumentError){
				msgString = error.message;
				messenger.message(msgString, modelEvent.ERROR_MARK);
				}
			}
/////////////////////////Private//////////////////////////////////////////////////////////////////////
		
		
		
		private function isIndividualAdult():Boolean{
			//функция полностью платформонезависимая
			//Определяет повзрослела ли особь
			if(adultAge>0){//Если время повзрослеть еще не насталло
				adultAge--;//Приближаем совершеннолетие еще на шаг
				return false;
				}
				else{
					if(adultAge==0){//После этого adultAge станет меньше нуля и сообщение появлятся не должно
						adultAge--;
						msgString= 'Individual ' + indNumber + ' now adult';
						messenger.message(msgString, modelEvent.INFO_MARK);
					}
					return true;
				}
			}
		
		private function isIndividualAlong():Boolean{//Есть ли в заданном квадрате кто либо еще
			//Функция платформонезависимая
			var YSIGN:String = 'Y';//Young
			var ASIGN:String = 'A';//Adult
			
			if(adultAge < 0){
				chessDesk[currentChessDeskI][currentChessDeskJ].numberOfIndividuals +=ASIGN;//Делаем в квадрате отметку своего присутсвия
				indStatus = ASIGN;
			}else{
				chessDesk[currentChessDeskI][currentChessDeskJ].numberOfIndividuals +=YSIGN;//В квадрате побывала молодая особь
				indStatus =YSIGN;
				}
			
			if(chessDesk[currentChessDeskI][currentChessDeskJ].numberOfIndividuals.length == 2 && chessDesk[currentChessDeskI][currentChessDeskJ].individualName != indNumber){//Если встретились две особи
				
				if(deleySteps > 2){//если перемещение происходит слишком быстро, не переключаем цвета
					individualPicture.markIndividual('collision');//Визуально отмечаем факт встречи особей
					}
				
				return false;
				}else{
					 individualPicture.markIndividual('nothing'); //Визуально показываем, что ничего не произошло					
					 
					 return true;
				}
			}

		
		private function maturing():void{
			//функция полностью платформонезависимая
			if(maturingDeley==0){
				
				IndividualEvent.currentChessDeskI = currentChessDeskI;
				IndividualEvent.currentChessDeskJ = currentChessDeskJ;
				IndividualEvent.maturing();
				
				msgString = 'Maturing in '+ currentChessDeskI+ ':'+ currentChessDeskJ;
				messenger.message(msgString, modelEvent.DEBUG_MARK);
				maturingDeley = int(indConfiguration.getOption('main.maturingDeley'));
			
			}
			else{
				maturingDeley--;
				}
			}
		private function internalMoveImpuls(event:TimerEvent):void{//Заставляем особь двигаться по собственному таймеру
			nextStep();
			}
		
		
		private function nextStep():void{
		
			individualPicture.markIndividual('nothing');
			//функция платформонезавмсимая, при условии, что кто то будет читать переменную individual.x и individual.y и на изменять сведения о положении особи
			deleySteps--;//Уменьшаем количество пропущеных ходов
						
			var amIAdult:Boolean = isIndividualAdult();//Стоит здесь, так как взрослеть особь должна в не зависимости от того, стоит она на месте или движется
			var indAgeState:String = 'young';
			
			if(indStatus != 'dead' && deleySteps==0){//И если отстояли на месте положенное количество тиков таймера, двигаемся дальше
				
				deleySteps = myBehaviour.getPlaceQuality(currentChessDeskI,currentChessDeskJ);//Смотрим на новой клетке число ходов
			
				var amIAlong:Boolean = isIndividualAlong();
			
				if(amIAdult){
					indAgeState = 'adult';
				
					if(!amIAlong){
						if(chessDesk[currentChessDeskI][currentChessDeskJ].numberOfIndividuals =='AA'){//Если встретились две взрослые
						maturing();
						}
					}
				}
			
				currentChessDeskI = myBehaviour.getNewPosition(currentChessDeskI,currentChessDeskJ).x;
				currentChessDeskJ = myBehaviour.getNewPosition(currentChessDeskI,currentChessDeskJ).y;
				chessDesk[currentChessDeskI][currentChessDeskJ].individualName = indNumber;
			
				individualPicture.nextStep(//Передаем координаты, куда особи надо переместится на следующем шаге
					chessDesk[currentChessDeskI][currentChessDeskJ].sqrX + 1,
					chessDesk[currentChessDeskI][currentChessDeskJ].sqrY +1,
					indAgeState//Взрослая ли уже особь или еще надо расти
					);
				
			  }
			  
			  if(chessDesk[currentChessDeskI][currentChessDeskJ].behaviourModel != ''){//Если в новом квадарте указанно поведение, которое особь должна начать проявлять
				motionBehaviour.switchBehaviour(chessDesk[currentChessDeskI][currentChessDeskJ].behaviourModel);//Включаем этот тип
				}
		}
			
		private function killIndividual():void{//Убирает особь со сцены
			//функция относительно платформонезависимая, так как таймеры и слушатели событий есть и в других языках
			indStatus = 'dead';//Теперь, если кто то попытается обратится к особи, он будет по крайне мере знать, что она присмерти
			var deltaTime:int;
				
			lifeEnd = new Date();
			timerForIndividuals.stop();//Выключаем таймер
			timerForIndividuals.removeEventListener(TimerEvent.TIMER, internalMoveImpuls);//И отсоединяемся от него
				
			deltaTime = lifeEnd.getTime() - lifeStart.getTime();
			
			msgString = 'Individual ' + indNumber + ' is dead. R.I.P. \n' + 'It lived ' + Math.round((deltaTime)*0.00006) + ' min';
			messenger.message(msgString, modelEvent.INFO_MARK);
			
			messenger = null;
			motionBehaviour = null;
			indConfiguration = null;
			lifeEnd = null;
			lifeStart = null;
			IndividualEvent.individual = indNumber;//Посылаем сообщение о том что особь с этим номером
			IndividualEvent.death();//Умерла
				
			errorType = null;
			}
			
////////////////////////////Public////////////////////////////////////////////////////
		
		public function externalTimer():void{ //Возможность управлять особью при помощью внешнего таймера
			timerForIndividuals.stop();
			msgString = 'Individual number '+ indNumber + ': ' + 'Internal timer has stoped';
			messenger.message(msgString, modelEvent.DEBUG_MARK);
			}
			
		public function doStep():void{//Заставляем особь двигаться по внешнему таймеру
			if(indStatus != 'dead'){//Если она может двигаться
				nextStep();
				}
			}
		
		public function stop():void{//Так особь можно заставить остановится
			msgString = 'Individual number '+ indNumber + ' has been stoped';
			messenger.message(msgString, modelEvent.DEBUG_MARK);
			individualPicture.markIndividual('stoped');
			}
		
		public function start():void{//Так особь можно заставить двигаться снова
			msgString = 'Individual number '+ indNumber + ' has been started';
			messenger.message(msgString, modelEvent.DEBUG_MARK);
			individualPicture.markIndividual('nothing');
			}
		
		public function getTickInterval():int{//Внешние модули могут узнавать частоту обновления состояния особи
			return tickInterval;
			}
		
		//Сюда надо ввести еще 2 функции: indSleep() и indWakeUp() первая из них останавливает таймер и особь замирает. Вторая включает таймер и особь начинает двигаться
		public function getName():int{
			return indNumber;
			}
		
		public function setName(newNumber:int):void{
			var oldNumber:int = indNumber;
			indNumber = newNumber;
			myBehaviour.setIndividualNumber(newNumber);
			msgString = 'Individual has change it number from ' + oldNumber + ' to ' + newNumber;
			messenger.message(msgString, modelEvent.DEBUG_MARK);
		}
	
		public function kill():void{
			if(indStatus != 'dead'){//Если она может двигаться
				msgString = 'Individual ' + indNumber + 'has killed';
				messenger.message(msgString, modelEvent.INFO_MARK);
				killIndividual();
				}
			}
		
		public function markPresenceInPlot():void{
			if(indStatus != 'dead'){//Если она может двигаться
				chessDesk[currentChessDeskI][currentChessDeskJ].cashe += indStatus;
				}
			}
	
			
		}

}
