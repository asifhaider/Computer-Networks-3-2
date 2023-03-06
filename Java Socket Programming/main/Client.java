package main;

import threads.ClientThreads;

import java.util.Scanner;

public class Client {

    private static final int PORT = 5112;
    private static final String CLIENT_FILES_ABS_PATH = "E:\\BUET 3-2\\CSE 322\\Offline 1 Socket\\Offline 1\\client_files";
    public static void main(String[] args) {
        System.out.println("Enter a filename to connect with the server and start uploading!");
        Scanner scn = new Scanner(System.in);
        while(scn.hasNextLine()){
            new ClientThreads(scn.nextLine(), CLIENT_FILES_ABS_PATH, PORT);
        }
    }
}
