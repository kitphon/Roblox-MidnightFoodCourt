# Menu consolidation — 24 October 2026

Changed MidnightManagement and MidnightStyleShop.
Kitchen: Overview, Supplies, Staff, Upgrades, Co-op, Quests. Shop/Gems shortcuts remain prominent. More options contains Journey and Travel.
Overview > My shop opens Save/Load section inside Overview with Back to overview. Separate Saves navigation removed. Legacy Saves entry events route here.
Journey includes personal and top weekly/all-time rankings. Separate Ranks navigation removed; legacy rank entry routes Journey.
Co-op kitchen cards have separate Join and Visit actions. City navigation removed; legacy City entry routes Travel. Emote is a character-action button in Kitchen header.
Shop: Packs, Gems, Themes, Outfits, Effects, Decor. Classic/Festivals/Staff/Crew/Visit/More styles tabs removed. Seasonal themes merged with Themes; NPC and player outfits merged with Outfits and labeled by target. Old cosmetics merged into matching categories with original purchase/equip commands.
Photo mode shortcut hidden from Shop; existing world photo spots and photo preview controls retained.
Status badges and distinct Equip/Unequip colors preserved; Get Gems route retained, including older premium items.

Validation: 38 checks passed: save section/nav aliases, ranks in Journey, 4 Co-op visit controls, all22 StyleCatalog items plus11 legacy items retained. Desktop Outfits screenshot and mobile portrait My shop screenshot reviewed. No runtime errors observed (existing ConfigService missing-key messages remain).
These are render/catalog/command wiring checks, not a full manual click-through of every menu.
Studio sandbox purchase simulation remains enabled; no real purchases/profile writes.
Stopped Play and restored default viewport. Publish from Studio to deploy.

