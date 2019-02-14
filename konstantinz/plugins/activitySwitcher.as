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
	private var stopedIndividuals:Array;//Список остановленных в данный момент особей
	private var activityObservationPosition:Array;
	private var numberOfObservingsInConfig:int;//Количество наблюдений (переключений) в конфигурационном файле
	private var cycleCounter:int;
	private var currentActivityPosition:int;//Позиция в таблице активности где надо искать текущее число особей, которых необходимо остановить
	private var activeIndividualsNumberPosition:String;
	private var signalType:String;
	private var selectionType:String;//percents or items
	private var killStoped:String;//Можно ли убивать неактивных особей
	private var dataPath:String;
	private var durationDataPath:String;
	private var calendarData:String;
	private var firstInit:String;

	public function activitySwitcher(){
		currentActivityPosition = 0;
		firstInit = 'true';
		killStoped = 'false';
		activeOnLoad = 'true';
		pluginEvent = new DispatchEvent();
		numberOfObservingsInConfig = 0;
		messenger.setMessageMark('Activity switcher plugin');
		}
	
	 override public function initSpecial():void{//Функция initSpecial() есть во всех плагинах и содержит специфичные переменные и функции которые надо запустить сразу после запуска плагина
		 
		 individuals = root.individuals;//Чтобы дальше root не встречался в тексте
		
		 dataPath = 'plugins.' + pluginName + '.data.observation';
		 calendarData = dataPath + '.day';
		 durationDataPath = dataPath + '.duration';
		 activityObservationPosition = new Array(0,0,0,0,0);//Положение нужной нам опции в узле. Вообще это не хороше лазить по XML файлу вслепую без учета имен тегов
				
		 signalType = configuration.getOption(optionPath + 'signal');
		 currentDay = configuration.getOption(calendarData, activityObservationPosition);//Берем из конфига дату первого наблюдения наблюдения. Надо сделать это сразу. Если плагин включается по календарным датам, он должен знать когда включится впервый раз
								
		if(signalType=='kill'){//Если плагин настроен чтобы убивать особей
		   killStoped = configuration.getOption(optionPath + 'killStoped');//Узнаем, должны ли мы убивать всех подряд или только активных осоей
				
			if(killStoped !='true' && killStoped !='false'){//Если опция killStoped напсиана неправильно
			   messenger.message('killStoped: ' + killStoped + '. ' + errorType.varIsIncorrect, 0);
			   killStoped = 'false';//Заменяем неправильное значение на значение по умолчанию 
			   }
			}
				
		selectionType = configuration.getOption(optionPath + 'selectionType');
				
		if(selectionType != 'percents' && selectionType != 'items'){//Если в настройках способ выборки особей поставлен неправильно или отсутствует
		   selectionType = 'percents';//Выбираем значение по умолчанию
		   msgString = errorType.varIsIncorrect + '. ' + errorType.defaultValue + ': percents';
		   messenger.message(msgString, modelEvent.ERROR_MARK);
		  }
				
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
				signalType = 'susupend';
				statMessageHead = 'inactive_ind_numb';
			default:
				messenger.message('Wrong type of signal', modelEvent.ERROR_MARK);
				signalType = 'susupend';
				statMessageHead = 'inactive_ind_numb';
				}
				
			activeIndividualsNumberPosition = dataPath + '.part';
			numberOfObservingsInConfig = countAllObservings();//Получаем количество заданных в конфиге наблюдений за активностью
			
			setDuration();
			cycleCounter = 1;
			msgString = 'cycle: ' + cycleCounter;
			
				
			if(alreadyInited == 'fals'){
			   setTimeout(pluginEvent.ready, 50);//Сообщение о том что плагин полностью готов к работе принимается функцией onPluginsJobeFinish в pluginLoader
			   }
		}
		
	override public function startPluginJobe():void{//Эта функция запускается периодичски, включая основной функционал плагина
		stopInd();//Это основной функционал
		setNewObservingPosition();
		setDuration()
		
		}
	
	private function countAllObservings():int{
		var numberOfObservingsInConfig:int = 0;
		var optionValue:String = 'empty';
		
		try{
		
			while(optionValue != 'Error'){//Пока не вышли за пределы списка наблюдений
				
				optionValue = configuration.getOption(activeIndividualsNumberPosition, activityObservationPosition);
				
				if(optionValue == null){
					throw new ReferenceError('Can non get current active inividuals number from config');
					}
				if(numberOfObservingsInConfig > MAX_OPTIONS_LIST_SIZE){
					throw new Error('To much search repitings: ' + numberOfObservingsInConfig);//Если есть угроза войти в бесконечный цикл, аварийно выходим
					}
				activityObservationPosition[3]++;
				numberOfObservingsInConfig++;
			}
			
		}catch(e:Error){
			msgString = e.message;
			messenger.message(msgString, modelEvent.ERROR_MARK);
			}
		
		activityObservationPosition[3] = 0;//Корректируем
		numberOfObservingsInConfig--;//Корректируем
		
		msgString = 'Number of observations is ' + numberOfObservingsInConfig;
		messenger.message(msgString, modelEvent.DEBUG_MARK);
		
		return numberOfObservingsInConfig;
		}
	
	private function setNewObservingPosition():void{
		if(currentActivityPosition > numberOfObservingsInConfig){//Если мы дошли до конца списка и Configuration container вернул ошибку int(Error) - 0
			currentActivityPosition = 0;//Возвращаемся в начало списка наблюдений чтобы начать переключение заново
			cycleCounter++;
			
			if(switchingEvent == 'steps'){
				msgString = 'cycle: ' + cycleCounter;
				messenger.message(msgString, modelEvent.STATISTIC_MARK);	
				}
				
				}else{
					currentActivityPosition++;
					}
				activityObservationPosition[3] = currentActivityPosition;//Указываем на положение текущего наблюдения в конфиге
				currentDay = configuration.getOption(calendarData, activityObservationPosition);//Берем из конфига дату наблюдения
				
				if(currentDay == 'Error'){//Если дошли до конца списка
					currentActivityPosition = 0
					activityObservationPosition[3] = currentActivityPosition;//Обнуляем счетчик. А то плагин будет стоять и ждать дату Error
					currentDay = configuration.getOption(calendarData, activityObservationPosition);//Берем из конфига дату наблюдения
					msgString = 'Plugin has begun new cycle';
					messenger.message(msgString, modelEvent.DEBUG_MARK);
					}
				
				msgString = 'Next observation data is ' + currentDay + ' (position ' + activityObservationPosition[3] + ')';
				messenger.message(msgString, modelEvent.DEBUG_MARK);
		}
	private function setDuration():void{
		currentDuration = int(configuration.getOption(durationDataPath, activityObservationPosition));
		
		if(currentDuration > 0){//Если время паузы прописано в конфиге
			setNewSwitchingInterval(currentDuration);
			msgString = 'Pause duration is set to ' + currentDuration;
			messenger.message(msgString, modelEvent.DEBUG_MARK);
			}else if(switchingIntervalHasChanged == 'true'){
				setNewSwitchingInterval(0);//0 - значит вернуть предыдущий интервал
				}
	};

	private function stopInd():void{//С этой функции начинает выполнятся основной функционал плагина
		
		var currentActiveIndividualsNumber:int;//Количество особей, которых нужно остановить в этот цикл
	
		try{

			currentActiveIndividualsNumber = int(configuration.getOption(activeIndividualsNumberPosition, activityObservationPosition));			
			stopOnly(currentActiveIndividualsNumber, selectionType);

			msgString = 'Current stoped individuals part is ' +  currentDay + '(position ' + currentActivityPosition + '): '+ currentActiveIndividualsNumber;
			messenger.message(msgString, modelEvent.DEBUG_MARK);
				
			if(activeIndividualsNumberPosition != 'Error'){
				msgString = statMessageHead + ':' + currentActiveIndividualsNumber;
				messenger.message(msgString, modelEvent.STATISTIC_MARK);//Посылаем данные о количестве неактивных особей как статистику
				}
					
			if(switchingEvent == 'steps' && currentDay != 'Error'){//У кого значение steps - управляет другими плагинами так как транслирует дату. Остальные дату показывать не должны
				  msgString = 'calendar_data' + ':' + currentDay;//Передаем в статистику дату наблюдения
				  messenger.message(msgString, modelEvent.STATISTIC_MARK);
				  }

				}catch(e:Error){
					messenger.message(e.message, modelEvent.ERROR_MARK);
					}
			}
	
	private function stopOnly(objNumber:int, unit_type:String):void{
	//Передаются два параметра - число особей, которое надо остановить и единицы измерения - проценты или штуки
		var itemsNumber:int;
		stopedIndividuals = new Array;
		
		try{
			switch(unit_type){
				case 'percents':

					itemsNumber = 0;
					itemsNumber = Math.round((objNumber/100)*(individuals.length))//Высчитываем количество из процентов
			
					for(var i:int = 0; i< itemsNumber; i++){//Определяем количество особей, которых надо остановить
						stopedIndividuals[i] = setObjRange();
						}
					fixRepitigItems();
					sendStop();
			
				break;

				case 'items':
			
					itemsNumber = 0;
					itemsNumber = objNumber - 1;
			
					for(i = 0; i< itemsNumber; i++){
					    stopedIndividuals[i] = setObjRange();
					    }
			           
			         fixRepitigItems();
				     sendStop();
			
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
			
		if(individuals[stopedObjPosition]==null && individuals[stopedObjPosition].statement != 'dead'){//Если особь существует и движеться ???????????? сюда вставить критерий поиска, напримр если статус особе отличается от заданного
			stopedObjPosition = setObjRange();
			}
				
		return stopedObjPosition;
		}
	
	private function fixRepitigItems():void{//Убирает повторяющиеся значения из списка останавливаемых особей
		stopedIndividuals.sort(Array.DESCENDING);//Это нужно, чтобы элементы удалялись один за одним начиная с самого последнего иначе есть риск обратится к уже несуществующему элементу	
		for(i = 1; i< stopedIndividuals.length; i++){//По возможности убираем повторяющиеся элементы сдвигая их на шаг вперед. Понятно что снижает скорость, зато увеличивает точность
			if(stopedIndividuals[i]==stopedIndividuals[i-1]){
			   stopedIndividuals[i]++;
			   }
			}
		}

	private function sendStop():void{
		var counter:int;
		try{
			if((individuals.length - 1) < CRITIAL_IND_NUMBER){
				throw new IllegalOperationError(errorType.tooSmall + '. Number of individals less then critical');
				}
			
			for(var i:int = 0; i< stopedIndividuals.length; i++){//Пробигаемся по списку особей, которых надо остановить
				
				if(individuals[stopedIndividuals[i]] != null){
				
					switch(signalType){
						case 'susupend':	
						
							if(individuals[stopedIndividuals[i]].hasOwnProperty('statement')){
								individuals[stopedIndividuals[i]].statement('suspend', switchingInterval);//Останавливаем особь на нужное время
								}
								else{
									throw new ReferenceError('Can not find call statement property. It seems, that individual now not exist');
									}
						break;
						case 'stop':
							if(individuals[stopedIndividuals[i]].hasOwnProperty('statement')){
								individuals[stopedIndividuals[i]].statement('stop', switchingInterval);//Останавливаем особь на нужное время
								}
								else{
									throw new ReferenceError('Can not find function stopIndividual. It seems, that individual now not exist');
									}
						break;
						case 'kill':
							
							if(individuals[stopedIndividuals[i]].hasOwnProperty('statement')){
								
								if(killStoped =='true'){//Если можно, убиваем всех особей из выборки
									individuals[stopedIndividuals[i]].statement('dead');
									}else{
										if(individuals[stopedIndividuals[i]].statement() =='moved'){//А иначе убиваем только тех, кто движеться
											individuals[stopedIndividuals[i]].statement('dead');
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
