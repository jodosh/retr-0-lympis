using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices.JavaScript;
using System.Security.Cryptography.X509Certificates;
using System.Text.Json;
using System.Xml.Linq;
using static System.Runtime.InteropServices.JavaScript.JSType;

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
        }

        private void InitializeGames()
        {
            // Read the JSON from the file
            var options = new JsonSerializerOptions
            {
                IncludeFields = true, // Include fields in deserialization
                PropertyNameCaseInsensitive = true // Make matching case-insensitive if needed
            };
            var configFile = System.IO.Path.Combine("config", "challenges.json");
            string jsonString = File.ReadAllText(configFile);
            
            // Deserialize the JSON string to a list of objects
            games = JsonSerializer.Deserialize<List<Game>>(jsonString, options);

            Console.WriteLine("List of objects has been exported to challenges.json");

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

                string? choice = Console.ReadLine();

                if (choice != null)
                {
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
