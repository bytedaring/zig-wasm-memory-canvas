var memory = new WebAssembly.Memory({
  initial: 2, /* pages */
  maximum: 2,
});

var importObject = {
  env: {
    consoleLog: (arg) => console.log(arg),
    memory: memory,
  }
}

WebAssembly.instantiateStreaming(fetch("zig-out/lib/zig-wasm-canvas.wasm"), importObject).then((rst) => {
  const wasmMemoryArray = new Uint8Array(memory.buffer);
  const exports = rst.instance.exports

  // Automatically set canvas size as defined in `checkerboard.zig`
  const checkerboardSize = exports.getCheckerboardSize();
  const canvas = document.getElementById('checkerboard');
  canvas.width = checkerboardSize;
  canvas.height = checkerboardSize;

  const context = canvas.getContext('2d');
  const imageData = context.createImageData(canvas.width, canvas.height);
  context.clearRect(0, 0, canvas.width, canvas.height);

  const getDarkValue = () => {
    return Math.floor(Math.random() * 100)
  }
  const getLightValue = () => {
    return Math.floor(Math.random() * 127) + 127
  }

  const drawCheckerboard = () => {
    exports.colorCheckerboard(
      getDarkValue(),
      getDarkValue(),
      getDarkValue(),
      getLightValue(),
      getLightValue(),
      getLightValue(),
    )

    const bufferOffset = exports.getCheckerboardBufferPointer();
    const imageDataArray = wasmMemoryArray.slice(bufferOffset, bufferOffset + checkerboardSize * checkerboardSize * 4);

    imageData.data.set(imageDataArray);

    context.clearRect(0, 0, canvas.width, canvas.height);
    context.putImageData(imageData, 0, 0);
  }

  drawCheckerboard();
  console.log(memory.buffer);
  setInterval(() => {
    drawCheckerboard();
  }, 250);
})
