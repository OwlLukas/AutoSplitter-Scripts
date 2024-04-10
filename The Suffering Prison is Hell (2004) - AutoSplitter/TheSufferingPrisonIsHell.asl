/*
The Suffering: Prison is Hell (2004) [PC] AutoSplitter by OwlLukas.
This AutoSplitter is currently only available for the Good old Games (GoG) version of the game that uses the All-In-One 1.0.4 patch by UCyborg.
*/

state("Suffering")
{
	// Missions
	byte missionNumber			:		"Suffering.rfl", 0x178660;					// Displays the current mission number. Value changes when the fade to black animation occurs before the loading screen is displayed.
	string25 sectionName		:		"Suffering.exe", 0x1C6B1C;					// Displays the current section of the game. The file name is tied to the current level. Value is displayed once a loading screen starts.
	string50 loadedLevel		:		"Suffering.exe", 0x067444, 0x6C;			// Displays the currently loaded file.

	// Menu and pause
	byte isMainMenu				:		"Suffering.rfl", 0x178520;					// Displays a 0 or 1 depending if the player is currently in the main menu.
	byte isPausedOrMainMenu		:		"Suffering.exe", 0x1C9C52;					// Displays a 0 or 1 depending if the player is in the pause menu mid-game, or in the main menu section.

	// Cutscenes and Flashbacks
	byte isCutsceneActive		:		"Suffering.rfl", 0x17BF30, 0x34;			// Displays a 0 or 1 depending if a cutscene is currently playing. This only applies to ingame rendered sequences and not flashbacks.
	byte isFlashbackActive		:		"wmvdecod.dll",  0x21774C;					// Displays a 0 or 1 depending if a flashback is currently playing. This only applies to flashbacks and not cutscenes. Also  displays 1 in main menu.

	// Tracking
	float progressCoordinate	:		"Suffering.exe", 0x1CA988;					// Displays the current players coordinates in the game geometry. Can be used to track if the player is currently in a certain area of the game.

	// Loading
	byte loading				:		"Suffering.rfl", 0x17BBFE;					// Displays a value above 0 when the loading screen is active. Can have multiple values that seem chapter unique. 0 when not loading.
}

startup
{

    // Set the refresh rate to 60
    refreshRate = 60;

	// Helps us to determine once a level has finished. This will help to start the IL Timer only when a new chapter was entered, and will prevent splitting when visiting old chapters.
	vars.levelFinished = new bool();

	// Define the list of of splits that already occured.
    vars.doneRooms = new List<string>();

	/*	Item1 = Chapter number
		Item2 = Chapter name
		Item3 = Section name
		Item4 = Chapter levelname that you leave
		Item5 = Chapter levelname that you enter next
	*/
	vars.chapters = new Tuple<string, string, string, string, string>[]
	{
		Tuple.Create("0", "Waiting to Die", "Prelude Docks", "0 Prelude Docks.lvl", "1a PrisonDeathRow.lvl"),
		Tuple.Create("1", "The Worst Place on Earth", "Death House", "1a PrisonDeathRow.lvl", "1b PrisonDeathRow.lvl"),
		Tuple.Create("2", "Descending", "Death House Basement", "1b PrisonDeathRow.lvl","1c PrisonDeathRow.lvl"),
		Tuple.Create("3", "Slumber of the Dead", "Death House North", "1c PrisonDeathRow.lvl", "2 Cellblocks.lvl"),
		Tuple.Create("4", "Abbott Prison Blues", "Cellblocks", "2 Cellblocks.lvl", "3a YardCellBlock.lvl"),
		Tuple.Create("5", "No More Prisons", "CellBlocks Yard", "3a YardCellBlock.lvl", "3b YardCellBlock.lvl"),
		Tuple.Create("6", "I Can Sleep When I'm Dead", "CellBlocks Interior", "3b YardCellBlock.lvl", "3a YardCellBlock.lvl"),
		Tuple.Create("7", "Everything Beautiful is Gone", "Cellblocks Yard", "3a YardCellBlock.lvl", "4a Quarry.lvl"),
		Tuple.Create("8", "Darkest Night, Eternal Blight", "Quarry East", "4a Quarry.lvl", "4b Quarry.lvl"),
		Tuple.Create("9", "Oblivion Regained", "Quarry West", "4b Quarry.lvl", "5a Asylum.lvl"),
		Tuple.Create("10", "You've Mistaken Me For Someone Else", "Asylum Backyard", "5a Asylum.lvl", "5b Asylum.lvl"),
		Tuple.Create("11", "Hate the Sin, Not the Sinner", "Asylum Interior", "5b Asylum.lvl", "6a Woods.lvl"),
		Tuple.Create("12", "A Lonely Place to Die", "The Woods", "6a Woods.lvl", "6b Woods.lvl"),
		Tuple.Create("13", "Dancing at the Dawn of the Apocalypse", "The Beach", "6b Woods.lvl", "1b PrisonDeathRow.lvl"),
		Tuple.Create("14", "Surfacing", "Death House Basement", "1b PrisonDeathRow.lvl", "1a PrisonDeathRow.lvl"),
		Tuple.Create("15", "An Eye for an Eye Makes the Whole World Blind", "Death House", "1a PrisonDeathRow.lvl", "3a YardCellBlock.lvl"),
		Tuple.Create("16", "Who Wants to Deny Forever?", "CellBlocks Yard", "3a YardCellBlock.lvl", "8a Bluff.lvl"),
		Tuple.Create("17", "Death Be Not Proud","Bluff", "8a Bluff.lvl", "8b Bluff.lvl"),
		Tuple.Create("18", "Single Bullet Theory", "Caves to Lighthouse", "8b Bluff.lvl", "9 Lighthouse.lvl"),
		Tuple.Create("19", "And a Child Shall Lead Them", "Lighthouse", "9 Lighthouse.lvl", "10 Docks.lvl"),
		Tuple.Create("20", "Last Breath Before Dying", "Docks", "10 Docks.lvl", "")

	};

		// Define the main settings groups.
		settings.Add("DefaultSpliter", true, "Split at the beginning of chapter:");
		settings.Add("IL_Start", false, "Individual Level Runs (IL)");

		// Define the main setting group tooltips.
		settings.SetToolTip("DefaultSpliter", "Split when a chapter was finished.");
		settings.SetToolTip("IL_Start", "Start the timer when a new level starts and split at the end. The timer will only start if the target IL was not visited already. You do not have to check the split group for a split to occur.");

		// Add the settings to a group.
		settings.Add("1", true, "1. The Worst Place on Earth", "DefaultSpliter");
		settings.Add("2", true, "2. Descending", "DefaultSpliter");
		settings.Add("3", true, "3. Slumber of the Dead", "DefaultSpliter");
		settings.Add("4", true, "4. Abbott Prison Blues", "DefaultSpliter");
		settings.Add("5", true, "5. No More Prisons", "DefaultSpliter");
		settings.Add("6", true, "6. I Can Sleep When I'm Dead", "DefaultSpliter");
		settings.Add("7", true, "7. Everything Beautiful is Gone", "DefaultSpliter");
		settings.Add("8", true, "8. Darkest Night, Eternal Blight", "DefaultSpliter");
		settings.Add("9", true, "9. Oblivion Regained", "DefaultSpliter");
		settings.Add("10", true, "10. You've Mistaken Me For Someone Else", "DefaultSpliter");
		settings.Add("11", true, "11. Hate the Sin, Not the Sinner", "DefaultSpliter");
		settings.Add("12", true, "12. A Lonely Place to Die", "DefaultSpliter");
		settings.Add("13", true, "13. Dancing at the Dawn of the Apocalypse", "DefaultSpliter");
		settings.Add("14", true, "14. Surfacing", "DefaultSpliter");
		settings.Add("15", true, "15. An Eye for an Eye Makes the Whole World Blind", "DefaultSpliter");
		settings.Add("16", true, "16. Who Wants to Deny Forever?", "DefaultSpliter");
		settings.Add("17", true, "17. Death Be Not Proud", "DefaultSpliter");
		settings.Add("18", true, "18. Single Bullet Theory", "DefaultSpliter");
		settings.Add("19", true, "19. And a Child Shall Lead Them", "DefaultSpliter");
		settings.Add("20", true, "20. Last Breath Before Dying", "DefaultSpliter");

}

