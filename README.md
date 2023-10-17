---
title: "Zig Wasm Memory Canvas"
date: 2023-10-16T17:32:08+08:00
lastmod: 2023-10-16T17:32:08+08:00
draft: false
keywords: [zig wasm]
description: ""
tags: [zig wasm]
categories: []
author: ""
---

展示HTML canvas、wasm memory 和 zig 交互的一个小示例。

![example](https://imgs.bytedaring.wang/img/2023/10-16/checkerboard.gif) 

这个示例来自[https://github.com/daneelsan/minimal-zig-wasm-canvas](https://github.com/daneelsan/minimal-zig-wasm-canvas)，而这示例本来修改来自[https://wasmbyexample.dev/examples/reading-and-writing-graphics/reading-and-writing-graphics.rust.en-us.html](https://wasmbyexample.dev/examples/reading-and-writing-graphics/reading-and-writing-graphics.rust.en-us.html)。对于当前这个本身，它如大多数 zig 项目一样，`zig` 命令是你唯一的依赖项。

## 总结

`main.zig` 定义了一个全局的 8X8 像素数组: `checkerboard_buffer`。并导出三个函数：`getCheckerboardBufferPointer()` 、`getCheckerboardSize()` 和 `colorCheckerboard(...)`, `getCheckerboardBufferPointer()` 返回一个指向`checkerboard_buffer`开始处的指针，这将在`script.js` 被使用。`getCheckerboardSize()` 返回棋盘格子数量。 `colorCheckerboard(...)`函数根据传入的颜色参数，来改变棋盘格的颜色。

`main.zig` 通过`build.zig`被编译成 wasm模块 `checkerboard.wasm`。

`index.html` 定义了一个canvas，并指定样式：`image-rendering: pixelated; width: 50%`，这是因为`main.zig`是定义的一个8x8 象素的棋盘格，所以需要通过 CSS属性[image-rendering](https://developer.mozilla.org/zh-CN/docs/Web/CSS/image-rendering) 来对 canvas 画出的图像进行放大显示，以获得一个清晰的棋盘格来清楚的展示颜色的变化。 

`script.js` 文件创建了一个名为`memory`的 [WebAssembly.Memory](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WebAssembly/Memory) ，它存储的是`WebAssembly`实例所访问内存的原始字节码。下一步是使用`WebAssembly.instantiateStreaming()`方法编译和示例化获取到的`wasm`模块，返回的一个[Promise](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise)对象，它包含一个`instanace`字段([WebAssembly.instanace](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/WebAssembly/Instance)) , 它保存有从`checkerboard.wasm` 导出的所有方法。

接下来是：

- 从`WebAssembly.Memory` memory 创建一个`Uint8Array`数组：`wasmMemoryArray`
- 获取到`index.html`中定义的canvas `checkerboard`, 并使用`getCheckerboardSize()`获取到的棋盘格数来指定canvas 的`width` 和 `height`，接着使用canvas的context 创建一个 [ImageData](https://developer.mozilla.org/en-US/docs/Web/API/ImageData) 对象：`ImageData` 
- 在循环中更新棋盘格的颜色：

    - 传入RGB颜色参数，调用`colorCheckerboard(...)`，这会修改`checkerboard_buffer`中保存的值
    - `checkerboard_buffer`中的内容，是一个段`wasmMemoryArray`，可以通过`getCheckerboardBufferPointer`获取内存起始地址 和 8 * 8 * 4 字节的偏移长度来获取
    - 将获取到的内容，放入到`imageData`
    - 将`imageData` 写入到`canvas`

## 构建

`build.zig` 指定的为一个构建目标是：`wasm32-freestanding-musl`

用于构建项目的最新zig版本是：

```bash
$ zig version
0.12.0-dev.817+54e7f58fc
```

构建wasm 模块，运行：

```bash
$ zig build

$ ls zig-out/lib/
zig-wasm-canvas.wasm


```
**注意:** 为了运行将内存导入到 WASM 二进制文件中，构建时需要指定`--import-memory`参数

## 运行

在项目目录上，启动一个服务：
```bash
$ python3 -m http.server
```
这时在你的浏览器中浏览：`localhost:8000`，就可以看到棋盘格在改变颜色。
