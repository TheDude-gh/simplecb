Simpleton's City Builder
Novapolis team, https://www.novapolis.net


===Basic setting===

=Print more logs to Script console
 - prints more information to AI/GS console

=Pause game on start. Unpause when first company starts
 - pauses game after start, unpauses game after first company is created (Multiplayer only)

=Generate Power Plant, Water Tower industries for each town (climate dependant)
 - generates some industries for City Builder games in towns (Power plants, Water towers) and cities (Banks)

=City Builder Goal (population)
 - the goal of the game. Nothing happens when goal is reached
 - set 0 to disable

=Game Length in Years.
 - displays remaining years until game "ends"
 - Set 0 to disable

=Town name - change town name according to its company owner and population
 - Claimed towns will change name according to president's name and town population (e.g. Mr Smith's Metropolis)

=Goal progress messages. Informs players about game end and goal progress of all companies.
 - Shows game progress and other info in Storybook

=Town area - place signs around town,
 - places sign under town sign to display town owner and signs around towns to mark claimed area
 - set 0 to disable

=Dynamic change of town growth rate. Every 5 years is increased by 1 up to maximum 4
 - Says all

=Limit cities population to percentage of the biggest claimed town on map. Set to 0 to disable.
	Will limit all cities to percentage of any claimed town. Range 0 to 1000%.

=Town Growth mechanism
 - You can choose from 2 mechanisms:
	- Normal - the same as original OpenTTD growth, it only requires the cargo and OpenTTD places new houses (and transport service)
	- Expand - Similar to Normal, but uses own mechanism, GS places houses instead of OpenTTD. Requires transport service and cargo to grow town

=Town will shrink slightly when not supplied
	Town will shrink when not properly supplied.

=Max claimable town population
 - maximum town population of claimable towns

=Town storage (x times requirements)
 - enable town storage. Storage is equal to x times the requirements at current town population
 - set 0 to disable

=City Builder Economy Preset
 - Select cargo requirement based on chosen economy and NewGRF cargosets.
 - You can select recommended vanilla presets or preset based on NewGRF industry and cargo set you want to play with
 - If you want your own cargo requirements, choose CUSTOM and set desired settings. In description it is hinted what number each cargo is, but since GS cannot read NewGRF settings, it is not reliable and if NewGRF authors change cargo ID in their GRF, description here will not fit

===CARGO SETTINGS===

=Cargo names
 - only to group following settings. Has no effect on game if you enable/disable it

=Requirements
 - Cargo requirements per 1000 town population. When set to 0, the cargo will not be required

=From
 - town will require this cargo once population reaches this amount

=Store
 - part of the delivered cargo that will be stored each month in percents. When storage is set to 0, nothing will be stored



