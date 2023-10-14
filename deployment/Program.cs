using System;
using System.Collections.Generic;
using System.IO;

class Program
{
    static void Main()
    {
        Environment.CurrentDirectory = Environment.CurrentDirectory.Replace("\\deployment", "");
        loadEnv();

        string deployName = Environment.GetEnvironmentVariable("DEPLOY_NAME") ?? "DefaultModName";
        string deployPath = Environment.GetEnvironmentVariable("DEPLOY_PATH") ?? "/bin/x64/plugins/cyber_engine_tweaks/mods/";
        string ignoreFilesArgs = string.Join(" ", File.ReadAllLines("./deployment/.deployignorefiles").Select(file => $"/xf {file}"));
        string ignoreDirsArgs = string.Join(" ", File.ReadAllLines("./deployment/.deployignoredirs").Select(dir => $"/XD {dir}"));

        List<string> copyFolders = new List<string>
        {
            "app",
            "config",
            "vendors",
            "views",
            "storage"
        };

        Dictionary<string, string?> copyFiles = new Dictionary<string, string?>
        {
            { "init.lua", null },
            { ".env.production", ".env" }
        };


        try
        {
            File.Delete($"./deployment/{deployName}.zip");
            Directory.Delete($"./deployment/{deployName}", true);
        }
        catch (System.Exception)
        {


        }



        if (!string.IsNullOrEmpty(deployName))
        {
            deployPath = $"{Environment.CurrentDirectory}/deployment/{deployName}{deployPath}{deployName}";
            deployPath = deployPath.Replace('/', '\\');
        }
        else
        {
            throw new Exception("Variable DEPLOY_NAME not present or null in .env file");
        }


        Directory.CreateDirectory(deployPath);



        foreach (string folder in copyFolders)
        {
            string folderPath = Path.Combine(deployPath, folder);
            Directory.CreateDirectory(folderPath);
            string cmd = $"robocopy {Environment.CurrentDirectory}\\{folder} {folderPath} /MIR /E {ignoreDirsArgs} {ignoreFilesArgs} /NFL /NDL /NJH /NJS /nc /ns /np";
            //Console.WriteLine($"\n\nRunning: {cmd}");
            ExecuteCommand(cmd);
        }

        foreach (var entry in copyFiles)
        {
            string sourceFile = entry.Key;
            string destinationFile = entry.Value ?? sourceFile;
            string cmd = $"copy {Environment.CurrentDirectory}\\{sourceFile} {Path.Combine(deployPath, destinationFile)}";
            //Console.WriteLine($"\n\nRunning: {cmd}");
            ExecuteCommand(cmd);
        }

        string deployedDir = $"{Environment.CurrentDirectory}\\deployment\\{deployName}";

        ExecuteCommand($"7z a ./deployment/{deployName}.zip {deployedDir}");
        Directory.Delete(deployedDir, true);
    }

    static void ExecuteCommand(string command)
    {
        System.Diagnostics.ProcessStartInfo procStartInfo = new System.Diagnostics.ProcessStartInfo("cmd", "/c " + command);
        procStartInfo.RedirectStandardOutput = true;
        procStartInfo.UseShellExecute = false;
        procStartInfo.CreateNoWindow = true;
        System.Diagnostics.Process proc = new System.Diagnostics.Process();
        proc.StartInfo = procStartInfo;
        proc.Start();
        string result = proc.StandardOutput.ReadToEnd();
        //Console.WriteLine(result);
    }

    static void dd(string data = "DUMP AND DIE")
    {

        Console.WriteLine(data);
        Environment.Exit(0);
    }

    static void loadEnv()
    {
        string envFile = ".env";


        if (File.Exists(envFile))
        {
            string[] lines = File.ReadAllLines(envFile);

            foreach (string line in lines)
            {
                if (line.Contains('='))
                {
                    string[] parts = line.Split('=');
                    string key = parts[0].Trim();
                    string value = parts[1].Trim();
                    value = (value == "true" || value == "false") ? value : value;
                    Environment.SetEnvironmentVariable(key, value);
                }
            }
        }
    }
}
