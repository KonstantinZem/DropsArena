//Предназначение этого класса - готовить для вывода на экран статистическую информацию в виде сводной таблицы
package konstantinz.community.auxilarity{

import flash.events.TimerEvent; 
import flash.errors.IllegalOperationError;
import flash.utils.*;
import konstantinz.community.auxilarity.*;

public class Accumulator{
	
	private const ERROR_MARK:int = 0;//Сообщение об ошибке помечаются в messanger помечаеся цифрой 0
	
	private var debugLevel:String;
	private var msgString:String;
	private var paramNamebuffer:Array//Здесь хранится информация для формирования таблицы статистики
	private var valueBuffer:Array//
	private var counter:int;
	private var paramPosition:int;
	private var refreshTime:int;
	private var refreshTimer:Timer;
	private var messenger:Messenger;
	
	public var statTable:Array;//Здесь будет хранится собираемая статистика
	public var statusBarText:String;
	
	private static var _instance:Accumulator;
	private static var _okToCreate:Boolean = false;//Переменная сигнализирует существует ли уже экземпляр данного класса


	public function Accumulator(){
	
		if ((!_okToCreate)){//Singleton realisation
             throw new Error("Class is singleton. Use method instance() to get it");
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
				_okToCreate = true;
				_instance = new Accumulator();
				_okToCreate = false;
				}
            return _instance;
            }
            
    public function clear():void{
		counter = 0;
		stopRefresh();
		paramNamebuffer = new Array;
		paramNamebuffer[0] = '№';
		valueBuffer = new Array;
		valueBuffer[0] = 0;
		statTable = new Array();
		statTable[0] = new Array;
		statusBarText = '';
		}

	public function setDebugLevel(dbgLevel:String):void{
		debugLevel = dbgLevel;
		}
	
	public function setRefreshTime(time:int):void{
		try{
			if(time<=0){
				throw new Error('Refresh time less then 0 sec or equial 0 sec');
				}
			refreshTime = time*1000;//Переводим время из секунд в миллисекунды
			refreshTimer = new Timer(refreshTime);
			refreshTimer.addEventListener(TimerEvent.TIMER, prepareStatTable);
			//refreshTimer.start();
		}catch(err:Error){
			msgString = err.message;
			messenger.message(msgString, ERROR_MARK);
			refreshTime = 0;
			}

		}
	public function stopRefresh():void{
		refreshTimer.stop();
		msgString = 'Accumulator has stoping refreshing statistical data';
		messenger.message(msgString, 2);
		}
		
	public function startRefresh():void{
		refreshTimer.start();
		msgString = 'Accumulator has starting refreshing statistical data';
		messenger.message(msgString, 2);
		}
	
	public function pushToBuffer(message:String):void{
		
		try{
			
			if(paramNamebuffer == null||valueBuffer == null){//Если массивы еще не инициированы
				throw new ReferenceError('One or both buffers not initilased yet');
				}
			
			var parsedMessage:Array = message.split(':');//Отделяем имя сообщения от ползной нагрузки
			
			if(parsedMessage.length==2){//Если параметр передан правильно и состоит из имени и значения
				if(paramNamebuffer.indexOf(parsedMessage[0])==-1){
					paramNamebuffer.push(parsedMessage[0]);//Добавляем его к массиву
					valueBuffer.push(parsedMessage[1]);
					}
				else{
					paramPosition = paramNamebuffer.indexOf(parsedMessage[0]);
					valueBuffer[paramPosition] = parsedMessage[1];//Заносим в соответсвующую позицию буфера значений переданное значение
					}
				
				}
				else{
					throw new ArgumentError('Wrong message format');
				}
					
			}catch(err:ReferenceError){
				msgString = err.message;
				messenger.message(msgString, ERROR_MARK);
				paramNamebuffer = new Array();//ИНициируем массивы и ничего дальше не делаем, все равно на следующем выхове все сработает правильно
				valueBuffer = new Array();
				}
			catch(err:ArgumentError){
				
				msgString = err.message;
				messenger.message(msgString, ERROR_MARK);
				
			}
				paramPosition = 0;
		}
		
		public function getStatistic():String{
			var statText:String
			try{
				statText = tableToString();
				}catch(e:Error){
					statText ='Table is empty yet';//Если таблица еще не сформирована, посылаем в ответ эту строку
				}
			return statText;
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
			var tbody:String='';//Таблица, отформатированная для печати
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
		var emptyString:String = '\u0020';
		var elength:int = pname.length - pvalue.length;
			
			for(var i:int = 0; i<elength; i++){
				emptyString  = emptyString + '\u0020';//Символ пробела
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
