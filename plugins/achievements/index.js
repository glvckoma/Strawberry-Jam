module.exports = function ({ client, dispatch }) {
  /**
   * Array of the achievements ids.
   */
  const achievements = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    11,
    12,
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    21,
    22,
    23,
    24,
    25,
    26,
    27,
    36,
    86,
    38,
    39,
    40,
    41,
    44,
    45,
    46,
    47,
    48,
    50,
    51,
    52,
    53,
    54,
    55,
    56,
    57,
    58,
    59,
    60,
    61,
    62,
    64,
    65,
    66,
    67,
    76,
    77,
    78,
    85,
    84,
    80,
    17,
    79,
    82,
    83,
    81,
    86,
    87,
    91,
    92,
    93,
    94,
    95,
    97,
    96,
    31,
    32,
    37,
    113,
    115,
    130,
    131,
    132,
    143,
    144,
    145,
    159,
    160,
    212,
    213,
    212,
    277,
    278,
    279,
    280,
    281,
    282,
    283,
    284,
    285,
    292,
    293,
    294,
    310,
    309,
    308,
    313,
    314,
    315,
    316,
    317,
    318,
    321,
    322,
    323,
    324,
    325,
    326,
    327,
    328,
    329,
    330,
    331,
    344,
    345,
    346,
    347,
    349,
    350,
    351,
    352,
    353,
    357,
    358,
    359,
    360,
    361,
    378,
    377,
    386,
    387,
    388,
    403,
    405,
    445,
    444,
    446
  ]

  /**
   * Handles the achievements message.
   */
  const handleAchievementsMessage = async () => {
    const textualRoomId = await dispatch.getState('room');
    const internalRoomIdValue = await dispatch.getState('internalRoomId');
    let parsedInternalRoomId = null;

    if (internalRoomIdValue !== null && internalRoomIdValue !== undefined) {
        parsedInternalRoomId = parseInt(internalRoomIdValue, 10);
        if (isNaN(parsedInternalRoomId)) {
            console.warn(`[Achievements Plugin] internalRoomId '${internalRoomIdValue}' could not be parsed to a number.`);
            parsedInternalRoomId = null;
        }
    }

    let roomIdToUse = null;
    if (parsedInternalRoomId !== null) {
        roomIdToUse = parsedInternalRoomId;
        if (window.IS_DEV) {
            console.log(`[Achievements Plugin] Using parsed internalRoomId: ${parsedInternalRoomId}`);
        }
    } else if (textualRoomId) {
        roomIdToUse = textualRoomId;
        console.warn(`[Achievements Plugin] Parsed internalRoomId not available (original value: ${internalRoomIdValue}). Falling back to textualRoomId: ${textualRoomId}. Achievements might not register correctly.`);
    }

    if (!roomIdToUse) {
      // Ensure 'application' is correctly referenced or passed if this plugin is a class
      // For now, assuming 'application' is globally available or part of the closure scope as in original
      if (typeof application !== 'undefined' && application.consoleMessage) {
        application.consoleMessage({
          message: 'Achievements: You must be in a room to use this plugin (room ID not found).',
          type: 'error'
        });
      } else {
        console.error('[Achievements Plugin] You must be in a room to use this plugin (room ID not found). `application` object not available for console message.');
      }
      return;
    }

    for (let i = 0; i < achievements.length; i++) {
      if (dispatch.connected) {
        dispatch.sendRemoteMessage(`%xt%o%zs%${roomIdToUse}%${achievements[i]}%9999999%1%`)
        await dispatch.wait(110)
      }
    }
  }

  /**
   * Chat message hook.
   */
  dispatch.onCommand({
    name: 'achievements',
    description: 'Gives your character (most) in-game achievements.',
    callback: handleAchievementsMessage
  })
}
