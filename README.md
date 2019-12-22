![Drops arena banner](https://raw.githubusercontent.com/KonstantinZem/DropsArena/master/pictures/screenshots/drops_arena_logo.png)

# Drops' Arena population model

## English

Drops arena -- is simple model that imitate life of animals' population. All data, that neccesery to model work, you have to write in configuration file. Then you can run this model in your website. The example of *Arianta arbustorum* land snail population model you can see in [my website](http://konstantinz.byethost32.com/drops_arena.zip "Drops arena on my website").

**The purpose of the model** is to recreate changes of the population in time based on such field observation data as:

1. Duration of the presence of individuals in areas with certain environmental conditions;
2. The speed and character of the movement of individuals;
3. Life expectancy of an individual and the number of offspring produced by it.

In order to make the model more flexible, most of its functionality is implemented in the form of plug-ins.

The compiled in swf files version of model yoy can foun [my website](http://konstantinz.byethost32.com/community_model.htm). Bellow you can see screenshotes of this model.

**The main model screen**

![Screenshot of the main model's window](https://raw.githubusercontent.com/KonstantinZem/DropsArena/master/pictures/screenshots/screenshot1.png)

**Results screen**

![Screenshot ow the window with resulting data](https://raw.githubusercontent.com/KonstantinZem/DropsArena/master/pictures/screenshots/screenshot2.png)

### The plug-ins

At the moment, the following types of plug-ins are developed for this model:

1. **cover** This plugin simulates the existence in the ecosystem of ground cover with certain environmental conditions. For the plug-in to work, a pictore in jpg or png format is necessary, in which the areas on which the ground cover should be painted black;
2. **activitySwitcher** A plugin that changes the number of active individuals on the screen or the mortality of individuals at specific intervals. The proportion of active individuals in each of the observations is prescribed in the configuration file.
3. **morisita** plug-in, which calculates at some time intervals the spatial distribution coefficient of Morisita.

Example of picture loading by cover plug-in

![Cover plug-in picture](https://raw.githubusercontent.com/KonstantinZem/DropsArena/master/pictures/park/5_aegopodium.png)

## Russian

Drops arena -- это простая модель, имитирующая популяцию животных. Все данные, необходимые для ее работы вводятся через конфигурационный файл. Вы можете встроить эту модель на вебстраницу. Пример модели популяции моллюска Arianta arbustorum можно увидеть на  [моем сайте](http://konstantinz.byethost32.com/community_model.htm)

**Цель модели** - воссоздать развитие популяции во времени на основе таких данных полевых наблюдений, как: 

1. Длительность нахождения особей на участках с определенными условиями окружающей среды;
2. Скорости и характера передвижения особей;
3. Продолжительности жизни особи и количество производимых ею потомков.

Для того, чтобы сделать модель более гибкой, большая часть ее функционала реализована в виде подгружаемых плагинов.

Откомпилированную в swf формат модель вы можете скачать с [моего сайта](http://konstantinz.byethost32.com/drops_arena.zip "here").

### Система плагинов

На сегодняшний момент для модели разработаны следующие типы плагинов:

1. **cover** Этот плагин имитирует существование в экосистеме напочвенного покрова который создает различный микроклимат. Для работы плагина необходим рисунок, на котором участки с напочвенным покровом закрашены черным цветом. Несколько вариантов напочвенного покрова могут быть загруженны одновременно или загружаться через определенное количество ходов модели.
2. **activitySwitcher** Этот плагин изменяет количество активных особей на экране либо имитирует смертность особей через определенные промежутки времени. Доля активных особей, наблюдаемая  в каждом из дней наблюдений прописывается в конфигурационном файле.
3. **morisita** Это плагин, который расчитывает через определенные промежутки времени коэффициент пространственного распределения Мориситы. Площадь, на которой необходимо расчитать показатель Мориситы устанавливается в конфигурационном файле. 
