using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Text.Json;

namespace Retr0lympis
{
    public class ConsoleApp
    {
        private List<Game>? games = [];
        private EventListener? eventListener;

        public ConsoleApp()
        {
            InitializeGames();
            InitializeEventListener();
        }

        private void InitializeGames()
        {
            var options = new JsonSerializerOptions
            {
                IncludeFields = true,
                PropertyNameCaseInsensitive = true
            };
            var configFile = Path.Combine("config", "challenges.json");
            string jsonString = File.ReadAllText(configFile);

            games = JsonSerializer.Deserialize<List<Game>>(jsonString, options);
        }

        private void InitializeEventListener()
        {
            string eventFilePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "config", "luascripts", "event.txt");
            eventListener = new EventListener(eventFilePath);
            eventListener.Start();
        }

        public void Run()
        {
            ShowMainMenu();
        }

        private void SafeClear()
        {
            try
            {
                if (!Console.IsOutputRedirected)
                    Console.Clear();
            }
            catch (IOException)
            {
                // Ignore safely
            }
        }

        private int InteractiveMenu(List<string> items, string title)
        {
            int selectedIndex = 0;
            ConsoleKey key;

            do
            {
                SafeClear();
                Console.WriteLine($"==== {title} ====");
                for (int i = 0; i < items.Count; i++)
                {
                    if (i == selectedIndex)
                    {
                        Console.BackgroundColor = ConsoleColor.Gray;
                        Console.ForegroundColor = ConsoleColor.Black;
                    }
                    else
                    {
                        Console.ResetColor();
                    }

                    Console.WriteLine(items[i]);
                }

                Console.ResetColor();
                Console.WriteLine();
                Console.WriteLine("Use ↑ ↓ to navigate, Enter to select.");

                key = Console.ReadKey(true).Key;

                if (key == ConsoleKey.UpArrow)
                {
                    selectedIndex = (selectedIndex - 1 + items.Count) % items.Count;
                }
                else if (key == ConsoleKey.DownArrow)
                {
                    selectedIndex = (selectedIndex + 1) % items.Count;
                }

            } while (key != ConsoleKey.Enter);

            return selectedIndex;
        }

        private void ShowMainMenu()
        {
            var options = new List<string>
            {
                "1. Select Game",
                "2. Check ROMS",
                "3. Exit"
            };

            while (true)
            {
                int selected = InteractiveMenu(options, "Retr-0-lympis Launcher");

                switch (selected)
                {
                    case 0:
                        SelectGame();
                        break;
                    case 1:
                        CheckRoms();
                        break;
                    case 2:
                        Environment.Exit(0);
                        break;
                }
            }
        }

        private void SelectGame()
        {
            if (games == null || games.Count == 0)
            {
                Console.WriteLine("No games found.");
                Console.ReadKey();
                return;
            }

            var gameDisplayList = games.Select((game, i) =>
            {
                bool exists = File.Exists(game.RomPath);
                string status = exists ? "" : " [MISSING ROM]";
                return $"{i + 1}. {game.Name}{status}";
            }).ToList();

            gameDisplayList.Add("Back");

            int selectedIndex = InteractiveMenu(gameDisplayList, "Select a Game");

            if (selectedIndex == gameDisplayList.Count - 1)
                return;

            SelectChallenge(games[selectedIndex]);
        }

        private void SelectChallenge(Game game)
        {
            if (game.Challenges == null || game.Challenges.Count == 0)
            {
                Console.WriteLine("No challenges available for this game.");
                Console.ReadKey();
                return;
            }

            var challengeDisplayList = game.Challenges.Select((c, i) => $"{i + 1}. {c.Name}").ToList();
            challengeDisplayList.Add("Back");

            int selectedIndex = InteractiveMenu(challengeDisplayList, $"{game.Name} Challenges");

            if (selectedIndex == challengeDisplayList.Count - 1)
                return;

            LaunchGame(game, game.Challenges[selectedIndex]);
        }

        private void CheckRoms()
        {
            SafeClear();
            Console.WriteLine("==== Checking ROMs ====");

            if (games != null)
            {
                foreach (var game in games)
                {
                    if (File.Exists(game.RomPath))
                    {
                        Console.WriteLine($"OK. {game.RomPath}");
                    }
                    else
                    {
                        Console.ForegroundColor = ConsoleColor.Red;
                        Console.WriteLine($"MISSING. {game.RomPath}");
                        Console.ResetColor();
                    }
                }

                Console.Write("Press any key to return to the main menu");
                Console.ReadKey();
            }
        }

        private void LaunchGame(Game game, Challenge challenge)
        {
            SafeClear();
            Console.WriteLine($"Launching {game.Name} with challenge: {challenge.Name}");

            string fceuxPath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "fceux", "fceux64.exe");
            string romPath = game.RomPath;
            string saveStatePath = challenge.SaveState1Path;
            string luaScriptPath = challenge.LuaScriptPath;

#if WINDOWS
            string arguments = $"-nogui -bginput 1 -loadstate \"{saveStatePath}\" -lua \"{luaScriptPath}\" \"{romPath}\"";
            ProcessStartInfo startInfo = new()
            {
                FileName = fceuxPath,
                Arguments = arguments,
                UseShellExecute = false,
                CreateNoWindow = false
            };
#else
            string arguments = $"-nogui -bginput 1 --loadlua \"{luaScriptPath}\" \"{romPath}\"";
            ProcessStartInfo startInfo = new()
            {
                FileName = "fceux",
                Arguments = arguments,
                UseShellExecute = false,
                CreateNoWindow = false
            };
#endif

            try
            {
                using (Process? process = Process.Start(startInfo))
                {
                    if (process != null)
                    {
                        process.WaitForExit();
                    }
                }

                string resultPath = luaScriptPath.Replace(".lua", ".txt");
                if (File.Exists(resultPath))
                {
                    string result = File.ReadAllText(resultPath);
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
