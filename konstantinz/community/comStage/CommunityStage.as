//Предназначение этого класса - предоставлять особям информацию о их местоположении и об условиях окружающей среды
package konstantinz.community.comStage{
	import flash.display.Sprite;
	import konstantinz.community.auxilarity.*

	public class CommunityStage extends Sprite{
		private const CRITICAL_LEVEL:int = 8; //Размер элемента, слишком мал для стабильной работы класса
		private const RECTCOLOR:Number = 0xFFFFFF //Цвет квадратика
		private const BORDERCOLOR:Number = 0x000000;
		
		private var squSize:int;
		private var stgHeight:int;//Высота сцены
		private var stgWidth:int;
		private var sqrQantH:int; //Количество квадратов в столбце
		private var sqrQantW:int; //Количество квадратов в ряду
		private var lifeQuant:int//Убыль жизни за ход
		private var errorType:Object;//Контейнер для ошибок
		private var debugLevel:String;
		private var msgString:String
		private var messenger:Messenger;
		
		public var chessDesk:Array;
		
		function CommunityStage(stgh:int,stgw:int,extOptions:Object){
			
			errorType = new ModelErrors();
			
			try{
				debugLevel = extOptions.getOption('main.debugLevel');
				messenger = new Messenger(debugLevel);
				messenger.setMessageMark('Community stage');
				
				for(var i:int = 0; i<arguments.length; i++){
					if(arguments[i] ==0){ //Если аргументу передали некорректные аргументы, генерируем ошибку
						throw new Error(errorType.paramError);
						}
					}
				this.squSize = int(extOptions.getOption('main.dropSize'));
				if(squSize<CRITICAL_LEVEL){//Если мы рискуем получить слишком много слишком мелких квадратов
					throw new Error(errorType.tooSmall + ' ' + errorType.unstableWarning);//Лучше сразу выбросить ошибку, чтобы не повесить комп
					}
				
				//this.envParams = new EnvParams();//Загружаем условия окружающей среды по умолчанию
				stgHeight = stgh;
				stgWidth = stgw;
				sqrQantH = stgHeight/squSize;//Количество квадратов по высоте
				sqrQantW = stgWidth/squSize;//Количество квадратов по ширине
				lifeQuant = int(extOptions.getOption('main.lifeQuant'));
				buildStage();
				buildNet();
					
				msgString = 'The stage ' + chessDesk.length + 'X' + chessDesk[0].length + ' has bulded succesfully';
				messenger.message(msgString, 1);
				}
			catch(error:ArgumentError){
				msgString = "<Error> " +  error.message;
				messenger.message(msgString, 0);
				}
				}
		   private function buildStage():void{
				
				chessDesk = new Array(sqrQantH);
				
				for(var i:int = 0; i<sqrQantH; i++){
					chessDesk[i] = new Array(sqrQantW);
					for(var j:int = 0; j< sqrQantW; j++){
						chessDesk[i][j] = new Array
						chessDesk[i][j]['picture'] = new Object();
						//chessDesk[i][j]['envParams'] = new Object();//Параметры окружающей среды
						chessDesk[i][j]['sqrX'] = new Object(); 
						chessDesk[i][j]['sqrY'] = new Object();
						chessDesk[i][j]['speedDeleyA'] = new Object();//Задержка между тиками таймера для взрослых
						chessDesk[i][j]['speedDeleyY'] = new Object();//Задержка между тиками таймера для молодых
						chessDesk[i][j]['lifeQuant'] = new Object();//Убыль жизни
						chessDesk[i][j]['numberOfIndividuals'] = new Object();//Количество особей в данном квадрате
						
						}
				}
				}
			
			private function buildNet():void{
				//Разлинеивает игровое поле в квадратики
				var xpos:int = 0; //Позиция квадрата на поле
				var ypos:int = 0;

				for(var i:int = 0; i<chessDesk.length; i++){
					
					for(var j:int = 0; j<chessDesk[i].length; j++){
						chessDesk[i][j]['picture'] = new Sprite();
						chessDesk[i][j]['picture'].graphics.lineStyle(1,BORDERCOLOR);
						chessDesk[i][j]['picture'].graphics.beginFill(RECTCOLOR);
						chessDesk[i][j]['picture'].graphics.drawRect(xpos,ypos,squSize,squSize);
						chessDesk[i][j]['sqrX'] = xpos; //Чтобы не лазить за координатами квадрата в картинку, разместим их внутри самого массива
						chessDesk[i][j]['sqrY'] = ypos;
						chessDesk[i][j]['speedDeleyA'] = 1;//по умолчанию двигаемся без задержки 
						chessDesk[i][j]['speedDeleyY'] = 1;
						chessDesk[i][j]['lifeQuant'] = lifeQuant;
						chessDesk[i][j]['numberOfIndividuals'] = '';//Изначально в квадрате нет ни одной особи
						
						addChild(chessDesk[i][j]['picture']);
						xpos = xpos + squSize;
						}
					   ypos = ypos + squSize;
	                   xpos = 0;
				}
				
				}
		}
	}
