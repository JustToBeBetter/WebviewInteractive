
function sendCommand(){
    var url="http://zc.like-me.cn/mobile";
    document.location = url;
}
function changeUrl(){
    sendCommand();
}
function sendParam(cmd,param){
    var url="testapp:"+cmd+":"+param;
    document.location = url;
}
function clickLink(){
    sendParam("alert","你好吗？");
}