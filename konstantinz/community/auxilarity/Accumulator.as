package konstantinz.community.auxilarity{

import flash.events.TimerEvent; 
import flash.utils.*;
import konstantinz.community.auxilarity.*;

public class Accumulator{
	
	private var refreshTime:int;
	private var debugLevel:String;
	private var msgString:String;
	private var paramNamebuffer:Array//Здесь хранится информация для формирования таблицы статистики
	private var valueBuffer:Array//
	private var refreshTimer:Timer;
	private var counter:int;
	private var messenger:Messenger;
	private var paramPosition:int;
	
	public var statTable:Array;//Здесь будет хранится собираемая статистика
	public var statusBarText:String;
	
	private static var _instance:Accumulator;

	public function Accumulator(){
		if (_instance){//Singleton realisation
             throw new Error("Class is singleton.");
		}else{
		
			debugLevel = '3';
			messenger = new Messenger(debugLevel);
			counter = 0;
			messenger.setMessageMark('Accumulator');
			msgString = "Acumulator loaded";
			messenger.message(msgString, 1);
			refreshTime = 0;
			paramNamebuffer = new Array;
			paramNamebuffer[0] = '№';
			valueBuffer = new Array;
			valueBuffer[0] = 0;
			statTable = new Array;
			statTable[0] = new Array;
			paramPosition = 0;
			statusBarText = '';
			}
	}
	
	public static function get instance():Accumulator{
            if (!_instance){
				_instance = new Accumulator();
				}
            return _instance;
            }

	public function setDebugLevel(dbgLevel):void{
		debugLevel = dbgLevel;
		}
	
	public function setRefreshTime(time:int):void{
		try{
			if(time<=0){
				throw new Error('Refresh time less then 0 sec or equial 0 sec');
				}
			refreshTime = time*1000;
			refreshTimer = new Timer(refreshTime);
			refreshTimer.addEventListener(TimerEvent.TIMER, prepareStatTable);
			refreshTimer.start();
		}catch(err:Error){
			msgString = err.message;
			messenger.message(msgString, 0);
			refreshTime = 0;
			}

		}
	public function pushToBuffer(message:String):void{
		
		try{
			
			var parsedMessage:Array = message.split(':');//Отделяем имя сообщения от ползной нагрузки
			
			if(parsedMessage.length==2){//Если параметр передан правильно и состоит из имени и значения
				if(paramNamebuffer.indexOf(parsedMessage[0])==-1){
					paramNamebuffer.push(parsedMessage[0]);//Добавляем его к массиву
					valueBuffer.push(parsedMessage[1]);
					}
				else{
					paramPosition = paramNamebuffer.indexOf(parsedMessage[0])
					valueBuffer[paramPosition] = parsedMessage[1];//Заносим в соответсвующую позицию буфера значений переданное значение
					}
				
				}
				else{
					throw new Error('Wrong message format');
				}
					
			}catch(err:Error){
				msgString = err.message;
				messenger.message(msgString, 0);
			}
				paramPosition = 0;
		}
		
		private function prepareStatTable(event:TimerEvent):void{
			statTable[0].length = 0;//Очищаем заголовок таблицы перед его заполнением
			counter++;
			statTable[statTable.length] = new Array;
		
			for(var i:int = 0; i < paramNamebuffer.length; i++){ 
				if(statTable[0].length<paramNamebuffer.length){//Если в буфере есть новые параметры
				
					statTable[0].push(paramNamebuffer[i]);
				}
				statTable[statTable.length-1].push(valueBuffer[i]);
			
			}
				
				valueBuffer[0]=counter;
				msgString = tableToString();
				messenger.message(msgString, 1);
				setStatusText();//Сохраняем статистическую информацию для показа в строке состояния
				
		}
		private function tableToString():String{//Готовит таблицу для печати в консоли отладки
			var tbody:String;//Таблица, отформатированная для печати
			var thead:String = ''//Строка загаловка таблицы
			var trow:String;//Строки таблицы
			var spacer:String;//Строка пробелов выравнивающая ширину столбца с заголовком столбца
			var numberSign:String;
			
			spacer = emptySpace(statTable[0][0], statTable[statTable.length - 1][0])//Находим разницу в динне между символом номера и последней цифрой счетчика в таблици
			numberSign = statTable[0][0] + spacer + '|';
			
			statTable[0][0] = statTable[0][0] + spacer;
			
			for(var i:int = 1; i<statTable[0].length; i++){
				thead = thead + statTable[0][i] + '|';
				}
				tbody = '\n|'+ numberSign + thead + '|\n';
			
			for(i = 1; i<statTable.length; i++){
				trow = '|';
				for(var j:int = 0; j<statTable[i].length; j++){
					spacer = emptySpace(statTable[i][j], statTable[0][j]);
					trow = trow + statTable[i][j] + spacer;
					}
				trow = trow + '|\n';
				tbody = tbody + trow;
					}
			statTable[0][0] = '№';
			return tbody;
		}
			
	private function emptySpace(pvalue:String, pname:String):String{//Печатает пустую строку для выравнивания 
		var emptyString:String = ' ';
		var elength:int = pname.length - pvalue.length;
			
			for(var i:int = 0; i<elength; i++){
				emptyString  = emptyString + ' ';
				}
			return emptyString;
			}
			
	private function setStatusText():void{
         statusBarText = '';
         for(var i:int = 1; i<statTable[0].length; i++){
            statusBarText = statusBarText + (statTable[0][i] + ': ' + statTable[statTable.length - 1][i] + '    ');
         }
      }

}

}
