// © COPYRIGHT 2022 APPDADDY SOFTWARE SOLUTIONS INC. ALL RIGHTS RESERVED.
let useHtmlRenderer = false;
if (useHtmlRenderer) {
	console.log("Rendering with HTML");
	window.flutterWebRenderer = "html";
} else {
	console.log("Rendering with CanvasKit");
	window.flutterWebRenderer = "canvaskit";
}