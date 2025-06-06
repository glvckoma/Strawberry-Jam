module.exports = function ({ dispatch, application }) {

  const log = (type, msg) => application.consoleMessage({ type, message: msg });

  let currentRoom = null; // Textual room name
  let currentInternalRoomId = null; // Numerical instance ID

  const refreshRoom = async () => {
    const textualRoom = await dispatch.getState('room');
    const internalRoomState = await dispatch.getState('internalRoomId'); // This might be a string

    currentRoom = textualRoom; // Can be null

    if (internalRoomState) {
      const parsedId = parseInt(internalRoomState, 10);
      if (!isNaN(parsedId)) {
        currentInternalRoomId = parsedId;
      } else {
        log('warn', `Phantoms: internalRoomId '${internalRoomState}' from state could not be parsed to a number.`);
        currentInternalRoomId = null;
      }
    } else {
      currentInternalRoomId = null;
    }

    if (!currentRoom && !currentInternalRoomId) {
      log('warn', 'Phantoms: No room ID is currently available from dispatch state.');
    }
  };

  const sequenceFns = [
    r => `%xt%o%qx%${r}%%`,
    r => `%xt%o%qj%${r}%stagingQuestadventures.queststaging_421_0_585_11672#30%14%1%0%`,
    r => `%xt%o%qs%${r}%dentestofpower%`,
    r => `%xt%o%qpup%${r}%bunny_key_3a%2209994%`,
    r => `%xt%o%qat%${r}%bunny_7%0%`,
    r => `%xt%o%qpup%${r}%bunny_key_3a%2209994%`,
    r => `%xt%o%qat%${r}%bunny_8%0%`,
    r => `%xt%o%qpup%${r}%bunny_key_3a%2209994%`,
    r => `%xt%o%qat%${r}%bunny_9%0%`,
    r => `%xt%o%qpup%${r}%bunny_key_3a%2209994%`,
    r => `%xt%o%qat%${r}%bunny_10%0%`,
    r => `%xt%o%qaskr%${r}%liza_2%1%1%`,
    r => `%xt%o%qpgift%${r}%0%0%0%`,
    r => `%xt%o%qpgift%${r}%1%0%0%`,
    r => `%xt%o%qpgift%${r}%2%0%0%`,
    r => `%xt%o%qpgift%${r}%3%0%0%`,
    r => `%xt%o%qpgift%${r}%4%0%0%`
  ];

  let interval   = null;
  let index      = 0;
  let loopActive = false;
  let sniffing   = false;

  const sendNext = async () => {
    await refreshRoom();
    const roomIdToSend = currentInternalRoomId || currentRoom; // Prioritize numerical ID

    if (!roomIdToSend) {
      log('error', 'Phantoms: No room ID available to send packet. Stopping loop.');
      stopAll();
      return;
    }
    dispatch.sendRemoteMessage(sequenceFns[index](roomIdToSend));
    index = (index + 1) % sequenceFns.length;
  };

  const handleIl = async ({ message: { value } }) => { // Made async
    if (!sniffing || value.length !== 14) return;

    await refreshRoom(); // Refresh room info
    const roomIdToSend = currentInternalRoomId || currentRoom; // Prioritize numerical ID

    if (!roomIdToSend) {
      log('error', 'Phantoms (handleIl): No room ID available to send ir packet.');
      return;
    }

    const slot = value[11], id = value[12];
    if (id === '138' || id === '148' || id === '342') return;

    dispatch.sendRemoteMessage(`%xt%o%ir%${roomIdToSend}%${slot}%`);
  };

  const startLoop = async () => { // Made async
    if (loopActive) return;
    await refreshRoom(); // Await refresh
    const roomIdToUse = currentInternalRoomId || currentRoom;

    if (!roomIdToUse) {
      log('error', 'Phantoms: Cannot start loop, no room ID available.');
      stopAll(); // Ensure it's stopped if it somehow was active or attempted
      return;
    }

    index = 0;
    // sendNext is now async, setInterval might not wait for promise resolution.
    // For simplicity, we'll keep setInterval, but be aware sendNext might overlap if 800ms is too short for its async operations.
    // A more robust solution for async loops would be a recursive setTimeout.
    if (interval) dispatch.clearInterval(interval); // Clear existing before starting new
    interval = dispatch.setInterval(sendNext, 800);
    loopActive = true;
  };
  const stopAll = () => {
    if (interval) dispatch.clearInterval(interval);
    interval = null;
    loopActive = sniffing = false;
  };

  dispatch.onCommand({
    name: 'phantoms',
    description: 'Farm ROTP and collect prizes! (use `off` to disable filtering).',
    callback: async ({ parameters }) => { // Made async
      const p = (parameters[0] || '').toLowerCase();
      if (p === 'off') {
        sniffing = false;
        if (!loopActive) await startLoop(); // await async function
        if (loopActive) log('success', 'ROTP farm mode enabled without filtering.');
      } else if (!p) {
        if (loopActive) {
          stopAll();
          log('warn', 'ROTP farm mode disabled.');
        } else {
          await startLoop(); // await async function
          if (loopActive) {
            sniffing = true;
            log('success', 'ROTP farm mode enabled with filtering.');
          }
        }
      } else { // Handles any other parameter as a toggle, effectively same as no parameter
        if (loopActive) {
          stopAll();
          log('warn', 'ROTP farm mode disabled.');
        } else {
          await startLoop(); // await async function
          if (loopActive) {
            sniffing = true;
            log('success', 'ROTP farm mode enabled with filtering.');
          }
        }
      }
    }
  });

  dispatch.onMessage({ type: 'aj', message: 'il', callback: handleIl });
}
