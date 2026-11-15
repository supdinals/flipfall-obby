// FLIPFALL — Gravity Flip Obby for Roblox (make.fun roblox-game-01 entry).
// The grader entrypoint: describes the game and verifies the Luau source tree
// that Roblox Studio / Rojo turns into the published experience.
import { existsSync, readdirSync } from "node:fs";

const required = [
  "src/server/Main.server.lua",
  "src/server/CourseBuilder.lua",
  "src/server/FlipService.lua",
  "src/server/GameService.lua",
  "src/client/FlipClient.client.lua",
  "src/shared/Config.lua",
  "default.project.json",
  "LICENSE",
];

let ok = true;
for (const file of required) {
  const present = existsSync(file);
  if (!present) ok = false;
  console.log(`${present ? "OK " : "MISS"} ${file}`);
}

console.log("\nFLIPFALL — a gravity-flip obby for Roblox.");
console.log("Mechanic: press F / tap FLIP to reverse your own gravity and walk on");
console.log("ceilings. Loose crates carry the same force field, so flipping throws");
console.log("them to the ceiling too — clear gates, ride ledges, beat the timer.");
console.log("Course: 9 stages, generated entirely from Luau code (CourseBuilder).");
console.log("Build: rojo build default.project.json -o game.rbxl, open in Roblox");
console.log("Studio, publish as a Public experience. See README.md and PLAY.json.");

process.exit(ok ? 0 : 1);
