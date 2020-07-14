// Author: Konstantin Zemoglyadchuk konstantinz@bk.ru
// Copyright (C) 2019 Konstantin Zemoglyadchuk
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
package konstantinz.plugins{

import flash.events.Event

	import flash.errors.IllegalOperationError;
	import flash.utils.*;
	import konstantinz.community.auxilarity.*;
	import konstantinz.community.comStage.*;
	import konstantinz.plugins.*;
    
public class activitySwitcher extends Plugin{
	private const CRITIAL_IND_NUMBER:int = 3;//До какого количество особей плагин будет работать
	private const MAX_OPTIONS_LIST_SIZE:int = 1000;//Чтобы небыло бесконечных поисковых циклов, их надо ограничить
	
	private var individuals:Vector.<Individual>//Ссылка на массив с управляемыми объектами

	public function activitySwitcher(){
		pluginEvent = new DispatchEvent();
		numberOfObservingsInConfig = 0;
		}
	
	 override public function initSpecial(task:Array, taskName:String, taskNumber:int):void{//Функция initSpecial() есть во всех плагинах и содержит специфичные переменные и функции которые надо запустить сразу после запуска плагина
		 
		 individuals = root.individuals;//Чтобы дальше root не встречался в тексте
		 task[taskNumber]= new ActivityTask();
		
		currentTask = task[taskNumber];
		initCurrentTaskData(currentTask, taskName,  taskNumber);	
				
		setDuration(currentTask);
		currentTask.cycleCounter = 1;
		msgString = 'cycle: ' + currentTask.cycleCounter;
				
		if(alreadyInited == 'fals'){
		   setTimeout(pluginEvent.ready, 50);//Сообщение о том что плагин полностью готов к работе принимается функцией onPluginsJobeFinish в pluginLoader
		   }
		}
	
	private function initCurrentTaskData(currentTask:ActivityTask, taskName:String, taskNumber:int):void{
		 var dataPath:String = optionPath + 'data.observation';
		 var calendarData:String = dataPath + '.day';
		 var durationDataPath:String = dataPath + '.duration';
		 
		 currentTask.name = taskName;
		 currentTask.number = taskNumber;
		 currentTask.currentActivityPosition = 0;
		 currentTask.firstInit = 'true';
		 currentTask.killStoped = 'false';
		 
		 currentTask.dataPath = dataPath;
		 currentTask.observationPosition = new Array(0,0,taskNumber,0);
		 currentTask.activityObservationPosition = new Array(0,0,taskNumber,0,0,0);//Положение нужной нам опции в узле. Вообще это не хороше лазить по XML файлу вслепую без учета имен тегов
		 currentTask.activeIndividualsNumberPosition = currentTask.dataPath + '.part';
		 currentTask.numberOfObservingsInConfig = countAllObservings(currentTask);//Получаем количество заданных в конфиге наблюдений за активностью
		 
		 currentTask.durationDataPath  = durationDataPath;
		 currentTask.signalType = configuration.getOption(optionPath + 'signal', currentTask.observationPosition);
		 currentTask.currentDay = configuration.getOption(calendarData, currentTask.activityObservationPosition);//Берем из конфига дату первого наблюдения наблюдения. Надо сделать это сразу. Если плагин включается по календарным датам, он должен знать когда включится впервый раз
		
		if(currentTask.signalType=='kill'){//Если плагин настроен чтобы убивать особей
		   currentTask.killStoped = configuration.getOption(optionPath + 'killStoped', currentTask.observationPosition);//Узнаем, должны ли мы убивать всех подряд или только активных осоей
				
			if(currentTask.killStoped !='true' && currentTask.killStoped !='false'){//Если опция killStoped напсиана неправильно
				ARENA::DEBUG{
					messenger.message('killStoped: ' + currentTask.killStoped + '. ' + errorType.varIsIncorrect, 0);
				}
			   currentTask.killStoped = 'false';//Заменяем неправильное значение на значение по умолчанию 
			   }
			}
				
		currentTask.selectionType = configuration.getOption(optionPath + 'selectionType', currentTask.observationPosition);
				
		if(currentTask.selectionType != 'percents' && currentTask.selectionType != 'items'){//Если в настройках способ выборки особей поставлен неправильно или отсутствует
		   currentTask.selectionType = 'percents';//Выбираем значение по умолчанию
		   
		   ARENA::DEBUG{
			 msgString = errorType.varIsIncorrect + '. ' + errorType.defaultValue + ': percents';
			 messenger.message(msgString, modelEvent.ERROR_MARK);
		   }
		  }
		 
		 currentTask.statMessageHead = setMsgHead(currentTask.signalType);
			
		if(currentTask.signalType == 'Error'){
			currentTask.signalType = 'susupend';
			}
			
		currentTask.switchingEvent = setSwitchingEvent(currentTask);
		currentTask.switchingInterval = setSwitchingInterval(currentTask);
		 
	}
	
	private function setMsgHead(signalType:String):String{
		var statMessageHead:String;
		
		switch(signalType){//Каким заголовком снабжать сообщения со статистической информацией
			case 'susupend':		
				statMessageHead = 'inactive_ind_numb';
			break;
			case 'stop':
				statMessageHead = 'hybernate_ind_numb';
			break;
			case 'kill':
				statMessageHead = 'dead_ind_numb';
			break;
			case 'Error':
				statMessageHead = 'inactive_ind_numb';
			default:
				messenger.message('Wrong type of signal', modelEvent.ERROR_MARK);
				statMessageHead = 'inactive_ind_numb';
				}
			return statMessageHead;
	};
		
	override public function startPluginJobe():void{//Эта функция запускается периодичски, включая основной функционал плагина
		stopInd(currentTask);//Это основной функционал
		setNewObservingPosition(currentTask);
		setDuration(currentTask);
		}
	
	private function countAllObservings(currentTask:ActivityTask):int{
		var numberOfObservingsInConfig:int = 0;
		var optionValue:String = 'empty';
		var functName:String = 'countAllObservings';
		
		try{
			
			if(currentTask == null){
				throw new Error(functName + '. CurrentTask: Variable is null');
				}
			
			if(currentTask.activeIndividualsNumberPosition == null){
				throw new Error(functName + '. ActiveIndividualsNumberPosition: Variable is null');
			}
			
			while(optionValue != 'Error'){//Пока не вышли за пределы списка наблюдений
				
				optionValue = configuration.getOption(currentTask.activeIndividualsNumberPosition, currentTask.activityObservationPosition);
				
				if(optionValue == null){
					throw new ReferenceError('Can non get current active inividuals number setNewSwitchingIntervalfrom config');
					}
				if(numberOfObservingsInConfig > MAX_OPTIONS_LIST_SIZE){
					throw new Error('To much search repitings: ' + numberOfObservingsInConfig);//Если есть угроза войти в бесконечный цикл, аварийно выходим
					}
				currentTask.activityObservationPosition[4]++;
				numberOfObservingsInConfig++;
			}
			
		}catch(e:Error){
			ARENA::DEBUG{
				msgString = e.message;
				messenger.message(msgString, modelEvent.ERROR_MARK);
				}
			}
		
		currentTask.activityObservationPosition[4] = 0;//Корректируем
		numberOfObservingsInConfig--;//Корректируем
		
		ARENA::DEBUG{
			msgString = 'Number of observations is ' + numberOfObservingsInConfig;
			messenger.message(msgString, modelEvent.DEBUG_MARK);
			}
		
		return numberOfObservingsInConfig;
		}
	
	private function setNewObservingPosition(currentTask:ActivityTask):void{
		var newDayPath:String = optionPath + 'data.observation.day';
		
		if(currentTask.currentActivityPosition == currentTask.numberOfObservingsInConfig -1){//Если мы дошли до конца списка и Configuration container вернул ошибку int(Error) - 0
			
			currentTask.currentActivityPosition = 0;//Возвращаемся в начало списка наблюдений чтобы начать переключение заново
			currentTask.cycleCounter++;
			
			if(currentTask.switchingEvent == 'steps'){
				msgString = 'cycle: ' + currentTask.cycleCounter;
				messenger.setMessageMark(currentTask.name);
				messenger.message(msgString, modelEvent.STATISTIC_MARK);	
				}
				
			}else{
				currentTask.currentActivityPosition++;
				}
				
				currentTask.activityObservationPosition[4] = currentTask.currentActivityPosition;//Указываем на положение текущего наблюдения в конфиге
				currentTask.currentDay = configuration.getOption(newDayPath, currentTask.activityObservationPosition);//Берем из конфига дату наблюдения
				
				if(currentTask.currentDay == 'Error'){//Если дошли до конца списка
					currentTask.currentActivityPosition = 0
					currentTask.activityObservationPosition[4] = currentTask.currentActivityPosition;//Обнуляем счетчик. А то плагин будет стоять и ждать дату Error
					currentTask.currentDay = configuration.getOption(newDayPath, currentTask.activityObservationPosition);//Берем из конфига дату наблюдения
					
					ARENA::DEBUG{
						msgString = 'Plugin has begun new cycle';
						messenger.message(msgString, modelEvent.DEBUG_MARK);
						}
					}
				
				ARENA::DEBUG{
					msgString = 'Next observation data is ' + currentTask.currentDay + ' (position ' + currentTask.activityObservationPosition[4] + ')';
					messenger.message(msgString, modelEvent.DEBUG_MARK);
					}
		}
	
	private function setDuration(currentTask:ActivityTask):void{
		currentTask.currentDuration = int(configuration.getOption(currentTask.durationDataPath, currentTask.activityObservationPosition));
		
		if(currentTask.currentDuration > 0){//Если время паузы прописано в конфиге
			setNewSwitchingInterval(currentTask.currentDuration);
			
			ARENA::DEBUG{
				msgString = 'Pause duration is set to ' + currentTask.currentDuration;
				messenger.message(msgString, modelEvent.DEBUG_MARK);
				}
			
			}else if(currentTask.switchingIntervalHasChanged == 'true'){
				setNewSwitchingInterval(0);//0 - значит вернуть предыдущий интервал
				}
	};

	private function stopInd(currentTask:ActivityTask):void{//С этой функции начинает выполнятся основной функционал плагина
		
		var currentActiveIndividualsNumber:int;//Количество особей, которых нужно остановить в этот цикл
	
		try{

			currentActiveIndividualsNumber = int(configuration.getOption(currentTask.activeIndividualsNumberPosition, currentTask.activityObservationPosition));			
			stopOnly(currentTask, currentActiveIndividualsNumber, currentTask.selectionType);
			
			ARENA::DEBUG{
				msgString = 'Current stoped individuals part is ' +  currentTask.currentDay + '(position ' + currentTask.currentActivityPosition + '): '+ currentActiveIndividualsNumber;
				messenger.message(msgString, modelEvent.DEBUG_MARK);
				}
				
			if(currentTask.activeIndividualsNumberPosition != 'Error'){
				msgString = currentTask.statMessageHead + ':' + currentActiveIndividualsNumber;
				messenger.setMessageMark(currentTask.name);
				messenger.message(msgString, modelEvent.STATISTIC_MARK);//Посылаем данные о количестве неактивных особей как статистику
				
				}
					
			if(currentTask.switchingEvent == 'steps' && currentTask.currentDay != 'Error'){//У кого значение steps - управляет другими плагинами так как транслирует дату. Остальные дату показывать не должны
				  msgString = 'calendar_data' + ':' + currentTask.currentDay;//Передаем в статистику дату наблюдения
				  messenger.setMessageMark(currentTask.name);
				  messenger.message(msgString, modelEvent.STATISTIC_MARK);
				  }

				}catch(e:Error){
					messenger.message(e.message, modelEvent.ERROR_MARK);
					}
			}
	
	private function stopOnly(currentTask:ActivityTask, objNumber:int, unit_type:String):void{
	//Передаются два параметра - число особей, которое надо остановить и единицы измерения - проценты или штуки
		var itemsNumber:int;
		currentTask.stopedIndividuals = new Array;
		
		try{
			switch(unit_type){
				case 'percents':

					itemsNumber = 0;
					itemsNumber = Math.round((objNumber/100)*(individuals.length))//Высчитываем количество из процентов
			
					for(var i:int = 0; i< itemsNumber; i++){//Определяем количество особей, которых надо остановить
						currentTask.stopedIndividuals[i] = setObjRange();
						}
					fixRepitigItems(currentTask);
					sendStop(currentTask);
			
				break;

				case 'items':
			
					itemsNumber = 0;
					itemsNumber = objNumber - 1;
			
					for(i = 0; i< itemsNumber; i++){
					    currentTask.stopedIndividuals[i] = setObjRange();
					    }
			           
			         fixRepitigItems(currentTask);
				     sendStop(currentTask);
			
				break;
				default:
					itemsNumber = 0
					messenger.message('Wrong unit type', modelEvent.ERROR_MARK);
				break;
			}
		}catch(e:Error){
			messenger.message(e.message, modelEvent.ERROR_MARK);
			}
	}
	
	private function setObjRange():int{//Поиск случайной особи 
		var stopedObjPosition:int = 0;
		
		stopedObjPosition = Math.round(Math.random()* (individuals.length - 2));
			
		if(individuals[stopedObjPosition]==null && individuals[stopedObjPosition].movement() != 'dead'){//Если особь существует и движеться ???????????? сюда вставить критерий поиска, напримр если статус особе отличается от заданного
			stopedObjPosition = setObjRange();
			}
				
		return stopedObjPosition;
		}
	
	private function fixRepitigItems(currentTask:ActivityTask):void{//Убирает повторяющиеся значения из списка останавливаемых особей
		currentTask.stopedIndividuals.sort(Array.DESCENDING);//Это нужно, чтобы элементы удалялись один за одним начиная с самого последнего иначе есть риск обратится к уже несуществующему элементу	
		for(i = 1; i< currentTask.stopedIndividuals.length; i++){//По возможности убираем повторяющиеся элементы сдвигая их на шаг вперед. Понятно что снижает скорость, зато увеличивает точность
			if(currentTask.stopedIndividuals[i] == currentTask.stopedIndividuals[i-1]){
			   currentTask.stopedIndividuals[i]++;
			   }
			}
		}

	private function sendStop(currentTask:ActivityTask):void{
		var counter:int;
		try{
			if((individuals.length - 1) < CRITIAL_IND_NUMBER){
				throw new IllegalOperationError('Number of individals less then critical');
				}
			
			for(var i:int = 0; i< currentTask.stopedIndividuals.length; i++){//Пробигаемся по списку особей, которых надо остановить
				
				if(individuals[currentTask.stopedIndividuals[i]] != null){

					switch(currentTask.signalType){
						case 'susupend':	
						
							if(individuals[currentTask.stopedIndividuals[i]].hasOwnProperty('movement')){
								individuals[currentTask.stopedIndividuals[i]].movement('suspend', currentTask.switchingInterval);//Останавливаем особь на нужное время
								}
								else{
									throw new ReferenceError('Can not find call statement property. It seems, that individual now not exist');
									}
						break;
						case 'stop':
							if(individuals[currentTask.stopedIndividuals[i]].hasOwnProperty('movement')){
								individuals[currentTask.stopedIndividuals[i]].movement('stop', currentTask.switchingInterval);//Останавливаем особь на нужное время
								}
								else{
									throw new ReferenceError('Can not find function stopIndividual. It seems, that individual now not exist');
									}
						break;
						case 'kill':
							
							if(individuals[currentTask.stopedIndividuals[i]].hasOwnProperty('movement')){
								
								if(currentTask.killStoped =='true'){//Если можно, убиваем всех особей из выборки
									individuals[currentTask.stopedIndividuals[i]].movement('dead');
									}else{
										if(currentTask.individuals[stopedIndividuals[i]].movement() =='moved'){//А иначе убиваем только тех, кто движеться
											currentTask.individuals[stopedIndividuals[i]].movement('dead');
											}
									
										}
									}
									else{
										throw new ReferenceError('Can not find function killIndividual. It seems, that individual now not exist');
										}
						break;
						default:
							messenger.message('Wrong type of signal', modelEvent.ERROR_MARK);
						break;
					}
				
				}
				
			}
			
		}
		catch(e:IllegalOperationError){
			messenger.message(e.message, modelEvent.ERROR_MARK);
			messenger.message('Activity switcher plugin has finished working', modelEvent.INFO_MARK);
		}
		catch(e:ReferenceError){
			messenger.message(e.message, modelEvent.ERROR_MARK);
			}
		catch(e:Error){
			messenger.message(e.message, modelEvent.ERROR_MARK);
			}
	}

}
}
