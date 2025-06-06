# Strawberry Jam - Packet Research Documentation

This document will serve as the central repository for findings related to Animal Jam game packets, researched from the `dev/ajclient-decompiled/scripts/scripts/` directory.

## Research Goals
- Identify packet structures for various in-game actions.
- Determine required parameters for each packet.
- Understand packet sequences for complex operations.
- Find how to dynamically obtain user-specific information (e.g., player ID, username) for packet construction.
- Ensure packet implementations in Strawberry Jam plugins are accurate, robust, and compatible.

## General Packet Structure Notes
*(This section can be filled with observations about common XT message formats, prefixes, delimiters, etc., as they are discovered.)*

---

## I. TFD Automator (The Forgotten Desert) Packets

### A. Den Entry
- **Objective:** Identify packets and sequence for entering a player's den, focusing on how to dynamically get the current player's identifier.
- **Key Files Investigated:**
    - [`dev/ajclient-decompiled/scripts/scripts/den/DenXtCommManager.as`](dev/ajclient-decompiled/scripts/scripts/den/DenXtCommManager.as) (specifically the `requestDenJoinFull` method).
- **Packet Command:** `dj`
- **Client-Side Method:** `DenXtCommManager.requestDenJoinFull(denOwnerUsername:String, numericFlag:int, visibilityBoolean1:Boolean, visibilityBoolean2:Boolean)`
- **Packet Structure Sent (Conceptual):** `%xt%o%dj%INTERNAL_ROOM_ID%denOwnerUsername%visibilityFlagString%numericFlag%`
    - `INTERNAL_ROOM_ID`: Handled by the client's XT framework, represents the room the player is currently in.
    - `denOwnerUsername`: The username of the owner of the den to join. This is the first parameter to `requestDenJoinFull`.
    - `visibilityFlagString`: A string "1" or "0", derived from `visibilityBoolean2` passed to `requestDenJoinFull`.
    - `numericFlag`: An integer, the second parameter to `requestDenJoinFull` (often -1).
