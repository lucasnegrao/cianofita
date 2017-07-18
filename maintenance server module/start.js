var module = {}
var fs = require('fs')
var path = require('path')
var net = require('net')

var fileToSend = '/Users/lucasnegrao/development/nodemcu/fan.lua'
var filename;
fs.readFile(fileToSend, (err, data) => {
  if (err) throw err;
    filename = path.basename(fileToSend)
    console.log(filename)
    send_new_file(filename);
    sendFileChunks(data,0)
});

var separator = String.fromCharCode(254)

function sendFileChunks(data,chunk){
    
    if(chunk>=data.length) {
        //send_do_file(filename)
    return
    }
    
    console.log(chunk)
    sendFileChunk(data.slice(chunk,chunk+1024));
    setTimeout(sendFileChunks.bind(null,data,chunk+=1024),2500) 
}

function sendFileChunk(chunk){
    console.log("sending "+separator+chunk)
    send_apd_file(filename+separator+chunk);
}




function send_do_file(file){
    send(Buffer.from('cmd:f.dof'+separator+file));    
}

function send_del_file(file){
    send(Buffer.from('cmd:f.del'+separator+file));    
}

function send_new_file(file){
    send(Buffer.from('cmd:f.new'+separator+file));    
}

function send_apd_file(file){
    send(Buffer.from('cmd:f.apd'+separator+file));    
}

function send_compile_file(file){
    send(Buffer.from('cmd:f.com'+separator+file));    
}

//    module.dgram = require('dgram');
//module.client = module.dgram.createSocket('tcp4');

function send(buf) {
    module.client.write(buf);
//    module.client.send(buf, 7532, "192.168.5.13",(err) => {
//    });
}

module.client = new net.Socket();

module.client.connect(7532, '192.168.5.25', function() {
	console.log('Connected');
	//module.client.write('Hello, server! Love, Client.');
});

module.client.on('data', function(data) {
	console.log('Received: ' + data);
//	module.client.destroy(); // kill client after server's response
});
