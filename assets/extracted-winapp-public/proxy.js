const express = require("express");
const tls = require("tls");
const WebSocket = require('ws');
const axios = require('axios');

whitelist = [
    "https://raw.githubusercontent.com/DrEmoji/AJPrivChat/refs/heads/main/Emojis"
]

function createProxyServer(port) {
    const app = express();

    app.use((req, res, next) => {
        res.header("Access-Control-Allow-Origin", req.headers.origin || "*");
        res.header("Access-Control-Allow-Methods", "GET, POST, OPTIONS");
        res.header(
            "Access-Control-Allow-Headers",
            "Origin, X-Requested-With, Content-Type, Accept, Authorization, authority, User-Agent, Referer"
        );
        res.header("Access-Control-Allow-Credentials", "true");
        if (req.method === "OPTIONS") return res.sendStatus(204);
        next();
    });


    app.use(express.json());
    app.all("/proxy", async (req, res) => {
        let url = req.query.url;
        if (!url) return res.status(400).json({ error: "URL required" });
        
        try {
            url = decodeURIComponent(url);
        } catch (e) {
            console.error("Failed to decode URL:", e.message);
            return res.status(400).json({ error: "Invalid URL encoding" });
        }
        
        try {
            new URL(url);
        } catch (e) {
            console.error("Invalid URL format:", url);
            return res.status(400).json({ error: "Invalid URL format" });
        }
        
        const isAllowed = whitelist.some(allowed => url.includes(allowed));
        if (!isAllowed) {
            console.error("URL not in whitelist:", url);
            return res.status(400).json({ error: "Invalid URL" });
        }
        
        console.log("Proxying to:", url);

        try {
            const headers = {
                "User-Agent": req.userAgent || "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/237.84.2.178 Safari/537.36",
                "Accept": "*/*",
                "Accept-Encoding": "gzip, deflate, br",
                "Accept-Language": "en-US",
                "Sec-Fetch-Dest": "empty",
                "Sec-Fetch-Mode": "cors",
                "Sec-Fetch-Site": "cross-site",
                "X-Forwarded-For": req.headers["x-forwarded-for"],
                "Client-IP": req.headers["x-forwarded-for"]
            };
            
            if (req.headers["content-type"]) {
                headers["Content-Type"] = req.headers["content-type"];
            }
            if (req.headers.authorization) {
                headers["Authorization"] = req.headers.authorization;
            }
            
            const axiosConfig = {
                method: req.method.toLowerCase(),
                url: url,
                headers: headers,
                responseType: 'arraybuffer',
                validateStatus: function (status) {
                    return status >= 200 && status < 600;
                }
            };
            
            if (req.method !== "GET" && req.method !== "HEAD" && req.body) {
                axiosConfig.data = req.body;
            }
            
            const response = await axios(axiosConfig);
            
            res.status(response.status);
            
            Object.keys(response.headers).forEach(key => {
                const value = response.headers[key];
                if (value && !["content-encoding", "transfer-encoding"].includes(key.toLowerCase())) {
                    res.setHeader(key, value);
                }
            });

            const contentType = response.headers['content-type'] || "application/octet-stream";
            res.setHeader("Content-Type", contentType);
            
            res.send(Buffer.from(response.data));

        } catch (error) {
            console.error("Proxy error:", error.message);
            res.status(500).json({ error: error.message });
        }
    });
    
    const server = app.listen(port, () => {
        console.log(`Proxy running on http://127.0.0.1:${port}`);
    });
    
    server.on('error', (err) => {
        if (err.code === 'EADDRINUSE') {
            console.log(`Proxy port ${port} already in use (likely from another instance), reusing existing server`);
        } else {
            console.error(`Proxy server error on port ${port}:`, err.message);
        }
    });
}
[8088].forEach(createProxyServer);
// this makes 4 proxies and u can just cycle through em >:))



function listenWebsocket(port){
    const wss = new WebSocket.Server({ port });
    
    wss.on('listening', () => {
        console.log('server is running on ws://localhost:' + String(port));
    });
    
    wss.on('error', (err) => {
        if (err.code === 'EADDRINUSE') {
            console.log(`WebSocket port ${port} already in use (likely from another instance), reusing existing server`);
        } else {
            console.error(`WebSocket server error on port ${port}:`, err.message);
        }
    });
    
    if (wss._server) {
        wss._server.on('error', (err) => {
            if (err.code === 'EADDRINUSE') {
                console.log(`WebSocket port ${port} already in use (likely from another instance), reusing existing server`);
            } else {
                console.error(`WebSocket server error on port ${port}:`, err.message);
            }
        });
    }
    
    wss.on('connection', (ws) => {
        console.log('client connected');
        var socket = null
        var hasConnected = false
        function send(data) {
            if (hasConnected){
                socket.write(data);
            }
        }

        ws.on('message', (message) => {
            console.log(`Received: ${message}`);
            if (!hasConnected){
                try{
                    const parsedMessage = JSON.parse(message);
                    if (parsedMessage.type == "connection"){
                        var url = parsedMessage.tcpUrl;
                        var port = ""
                        if ((!url.startsWith("tlssocket://") && !url.startsWith("socket://")) && (url.split(":")[1])) {
                            port  = url.split(":")[1]
                            url = url.split(":")[0]
                        } else{
                            url = url.split("://")[1]
                            port = url.split(":")[1]
                            url = url.split(":")[0]
                        }
                        socket = tls.connect({
                            host: url,
                            port: port,
                            servername: url,
                            minVersion: 'TLSv1.2',
                            maxVersion: 'TLSv1.3',
                            rejectUnauthorized: false
                        }, () => {
                            ws.send('{"type":"connected"}');
                            socket.write("<policy-file-request/>\0");
                            hasConnected = true;
                        });
                        socket.on('error', (err) => {
                            console.log('TCP connection error:', err);
                            ws.send('{"type":"error","message":"1","error":' + JSON.stringify(err) + '}');
                        })
                        socket.on('data', (data) => {
                            ws.send(data);
                        })

                    }
                }catch(e){
                    console.log(e);
                }
            } else {
                send(message);
            }
        });

        ws.on('close', () => {
            console.log('Client disconnected');
            if (socket){
                socket.destroy();
            }
        });
    }); 
}

listenWebsocket(8089); // the big boy stuff