- **Findings:**
    - **Packet ID(s):** The core command is `dj`.
    - **Parameters (as sent in the array by `requestDenJoinFull`):**
        1. `denOwnerUsername: String` (e.g., "animaljammer123")
        2. `visibilityFlag: String` (e.g., "1")
        3. `numericId: int` (e.g., -1)
    - **Sequence:** A single `dj` packet is sent.
    - **Dynamic Values Needed for "Go to My Den":**
        - `denOwnerUsername`: This must be the current logged-in player's username.
        - **How to Obtain:** Typically available globally in the client via a path like `gMainFrame.userInfo.playerUserInfo.userName`. Plugins needing to send this packet for the current user must retrieve this value from the game's runtime environment.
    - **Note on Example Packet:** The example `%xt%o%dj%{denId}%{userIdentifier}%1%-1%` from `things-to-address.md` seems to imply `userIdentifier` is the second parameter. However, based on `DenXtCommManager.requestDenJoinFull`, the `denOwnerUsername` (which is the `userIdentifier` when joining one's own den) is the *first* parameter in the array sent with the `dj` command. The `{denId}` in the example might be a conceptual placeholder for this username.

### B. Adventure Start
- **Objective:** Identify packets and sequence for a player starting an adventure (e.g., TFD), focusing on public instances.
- **Key Files Investigated:**
    - [`dev/ajclient-decompiled/scripts/scripts/quest/QuestXtCommManager.as`](dev/ajclient-decompiled/scripts/scripts/quest/QuestXtCommManager.as)
    - (Room transition logic would be in `RoomXtCommManager.as` and `RoomManagerWorld.as`)
- **Typical Sequence for Starting a Public Adventure (e.g., TFD Automator):**
    1.  **Client sends `qj` (Quest Join - Public Instance Request):**
        -   Client-Side Method: `QuestXtCommManager.sendQuestCreateJoinPublic(questDefId:int, difficultyFlag:int, autoStartNext:Boolean)`
        -   Packet Sent: `gMainFrame.server.setXtObject_Str("qj", [currentRoomName, questDefId, difficultyFlag, 0]);`
        -   Conceptual XT String: `%xt%o%qj%<INTERNAL_CLIENT_ROOM_ID>%QUEST_DEF_ID%DIFFICULTY_FLAG%0%`
            -   `INTERNAL_CLIENT_ROOM_ID`: The ID of the room the client is currently in (e.g., obtained via `gMainFrame.server.getCurrentRoomName()`).
            -   `QUEST_DEF_ID`: The definition ID for the specific adventure (e.g., TFD). This is the `{roomId}` in a conceptual sense.
            -   `DIFFICULTY_FLAG`: An integer representing difficulty or mode (e.g., `0` for normal, `23` might be a specific difficulty if applicable).
            -   `0`: An additional hardcoded flag.
        -   `userIdentifier` is implicit (known by the server from the connection).
    2.  **Server responds with `qw` (Quest Wait), placing the player in a lobby.**
        -   The `lobbyRoomName` is provided in this response.
    3.  **Client sends `qs` (Quest Start from Lobby):**
        -   Client-Side Method: `QuestXtCommManager.sendQuestStartRequest()`
        -   Packet Sent: `gMainFrame.server.setXtObject_Str("qs", [lobbyRoomName]);`
        -   Conceptual XT String: `%xt%o%qs%<LOBBY_ROOM_ID_FROM_SERVER_QW_RESPONSE>%`
    4.  **Server responds to `qs` with adventure details, including the specific adventure instance `roomDefId`.**
    5.  **Client sends `gl` (Go Location) or `jp` (Join Room) to enter the adventure instance:**
        -   This is triggered by the client's internal room loading mechanism (`RoomManagerWorld.loadRoom()`) after receiving the adventure `roomDefId`.
        -   Conceptual XT String (from example): `%xt%o%gl%<ADVENTURE_INSTANCE_ROOM_ID>%201%`
            -   `<ADVENTURE_INSTANCE_ROOM_ID>`: The actual ID of the adventure map instance.
            -   `201`: Likely a join type flag.
- **Analysis of Example Packet `%xt%o%qjc%{roomId}%{userIdentifier}%23%0%`:**
    -   The command `qjc` is sent by the client using `QuestXtCommManager.sendQuestCreatePrivate(questDefId:int, difficultyFlag:int)`.
    -   Packet Sent by `sendQuestCreatePrivate`: `gMainFrame.server.setXtObject_Str("qjc", [currentRoomName, questDefId, difficultyFlag]);`
    -   This client-sent `qjc` packet for *creating* a private lobby does **not** include `userIdentifier` as a payload parameter. The server infers the creator.
    -   The example `qjc` packet from `things-to-address.md` has a different parameter structure (4 params after command vs. 3) and includes `userIdentifier`. This suggests the example might be:
        -   A server-to-client message (e.g., broadcasting host info in a lobby).
        -   A client-to-server message for a different action than creating a private lobby.
        -   An inaccurate representation for the client's initial "create private adventure" request.
    -   For TFD automation (solo play), `qj` (public) is more typical than `qjc` (private).
- **Findings Summary for Adventure Start (Public):**
    - **Packet ID(s) & Sequence:** `qj` -> (server `qw`) -> `qs` -> (server `qs` response) -> client triggers `gl`/`jp`.
    - **Parameters for `qj`:** `[currentRoomName, questDefId, difficultyFlag, 0]`
    - **Parameters for `qs`:** `[lobbyRoomName]`
    - **Parameters for `gl`:** `[adventureInstanceRoomId, joinTypeFlag (e.g., 201)]`
    - **Dynamic Values Needed:**
        - `currentRoomName`: From client's current state.
        - `questDefId`: Specific to the adventure (e.g., TFD). Needs to be identified.
        - `difficultyFlag`: Specific to the adventure/desired mode.
        - `lobbyRoomName`: From server's `qw` response.
        - `adventureInstanceRoomId`: From server's `qs` response.
        - `userIdentifier`: Implicitly known by the server for `qj` and `qs` requests initiated by the player. Not sent as an explicit payload parameter in these initial requests.

### C. Adventure Completion
- **Objective:** Identify packets and sequence for completing or exiting a TFD adventure.
- **Key Files Investigated:**
    - [`dev/ajclient-decompiled/scripts/scripts/quest/QuestXtCommManager.as`](dev/ajclient-decompiled/scripts/scripts/quest/QuestXtCommManager.as) (specifically the `sendQuestExit` method).
- **Packet Command:** `qx`
- **Client-Side Method:** `QuestXtCommManager.sendQuestExit(adventureRoomId:String)`
- **Packet Structure Sent (Conceptual):** `%xt%o%qx%<INTERNAL_SFS_ROOM_ID_OF_ADVENTURE>%adventureRoomIdFromParam%`
    -   `<INTERNAL_SFS_ROOM_ID_OF_ADVENTURE>`: The SmartFoxServer internal ID of the adventure room the player is currently in. This is typically handled by the XT framework.
    -   `adventureRoomIdFromParam`: The string parameter passed to `sendQuestExit`, which should be the identifier of the adventure instance being exited/completed. This corresponds to the `{roomId}` in the example.
- **Findings:**
    - **Packet ID(s):** The command is `qx`.
    - **Parameters (as sent in the array by `sendQuestExit`):**
        1.  `adventureRoomId: String` (e.g., the specific instance ID of the TFD adventure map).
    - **Sequence:** A single `qx` packet is sent.
    - **Dynamic Values Needed:**
        -   `adventureRoomId`: The ID of the specific adventure instance the player is currently in and wishes to exit. This ID would have been obtained when the adventure was started and the player joined the adventure room.
    - **Note on Example Packet `%xt%o%qx%{roomId}%%`:**
        -   The `{roomId}` corresponds to the `adventureRoomId` parameter sent by the client.
        -   The `%%` (two empty parameters) in the example are not explicitly sent by the `sendQuestExit` function, which only provides one parameter in its payload array. These might be optional parameters handled by the server or an older/alternative format. For automation, sending the `adventureRoomId` as the single payload parameter is consistent with the client code.

---

## II. Anti-AFK System Packets

- **Objective:** Identify packets that maintain an active game session with the main server and prevent general AFK timeout/disconnection.
- **Key Files Investigated:**
    - [`dev/ajclient-decompiled/scripts/scripts/game/GameBase.as`](dev/ajclient-decompiled/scripts/scripts/game/GameBase.as): This file contains an idle timer (`_gameIdleTimer`) and logic (`gameBaseHeartbeat`) to warn (at 3 mins) and then kick (at 4 mins) a player from *minigames that are not "in-room" games* due to inactivity. This is a minigame-specific AFK mechanism and does **not** handle the general keep-alive with the main game server.
- **Further Investigation Needed:**
    - The general keep-alive packet (e.g., the known `%xt%o%p%` ping packet, or others) is likely handled by a more central networking component of the client.
    - Need to identify where the main client sends periodic pings or other keep-alive messages to SmartFoxServer.
    - Analyze why the current `%xt%o%p%` might be insufficient or if other actions/packets are required to fully prevent AFK.
- **Findings (Pending further research on general Anti-AFK):**
    - Packet ID(s): (Known: `%xt%o%p%` - ping. Are there others?)
    - Parameters:
    - Frequency/Timing:
    - Conditions under which the current keep-alive fails:

---

## III. BuddyLogger Packets

- **Objective:** Identify packets related to fetching and managing buddy lists.
- **Key Files Investigated:**
    - [`dev/ajclient-decompiled/scripts/scripts/buddy/BuddyXtCommManager.as`](dev/ajclient-decompiled/scripts/scripts/buddy/BuddyXtCommManager.as)
- **Findings for Requesting Buddy List:**
    - **Packet Command:** `bl`
    - **Client-Side Method:** `BuddyXtCommManager.sendBuddyListRequest()`
    - **Packet Structure Sent:** `%xt%o%bl%<INTERNAL_SFS_ROOM_ID>%`
        -   The client sends the `bl` command with an empty payload array (`[]`).
        -   The `<INTERNAL_SFS_ROOM_ID>` is the ID of the room the player is currently in, automatically prepended by the client's XT framework.
    - **Server Response:** The server replies with a `bl` packet.
        -   The `BuddyXtCommManager.buddyListblockedListResponse()` method handles this.
        -   If `responseArray[2] == "0"`, it's buddy list data, processed by `BuddyManager.buddyListResponseHandler(responseArray)`.
        -   The `responseArray` contains the buddy list details starting from index 3.
    - **Dynamic Values Needed:** None for the request packet itself, beyond the implicit current room ID. The server knows which user's buddy list to fetch based on their connection.
- **Other Buddy-Related Packets (from `BuddyXtCommManager.as`):**
    - `ba` (Buddy Add Request): `sendBuddyAddRequest(username:String)`
    - `bc` (Buddy Confirm Request): `sendBuddyConfirmRequest(username:String, accepted:Boolean)`
    - `bd` (Buddy Delete Request): `sendBuddyDeleteRequest(username:String)`
    - `br` (Buddy Room Request - find buddy's room): `sendBuddyRoomRequest(username:String)`
    - `bb` (Buddy Block Request): `sendBuddyBlockRequest(username:String)`
    - `bu` (Buddy Unblock Request): `sendBuddyUnblockRequest(username:String)`
    - `bi` (Buddy Block Info Request - check if user is blocking current player): `sendBuddyBlockInfoRequest(username:String)`
    - Server sends `bs` (Buddy Status Update) when a buddy's status changes (e.g., logs in/out, changes room).

---

## IV. Colors Plugin Packets

- **Objective:** Identify packets used to change an avatar's colors.
- **Key Files Investigated:**
    - [`dev/ajclient-decompiled/scripts/scripts/avatar/AvatarXtCommManager.as`](dev/ajclient-decompiled/scripts/scripts/avatar/AvatarXtCommManager.as) (specifically the `requestColorChange` method).
- **Packet Command:** `ap` (Avatar Paint)
- **Client-Side Method:** `AvatarXtCommManager.requestColorChange(newColorsArray:Array, perUserAvatarId:int)`
- **Packet Structure Sent (Conceptual):** `%xt%o%ap%<INTERNAL_SFS_ROOM_ID>%PRIMARY_COLOR%SECONDARY_COLOR%TERTIARY_COLOR%PER_USER_AVATAR_ID%`
- **Findings:**
    - **Packet ID(s):** The command is `ap`.
    - **Parameters (as sent in the array by `requestColorChange`):**
        1.  `primaryColor:uint` (e.g., `2947494441`)
        2.  `secondaryColor:uint` (e.g., `2936012800`)
        3.  `tertiaryColor:uint` (e.g., `2952789759`, often pattern color)
        4.  `perUserAvatarId:int` (e.g., `1526298`, the unique ID of the specific avatar being changed)
    - **Sequence:** A single `ap` packet is sent.
    - **Dynamic Values Needed:**
        -   `primaryColor`, `secondaryColor`, `tertiaryColor`: The new color values selected by the user.
        -   `perUserAvatarId`: The ID of the currently active avatar. This is typically available in the client's state (e.g., `gMainFrame.userInfo.playerUserInfo.currPerUserAvId` or a similar variable holding the active avatar's unique ID).
    - **Note on Example Packet `%xt%o%ap%1526298%2947494441%2936012800%2952789759%0%`:**
        -   The parameters align as: `PER_USER_AVATAR_ID` (`1526298`), `PRIMARY_COLOR` (`2947494441`), `SECONDARY_COLOR` (`2936012800`), `TERTIARY_COLOR` (`2952789759`).
        -   The final `0` in the example packet is **not** sent by the `requestColorChange` function in the ActionScript. The client code sends only the four parameters listed above in its payload array. This `0` might be an optional server-side default or an artifact from a different context.

---

## V. Advertising Plugin Packets

- **Objective:** Identify packets for sending public chat messages.
- **Key Files Investigated:**
    - [`dev/ajclient-decompiled/scripts/scripts/chat/`](dev/ajclient-decompiled/scripts/scripts/chat/) (No relevant files found)
    - [`dev/ajclient-decompiled/scripts/scripts/room/RoomXtCommManager.as`](dev/ajclient-decompiled/scripts/scripts/room/RoomXtCommManager.as) (Handles room joining and properties, but not direct sending of public chat messages via a specific XT command).
- **Findings for Public Chat (Advertising):**
    - **Packet Command:** `sm` (Send Message - a standard SmartFoxServer public message command).
    - **Client-Side Method:** Public chat messages are typically sent using a direct SmartFoxServer API call like `gMainFrame.server.sendPublicMessage(messageText)`, rather than a specific XT command wrapper in `RoomXtCommManager.as`.
    - **Packet Structure Sent:** `%xt%m%sm%<INTERNAL_SFS_ROOM_ID>%MESSAGE_TEXT%`
        -   `<INTERNAL_SFS_ROOM_ID>`: The SmartFoxServer internal ID of the room the player is currently in. This is automatically handled by the `sendPublicMessage` call or needs to be fetched (e.g., `gMainFrame.server.getCurrentRoom().id`).
        -   `MESSAGE_TEXT`: The content of the advertisement/chat message.
    - **Dynamic Values Needed:**
        -   `MESSAGE_TEXT`: The advertisement string.
        -   `INTERNAL_SFS_ROOM_ID`: The ID of the current room the player is in, to ensure the message is broadcast in the correct context.
    - **Context:** This `sm` packet sends a message to all users in the current SFS room.

---

## VI. General/Utility Packets

### A. Room Navigation
- **Objective:** Identify packets for joining different rooms (lands, dens) and how room identifiers are handled.
- **Key Files Investigated:**
    - [`dev/ajclient-decompiled/scripts/scripts/room/RoomXtCommManager.as`](dev/ajclient-decompiled/scripts/scripts/room/RoomXtCommManager.as)
    - [`dev/ajclient-decompiled/scripts/scripts/den/DenXtCommManager.as`](dev/ajclient-decompiled/scripts/scripts/den/DenXtCommManager.as)
- **Findings for General Room/Land Join:**
    - **Packet Command:** `rj` (Room Join)
    - **Client-Side Method:** `RoomXtCommManager.sendRoomJoinRequestFull(roomNameOrId:String, forceInvis:Boolean, confirmLanguageChange:Boolean, joinType:RoomJoinType)`
    - **Parameters Sent (Payload Array for `rj`):**
        1.  `roomNameOrId:String`: The target room's string identifier (e.g., "sarepiaforest", "appondale", or a specific instance like "room_12345#shard_2").
        2.  `confirmLanguageChangeString:String`: "1" or "0".
        3.  `forceInvisString:String`: "1" or "0".
        4.  `joinType:int`: Numerical representation of `RoomJoinType` enum (e.g., `RoomJoinType.AUTO` which might be 0 or 1).
    - **Conceptual XT String:** `%xt%o%rj%<INTERNAL_SFS_ROOM_ID_CLIENT_IS_IN>%ROOM_NAME_OR_ID%LANG_FLAG%INVIS_FLAG%JOIN_TYPE%`
- **Findings for Den Join:**
    - **Packet Command:** `dj` (Den Join)
    - **Client-Side Method:** `DenXtCommManager.requestDenJoinFull(denOwnerUsername:String, numericFlag:int, visibilityBoolean1:Boolean, visibilityBoolean2:Boolean)`
    - **Parameters Sent (Payload Array for `dj`):**
        1.  `denOwnerUsername:String`
        2.  `visibilityFlagString:String` ("1" or "0")
        3.  `numericFlag:int` (e.g., -1)
    - **Conceptual XT String:** `%xt%o%dj%<INTERNAL_SFS_ROOM_ID_CLIENT_IS_IN>%DEN_OWNER_USERNAME%VISIBILITY_FLAG%NUMERIC_FLAG%`
- **Obtaining/Understanding Room IDs:**
    - **Room Definition ID (`defId`):** A static numerical ID for each unique room type (e.g., Sarepia Forest might have a specific `defId`). These are loaded by the client (e.g., via `RoomXtCommManager.roomDefResponse`) and stored, mapping to `pathName` (string name like "sarepiaforest").
    - **SmartFoxServer Instance ID (SFS Room ID):** A dynamic numerical ID assigned by the server to a specific instance of a room that players are in. This is the ID used in the header of XT packets (`%xt%...%<SFS_ROOM_ID>%...%`).
        -   The client receives this SFS Room ID in the server's `rj` (room join) response (handled by `RoomXtCommManager.roomJoinResponse`).
        -   It can be accessed via `gMainFrame.server.getCurrentRoom().id`.
    - **`roomNameOrId` Parameter:** When sending `rj`, the client can use the string `pathName` (e.g., "sarepiaforest") or a more specific instance identifier if available (e.g., "sarepiaforest#shard_1" or "room_instance_123").

### B. Player/Session Information
- **Objective:** Identify how the client obtains and stores essential player data used in constructing various packets.
- **Key Files/Mechanisms:**
    - Initial Login Sequence (establishes basic user identity).
    - [`dev/ajclient-decompiled/scripts/scripts/avatar/AvatarXtCommManager.as`](dev/ajclient-decompiled/scripts/scripts/avatar/AvatarXtCommManager.as) (handles `ad` - Avatar Data, and `al` - Avatar List responses).
    - Global state objects like `gMainFrame.userInfo` and `gMainFrame.userInfo.playerUserInfo`.
- **Findings:**
    -   **Current Player's Username:**
        -   **How Obtained:** Established during login.
        -   **Storage/Access:** Typically available globally, e.g., `gMainFrame.userInfo.myUserName` or `gMainFrame.userInfo.playerUserInfo.userName`.
        -   **Used In:** Den entry (`dj` for own den), identifying player in various contexts.
    -   **Player's User ID (Persistent Database ID):**
        -   **How Obtained:** Part of the user's core information received after login and potentially in avatar data.
        -   **Storage/Access:** Likely `gMainFrame.userInfo.playerUserInfo.userId` or a similar field within the main user object.
        -   **Used In:** Backend identification, linking various game data to the account.
    -   **Player's SmartFoxServer User ID (`sfsUserId`):**
        -   **How Obtained:** Assigned by SmartFoxServer upon joining a room/zone.
        -   **Storage/Access:** Available through SFS API, e.g., `gMainFrame.server.sfs.mySelf.id` or `AvatarManager.playerSfsUserId`.
        -   **Used In:** Identifying the player within the SFS room context for certain actions (e.g., `qpup` - quest pick up item).
    -   **Current Active Animal's `perUserAvId` (Per User Avatar ID):**
        -   **How Obtained:** Received via `ad` (Avatar Data) and `al` (Avatar List) XT responses, handled by `AvatarXtCommManager`. The `al` response determines which avatar is currently active.
        -   **Storage/Access:** Typically stored in a global variable reflecting the active avatar, e.g., `gMainFrame.userInfo.myPerUserAvId` or `gMainFrame.userInfo.playerUserInfo.currPerUserAvId`. The full details of each avatar (including its `perUserAvId`) are stored in `AvatarInfo` objects within `gMainFrame.userInfo.playerUserInfo.avList`.
        -   **Used In:** Packets that target a specific avatar instance, such as changing colors (`ap`), equipping items, etc.
    -   **Current Animal Type ID (`avTypeId`):**
        -   **How Obtained:** Part of the `AvatarInfo` received via `ad` and `al` responses.
        -   **Storage/Access:** Stored within the active `AvatarInfo` object.
        -   **Used In:** Determining compatibility with items, environments, quests.
    -   **Current Room ID (SFS Instance ID):**
        -   **How Obtained:** Received in the `rj` (Room Join) server response.
        -   **Storage/Access:** `gMainFrame.server.getCurrentRoom().id`.
        -   **Used In:** Header of most XT packets to target the current room instance.