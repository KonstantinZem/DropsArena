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
	
	import flash.display.Sprite;
	import flash.events.TimerEvent; 
	import flash.utils.*;
	import flash.geom.ColorTransform;
	import konstantinz.community.auxilarity.*;

	public class Individual extends Sprite{
		//Класс, описывающий поведение отдельного организма в сообществе
		private var tickInterval:int = 20;//Интервал между тиками таймера
		private var indName:Sprite;
		private var indNumber:int
		private var indConfiguration:Object
		private var maturingDeley:int;//Промежуток между размножениями
		private var debugeMessage:DebugeMessenger
		
		//**************************** Colors ************************************************//
		private var BORDERCOLOR:Number = 0x000000;
		private var INDCOLOR:Number = 0x990000;
		private var COLLISIONCOLOR:Number = 0xFFFF00;
		private var STOPEDCOLOR:Number = 0x808080; 
		
		//************************************************************************************//
		private var indSize:int;//Размер квадрата особи
		private var lifeStart:Date
		private var lifeEnd:Date;
		private var adultAge:int;//Время взросления. Передается из настроек
		private var offspringsQuant:int
		private var chessDesk:Array; //Ссылка на внешний массив с координатами и условиями среды
		private var errorType:Object;//Контейнер для ошибок;
		private var indDirection:int;//Текущие направление
		private var debugLevel:String;
		private var deleySteps:int;//количество ходов, которые надо пропустить для замедления движения
		private var timerForIndividuals:Timer; //Не самое удачное решение, снабдить каждую особь своим таймером, но сделать один из главного класса у меня не получается
		private var msgString:String;
		private var date:Date;
		private var currentChessDeskI:int//Номер строки текущего квадрата
		private var currentChessDeskJ:int//Номер столбца текущего квадрата
				
		public var IndividualEvent:DispatchEvent;
		
		
		function Individual(mroot:Object, desk:Array, behaviour:Object, ...args){
			IndividualEvent = new DispatchEvent();
			errorType = new ModelErrors();
			try{
				indConfiguration = behaviour;
				debugLevel = indConfiguration.getOption('main.debugLevel');
				debugeMessage = new DebugeMessenger(debugLevel);
				debugeMessage.setMessageMark('Individual');
				indNumber = args[0];
			
			if(args[0]==undefined){
				indNumber = Math.round(Math.random()*1000);;
				msgString = 'Individual ' + errorType.idUndefined + ' There were set random name ' + indNumber;
				debugeMessage.message(msgString, 2);
				}
				
			adultAge = int(indConfiguration.getOption('main.adultAge'))
			offspringsQuant = int(indConfiguration.getOption('main.offspringsQuant'))//Количество оставленных потомков
			maturingDeley = 0;

			indSize = int(indConfiguration.getOption('main.dropSize'));
			chessDesk = desk;
			
			if(args[1]==undefined||args[2]==undefined){
				currentChessDeskI = 0;//Если не указано начальное положение особи, начинаем двигаться с верхнего левого угла (первый квадрат)
				currentChessDeskJ = 0;
			}
			else{
				currentChessDeskI = args[1];
				currentChessDeskJ = args[2];
			}
			
			deleySteps = 1;
			timerForIndividuals = new Timer(tickInterval); 
			drawIndividual();
			timerForIndividuals.addEventListener(TimerEvent.TIMER, internalMoveImpuls);
			timerForIndividuals.start();
			lifeStart = new Date();
			msgString = 'Individual ' + indNumber + ' has created. \n It current position is '+ currentChessDeskI+ ':' + currentChessDeskJ;
			debugeMessage.message(msgString, 1);
			
			}
			catch(error:ArgumentError){
				msgString = "<Error> " +  error.message;
				debugeMessage.message(msgString, 0);
				}
			}
		/////////////////////////Private//////////////////////////////////////////////////////////////////////
		
		private function drawIndividual():void{//Рисует особь в виде цветного квадрата
			//Функция напрямую завязана на графике
			indName = new Sprite();
			indName.graphics.lineStyle(1,BORDERCOLOR);
		    indName.graphics.beginFill(INDCOLOR);
			indName.graphics.drawRect(0,0,indSize,indSize);
			addChild(indName);
			}
		
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
						debugeMessage.message(msgString, 2);
					}
					return true;
				}
			}
		private function isIndividualAlong():Boolean{//Есть ли в заданном квадрате кто либо еще
			//Функция платформонезависимая
			var YSIGN:int = 1;
			var ASIGN:int = 2;
			var cs:int
			
			if(adultAge<0){
				chessDesk[currentChessDeskI][currentChessDeskJ]['numberOfIndividuals']+=ASIGN;//Делаем в квадрате отметку своего присутсвия
				cs = ASIGN;
			}
			else{
				chessDesk[currentChessDeskI][currentChessDeskJ]['numberOfIndividuals']+=YSIGN;//В квадрате побывала молодая особь
				cs=YSIGN;
				}
			
			if(chessDesk[currentChessDeskI][currentChessDeskJ]['numberOfIndividuals']>cs){
				
				if(deleySteps>2){//если перемещение происходит слишком быстро, не переключаем цвета
					
					markIndividual('collision');//Визуально отмечаем факт встречи особей
				}
				setTimeout(clearCell, 2)
				return false;
				}
				else{
					 markIndividual('nothing'); //Визуально показываем, что ничего не произошло
					 setTimeout(clearCell, 2)//Без временной задержки особи затирают о себе информацию быстрее чем другие смогут ее прочитать
					
					 return true;
					 }
			}
			
		private function markIndividual(individualState:String):void{//Отмечает цветом особей в различном состоянии
			var ct:ColorTransform = new ColorTransform();
			
			switch(individualState) 
				{ 
					case 'collision': 
					ct.color = COLLISIONCOLOR;
					indName.transform.colorTransform = ct;
					break; 
					
					case 'nothing':
					ct.color = INDCOLOR;
					indName.transform.colorTransform = ct;
					break; 
					
					 case 'stoped':
					
					ct.color = STOPEDCOLOR
					indName.transform.colorTransform = ct;
					
					break;
					
					default: 
					ct.color = INDCOLOR;
					indName.transform.colorTransform = ct;
				}
		}

		private function clearCell():void{
			//функция полностью платформонезависимая
			chessDesk[currentChessDeskI][currentChessDeskJ]['numberOfIndividuals'] = 0
			}
		
		private function maturing():void{
			//функция полностью платформонезависимая
			if(maturingDeley==0){
				
				IndividualEvent.currentChessDeskI = this.currentChessDeskI;
				IndividualEvent.currentChessDeskJ = this.currentChessDeskJ;
				IndividualEvent.maturing();
				
				msgString = 'Maturing in '+ currentChessDeskI+ ':'+ currentChessDeskJ;
				debugeMessage.message(msgString, 3);
				maturingDeley = int(indConfiguration.getOption('main.maturingDeley'));
			
			}
			else{
				maturingDeley--;
				}
			}
		private function internalMoveImpuls(event:TimerEvent):void{//Заставляем особь двигаться по собственному таймеру
			nextStep()
			}
		
		
		private function nextStep():void{
			//функция платформонезавмсимая, при условии, что кто то будет читать переменную indName.x и indName.y и на изменять сведения о положении особи
			deleySteps--;//Уменьшаем количество пропущеных ходов
						
			var amIAdult:Boolean = isIndividualAdult();//Стоит здесь, так как взрослеть особь должна в не зависимости от того, стоит она на месте или движется
			
			if(deleySteps==0){//И если отстояли на месте положенное количество тиков таймера, двигаемся дальше
				deleySteps = chessDesk[currentChessDeskI][currentChessDeskJ]['speedDeleyA'];//Смотрим на новой клетке число ходов
			
				var amIAlong:Boolean = isIndividualAlong();
			
			if(amIAdult){
				if(!amIAlong){
					if(chessDesk[currentChessDeskI][currentChessDeskJ]['numberOfIndividuals']==4){//Если встретились две взрослые
					maturing();
					}
				}
			}
		
			indDirection = Math.round(Math.random()*8);
			
			
			switch(indDirection){
				case 0: //Стоим наместе
				indName.x = chessDesk[currentChessDeskI][currentChessDeskJ]['sqrX'];
				indName.y = chessDesk[currentChessDeskI][currentChessDeskJ]['sqrY'];
				
				break;
				case 1://Идем вниз
				
				if(currentChessDeskI>chessDesk.length-2){
					currentChessDeskI--;
					indName.x = chessDesk[currentChessDeskI][currentChessDeskJ]['sqrX'];
					indName.y = chessDesk[currentChessDeskI][currentChessDeskJ]['sqrY'];
					}
					else{
						indName.x = chessDesk[currentChessDeskI+1][currentChessDeskJ]['sqrX'];
						indName.y = chessDesk[currentChessDeskI+1][currentChessDeskJ]['sqrY'];
						currentChessDeskI++;
						}
				break;
				case 2://Идем вверх
				
				if(currentChessDeskI==0){
					indName.x = chessDesk[0][currentChessDeskJ]['sqrX'];
					indName.y = chessDesk[0][currentChessDeskJ]['sqrY'];
					}
					else{
						indName.x = chessDesk[currentChessDeskI-1][currentChessDeskJ]['sqrX'];
						indName.y = chessDesk[currentChessDeskI-1][currentChessDeskJ]['sqrY'];
						currentChessDeskI--;
					}
				break;
				case 3: //Направо
				
				if(currentChessDeskJ>chessDesk[0].length-2){
					currentChessDeskJ--;
					indName.x = chessDesk[currentChessDeskI][currentChessDeskJ]['sqrX'];
					indName.y = chessDesk[currentChessDeskI][currentChessDeskJ]['sqrY'];
					
					}
					else{
						indName.x = chessDesk[currentChessDeskI][currentChessDeskJ+1]['sqrX'];
						indName.y = chessDesk[currentChessDeskI][currentChessDeskJ+1]['sqrY'];
						currentChessDeskJ++;
						}
				break;
				case 4://Идем налево
				
				if (currentChessDeskJ==0){
					indName.x = chessDesk[currentChessDeskI][0]['sqrX'];
					indName.y = chessDesk[currentChessDeskI][0]['sqrY'];
					}
					else{
						indName.x = chessDesk[currentChessDeskI][currentChessDeskJ-1]['sqrX'];
						indName.y = chessDesk[currentChessDeskI][currentChessDeskJ-1]['sqrY'];
						currentChessDeskJ--;
						}
				break;
				default://Стоим на месте
				
				indName.x = chessDesk[currentChessDeskI][currentChessDeskJ]['sqrX'];
				indName.y = chessDesk[currentChessDeskI][currentChessDeskJ]['sqrY'];
				
				}
				
			  }
				
			}
			
			private function killIndividual():void{//Убирает особь со сцены
			//функция относительно платформонезависимая, так как таймеры и слушатели событий есть и в других языках
				var deltaTime:int;
				lifeEnd=new Date();
			
				timerForIndividuals.stop();//Выключаем таймер
				timerForIndividuals.removeEventListener(TimerEvent.TIMER, internalMoveImpuls);//И отсоединяемся от него
				
				deltaTime = lifeEnd.getTime()-lifeStart.getTime();
				msgString = 'Individual ' + indNumber + ' is dead. R.I.P. \n' + 'It lived ' +Math.round((deltaTime)*0.00006) + ' min';
				debugeMessage.message(msgString, 2);
				debugeMessage = null;
				IndividualEvent.indName = indNumber;//Посылаем сообщение о том что особь с этим номером
				IndividualEvent.death();//Умерла
				
				
				if(parent.contains(indName)){//Перед тем как удалить особь со сцены 
					removeChild(indName);//Проверяем, не была ли она уже удалена до этого
				}
			}
			
		////////////////////////////Public////////////////////////////////////////////////////
		
		public function externalTimer():void{
			timerForIndividuals.stop()
			msgString = 'Individual number '+ indNumber + ': ' + 'Internal timer has stoped';
			debugeMessage.message(msgString, 3);
			}
			
		public function doStep():void{//Заставляем особь двигаться по внешнему таймеру
			nextStep()
			}
		
		public function stop():void{//Так особь можно заставить остановится
				msgString = 'Individual number '+ indNumber + ' has been stoped'
				debugeMessage.message(msgString, 3);
				markIndividual('stoped');
			}
		
		public function start():void{//Так особь можно заставить двигаться снова
				msgString = 'Individual number '+ indNumber + ' has been started';
				debugeMessage.message(msgString, 3);
				markIndividual('nothing');
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
			indNumber = newNumber
			msgString = 'Individual has change it number from ' + oldNumber + ' to ' + newNumber;
			debugeMessage.message(msgString, 3);
		}
	
		public function kill():void{
			killIndividual();
		}
	
			
		}

}
