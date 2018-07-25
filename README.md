![Drops arena banner](http://konstantinz.byethost32.com/drops_arena_logo.png)

# Drops' Arena population model

## English

**The purpose of the model** is to recreate the development of the population in time based on such field observations as:
1. Duration of the presence of individuals in areas with certain environmental conditions;
2. The speed and character of the movement of individuals;
3. Life expectancy of an individual and the number of offspring produced by it.

In order to make the model more flexible, most of its functionality is implemented in the form of plug-ins.

The compiled in swf files version of model yoy can foun [here](http://konstantinz.byethost32.com/drops_arena.zip "here").

The main model screen

![Model screenshot 1](https://raw.githubusercontent.com/KonstantinZem/DropsArena/variable_behaviour/pictures/screenshot1.png)

Results screen

![Model screenshot 1](https://raw.githubusercontent.com/KonstantinZem/DropsArena/variable_behaviour/pictures/screenshot2.png)

### The plug-ins

At the moment, the following types of plug-ins are developed for this model:

1. **cover** This plugin simulates the existence in the ecosystem of ground cover with certain environmental conditions. For the plug-in to work, a pictore in jpf or png format is necessary, in which the areas on which the ground cover should be painted black;
2. **activitySwitcher** A plugin that changes the number of active individuals on the screen or the mortality of individuals at specific intervals. The proportion of active individuals in each of the observations is prescribed in the configuration file.
3. **morisita** plug-in, which calculates at some time intervals the spatial distribution coefficient of Morisita.

Example of picture loading by cover plug-in

![Cover plug-in picture](http://konstantinz.byethost32.com/pictures/park/aegopodium.png)

## Russian

**Цель модели** - воссоздать развитие популяции во времени на основе таких данных полевых наблюдений, как: 
1. Длительность нахождения особей в участках с определенными условиями окружающей среды;
2. Скорости и характера передвижения особей;
3. Продолжительности жизни особи и количество производимых ею потомков.

Для того, чтобы сделать модель более гибкой, большая часть ее функционала реализована в виде подгружаемых плагинов.

Откомпилированную в swf формат модель вы можете скачать  [здесь](http://konstantinz.byethost32.com/drops_arena.zip "here").

### Система плагинов

На сегодняшний момент для модели разработаны следующие типы плагинов:

1. **cover** плагин имитирует существование в экосистеме напочвенного покрова с определенными условиями среды. Для работы плагина необходим рисунок, на котором участки, на которых должен быть напочвенный покров закрашены черным цветом 
2. **activitySwitcher** плагин, который изменяет количество активных особей на экране либо смертность особей через определенные промежутки времени. Доля активных особей в каждом из наблюдений прописывается в конфигурационном файле.
3. **morisita** плагин, который расчитывает через определенные промежутки времени коэффициент пространственного распределения Мориситы.
