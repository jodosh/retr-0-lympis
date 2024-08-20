using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Security.Cryptography.X509Certificates;
using System.Xml.Linq;

namespace Retr0lympis
{
    public class ConsoleApp
    {
        private List<Game> games = new();
        private List<Challenge> marioChallenges = new();
        //private Dictionary<string, List<string>> challenges;

        public ConsoleApp()
        {
            InitializeGames();
            //InitializeChallenges();
        }

        private void InitializeGames()
        {
            //SuperMario Bros 1
            Game Smb1 = new("Super Mario Bros.", "Super Mario Bros.nes");
            Smb1.AddChallenge("Get the first mushroom", "SMBChallenge1.fcs", "SMB.challenge01.lua");
            games.Add(Smb1);

            //The 3-D Battles of World Runner
            Game WorldRunner = new("The 3-D Battles of World Runner", "3-D Battles of World Runner, The.nes");
            WorldRunner.AddChallenge("Beat Boss 1", "3-D Battles of World Runner.challenge01.fc0", "3-D Battles of World Runner.challenge01.lua");
            games.Add(WorldRunner);


            //Zelda 2 - The Adventure of Link
            Game Zelda2 = new("Zelda 2 - The Adventure of Link", "Zelda 2 - The Adventure of Link.nes");
            Zelda2.AddChallenge("Magic in the Dark", "Z2Challenge1.fcs", "Zelda2.challenge01.lua");
            Zelda2.AddChallenge("Kill Horsehead!", "Z2Challenge2.fcs", "Zelda2.challenge02.lua");
            Zelda2.AddChallenge("Get that Trophy!", "Z2TrophyChallenge.fcs", "Zelda2.challenge03.lua");
            Zelda2.AddChallenge("Get Life 2", "Z2Challenge4.fcs", "Zelda2.challenge04.lua");
            games.Add(Zelda2);

            //TMNT
            Game Tmnt = new("Teenage Mutant Ninja Turtles",  "TMNT.nes");
            Tmnt.AddChallenge("Clear the underwater level", "TMNT.challenge01.fcs", "TMNT.challenge01.lua");
            Tmnt.AddChallenge("Beat Rocksteady with Raph", "TMNT.challenge02.fcs", "TMNT.challenge02.lua");
            games.Add(Tmnt);

            //CV1
            Game Cv1 = new("Castlevania", "Castlevania.nes");
            Cv1.AddChallenge("Kill bat.. knife only", "CV1KillTheBat.fcs", "CV1BatKnifeChallenge.lua");
            Cv1.AddChallenge("Get 10 hearts!", "CV1Get10Hearts.fcs", "CV110HeartChallenge.lua");
            Cv1.AddChallenge("Escape the Castle!", "CV1CastleEscape.fcs", "CVCastleEscapeChallenge.lua");
            Cv1.AddChallenge("Escape the Castle! PART II", "CV1CastleEscapePart2.fcs", "CVCastleEscapePart2Challenge.lua");
            Cv1.AddChallenge("Knight Alley - Find Death!", "CV1KnightAlley.fcs", "CV1KnightAlleyChallenge.lua");
            Cv1.AddChallenge("Cheat Death - Survival Challenge", "CV1CheatDeathChallenge.fcs", "CV1CheatDeathChallenge.lua");
            games.Add(Cv1);

            //Kid Icarus
            Game KidIcarus = new("Kid Icarus", "Kid Icarus.nes");
            KidIcarus.AddChallenge("Finish 1-1", "KidIcarus11challenge.fcs", "KidIcarus11Challenge.lua");            
            games.Add(KidIcarus);

            //Kid Icarus
            Game SuperDodgeBall = new("Super Dodge Ball", "Super Dodge Ball.nes");
            SuperDodgeBall.AddChallenge("Tom must DIE!", "SuperDodgeTomMustDieChallenge.fcs", "SuperDodgeBallTomMustDieChallenge.lua");
            games.Add(SuperDodgeBall);

            games.Sort((x,y) => string.Compare(x.Name,y.Name));
        }


        public void Run()
        {
            ShowMainMenu();
        }

        private void ShowMainMenu()
        {
            while (true)
            {
                Console.Clear();
                Console.WriteLine("==== Retr-0-lympis Launcher ====");
                Console.WriteLine("1. Select Game");
                Console.WriteLine("2. Check ROMS");
                Console.WriteLine("3. Exit");
                Console.Write("Choose an option: ");

                string choice = Console.ReadLine();

                switch (choice)
                {
                    case "1":
                        SelectGame();
                        break;
                    case "2":
                        CheckRoms();
                        break;
                    case "3":
                        Environment.Exit(0);
                        break;
                    default:
                        Console.WriteLine("Invalid choice. Press any key to try again.");
                        Console.ReadKey();
                        break;
                }
            }
        }

