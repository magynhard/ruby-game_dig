const { GameDig } = require('gamedig');


const type = "q3a";
const host = "5.104.111.196";
const port = 27961;

const fun = async ()  => {
    const serverData = await GameDig.query({
        type: type,
        host: host,
        port
    });
    console.log(serverData);
};

fun();