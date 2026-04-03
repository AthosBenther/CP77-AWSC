using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;

class Program
{
    static string logFile = "./deployment/deployment.log";

    static void Main()
    {
        // Initialize log file
        try
        {
            Directory.CreateDirectory("./deployment");
            File.WriteAllText(
                logFile,
                $"=== DEPLOYMENT LOG - {DateTime.Now:yyyy-MM-dd HH:mm:ss} ===\n\n"
            );
        }
        catch { }

        Log("=== DEPLOYMENT SCRIPT STARTED ===");
        Log($"Initial directory: {Environment.CurrentDirectory}");

        Environment.CurrentDirectory = Environment.CurrentDirectory.Replace("\\deployment", "");
        Log($"Working directory: {Environment.CurrentDirectory}");

        loadEnv();
        Log("Environment variables loaded from .env file");

        string deployName = Environment.GetEnvironmentVariable("DEPLOY_NAME") ?? "DefaultModName";
        Log($"Deployment Name: {deployName}");

        string deployPath =
            Environment.GetEnvironmentVariable("DEPLOY_PATH")
            ?? "/bin/x64/plugins/cyber_engine_tweaks/mods/";
        Log($"Deployment Path (base): {deployPath}");

        string ignoreFilesArgs = string.Join(
            " ",
            File.ReadAllLines("./deployment/.deployignorefiles").Select(file => $"/xf {file}")
        );
        Log($"Ignore files args loaded");

        string ignoreDirsArgs = string.Join(
            " ",
            File.ReadAllLines("./deployment/.deployignoredirs").Select(dir => $"/XD {dir}")
        );
        Log($"Ignore dirs args loaded");

        List<string> copyFolders = new List<string>
        {
            "app",
            "config",
            "vendors",
            "resources",
            "storage",
        };

        Dictionary<string, string?> copyFiles = new Dictionary<string, string?>
        {
            { "init.lua", null },
            { ".env.production", ".env" },
        };

        Log("\n--- CLEANUP PHASE ---");
        try
        {
            File.Delete($"./deployment/{deployName}.zip");
            Log($"Deleted existing zip file: ./deployment/{deployName}.zip");
        }
        catch (System.Exception ex)
        {
            Log($"No existing zip to delete or error: {ex.Message}");
        }

        try
        {
            Directory.Delete($"./deployment/{deployName}", true);
            Log($"Deleted existing deployment directory: ./deployment/{deployName}");
        }
        catch (System.Exception ex)
        {
            Log($"No existing deployment directory to delete or error: {ex.Message}");
        }

        if (!string.IsNullOrEmpty(deployName))
        {
            deployPath =
                $"{Environment.CurrentDirectory}/deployment/{deployName}{deployPath}{deployName}";
            deployPath = deployPath.Replace('/', '\\');
            Log($"Final deployment path: {deployPath}");
        }
        else
        {
            throw new Exception("Variable DEPLOY_NAME not present or null in .env file");
        }

        Log("\n--- CREATING DEPLOYMENT DIRECTORY STRUCTURE ---");
        Directory.CreateDirectory(deployPath);
        Log($"Created deployment directory: {deployPath}");

        Log("\n--- COPYING FOLDERS ---");
        foreach (string folder in copyFolders)
        {
            if (Directory.Exists(folder))
            {
                string folderPath = Path.Combine(deployPath, folder);
                Directory.CreateDirectory(folderPath);
                string cmd =
                    $"robocopy {Environment.CurrentDirectory}\\{folder} {folderPath} /MIR /E {ignoreDirsArgs} {ignoreFilesArgs} /NFL /NDL /NJH /NJS /nc /ns /np";
                Log($"Copying folder: {folder}");
                ExecuteCommand(cmd);
            }
            else
            {
                Log($"Skipped folder (not found): {folder}");
            }
        }

        Log("\n--- COPYING FILES ---");
        foreach (var entry in copyFiles)
        {
            string sourceFile = entry.Key;
            string destinationFile = entry.Value ?? sourceFile;

            if (File.Exists(sourceFile))
            {
                string cmd =
                    $"copy {Environment.CurrentDirectory}\\{sourceFile} {Path.Combine(deployPath, destinationFile)}";
                Log($"Copying file: {sourceFile} -> {destinationFile}");
                ExecuteCommand(cmd);
            }
            else
            {
                Log($"Skipped file (not found): {sourceFile}");
            }
        }

        string deployedDir = $"{Environment.CurrentDirectory}\\deployment\\{deployName}";

        Log("\n--- CREATING ZIP FILE ---");
        Log($"Creating zip: ./deployment/{deployName}.zip from {deployedDir}");

        try
        {
            string zipPath = $"./deployment/{deployName}.zip";
            if (File.Exists(zipPath))
            {
                File.Delete(zipPath);
            }
            ZipFile.CreateFromDirectory(deployedDir, zipPath, CompressionLevel.Optimal, false);
            Log($"ZIP file created successfully using native compression");
        }
        catch (System.Exception ex)
        {
            Log($"Error creating ZIP file: {ex.Message}");
        }

        if (File.Exists($"./deployment/{deployName}.zip"))
        {
            Log($"✓ ZIP FILE CREATED SUCCESSFULLY");
            FileInfo zipInfo = new FileInfo($"./deployment/{deployName}.zip");
            Log($"  Size: {zipInfo.Length} bytes");
        }
        else
        {
            Log($"✗ ERROR: ZIP FILE WAS NOT CREATED!");
        }

        Log("\n--- CLEANUP ---");
        try
        {
            Directory.Delete(deployedDir, true);
            Log($"Deleted temporary deployment directory: {deployedDir}");
        }
        catch (System.Exception ex)
        {
            Log($"Error deleting temporary directory: {ex.Message}");
        }

        Log("\n=== DEPLOYMENT SCRIPT COMPLETED ===");
    }