        private void SelectGame()
        {
            Console.Clear();
            Console.WriteLine("==== Select a Game ====");

            for (int i = 0; i < games.Count; i++)
            {
                if (File.Exists(games[i].RomPath))
                {
                    Console.ForegroundColor = ConsoleColor.White;                    
                }
                else
                {
                    Console.ForegroundColor = ConsoleColor.Red;
                }
                Console.WriteLine($"{i + 1}. {games[i].Name}");
            }
            Console.ForegroundColor = ConsoleColor.Blue;
            Console.WriteLine("B. Back");
            Console.ForegroundColor = ConsoleColor.White;

            Console.Write("Choose a game: ");
            var userInput = Console.ReadLine();
            if (int.TryParse(userInput, out int gameChoice) && gameChoice > 0 && gameChoice <= games.Count)
            {
                Game selectedGame = games[gameChoice - 1];
                SelectChallenge(selectedGame);
            }
            else if(userInput == "b" || userInput =="B")
            {
                //nothing needs to be done to go back
            }
            else
            {
                Console.WriteLine("Invalid choice. Press any key to return to the main menu.");
                Console.ReadKey();
            }
        }

        private void CheckRoms()
        {
            Console.Clear();
            Console.WriteLine("==== Checking ROMs ====");

            for (int i = 0; i < games.Count; i++)
            {
                if (File.Exists(games[i].RomPath))
                {
                    Console.WriteLine($"OK. {games[i].RomPath}");
                }
                else
                {
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.WriteLine($"MISSING. {games[i].RomPath}");
                    Console.ForegroundColor = ConsoleColor.White;
                }
            }

            Console.Write("Press Any key to return to the main menu");
            Console.ReadKey();
        }

        private void SelectChallenge(Game game)
        {
            Console.Clear();
            Console.WriteLine($"==== {game.Name} Challenges ====");

            List<Challenge> gameChallenges = game.Challenges;

            for (int i = 0; i < gameChallenges.Count; i++)
            {
                Console.WriteLine($"{i + 1}. {gameChallenges[i].Name}");
            }
            Console.ForegroundColor = ConsoleColor.Blue;
            Console.WriteLine("B. Back");
            Console.ForegroundColor = ConsoleColor.White;

            Console.Write("Choose a challenge: ");
            var userInput = Console.ReadLine();
            if (int.TryParse(userInput, out int challengeChoice) && challengeChoice > 0 && challengeChoice <= gameChallenges.Count)
            {
                Challenge selectedChallenge = gameChallenges[challengeChoice - 1];
                LaunchGame(game, selectedChallenge);
            }
            else if (userInput == "b" || userInput == "B")
            {
                SelectGame();
            }
            else
            {
                Console.WriteLine("Invalid choice. Press any key to return to the main menu.");
                Console.ReadKey();
            }
        }

        private void LaunchGame(Game game, Challenge challenge)
        {
            Console.Clear();
            Console.WriteLine($"Launching {game.Name} with challenge: {challenge.Name}");

            // Define paths
            string fceuxPath = System.IO.Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "fceux", "fceux64.exe");
            string romPath = game.RomPath;
            string saveStatePath = challenge.SaveStatePath;
            string luaScriptPath = challenge.LuaScriptPath;

            // Start FCEUX with the ROM, save state, and Lua script
            string arguments = $"-nogui -bginput 1 -loadstate \"{saveStatePath}\" -lua \"{luaScriptPath}\" \"{romPath}\"";

            ProcessStartInfo startInfo = new()
            {
                FileName = fceuxPath,
                Arguments = arguments,
                UseShellExecute = false,
                CreateNoWindow = false
            };

            try
            {
                using (Process process = Process.Start(startInfo))
                {
                    process.WaitForExit(); // Wait for FCEUX to exit
                }

                // Read the result from the corresponding stats file
                string resultPath = luaScriptPath.Replace(".lua", ".txt");
                if (System.IO.File.Exists(resultPath))
                {
                    string result = System.IO.File.ReadAllText(resultPath);
                    Console.WriteLine("Challenge Result:");
                    Console.WriteLine(result);
                }
                else
                {
                    Console.WriteLine("Failed to retrieve challenge result.");
                    Console.WriteLine(resultPath.ToString());
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Failed to start FCEUX: {ex.Message}");
            }

            Console.WriteLine("Press any key to return to the main menu.");
            Console.ReadKey();
        }



    }
}
