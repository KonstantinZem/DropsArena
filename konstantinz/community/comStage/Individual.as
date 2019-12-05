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
	import flash.events.Event; 
	import flash.utils.*;
	import konstantinz.community.comStage.*;
	import konstantinz.community.comStage.behaviour.*;
	import konstantinz.community.auxilarity.*;

	public class Individual{
		//Класс, описывающий поведение отдельного организма в сообществе
		
		private const YOUNG_SIGHT:String = 'young';
		private const ADULT_SIGHT:String = 'adult';
		private const COLLISION_SIGHT:String = 'collision';
		private const STOP_SIGHT:String = 'stop';
		private const SUSPEND_SIGHT:String = 'suspend';
		private const MOVING_SIGHT:String = 'moving';
		private const DEAD_SIGHT:String = 'dead';
		
		private var tickInterval:int = 20;//Интервал между тиками таймера
		private var lifeStart:Date;
		private var currentChessDeskI:int;//Номер строки текущего квадрата
		private var currentChessDeskJ:int;//Номер столбца текущего квадрата
		private var stepLength:int;//Длинна шага особи
		private var deleySteps:int;//количество ходов, которые надо пропустить для замедления движения
		private var chessDesk:Array; //Ссылка на внешний массив с координатами и условиями среды
		private var indPlacement:Array;
		private var msgString:String;
		private var debugLevel:String;
		private var indAgeState:String;
		private var indStatus:String;//Так как особи могут подаваться внешние команды, надо всегда знать может ли особь эти команды выполнить
		private var currentBehaviourName:String;//Переключаться поведение будет только если название поведения из пришедшего сообщения будет отличаться от записанного сюда
		
		private var indConfiguration:ConfigurationContainer;
		private var messenger:Messenger;
		
		private var myBehaviour:BaseMotionBehaviour;
		private var motionBehaviour:MotionBehaviourSwitcher;
		private var maturingBehaviour:MaturingBehaviour;
		private var stepDispatcher:StepDispatcher;
		
		private var modelEvent:ModelEvent;//А если это все брать из MotionBehaviour
		private var errorType:ModelErrors;//Контейнер для ошибок;
		private var timerForIndividuals:Timer; //Не самое удачное решение, снабдить каждую особь своим таймером, но сделать один из главного класса у меня не получается
		
		public var IndividualEvent:DispatchEvent;
		
		function Individual(stage:Array, configuration:ConfigurationContainer, ...args){
			var indNumber:int;
			var lifeTime:int;
			
			IndividualEvent = new DispatchEvent();
			errorType = new ModelErrors();
			
			try{
				indConfiguration = configuration;
				debugLevel = indConfiguration.getOption('main.debugLevel');
				messenger = new Messenger(debugLevel);
				messenger.setMessageMark('Individual');
				modelEvent = new ModelEvent();//Будем брать основные константы от сюда
				indNumber = args[0];
				
				stepDispatcher = new StepDispatcher(debugLevel);
				
				stepDispatcher.addEventListener(StepDispatcher.DO_STEP, step);
				
				lifeTime = int(indConfiguration.getOption('main.individuals.lifeTime'));
				stepDispatcher.setLifeTime(lifeTime);
				
				if(args[0]==undefined){
					indNumber = Math.round(Math.random()*1000);
					
					ARENA::DEBUG{
						msgString = 'Individual ' + errorType.idUndefined + ' There were set random name ' + indNumber;
						messenger.message(msgString, modelEvent.INFO_MARK);
						}
					}
				
				stepDispatcher.setIndividualNumber(indNumber);
				
				stepLength = int(indConfiguration.getOption('main.stepLength'));
				
				if(stepLength <= 0){
					stepLength = 1;
					
					ARENA::DEBUG{
						msgString = 'Step length: ' + errorType.varIsIncorrect;
						messenger.message(msgString, modelEvent.ERROR_MARK);
						}
					}
				
				chessDesk = stage;
				
				indPlacement = new Array();
				indPlacement.x = 0;
				indPlacement.y = 0;
				indPlacement.direction = 0;
				indPlacement.previousX = 0;
				indPlacement.previousY = 0;
			
				motionBehaviour = new MotionBehaviourSwitcher(chessDesk, indConfiguration, debugLevel);
				stepDispatcher.addEventListener(StepDispatcher.COLLISION, motionBehaviour.onIndividualStateChange);
				stepDispatcher.addEventListener(StepDispatcher.STEP_DONE, motionBehaviour.onNextStep);
				
				myBehaviour = motionBehaviour.newBehaviour;
				motionBehaviour.setSuspender(stepDispatcher);
				
				//adultAge = int(indConfiguration.getOption('main.individuals.adultAge'));
				maturingBehaviour = new MaturingBehaviour();
				maturingBehaviour.setDeley(int(indConfiguration.getOption('main.individuals.maturingDeley')));
			
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
				
				ARENA::DEBUG{
					msgString = 'Individual ' + indNumber + ' has created. \n It current position is '+ currentChessDeskI+ ':' + currentChessDeskJ;
					messenger.message(msgString, modelEvent.INIT_MSG_MARK);
					}
				
				indStatus = 'active';
				indAgeState = YOUNG_SIGHT;
			
			}catch(error:ArgumentError){
				msgString = error.message;
				messenger.message(msgString, modelEvent.ERROR_MARK);
				}
			}
/////////////////////////Private//////////////////////////////////////////////////////////////////////
		
		private function individualAlong():Boolean{//Есть ли в заданном квадрате кто либо еще
						
			if(individualCounter('count', 'individuals', currentChessDeskI, currentChessDeskJ) > 1 && chessDesk[currentChessDeskI][currentChessDeskJ].individualName != stepDispatcher.getIndividualNumber()){//Если встретились две особи
				return false;
				
				}else{
					return true;
					}
			}
			
		private function individualCounter(todo:String, age:String, xpos:int, ypos:int):int{
				var individualsInCell:int = 0;
				var symbolPos:int = 0;
				var inquiry:String = todo + '_' + age;
				
				try{
					switch(inquiry){
						case 'add_adult':
							chessDesk[xpos][ypos].numberOfIndividuals.adult ++;
						break;
						case 'add_young':
							chessDesk[xpos][ypos].numberOfIndividuals.young ++;
						break;
						case 'remove_adult':
							if(chessDesk[xpos][ypos].numberOfIndividuals.adult > 0){//Удаляем, если есть что удалять
								chessDesk[xpos][ypos].numberOfIndividuals.adult --;
								}
						break;
						case 'remove_young':
							if(chessDesk[xpos][ypos].numberOfIndividuals.young > 0){//Удаляем, если есть что удалять
								chessDesk[xpos][ypos].numberOfIndividuals.young --;
								}
						break;
						case 'count_individuals':
							individualsInCell = chessDesk[xpos][ypos].numberOfIndividuals.young + chessDesk[xpos][ypos].numberOfIndividuals.adult;
						break;
						case 'count_adult':
							individualsInCell = chessDesk[xpos][ypos].numberOfIndividuals.adult;
						break;
						default:
							ARENA::DEBUG{
								msgString = 'Wrong symbol';
								messenger.message(msgString, modelEvent.ERROR_MARK);
								}
						break;
						}
					}catch(e:Error){
						ARENA::DEBUG{
							msgString = e.message;
							messenger.message(msgString, modelEvent.ERROR_MARK);
							}
						}
					
					return individualsInCell;
				}

		
		private function maturing():void{
			IndividualEvent.currentChessDeskI = currentChessDeskI;
			IndividualEvent.currentChessDeskJ = currentChessDeskJ;
			IndividualEvent.maturing();
				
			ARENA::DEBUG{
				msgString = 'Maturing in '+ currentChessDeskI+ ':'+ currentChessDeskJ;
				messenger.message(msgString, modelEvent.DEBUG_MARK);
				}
			}
		
		private function internalMoveImpuls(event:TimerEvent):void{//Заставляем особь двигаться по собственному таймеру
			nextStep();
			stepDispatcher.stepDone();
			}
		
		
		private function nextStep():void{
			
			//функция платформонезавмсимая, при условии, что кто то будет читать переменную individual.x и individual.y и на изменять сведения о положении особи
			var numberOfIndividualsinCell:int;
			
			if(deleySteps > 0){
				deleySteps--;//Уменьшаем количество пропущеных ходов
				}
			
			if(stepDispatcher.statement() == MOVING_SIGHT && deleySteps==0){//И если отстояли на месте положенное количество тиков таймера, двигаемся дальше
				
				deleySteps = myBehaviour.getPlaceQuality(currentChessDeskI,currentChessDeskJ);//Смотрим на новой клетке число ходов
				numberOfIndividualsinCell = individualCounter('count', ADULT_SIGHT, currentChessDeskI, currentChessDeskJ)
			
				maturingBehaviour.onIndividualStep();
				indAgeState = maturingBehaviour.getState();
	
				if(!individualAlong()){
					stepDispatcher.statement(COLLISION_SIGHT);
					numberOfIndividualsinCell = individualCounter('count', ADULT_SIGHT, currentChessDeskI, currentChessDeskJ);
					
					if(maturingBehaviour.timeToMaturing() == true && numberOfIndividualsinCell > 1){//Если встретились две взрослые, то идет обычное двуполое размножение
						maturing();//Начнется размножение. Позже надо предусмотреть возможность партеногенеза. Вызывая функцию maturing() с помощью события генерируемого внутри maturingBehaviour
					    }
				
					}else{
						stepDispatcher.statement(MOVING_SIGHT);
						}
				
				individualCounter('remove', indAgeState, currentChessDeskI, currentChessDeskJ);
				
				indPlacement.previousX = chessDesk[currentChessDeskI][currentChessDeskJ].sqrX + 1;//Сохраняем свое прошлое положение
				indPlacement.previousY = chessDesk[currentChessDeskI][currentChessDeskJ].sqrY + 1;
						
				currentChessDeskI = myBehaviour.getNewPosition(currentChessDeskI,currentChessDeskJ).x;
				currentChessDeskJ = myBehaviour.getNewPosition(currentChessDeskI,currentChessDeskJ).y;
				chessDesk[currentChessDeskI][currentChessDeskJ].individualName = stepDispatcher.getIndividualNumber();
				
				individualCounter('add', indAgeState, currentChessDeskI, currentChessDeskJ);
				
				indPlacement.x = chessDesk[currentChessDeskI][currentChessDeskJ].sqrX + 1;
				indPlacement.y = chessDesk[currentChessDeskI][currentChessDeskJ].sqrY + 1;
				}
			  
			  if(chessDesk[currentChessDeskI][currentChessDeskJ].behaviourModel != '' && chessDesk[currentChessDeskI][currentChessDeskJ].behaviourModel != 'empty'){//Если в новом квадарте указанно поведение, которое особь должна начать проявлять
				motionBehaviour.switchBehaviour(chessDesk[currentChessDeskI][currentChessDeskJ].behaviourModel);//Включаем этот тип
				}
			  
			  if(stepDispatcher.statement() == DEAD_SIGHT){
				  killIndividual();
				  }
		}
			
		private function killIndividual():void{//Убирает особь со сцены
			var lifeEnd:Date;
			var deltaTime:int;
			
			stepDispatcher.statement(DEAD_SIGHT);//Теперь, если кто то попытается обратится к особи, он будет по крайне мере знать, что она присмерти
				
			lifeEnd = new Date();
			timerForIndividuals.stop();//Выключаем таймер
			timerForIndividuals.removeEventListener(TimerEvent.TIMER, internalMoveImpuls);//И отсоединяемся от него
				
			deltaTime = lifeEnd.getTime() - lifeStart.getTime();
			
			individualCounter('remove', indAgeState, currentChessDeskI, currentChessDeskJ);//Освобождаем ячейку от следов своего присутсвия
			
			ARENA::DEBUG{
				msgString = 'Individual ' + stepDispatcher.getIndividualNumber() + ' is dead. R.I.P. \n' + 'It lived ' + Math.round((deltaTime)*0.00006) + ' min';
				messenger.message(msgString, modelEvent.INFO_MARK);
				}
			}
			
		private function step(e:Event):void{//Вызывается из indDispatcher каждй раз, когда из него приходит событие StepDispatcher.DO_STEP
			if(stepDispatcher.statement() != DEAD_SIGHT){
				nextStep();
				}
			stepDispatcher.stepDone();
			}
			
////////////////////////////Public////////////////////////////////////////////////////
		
		public function externalTimer():void{ //Возможность управлять особью при помощью внешнего таймера
			timerForIndividuals.stop();
			
			ARENA::DEBUG{
				msgString = 'Individual number '+ stepDispatcher.getIndividualNumber() + ': ' + 'Internal timer has stoped';
				messenger.message(msgString, modelEvent.DEBUG_MARK);
				}
			}
			
		public function doStep():void{//Заставляем особь двигаться по внешнему таймеру
			stepDispatcher.doStep();
			}

		public function name(newNumber:int = -1):int{
			if(newNumber > 0){
				var oldNumber:int = stepDispatcher.getIndividualNumber();
				
				myBehaviour.setIndividualNumber(newNumber);
				stepDispatcher.setIndividualNumber(newNumber);
				
				ARENA::DEBUG{
					msgString = 'Individual has change it number from ' + oldNumber + ' to ' + newNumber;
					messenger.message(msgString, modelEvent.DEBUG_MARK);
					}
				}
			return stepDispatcher.getIndividualNumber();
		}

		public function statement(statementName:String = 'empty', statementLength:int = 0):String{
			var indNumber:int = stepDispatcher.getIndividualNumber();
			
			if(stepDispatcher.statement() != DEAD_SIGHT && stepDispatcher.statement() != 'stop'){//Особь поменяет свое состояние только если она жива и не находится в гибернации
				switch(statementName){
					case SUSPEND_SIGHT:
						
						ARENA::DEBUG{
							msgString = 'Individual number '+ indNumber + ' has been suspended';
							messenger.message(msgString, modelEvent.DEBUG_MARK);
							}
						
						stepDispatcher.statement(SUSPEND_SIGHT, statementLength);
					break;
					case STOP_SIGHT:
						
						ARENA::DEBUG{
							msgString = 'Individual number '+ indNumber + ' has been stoped';
							messenger.message(msgString, modelEvent.DEBUG_MARK);
							}
						
						stepDispatcher.statement(STOP_SIGHT, statementLength);
						individualCounter('remove', indAgeState, currentChessDeskI, currentChessDeskJ);
					break;
					case MOVING_SIGHT:
						if(stepDispatcher.statement() != STOP_SIGHT){
							stepDispatcher.statement(MOVING_SIGHT);
							}
					break;
					case DEAD_SIGHT:
						if(stepDispatcher.statement() != DEAD_SIGHT){//Если особь уже не мертва
							
							ARENA::DEBUG{
								msgString = 'Individual ' + indNumber + 'has killed';
								messenger.message(msgString, modelEvent.INFO_MARK);
								}
							
							killIndividual();
							}
					break;
					case 'empty':
						
					break;
					default:
						msgString = 'Wrong statement name ' + statementName;
						messenger.message(msgString, modelEvent.ERROR_MARK);
					break;
					}
				}else{
					
					ARENA::DEBUG{
						msgString = 'Individual get '+ statementName + ' but it can not switching cause has status ' + stepDispatcher.statement();
						messenger.message(msgString, modelEvent.DEBUG_MARK);//Применять только при малом числе особей
						}
					}
				return stepDispatcher.statement();
			}
		
		public function placement():Array{
			return indPlacement;
			}
		
		public function age(newAge:int = 0):String{
			var lifeTime:int = stepDispatcher.getLifeTime();
			var adultAge:int = int(indConfiguration.getOption('main.individuals.adultAge'));//Время взросления. Передается из настроек
			
			if(newAge > 0){
				lifeTime = lifeTime - newAge;
				maturingBehaviour.setAdultAge(adultAge - newAge);
				stepDispatcher.setLifeTime(lifeTime);
				}
			return indAgeState;
			}
		public function direction():int{
			return myBehaviour.getDirection();
			};
		
		public function behaviour(newBehaviour:String = 'empty'):String{
			var currentBehaviourName:String = 'undefined';
				if(motionBehaviour != null){
					if(newBehaviour == 'empty'){
						currentBehaviourName = motionBehaviour.getCurrentBehaviour();//Если функцию вызвали без параметров, это значит, что она должна просто вывести название текущей модели поведения
						}else{
							motionBehaviour.switchBehaviour(newBehaviour);
							myBehaviour = motionBehaviour.newBehaviour;
							}
						}
				return currentBehaviourName;
			}
			
	}
}
