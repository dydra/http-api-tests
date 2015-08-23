#
# just enough of an http server to accept post content bodies,
# save them to the _relativized_ path from the http request and
# respond with a confirmation

import SimpleHTTPServer
import SocketServer
import logging
import cgi

PORT = 8000

class ServerHandler(SimpleHTTPServer.SimpleHTTPRequestHandler):


    def do_POST(self):
        length = int(self.headers['Content-Length'])
        filename = self.path[1:]
        data = self.rfile.read(size=length)
        open(filename, "wb").write(data)
        message = "received " + filename + " [as " + str(length) + " bytes]"
        self.respond(message + "\n")
        self.log_message(message)

    def do_GET(self):
        response = """
        <html><body>
        <form enctype="multipart/form-data" method="post">
        <p>File: <input type="file" name="file"></p>
        <p><input type="submit" value="Upload"></p>
        </form>
        </body></html>
        """        

        self.respond(response)

    def respond(self, response, status=200):
        self.send_response(status)
        self.send_header("Content-type", "text/html")
        self.send_header("Content-length", len(response))
        self.end_headers()
        self.wfile.write(response)  

Handler = ServerHandler

httpd = SocketServer.TCPServer(("", PORT), Handler)

print "serving at port", PORT
httpd.serve_forever()
