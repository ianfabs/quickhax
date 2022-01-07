# Quickhax

This mod - based off of the CET example "ModOverride" - allows you to access quick hacks for crafting and money and dev points

Eventually this will allow you to add your own custom shortcuts with custom inputs.

Currently supported:
  - `Game.GiveDevPoints("Attribute", n)` ~ Give attribute points (These are for upgrading the "**main**" categories like **Technical Ability**, **Body**, **Reflexes**, etc.)
  - `Game.GiveDevPoints("Primary", n)` ~ Give perk points
  - `Game.AddToInventory("Items.money",n)` ~ Give money (hopefully that is obvious)
  - following the pattern `{Rarity}Material{i}`, the following commands give you *n* quantity of items of `{Rarity}` rarity where if *i* is 2 the items are **Upgrade** components or *1* if they are regular components of that `{Rarity}`. 
  - `Game.AddToInventory("Items.LegendaryMaterial1",n)`
  - `Game.AddToInventory("Items.LegendaryMaterial2",n)`
  - `Game.AddToInventory("Items.EpicMaterial1",n)`
  - `Game.AddToInventory("Items.EpicMaterial2",n)`
  - `Game.AddToInventory("Items.RareMaterial1",n)`
  - `Game.AddToInventory("Items.RareMaterial2",n)`
  - `Game.AddToInventory("Items.UncommonMaterial1",n)`
  - `Game.AddToInventory("Items.CommonMaterial1",n)`