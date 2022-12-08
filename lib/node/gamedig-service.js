const Gamedig = require('gamedig');
const Hapi = require('@hapi/hapi');

const server = Hapi.server({
    port: 24445,
    host: 'localhost'
});

const init = async () => {

    server.route({
        method: 'GET',
        path: '/exit',
        handler: async (request, h) => {
            server.stop();
            process.exit(0);
            return '';
        }
    });

    server.route({
        method: 'GET',
        path: '/{type}/{ip}',
        handler: async (request, h) => {

            const { type, ip } = request.params;
            const [ host, port ] = ip.split(':')

            const serverData = await Gamedig.query({
                type: type,
                host,
                port
            });
            return serverData;
        }
    });

    await server.start();
};

process.on('unhandledRejection', (err) => {
    console.error(err);
});

init();