    static void ExecuteCommand(string command)
    {
        System.Diagnostics.ProcessStartInfo procStartInfo = new System.Diagnostics.ProcessStartInfo(
            "cmd",
            "/c " + command
        );
        procStartInfo.RedirectStandardOutput = true;
        procStartInfo.RedirectStandardError = true;
        procStartInfo.UseShellExecute = false;
        procStartInfo.CreateNoWindow = true;
        System.Diagnostics.Process proc = new System.Diagnostics.Process();
        proc.StartInfo = procStartInfo;
        proc.Start();
        string output = proc.StandardOutput.ReadToEnd();
        string error = proc.StandardError.ReadToEnd();
        proc.WaitForExit();

        if (!string.IsNullOrWhiteSpace(output))
        {
            Log(output);
        }
        if (!string.IsNullOrWhiteSpace(error))
        {
            Log("ERROR OUTPUT: " + error);
        }

        if (proc.ExitCode != 0)
        {
            Log($"Command failed with exit code: {proc.ExitCode}");
        }
    }

    static void Log(string message)
    {
        string timestamp = DateTime.Now.ToString("HH:mm:ss");
        string logMessage = $"[{timestamp}] {message}";
        Console.WriteLine(logMessage);
        try
        {
            File.AppendAllText(logFile, logMessage + Environment.NewLine);
        }
        catch { }
    }

    static void dd(string data = "DUMP AND DIE")
    {
        Log(data);
        Environment.Exit(0);
    }

    static void loadEnv()
    {
        string envFile = ".env";

        if (File.Exists(envFile))
        {
            string[] lines = File.ReadAllLines(envFile);
            Log($"Loaded {lines.Length} lines from {envFile}");

            foreach (string line in lines)
            {
                if (line.Contains('=') && !line.StartsWith("#"))
                {
                    string[] parts = line.Split('=');
                    string key = parts[0].Trim();
                    string value = parts[1].Trim();
                    value = (value == "true" || value == "false") ? value : value;
                    Environment.SetEnvironmentVariable(key, value);
                    Log($"  {key} = {value}");
                }
            }
        }
        else
        {
            Log($"ERROR: .env file not found!");
        }
    }
}
