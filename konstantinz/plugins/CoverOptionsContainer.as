package konstantinz.plugins{
	import flash.events.Event
	import konstantinz.community.auxilarity.OptionsContainer
	public class CoverOptionsContainer extends OptionsContainer{
		public static var PLUG_LOADED:String = 'plug_loaded';//Так как статические переменные не наследуются создаем свое собственное событие
		public static var LOADING_ERROR:String = 'loading_error';
		public var picture:String;
		public var color:*;
		public var adeley:String;
		
		public function CoverOptionsContainer(config:String = 'cover.cfg'){
			super(config)
			initVars();
			super.addEventListener(OptionsContainer.LOADED, ready);
			
			}
		override public function initVars():void{
			this.color = 0x000000;
			this.adeley = 1
			varItem = new Array('picture','color','adeley','debugLevel')
			}
			
		public function ready(e:Event):void{
			for(var i:int = 0;i<optionsFromFile.length; i++){
				this[optionsFromFile[i]] = valuesFromFile[i]
				}
						
			super.removeEventListener(OptionsContainer.LOADED, ready);//
			dispatchEvent(new Event(CoverOptionsContainer.PLUG_LOADED));
			
			}
		}
	
	}