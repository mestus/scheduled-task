using System;

namespace ScheduledTask
{
    public class Run
    {
        public static void Command(string exe, string args)
        {
            Console.WriteLine($"{DateTimeOffset.Now}: Running command '{exe}' with arguments '{args}'");

            try
            {
                var procStartInfo = new System.Diagnostics.ProcessStartInfo(exe);
                procStartInfo.RedirectStandardOutput = true;
                procStartInfo.RedirectStandardError = true;
                procStartInfo.UseShellExecute = false;
                procStartInfo.CreateNoWindow = true;
                procStartInfo.Arguments = args;

                var proc = new System.Diagnostics.Process();
                proc.StartInfo = procStartInfo;
                proc.Start();

                var stdout = proc.StandardOutput.ReadToEnd();
                var stderr = proc.StandardError.ReadToEnd();
                proc.WaitForExit();

                if (!string.IsNullOrWhiteSpace(stdout)) Console.WriteLine(stdout);
                if (!string.IsNullOrWhiteSpace(stderr)) Console.WriteLine(stderr);
                
            }
            catch (Exception e)
            {
                Console.Error.WriteLine(e.Message);
            }
        }
    }
}