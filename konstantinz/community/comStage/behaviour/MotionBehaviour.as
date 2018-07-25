package konstantinz.community.comStage.behaviour{
	public interface MotionBehaviour{
		function setPopulationArea(commStage:Array):void// передает классу ссылку на массив координат внутри класса CommunityStage А еще лучше передавать это через конструктор
		function getNewPosition(currentX:int, currentY:int):Array//Класс на основе выбранного алгоритма поведения определяет новую позицию особи
		function getNewState():String//На основе выбранного алгоритма поведения определяется новое состояние особи
		function getPlaceQuality(currentX:int, currentY:int):int;
	}
}
