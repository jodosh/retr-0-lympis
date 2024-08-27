using System;
using System.IO;
using System.Threading;
using System.Diagnostics;
using System.Threading.Tasks;

namespace Retr0lympis
{
    public class EventListener
    {
        private readonly string _eventFilePath;
        private readonly FileSystemWatcher _fileWatcher;
        private bool _processingFile;
        private AudioPlayer _audioPlayer;

        public EventListener(string eventFilePath)
        {
            _eventFilePath = Path.GetFullPath(eventFilePath); // Ensure full path is used

            string directory = Path.GetDirectoryName(_eventFilePath);
            if (string.IsNullOrEmpty(directory) || !Directory.Exists(directory))
            {
                throw new ArgumentException("The directory specified for the event file is invalid or does not exist.", nameof(eventFilePath));
            }

            _fileWatcher = new FileSystemWatcher(directory)
            {
                Filter = Path.GetFileName(_eventFilePath),
                NotifyFilter = NotifyFilters.LastWrite | NotifyFilters.FileName | NotifyFilters.Size
            };

            _fileWatcher.Changed += OnChanged;
            _fileWatcher.Created += OnChanged;

            _audioPlayer = new AudioPlayer();
        }

        public void Start()
        {
            _fileWatcher.EnableRaisingEvents = true;
            Debug.WriteLine($"Event listener started. Monitoring file changes at {_eventFilePath}...");
            Console.WriteLine($"Event listener started. Monitoring file changes at {_eventFilePath}...");
        }

        private async void OnChanged(object sender, FileSystemEventArgs e)
        {
            if (_processingFile)
                return;

            Debug.WriteLine("File change detected.");
            Console.WriteLine("File change detected.");

            _processingFile = true;
            Thread.Sleep(100); // Short delay to ensure file is ready to be read

            try
            {
                if (File.Exists(_eventFilePath))
                {
                    string content = File.ReadAllText(_eventFilePath).Trim();
                    Debug.WriteLine($"File content: {content}");
                    Console.WriteLine($"File content: {content}");

                    if (content == "play_sound")
                    {
                        // Use the relative path to the sound file
                        string soundFilePath = Path.Combine(AppDomain.CurrentDomain.BaseDirectory, "sounds", "BEAN_DIP.WAV");
                        await _audioPlayer.PlaySoundAsync(soundFilePath);
                        ClearFile();
                    }
                }
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Error processing event file: {ex.Message}");
                Console.WriteLine($"Error processing event file: {ex.Message}");
            }
            finally
            {
                _processingFile = false;
            }
        }

        private void ClearFile()
        {
            try
            {
                File.WriteAllText(_eventFilePath, string.Empty); // Clear the file after processing
                Debug.WriteLine("File cleared after playing sound.");
                Console.WriteLine("File cleared after playing sound.");
            }
            catch (Exception ex)
            {
                Debug.WriteLine($"Error clearing event file: {ex.Message}");
                Console.WriteLine($"Error clearing event file: {ex.Message}");
            }
        }
    }
}
