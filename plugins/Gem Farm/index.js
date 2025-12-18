module.exports = function ({ dispatch, application }) {

  const log = (type, msg) => application.consoleMessage({ type, message: msg });

  // IDs you actively want to recycle
  const TARGET_IDS = ['857','860','861','862','863','864','865','866','867','868','869','870'];

  let currentRoom = null;
  let currentInternalRoomId = null;

  const refreshRoom = async () => {
    const textualRoom = await dispatch.getState('room');
    const internalRoomState = await dispatch.getState('internalRoomId');
    currentRoom = textualRoom;
    if (internalRoomState) {
      const parsedId = parseInt(internalRoomState, 10);
      currentInternalRoomId = isNaN(parsedId) ? null : parsedId;
      if (isNaN(parsedId)) {
        log('warn', `GemFarm: internalRoomId '${internalRoomState}' could not be parsed to a number.`);
      }
    } else {
      currentInternalRoomId = null;
    }
    if (!currentRoom && !currentInternalRoomId) {
      log('warn', 'GemFarm: No room ID currently available.');
    }
  };

  // Packets: quest start (sent once), then looped actions
  const questStartPacket = r => `%xt%o%qj%${r}%Z%49%0%0%`; // Join gem farm quest
  const loopPackets = [
    r => `%xt%o%qat%${r}%gui_goal4%0%`,
    r => `%xt%o%qpgiftplr%${r}%0%0%0%`,
    r => `%xt%o%qpgiftplr%${r}%1%0%0%`
  ];

  let loopInterval = null;
  let loopIndex = 0;
  let loopActive = false;
  let sniffing = false;

  const sendLoopPacket = async () => {
    await refreshRoom();
    const roomId = currentInternalRoomId || currentRoom;
    if (!roomId) {
      log('error', 'GemFarm: No room ID to send loop packet. Stopping.');
      stopAll();
      return;
    }
    dispatch.sendRemoteMessage(loopPackets[loopIndex](roomId));
    loopIndex = (loopIndex + 1) % loopPackets.length;
  };

  const handleIl = async ({ message: { value } }) => {
  if (!sniffing || value.length !== 14) return;

  await refreshRoom();
  const roomId = currentInternalRoomId || currentRoom;
  if (!roomId) {
    log('error', 'GemFarm (handleIl): No room ID for ir packet.');
    return;
  }

  const slot = value[11];
  const id   = value[12];

  // Only trigger recycle if ID is in our target list
  if (!TARGET_IDS.includes(id)) return;

  dispatch.sendRemoteMessage(`%xt%o%ir%${roomId}%${slot}%`);
};

  const startLoop = async () => {
    if (loopActive) return;
    await refreshRoom();
    const roomId = currentInternalRoomId || currentRoom;
    if (!roomId) {
      log('error', 'GemFarm: Cannot start loop, no room ID.');
      stopAll();
      return;
    }

    // Send quest start once
    dispatch.sendRemoteMessage(questStartPacket(roomId));

    loopIndex = 0;
    if (loopInterval) dispatch.clearInterval(loopInterval);
    loopInterval = dispatch.setInterval(sendLoopPacket, 500);
    loopActive = true;
  };

  const stopAll = () => {
    if (loopInterval) dispatch.clearInterval(loopInterval);
    loopInterval = null;
    loopActive = sniffing = false;
  };

  dispatch.onCommand({
    name: 'gemfarm',
    description: 'Automate gem farming.',
    callback: async ({ parameters }) => {
      const p = (parameters[0] || '').toLowerCase();
      if (p === 'off') {
        sniffing = false;
        if (!loopActive) await startLoop();
        if (loopActive) log('success', 'GemFarm mode enabled without recycling filter.');
      } else if (!p) {
        if (loopActive) {
          stopAll();
          log('warn', 'GemFarm mode disabled.');
        } else {
          await startLoop();
          if (loopActive) {
            sniffing = true;
            log('success', 'GemFarm mode enabled.');
          }
        }
      } else {
        // Any other param toggles mode
        if (loopActive) {
          stopAll();
          log('warn', 'GemFarm mode disabled.');
        } else {
          await startLoop();
          if (loopActive) {
            sniffing = true;
            log('success', 'GemFarm mode enabled with recycling filter.');
          }
        }
      }
    }
  });

  dispatch.onMessage({ type: 'aj', message: 'il', callback: handleIl });
};
