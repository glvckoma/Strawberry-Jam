# InvisibleToggle Plugin

**WARNING:**  
This plugin uses a "mod" command to toggle invisibility in Animal Jam Classic.  
**Use at your own risk.** This may violate Animal Jam's Terms of Service and could result in account suspension or bans.

---

## What It Does

- Adds an `!invis` command to the Jam console to toggle invisibility.
- Toggles your invisibility state by sending the `%xt%fi%-1%` packet to the server to become invisible.
- Toggles back to visible by sending the `%xt%fi%-1%0%` packet.

---

## Usage

1. Load the plugin in Jam.
2. Type `!invis` in the Jam console to toggle invisibility.
   - The first time you use it, you will become invisible (`%xt%fi%-1%` sent).
   - The next time, you will become visible again (`%xt%fi%-1%0%` sent).

You can also use `window.toggleInvis()` in the browser console (F12 or Ctrl+Shift+I) if desired.

---

## Technical Details

- **Invisibility ON:**  
  Sends `%xt%fi%-1%` to the server.

- **Invisibility OFF:**  
  Sends `%xt%fi%-1%0%` to the server.

---

## Use Cases

- Troll your friends or people by making it appear someone is in their den, but they can't see where you are. Or spy on conversations!
- Become completely invisible to other players.
- Interesting fact: being invisible causes movement logs to not be sent to the server, which *could* potentially be used to avoid bans when botting or auto-completing minigames (though this is highly speculative and not guaranteed).

---

## Disclaimer

- This is a "mod" command and is not officially supported.
- **This is a high-risk command as not much is known about its effects or server-side detection.**
- Use at your own risk. The author is not responsible for any consequences, including account bans or data loss.
