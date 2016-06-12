function sendCommand(){
    var url="http://zc.like-me.cn/mobile";
    document.location = url;
}
function changeUrl(){
    sendCommand();
}
function cameraCallback(imageData) {
    var img = createImageWithBase64(imageData);
    document.getElementById("cameraWrapper").appendChild(img);
}
function photolibraryCallback(imageData) {
    var img = createImageWithBase64(imageData);
    document.getElementById("photolibraryWrapper").appendChild(img);
}
function albumCallback(imageData) {
    var img = createImageWithBase64(imageData);
    document.getElementById("albumWrapper").appendChild(img);
}
function createImageWithBase64(imageData) {
    var img = new Image();
    img.src = "data:image/jpeg;base64," + imageData;
    img.style.width  = "50px";
    img.style.height = "50px";
    return img;
}