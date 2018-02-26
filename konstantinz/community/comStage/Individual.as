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
		private static var tickInterval:int = 20;//Интервал между тиками таймера
		private var indName:*;
		private var myNumber:int
		private var myBehavior:Object
		private var maturingDeley:int;//Промежуток между размножениями
		
		//**************************** Colors ************************************************//
		private var BORDERCOLOR:Number = 0x000000;
		private var INDCOLOR:Number = 0x990000;
		private var COLLISIONCOLOR:Number = 0xFFFF00; 
		
		//************************************************************************************//
		private var indSize:int;//Размер квадрата особи
		private var immortal:Boolean;//Можно сделать особь бессмертной
		private var lifeTime:int//Время жизни в ходах
		private var lifeStart:Date
		private var lifeEnd:Date;
		private var adultAge:int;//Время взросления. Передается из настроек
		private var offspringsQuant:int
		private var chessDesk:Array; //Ссылка на внешний массив с координатами и условиями среды
		private var errorType:Object;//Контейнер для ошибок;
		private var myDirection:int;//Текущие направление
		private var debugLevel:String;
		private var deleySteps:int;//количество ходов, которые надо пропустить для замедления движения
		private var timerForIndividuals:Timer; //Не самое удачное решение, снабдить каждую особь своим таймером, но сделать один из главного класса у меня не получается
		private var msgStreeng:String;
		private var date:Date;
		private var currentChessDeskI:int//Номер строки текущего квадрата
		private var currentChessDeskJ:int//Номер столбца текущего квадрата
		private var indX:int; 
		private var indY:int; 
		
		public var IndividualEvent:Object;
		
		
		function Individual(mroot:Object, desk:Array, behaviour:Object, ...args){
			IndividualEvent = new DispatchEvent();
			errorType = new ModelErrors();
			try{
				this.myBehavior = behaviour;
				this.indName = args[0];
				this.debugLevel = myBehavior.getOption('main.debugLevel');
				this.myNumber = args[0];
			
			if(args[0]==undefined){
				indName = Math.round(Math.random()*1000);
				myNumber = indName;
				msgStreeng = 'Individual ' + errorType.idUndefined + ' There were set random name ' + indName;
				debugMsg(msgStreeng);
				}
			
			this.immortal = false;//По умолчанию время жизни особи конечно
			this.lifeTime = int(myBehavior.getOption('main.lifeTime'));
			this.msgStreeng = 'Individual life time is ' + lifeTime;
			debugMsg(msgStreeng);
			
			if(lifeTime==0){//Если так, то особь становится бессмертной
				this.immortal=true;
				msgStreeng ='Individual ' + myNumber + ' will be immortal';
				debugMsg(msgStreeng);
				}
				
			this.adultAge = int(myBehavior.getOption('main.adultAge'))
			this.offspringsQuant = int(myBehavior.getOption('main.offspringsQuant'))//Количество оставленных потомков
			this.maturingDeley = 0;

			this.indSize = int(myBehavior.getOption('main.dropSize'));
			this.chessDesk = desk;
			this.indX= chessDesk[0][0]['sqrX'];//Передает начальные координаты особи
			this.indY = chessDesk[0][0]['sqrY'];
			
			if(args[1]==undefined||args[2]==undefined){
				this.currentChessDeskI = 0;//Если не указано начальное положение особи, начинаем двигаться с верхнего левого угла (первый квадрат)
				this.currentChessDeskJ = 0;
			}
			else{
				this.currentChessDeskI = args[1];
				this.currentChessDeskJ = args[2];
			}
			
			this.deleySteps = 1;
			this.timerForIndividuals = new Timer(tickInterval); 
			drawIndividual();
			this.msgStreeng = 'Individual ' + myNumber + ' has created. \n It current position is '+ currentChessDeskI+ ':' + indY;
			debugMsg(msgStreeng);
			}
			catch(error:ArgumentError){
				trace("<Error> " +  error.message);
				}
			}
		/////////////////////////Private//////////////////////////////////////////////////////////////////////
		private function debugMsg(msg:String):void{
			if(debugLevel=='true'){
				trace(msg);
			}
			}
		private function drawIndividual():void{
			//Рисует особь в виде цветного квадрата
			//Функция напрямую завязана на графике
			indName = new Sprite();
			indName.graphics.lineStyle(1,BORDERCOLOR);
		    indName.graphics.beginFill(INDCOLOR);
			indName.graphics.drawRect(indX,indY,indSize,indSize);
			addChild(indName)
			
			timerForIndividuals.addEventListener(TimerEvent.TIMER, nextStep);
			timerForIndividuals.start();
			lifeStart = new Date();
			}
		private function killIndividual():void{//Убирает особь со сцены
			//функция относительно платформонезависимая, так как таймеры и слушатели событий есть и в других языках
			var deltaTime:int;
			lifeEnd=new Date();
			
			timerForIndividuals.stop();//Выключаем таймер
			timerForIndividuals.removeEventListener(TimerEvent.TIMER, nextStep);//И отсоединяемся от него
			
			this.removeChild(indName);
			deltaTime = lifeEnd.getTime()-lifeStart.getTime()
			msgStreeng = 'Individual ' + myNumber + ' is dead. R.I.P. \n' + 'It lived ' +Math.round((deltaTime)*0.00006) + ' min';
			debugMsg(msgStreeng);
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
						msgStreeng='Individual ' + myNumber + ' now adult\n';
						debugMsg(msgStreeng);
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
				msgStreeng = 'Individ '+ myNumber +' meet another one.\n'
				
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
			
		private function markIndividual(individualState:String){//Отмечает цветом особей в различном состоянии
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
				
				msgStreeng = 'Maturing in '+ indX+ ':'+ indY;
				debugMsg(msgStreeng);
				maturingDeley = int(myBehavior.getOption('main.maturingDeley'));
			
			}
			else{
				maturingDeley--;
				}
			}
		
		////////////////////////////Public////////////////////////////////////////////////////
		
		//Сюда надо ввести еще 2 функции: indSleep() и indWakeUp() первая из них останавливает таймер и особь замирает. Вторая включает таймер и особь начинает двигаться
		
		public function nextStep(event:TimerEvent):void{
			//функция платформонезавмсимая, при условии, что кто то будет читать переменную indName.x и indName.y и на изменять сведения о положении особи
			deleySteps--;//Уменьшаем количество пропущеных ходов
			
			if(!immortal){//Если особь не бессмертна, следим за временем жизни
				lifeTime = lifeTime-chessDesk[currentChessDeskI][currentChessDeskJ]['lifeQuant'];
				if(lifeTime<0){
					killIndividual();
				}
			}
			
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
		
			myDirection = Math.round(Math.random()*8);
			
			
			switch(myDirection){
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
			
		}

}
