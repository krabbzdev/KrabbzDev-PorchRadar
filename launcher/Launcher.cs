// Launcher for KrabbzDev's Porch Radar: the small, signed Krabbz9999-FlightTracker.exe that the shortcuts point to.
// It starts the real Node.js runtime (runtime\node.exe, Node's own signed binary, never modified) on the app's code
// (app\server.js) with no console window, passes on any arguments (for example --background), then exits.
// The app code in app\ is what self-updates; this launcher only changes when the installer does.
// Build: csc /target:winexe /out:build\base\Krabbz9999-FlightTracker.exe launcher\Launcher.cs launcher\AssemblyInfo.cs
using System;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Windows.Forms;

static class Launcher
{
    [STAThread]
    static int Main(string[] args)
    {
        string dir = AppDomain.CurrentDomain.BaseDirectory;
        string node = Path.Combine(dir, "runtime", "node.exe");
        string script = Path.Combine(dir, "app", "server.js");
        if (!File.Exists(node) || !File.Exists(script))
        {
            MessageBox.Show("Porch Radar's files are missing from:\n" + dir + "\n\nPlease run the installer again.",
                "KrabbzDev's Porch Radar", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return 1;
        }
        var line = new StringBuilder(Quote(script));
        foreach (string a in args) line.Append(' ').Append(Quote(a));
        try
        {
            Process.Start(new ProcessStartInfo(node, line.ToString())
            {
                WorkingDirectory = dir,
                UseShellExecute = false,
                CreateNoWindow = true
            });
        }
        catch (Exception e)
        {
            MessageBox.Show("Porch Radar could not start:\n" + e.Message, "KrabbzDev's Porch Radar", MessageBoxButtons.OK, MessageBoxIcon.Error);
            return 1;
        }
        return 0;
    }

    // Windows command-line quoting for one argument
    static string Quote(string a)
    {
        if (a.Length > 0 && a.IndexOfAny(new[] { ' ', '\t', '"' }) < 0) return a;
        return "\"" + a.Replace("\"", "\\\"") + "\"";
    }
}
