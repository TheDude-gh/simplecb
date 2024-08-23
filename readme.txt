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



=City Builder Preset cargo settings.
Amount is amount needed per 1000 town population

 Preset                Cargo name          From Pop    Amount  Stored %
---------------------------------------------------------------------
 Vannila TEMP          Coal                     250     100     0
                       Pax                      500     200     0
                       Mail                    1000      40     0
                       Goods                   1500     200   100
                       Valuables               2500      10   100
---------------------------------------------------------------------
 Vannila ARCTIC        Food                     150     100   100
                       Coal                     250     100     0
                       Pax                      500     150     0
                       Mail                    1000      30     0
                       Goods                   1500     125   100
                       Gold                    2500      40   100
---------------------------------------------------------------------
 Vannila TROPIC        Water                      0     100     0
                       Food                       0     100   100
                       Pax                      500     150     0
                       Mail                    1000      30     0
                       Goods                   1500     125   100
                       Diamonds                2500      50   100
---------------------------------------------------------------------
 Vannila TOYLAND       Pax                      250     160     0
                       Mail                     750      15     0
                       Sweets                  1500     200   100
                       Fizzy Drinks            2500     200   100
                       Toys                    5000     100   100
---------------------------------------------------------------------
 ECS                   Pax                      125      50     0
                       Mail                     500      20     0
                       Food                     750      30   100
                       Tourists                2000       4     0
                       Goods                   3000      70   100
                       Gasoline                4000      15   100
                       Wood Products           5000      13   100
                       Building Materials      6000      13   100
                       Glass                   7500      20   100
                       Steel                   8000       5   100
                       Coal                    9000      15   100
                       Vehicles               10000       4   100
                       Gold                   11000       8   100
---------------------------------------------------------------------
 XIS                   Pax                      250     100     0
                       Mail                     500      20     0
                       Goods                   2500     150   100
                       Alcohol                 5000      25   100
                       Petroleum Fuels         7000      30   100
                       Recyclables            15000      50   100
                       Vehicles               25000      10   100
---------------------------------------------------------------------
 YETI                  Pax                      250     200     0
                       Mail                     500      25     0
                       Building Materials      1000      40   100
                       Food                    2500      40   100
                       Yeti Dudes              5000      25     0
                       Machinery               8000      30   100
---------------------------------------------------------------------
 FIRS 3 TEMP           Pax                      250     200     0
                       Mail                     500      20     0
                       Food                    1000      50   100
                       Goods                   2500     150   100
                       Alcohol                 5000      40   100
---------------------------------------------------------------------
 FIRS 3 ARCTIC         Pax                      250     200     0
                       Mail                     500      20     0
                       Food                    1000      50   100
                       Goods                   2500     150   100
                       Alcohol                 5000      40   100
---------------------------------------------------------------------
 FIRS 3 TROPIC         Pax                      250     200     0
                       Mail                     500      20     0
                       Food                    1000      50   100
                       Goods                   2500     150   100
                       Alcohol                 5000      40   100
                       Coffee                 10000      30   100
---------------------------------------------------------------------
 FIRS 3 HOT COUNTRY    Pax                      250     200     0
                       Mail                     500      20     0
                       Food                    1000      50   100
                       Goods                   2500     150   100
                       Alcohol                 5000      40   100
                       Coffee                 10000      30   100
---------------------------------------------------------------------
 FIRS 3 STEEL TOWN     Pax                      250     150     0
                       Mail                     500      20     0
                       Food                    1000      40   100
                       Coal                    2500     200     0
                       Petroleum Fuels         5000      50   100
                       Vehicles                7500      50   100
---------------------------------------------------------------------
 FIRS 3 EXTREME        Pax                      250     200     0
                       Mail                     500      20     0
                       Food                    1000      50   100
                       Goods                   2500     150   100
                       Alcohol                 5000      40   100
                       Petroleum Fuels         7500      30   100
                       Recyclables            10000      40   100
---------------------------------------------------------------------
 FIRS 4 TEMP           Pax                      250     200     0
                       Mail                     500      20     0
                       Food                    1000      50   100
                       Goods                   2500     150   100
                       Alcohol                 5000      40   100
---------------------------------------------------------------------
 FIRS 4 ARCTIC         Pax                      250     200     0
                       Mail                     500      20     0
                       Food                    1000      50   100
                       Peat                    2500      80   100
---------------------------------------------------------------------
 FIRS 4 TROPIC         Pax                      250     200     0
                       Mail                     500      20     0
                       Food                    1000      50   100
                       Goods                   2500     150   100
                       Alcohol                 5000      40   100
                       Coffee                 10000      30   100
---------------------------------------------------------------------
 FIRS 4 HOT COUNTRY    Pax                      250     200     0
                       Mail                     500      20     0
                       Food                    1000      50   100
                       Goods                   2500     150   100
                       Alcohol                 5000      40   100
                       Petroleum Fuels         7500      25   100
                       Coffee                 10000      30   100
---------------------------------------------------------------------
 FIRS 4 STEEL TOWN     Pax                      250     150     0
                       Mail                     500      20     0
                       Food                    1000      40   100
                       Coal                    2500     200     0
                       Vehicles                7500      50   100
---------------------------------------------------------------------
