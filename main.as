﻿// Author: Konstantin Zemoglyadchuk konstantinz@bk.ru
// Copyright (C) 2017 Konstantin Zemoglyadchuk
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

package{
    
    import flash.display.Sprite
	import flash.events.Event; 
	import konstantinz.community.comStage.*
	import konstantinz.community.auxilarity.*
   
    public class main extends Sprite{
		
		private var stgHeight:int;
		private var stgWidth:int;
		private var versionText:Sprite
		private var debugLevel:String;
		private var msgStreeng:String;
		private var debugeMessage:DebugeMessenger
		
		public var indSuspender:Array//Структура, через которую особей можно на нужное время останавливать
		public var configuration:ConfigurationContainer;
		public var commStage:*
		public var plugins:Sprite;
		public var individuals:Array;
		public var model:Sprite

		public function main(){
			
			stgHeight = parent.stage.stageHeight;
			stgWidth = parent.stage.stageWidth;
			configuration = new ConfigurationContainer('configuration.xml', 'true');
			configuration.addEventListener(ConfigurationContainer.LOADED, init);//
			configuration.addEventListener(ConfigurationContainer.LOADING_ERROR, init)//Если не найдем конфигурационного файла, все равно загружаем программу дальше
			
			model = new Sprite();
			this.addChild(model);
        }
        

		private function init(e:Event):void{
			var initPosition:String;//Каким образом будут добавлятся первые особи
			var intX:int = 0//Первоначальная координата по x
			var intY:int = 0//Первоначальная координата по y
			debugLevel = configuration.getOption('main.debugLevel'); //Нужно ли отображать отладочную информацию
			debugeMessage = new DebugeMessenger(debugLevel);
			debugeMessage.setMessageMark('Main');
						
			versionText = new myVersion('0.42',debugLevel);
			
			initPosition = configuration.getOption('main.initPosition');
			model.addChild(versionText);
			
			versionText.x = 10;
			versionText.y = 0;

			commStage = new CommunityStage(stgHeight+10,stgWidth+20,configuration);
			model.addChild(commStage);
			commStage.x = 10;
			commStage.y = 20;
			commStage.scaleX = 0.9;
			commStage.scaleY = 0.9;
			individuals = new Array;
			indSuspender = new Array;
						
			switch(initPosition){//Помещаем первых особей по разным схемам, согласно конфигу
				case 'left-top':
					intX = 0;
					intY = 0;
					addInitIndividuals(intX,intY);
				break;
				
				case 'left-bottom':
					intX = commStage.chessDesk.length-1;
					intY = 0;
					addInitIndividuals(intX,intY);
				break;
				
				case 'right-top':
					intX = 0;
					intY = commStage.chessDesk[1].length-1;
					addInitIndividuals(intX,intY);
				break;
				
				case 'right-bottom':
					intX = commStage.chessDesk.length-1;
					intY = commStage.chessDesk[0].length-1;
					addInitIndividuals(intX,intY);
				break;
				
				case 'center':
					intX = commStage.chessDesk.length/2;
					intY = commStage.chessDesk[0].length/2;
					addInitIndividuals(intX,intY);
				break;
				
				case 'random':
					rndAddInitIndividuals();
				break;
				
				default:
					addInitIndividuals(0,0);
				}
			
			if(configuration.getOption('main.pluginEnable')=='true'){
				plugins = new PluginLoader(configuration);
				model.addChild(plugins);
				msgStreeng = 'Plugins are enabled';
				
			}else{
				msgStreeng = 'Plugins are disabled';
				}
					
			configuration.removeEventListener(ConfigurationContainer.LOADED, init);
			debugeMessage.message(msgStreeng, 2)
		}
		
		private function addInitIndividuals(indX:int, indY:int):void{//Добавляем первых особей
			
			for (var i:int = 0; i< int(configuration.getOption('main.indQuntaty')); i++){
				individuals[i] = new Individual(this,commStage.chessDesk,configuration,i,indX,indY);
				indSuspender[i] = new Suspender(individuals[i],commStage.chessDesk,configuration)
				
				commStage.addChild(individuals[i])
				individuals[i].IndividualEvent.addEventListener(ModelEvent.MATURING, addNewIndividuals);
				individuals[i].IndividualEvent.addEventListener(ModelEvent.DEATH, removeIndividuals);
			}
			
			}
			
		private function rndAddInitIndividuals():void{//Добавляем первых особей в случайных позициях
			
			var indXRnd : int;
			var indYRnd : int;
			
			var chessDeskLengthX:int = commStage.chessDesk.length - 1
			var chessDeskLengthY:int = commStage.chessDesk[1].length - 1
			
			for (var i:int = 0; i< int(configuration.getOption('main.indQuntaty')); i++){
				indXRnd = Math.round(Math.random() * chessDeskLengthX)
				indYRnd = Math.round(Math.random() * chessDeskLengthY)
				
				individuals[i] = new Individual(this,commStage.chessDesk,configuration,i,indXRnd,indYRnd);
				indSuspender[i] = new Suspender(individuals[i],commStage.chessDesk,configuration)
				commStage.addChild(individuals[i])
				individuals[i].IndividualEvent.addEventListener(ModelEvent.MATURING, addNewIndividuals);
				individuals[i].IndividualEvent.addEventListener(ModelEvent.DEATH, removeIndividuals);
			}
			
			}
		
		private function addNewIndividuals(e:Event):void {

			var startPos:int = this.individuals.length;
			var stopPos:int = startPos + int(configuration.getOption('main.offspringsQuant'));
				
				for(var i:int = startPos;i<stopPos;i++){
					var newX:int = e.target.currentChessDeskI;
					var newY:int = e.target.currentChessDeskJ;
					individuals[i] = new Individual(this,commStage.chessDesk, configuration, i,newX,newY);
					indSuspender[i] = new Suspender(individuals[i],commStage.chessDesk,configuration)
					
					commStage.addChild(individuals[i])
					individuals[i].IndividualEvent.addEventListener(ModelEvent.MATURING, addNewIndividuals);
					individuals[i].IndividualEvent.addEventListener(ModelEvent.DEATH, removeIndividuals);
				}
		}
		
		private function removeIndividuals(e:Event):void {
			var indName = e.target.indName
			
			individuals[indName].IndividualEvent.removeEventListener(ModelEvent.DEATH, removeIndividuals);
			individuals[indName] = null;//Убираем из массива особей
			indSuspender[indName] = null;//И связанные с ними драйверы
			
			indSuspender.splice(indName,1);//Ужимаем массивы
			individuals.splice(indName,1);
			
			for(var i:int = 0; i<individuals.length; i++){
				individuals[i].setName(i);//После ужимания массива делаем так, чтобы имя особи совпадало с ее позицией
				}
			
			msgStreeng = 'Now number of individuals is ' + individuals.length;
			debugeMessage.message(msgStreeng, 2)
			}

    }
}
