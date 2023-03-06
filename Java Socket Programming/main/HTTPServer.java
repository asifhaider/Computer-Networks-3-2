package main;

import threads.ServerThreads;

import java.io.*;
import java.net.ServerSocket;
public class HTTPServer {
    private static final int PORT = 5112;   // roll last 4 digit port no.
    private static final String ROOT_ABS_PATH = "E:\\BUET 3-2\\CSE 322\\Offline 1 Socket\\Offline 1";
    private static final String LOG_ABS_PATH = "E:\\BUET 3-2\\CSE 322\\Offline 1 Socket\\Offline 1\\logs";
    private static final String UPLOAD_ABS_PATH = "E:\\BUET 3-2\\CSE 322\\Offline 1 Socket\\Offline 1\\uploaded";

    public static void main(String[] args) throws IOException {

        // listening on a specified port
        ServerSocket serverConnect = new ServerSocket(PORT);

        // starts accepting HTTP requests
        while(true)
        {
            System.out.println("==================== Server started ====================\nListening for connections on port no.: " + PORT + " ...\n");
            new ServerThreads(serverConnect.accept(), ROOT_ABS_PATH, LOG_ABS_PATH, UPLOAD_ABS_PATH, PORT);
            System.out.println("Connection established!\n");
        }
    }
}