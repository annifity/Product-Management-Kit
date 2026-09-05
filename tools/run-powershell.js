const { spawnSync } = require("node:child_process");
const path = require("node:path");

const [, , scriptArg, ...scriptArgs] = process.argv;

if (!scriptArg) {
  console.error("Usage: node tools/run-powershell.js <script.ps1> [arguments]");
  process.exit(64);
}

const windowsPowerShell = process.env.SystemRoot
  ? path.join(
      process.env.SystemRoot,
      "System32",
      "WindowsPowerShell",
      "v1.0",
      "powershell.exe",
    )
  : null;
const programFilesPwsh = process.env.ProgramFiles
  ? path.join(process.env.ProgramFiles, "PowerShell", "7", "pwsh.exe")
  : null;
const candidates =
  process.platform === "win32"
    ? [
        "pwsh.exe",
        "powershell.exe",
        programFilesPwsh,
        windowsPowerShell,
        "pwsh",
        "powershell",
      ].filter(Boolean)
    : ["pwsh", "powershell"];

let executable;
for (const candidate of candidates) {
  const probe = spawnSync(candidate, ["-NoProfile", "-Command", "$PSVersionTable.PSVersion.ToString()"], {
    encoding: "utf8",
    windowsHide: true,
  });
  if (!probe.error && probe.status === 0) {
    executable = candidate;
    break;
  }
}

if (!executable) {
  console.error("PowerShell was not found. Install PowerShell 7 (`pwsh`) or Windows PowerShell.");
  process.exit(127);
}

const scriptPath = path.resolve(process.cwd(), scriptArg);
const result = spawnSync(
  executable,
  ["-NoProfile", "-ExecutionPolicy", "Bypass", "-File", scriptPath, ...scriptArgs],
  {
    stdio: "inherit",
    windowsHide: true,
  },
);

if (result.error) {
  console.error(result.error.message);
  process.exit(1);
}

process.exit(result.status === null ? 1 : result.status);
