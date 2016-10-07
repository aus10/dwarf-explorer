// This file is required by the index.html file and will
// be executed in the renderer process for that window.
// All of the Node.js APIs are available in this process.
var window = window;
var TextDecoder = TextDecoder;

window.Elm = require('./build/elm.js');
var net = require('net');

var node = document.getElementById('main');
var app = Elm.Main.embed(node);

// app.ports.dwarfList.send([
//     {
//         name:"test", 
//         profession: "profession test",
//         currentJob: "Walking",
//         stressLevel: "High",
//         skills: [
//             {
//                 name: "Woodcutting",
//                 ratingCaption: "Master",
//                 ratingValue:100,
//                 xp: 0,
//                 maxXp: 100
//             },
//             {
//                 name: "Mining",
//                 ratingCaption: "Master",
//                 ratingValue:100,
//                 xp: 10,
//                 maxXp: 100
//             }
//         ],
//         inventory: [
//             {
//                 name: "Sword",
//                 stackSize: 1,
//                 subtype: "TEST_ITEM"
//             }
//         ],
//         buildings: [
//             {
//                 name: "Bed"
//             }
//         ]
//     }, 
//     {
//         name:"test2", 
//         profession: "Woodcutter",
//         currentJob: "Walking",
//         stressLevel: "High",
//         skills: [
//             {
//                 name: "Woodcutting",
//                 ratingCaption: "Master",
//                 ratingValue:100,
//                 xp: 0,
//                 maxXp: 100
//             },
//             {
//                 name: "Mining",
//                 ratingCaption: "Master",
//                 ratingValue:100,
//                 xp: 10,
//                 maxXp: 100
//             }
//         ],
//         inventory: [
//             {
//                 name: "Sword",
//                 stackSize: 1,
//                 subtype: "TEST_ITEM"
//             }
//         ],
//         buildings: [
//             {
//                 name: "Bed"
//             }
//         ]
//     }
// ]);

var client = new net.Socket();

client.connect(51234, '127.0.0.1', function () {
	console.log('Connected');
	client.write('Hello, server! Love, Client.\n');
});

var jsonBuffer = "";

client.on('data', function (data) {
	// first try
	var enc = new TextDecoder();
	var decodedString = enc.decode(data, { stream: true });
	var dwarves = [];

	jsonBuffer += decodedString;
	try {
		dwarves = JSON.parse(jsonBuffer);
		finishedStream = true;
		jsonBuffer = "";
		dwarves = dwarves.map(function (dwarf) {
			dwarf.inventory = Object.keys(dwarf.inventory).map(function (index) {
				return dwarf.inventory[index];
			});
			return dwarf;
		});
		app.ports.dwarfList.send(dwarves);
	} catch (error) {

	}

	console.log('Received: ' + decodedString);


	//client.destroy(); // kill client after server's response
});

client.on('close', function () {
	console.log('Connection closed');
});





// app.ports.check.subscribe(function(word) {

// });

