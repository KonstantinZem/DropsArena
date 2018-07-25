package konstantinz.community.comStage.behaviour{

	import konstantinz.community.auxilarity.*;
	import flash.errors.IllegalOperationError;
	import flash.events.*;

public class BehaviourChoicer extends EventDispatcher{
	
	private const ERROR_MARK:int = 0;//Сообщение об ошибке помечаются в messanger помечаеся цифрой 0
	private const CONDITION_PATH:String = 'main.behaviourSwitching.rule.condition.condition_name'//3,4;
	private const BEHAVIOUR_TYPE_PATH:String = 'main.behaviourSwitching.rule.behavior';//3
	private const CONDITION_MAX_VALUE:String = 'main.behaviourSwitching.rule.condition.condition_max_value';
	private const CONDITION_MIN_VALUE:String = 'main.behaviourSwitching.rule.condition.condition_min_value';
	private const MAX_OPTIONS_LIST_SIZE:int = 10;//Чтобы небыло бесконечных поисковых циклов, их надо ограничить
	
	public static var BEHAVIOUR_HAS_FOUND:String = 'behaviour_has_found';//Так мы говорим, что нужное поведение найдено
	
	private var debugLevel:String;
	private var msgString:String;
	private var paramNamebuffer:Array//Здесь хранится название факторов среды
	private var valueBuffer:Array//Здесь хранится значение факторов среды
	private var counter:int;
	private var paramPosition:int;
	private var messenger:Messenger;
	private var configuration:ConfigurationContainer;
	private var behaviourSvitchingRules:Array;//Здесь будут хранится эталонные значения условий и название схем поведения
	private var rulesAreIncomplited:String;//Пометка о ошибках на стадии инициации, чтобы предотвартить неправильную работу при ошибках в конфигурационном файле
	
	public var behaviourName:String;
	
	function BehaviourChoicer(pathToConfig:ConfigurationContainer, dbgLevel:String = '3'){
		rulesAreIncomplited = 'false';
		debugLevel = dbgLevel;
		configuration = pathToConfig;
		configuration.setDebugLevel(debugLevel);
		paramNamebuffer = new Array();
		valueBuffer = new Array();
		messenger = new Messenger(debugLevel);
		counter = 0;
		messenger.setMessageMark('BehaviourChoicer');
		msgString = "BehaviourChoicer  loaded";
		messenger.message(msgString, 1);
		initRules();
		
		}
		
	public function getConditionsMeaning(meaning:String):void{//Получаем из внешнего мира значения факторов среды
		try{
			
			if(rulesAreIncomplited =='true'){//Если в конфигурационный файл внесли не все опции, нужные для описани эталонных условий
				throw new Error('I can not process data cause some errors in initiation time');//Лучше сразу перестать обрабатывать запрос чтобы не искажать данные
				}
			
			if(paramNamebuffer == null||valueBuffer == null){//Если массивы еще не инициированы
				throw new ReferenceError('One or both buffers not initilased yet');
				}
			
			var parsedMessage:Array = meaning.split(':');//Отделяем имя сообщения от ползной нагрузки
			
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
				
				choseBehaviour();
					
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
			catch(err:Error){
				
				msgString = err.message;
				messenger.message(msgString, ERROR_MARK);
				
			}
				paramPosition = 0;
		}
		
		private function initRules():void{//Заполняем массив эталонными значениями из конфига так как слишком частое обащение к конфигу приводит к зависанию
			behaviourSvitchingRules = new Array();
			var parsingErrors:String = 'false';
			var rulePosition:int = 0;//Позиция конкретного элемента <rule> в конфигурационном файле
			var currentPosition:Array = new Array(0,0,0,0,0);//Этот массив будет указывать на конкретный элемент
			var currentBNamePosition:Array = new Array(0,0,0,0);
			var behaviourType:String = '';
			var conditionName:String = '';
			var conditionMinValue:Number = 0;
			var conditionMaxValue:Number = 0;
			
			try{
			
				while(behaviourType != 'Error'){//Если мы еще не вышли за пределы списка типов поведения
					behaviourSvitchingRules[rulePosition] = new Object();
					behaviourType = configuration.getOption(BEHAVIOUR_TYPE_PATH,currentBNamePosition);//Получаем название первой в списке модели поведения
										
					behaviourSvitchingRules[rulePosition]['behaviour_name'] = behaviourType;
					behaviourSvitchingRules[rulePosition]['conditions'] = new Array();
			    
					while(conditionName != 'Error'){
						conditionName = configuration.getOption(CONDITION_PATH,currentPosition);//Читаем из конфигурационного файла по очереди названия факторов
											
						behaviourSvitchingRules[rulePosition]['conditions'][currentPosition[3]] = new Object();
						behaviourSvitchingRules[rulePosition]['conditions'][currentPosition[3]]['name'] = conditionName;
					
						conditionMinValue = Number(configuration.getOption(CONDITION_MIN_VALUE,currentPosition));
						conditionMaxValue = Number(configuration.getOption(CONDITION_MAX_VALUE,currentPosition));
											
						behaviourSvitchingRules[rulePosition]['conditions'][currentPosition[3]]['min_value'] = conditionMinValue;
						behaviourSvitchingRules[rulePosition]['conditions'][currentPosition[3]]['max_value'] = conditionMaxValue;
						currentPosition[3]++;//Если текущий набор правил не соответсвует текущему значению факторов, переходим к следующему набору
										
						}
			if(conditionName == 'Error'&& isNaN(conditionMinValue) && isNaN(conditionMaxValue)){
			 	behaviourSvitchingRules[rulePosition]['conditions'].pop();//Убираем последний элемент массива. Он пустой, так как цикл while делает лишний оборот
			    conditionMinValue = 0;
				conditionMaxValue = 0;
			}
					currentBNamePosition[2]++;
					currentPosition[3] = 0;
					conditionName = '';
					currentPosition[2]++;
					rulePosition++;
					
				}
				
				if(behaviourType=='Error' && behaviourSvitchingRules[rulePosition - 1]['conditions'].length == 0){
					behaviourSvitchingRules.pop();//Убираем последний элемент массива. Он пустой, так как цикл while делает лишний оборот
				}
				
				parsingErrors = conditionsIncompleted();//Проверяем чтобы все нужные для вычисления условия присутсвовали в массиве
				
				if(parsingErrors == 'true'){//Если в конфигурационном файле какое то условие не указанно
					throw new Error('Rules are incompleted');
					}
									
			}catch(err:Error){
				msgString = err.message;
				messenger.message(msgString, ERROR_MARK);
				rulesAreIncomplited ='true';//Помечаем, что при обработке конфигураци
				}
			}
		
		private function conditionsIncompleted():String{
			var areConditionsIncompleted:String = 'false';
			var lastConditionPosition:int = 0;
			
			for(var i:int = 0; i<behaviourSvitchingRules.length; i++){
				
				lastConditionPosition = behaviourSvitchingRules[i]['conditions'].length - 1;
				
				if(behaviourSvitchingRules[i]['behaviour_name']=='Error'){
					areConditionsIncompleted = 'true';
					msgString = 'Behaviour name in block ' + i + ' not set';
					messenger.message(msgString, ERROR_MARK);
					}
				if(behaviourSvitchingRules[i]['conditions'].length==0){
					areConditionsIncompleted = 'true';
					msgString = 'Factor name in block ' + i + ' not set';
					messenger.message(msgString, ERROR_MARK);
					}
					
				if(behaviourSvitchingRules[i]['conditions'][lastConditionPosition]['name']=='Error'){
					areConditionsIncompleted = 'true';
					msgString = 'Condition name in block ' + i + ' not set';
					messenger.message(msgString, ERROR_MARK);
					}
				if(isNaN(behaviourSvitchingRules[i]['conditions'][lastConditionPosition]['min_value']) || isNaN(behaviourSvitchingRules[i]['conditions'][lastConditionPosition]['max_value'])){
					areConditionsIncompleted = 'true';
					msgString = 'Something wrong in factor values set';
					messenger.message(msgString, ERROR_MARK);
					}
				}
				
				return areConditionsIncompleted;
			}
		
		private function choseBehaviour():String{//Функция возвращает название модели поведения, соответсвующую имеющимуся набору факторов

			var isBehaviourSuitable:String = 'true';
			var behaviourType:String = 'not_found';
			var rulePosition:int = 0;//Позиция конкретного элемента <rule> в конфигурационном файл
			
			try{
							
				for (var i:int = 0; i<behaviourSvitchingRules.length; i++){//Если мы еще не вышли за пределы списка типов поведения
					
					
					isBehaviourSuitable = checkBehaviourSuitability(rulePosition);
						
					if(isBehaviourSuitable == 'false'){
						rulePosition++;//Если текущий набор правил не соответсвует текущему значению факторов, переходим к следующему набору
						isBehaviourSuitable='true';
						}else{
							dispatchEvent(new Event(BehaviourChoicer.BEHAVIOUR_HAS_FOUND));
							
							behaviourType = behaviourSvitchingRules[rulePosition]['behaviour_name']; 
							
							behaviourName = behaviourType;
							msgString = 'Proper behaviour has found: ' + behaviourType + '; '+ paramNamebuffer + '; ' + valueBuffer;
							messenger.message(msgString, 2);
							break;//Если мы нашли нужное поведение, прекращаем поиск
							}

					}
				
				}catch(err:Error){
					msgString = err.message;
					messenger.message(msgString, ERROR_MARK);
					}
					
			return behaviourType;
		}
		
		private function checkBehaviourSuitability(position:int):String{
			var isBehaviourSuitable:String ='true';
			var conditionName:String = '';
			var conditionMinValue:int = 0;
			var conditionMaxValue:int = 0;
			var currentFactorValue:int//Текущее значение фактора среды, находящиеся в valueBuffer
			
			try{
			
				for (var i:int = 0; i<behaviourSvitchingRules[position]['conditions'].length; i++){//До тех пор, пока не вышли за пределы списка
					
					for(var j:int = 0; j<paramNamebuffer.length; j++){
					
					conditionName = behaviourSvitchingRules[position]['conditions'][i]['name'];
					conditionMinValue = behaviourSvitchingRules[position]['conditions'][i]['min_value'];
					conditionMaxValue = behaviourSvitchingRules[position]['conditions'][i]['max_value'];
					
					currentFactorValue = valueBuffer[paramNamebuffer.indexOf(conditionName)];
						
					if(currentFactorValue > conditionMinValue && currentFactorValue < conditionMaxValue){//Если значение фактора находится в пределах указанных в правиле
								
						msgString = conditionName + ':' + currentFactorValue + ':' + conditionMinValue + '-' + conditionMaxValue;
					    messenger.message(msgString, 3);		
						}else{//Иначе делаем пометку, что рассматривемый тип поведения не подходит
							isBehaviourSuitable='false';
							}
						}
							
					}
				}catch(err:Error){
					msgString = err.message;
					messenger.message(msgString, ERROR_MARK);
				}
				return isBehaviourSuitable;
			}
	}
}
