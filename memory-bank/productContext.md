# Product Context: Strawberry Jam

> **Note:** This project is a fork of the original Jam by sxip. All new work, documentation, and branding is under the name "Strawberry Jam".

## Problem Space

Animal Jam Classic (AJC) is an online game with a defined set of features and interactions. Users may wish to:

-   Understand the underlying mechanics and network communication of the game.
-   Automate repetitive tasks within the game.
-   Experiment with client-side modifications or enhancements not offered by the official client.
-   Analyze game data for patterns or insights.
-   Develop custom tools that interact with the game state.

The official AJC client does not provide mechanisms for these activities.

## Solution: Strawberry Jam Proxy

Strawberry Jam addresses these needs by acting as a Man-in-the-Middle (MITM) proxy. By intercepting the communication between the client and server, Strawberry Jam provides a platform to:

-   **Observe:** View raw network packets to understand game protocols.
-   **Modify:** Alter packets to change game behavior (within the limits of server-side validation). ~~often requiring knowledge of item/animal IDs found in DefPacks.~~ (DefPacks are external/out of scope).
-   **Automate:** Send packets programmatically via plugins to perform actions automatically (e.g., anti-AFK, potentially others).
-   **Extend:** Add custom features or data logging through its plugin system, including the `Username Logger` (refactored from the original `buddyListLogger`, which was moved externally).
-   **Decode:** ~~Provide access (currently via manually added files) to decoded game data (DefPacks) to aid in understanding packet structures and identifying game entities.~~ (DefPacks are external/out of scope).

## Target User

-   Technically inclined AJC players interested in the game's inner workings.
-   Developers wanting to create custom tools or bots for AJC.
-   Users seeking quality-of-life improvements or automation not present in the base game.

## User Experience Goals (Inferred)

-   Provide a visual interface (Electron app) for ease of use compared to purely command-line proxies.
-   Allow straightforward loading and management of plugins.
-   Offer visibility into network traffic through a dedicated panel.
-   Enable basic packet manipulation and sending via tools like the "Packet Spammer".

## Challenges & Considerations

-   **Stability:** The application currently exhibits instability, particularly with its internal command system and potentially asynchronous operations, leading to errors like "Invalid Status Type".
-   **Security:** The default Electron configuration is highly insecure (`nodeIntegration: true`, `contextIsolation: false`, etc.), and the plugin system allows arbitrary code execution, posing significant security risks to the user. TLS certificate validation is also disabled by default when connecting to the game server.
-   **Complexity:** Understanding network protocols and developing plugins requires technical knowledge. ~~Strawberry Jam currently lacks built-in tools for easily accessing or managing DefPack data.~~ (DefPacks are external/out of scope).
-   **Terms of Service:** Using MITM tools and automating actions likely violates AJC's Terms of Service, carrying a risk of account suspension.
