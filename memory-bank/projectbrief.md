# Project Brief: Strawberry Jam

## Core Purpose

Strawberry Jam is a modular Man-in-the-Middle (MITM) proxy designed specifically for the game Animal Jam Classic (AJC). It is a **fork** of the original **Jam** project by **sxip** ([https://github.com/Sxip/jam](https://github.com/Sxip/jam)), but all new work, documentation, and branding is under the name "Strawberry Jam". Its primary function is to intercept, analyze, and potentially modify the network communication between the AJC client and the official game servers.

## Scope

-   **Proxying:** Intercept TCP traffic (typically on port 443, redirected locally) between the AJC client and server.
-   **Packet Handling:** Parse and potentially modify AJC's network packets (primarily XML and XT formats).
-   **Extensibility:** Allow users to create and load custom plugins (written in JavaScript) to add features, automate actions, or modify game behavior.
-   **User Interface:** Provide an Electron-based desktop application with a UI for managing the proxy, viewing network traffic, and interacting with plugins.
-   **Development Environment:** Built using Node.js and Electron.

## Key Goals (Inferred)

-   Enable analysis and understanding of the AJC network protocol.
-   Provide a platform for developing custom tools and modifications for AJC.
-   Offer features beyond the standard client through plugins (e.g., automation, data logging, appearance changes).
-   ~~Utilize decoded game data (DefPacks) for understanding packet structures and enabling advanced modifications.~~ (DefPacks are stored externally and currently out of scope).

## Current Status (High-Level)

-   Core proxy functionality (MITM, packet parsing/forwarding) is operational.
-   Plugin system (`Dispatch`) exists but exhibits instability, primarily due to issues with chat command execution (`dispatch.onCommand`) and timed packet sending (`dispatch.setInterval` + `sendRemoteMessage`), likely linked to errors in `application.consoleMessage`. Synchronous I/O during plugin load also causes issues.
-   Several custom plugins exist (`nearbyUsernames`, `colors`, `spammer`, etc.), though some relying on commands/timers are unstable. `antiAfk` was removed due to instability. The `UsernameLogger` plugin (refactored from the original `buddyListLogger`, which was moved externally) handles username collection. A `Login Packet Manipulator` UI plugin allows editing the incoming login packet data before it reaches the client.
-   External scripts (`process_logs.js`) are used for reliable processing (API calls, file I/O) due to internal limitations.
-   ~~A set of decoded DefPack JSON files (version 1713) is available in the `1713-defPacks/` directory, providing valuable data on items, animals, etc.~~ (DefPacks stored externally, out of scope).