init
{
	// Determine the game version based on the exe memory size.
	if (modules.First().ModuleMemorySize == 0x2F9000)
	{
		version = "AiO 1.0.1.0";	// All-in-One fix by UCyborg that is build on top of the 1.1 patch. (AiO 1.0.4) (Exe version 1.1.0.1)
	}
}

update
{
	// Set levelFinished to true only if a level was actually finished.
	if (current.missionNumber > old.missionNumber && current.isPausedOrMainMenu == 0)
	{
		vars.levelFinished = true;
	}
}

start
{
	// Define the default starting criteria according to the game rules. This is independent of the IL setting, as this will not trigger. Includes coordinates for First- and Third person view.
	if (current.missionNumber == 1 && old.isCutsceneActive == 1 && current.isCutsceneActive == 0 && current.progressCoordinate == 817717.25)
	{
		return true;
	}

	// Dont allow splitting from the pause or main menu.
	if (current.isPausedOrMainMenu == 1)
	{
		return false;
	}

	// Define the logic to start the timer for Individual Level Runs (IL's)
	if ((settings["IL_Start"] && old.loadedLevel != current.loadedLevel && vars.levelFinished == true) || (settings["IL_Start"] && current.loadedLevel.Contains("0 Prelude Docks.lvl") && old.loadedLevel == ""))
	{
		vars.levelFinished = false;
		return true;
	}

}


onSplit
{
	// Add the next chapter number to the list. (For example, going from chapter 2 to 3 will save chapter 3 here.)
	vars.doneRooms.Add(current.missionNumber.ToString());
}

split
{

	// Dont allow splitting when a level is loaded through the pause- or main menu.
	if (current.isPausedOrMainMenu == 1)
	{
		return false;
	}

	// Final level is unique with the progress coordinate set on the final area. Only one flashback can occur here that is not skippable.
	if (current.missionNumber == 20  && old.isFlashbackActive == 0 && current.isFlashbackActive == 1 && current.progressCoordinate > 900000)
	{
		vars.levelFinished = false;
		return true;
	}

	// Define the logic when a split occurs.
	if (settings[current.missionNumber.ToString()] && current.loadedLevel != old.loadedLevel & vars.levelFinished == true && (!vars.doneRooms.Contains(current.missionNumber.ToString())))
	{
		vars.levelFinished = false;
		return true;
	}

	// Always split at the end of a level when IL timer is activated.
	if (settings["IL_Start"] && current.loadedLevel != old.loadedLevel && vars.levelFinished == true)
	{
		vars.levelFinished = false;
		return true;
	}
}


onReset
{
	// Reset the list to prevent double splits.
    vars.doneRooms.Clear();
	vars.levelFinished = false;
}

reset
{
	// In a run the player never goes to the main menu. If the player dies, either a checkpoint reloads by default, or the player chooses to load a savegame in the pause menu.
	return current.isMainMenu != 0;
}

isLoading
{
	// Default logic. Pause the game timer when a loading screen is currently displayed (This is for the progress bar, after it finishes, the level fade-in happens).
	return current.loading != 0;
}